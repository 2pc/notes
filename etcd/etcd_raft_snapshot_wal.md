
需要区分raft library的存储与etcd的存储

etcd server通过WAL和snapshot实现持久化存储.


etcd server实现

```
type Storage interface {
	// Save function saves ents and state to the underlying stable storage.
	// Save MUST block until st and ents are on stable storage.
	Save(st raftpb.HardState, ents []raftpb.Entry) error
	// SaveSnap function saves snapshot to the underlying stable storage.
	SaveSnap(snap raftpb.Snapshot) error
	// Close closes the Storage and performs finalization.
	Close() error
}

type storage struct {
	*wal.WAL
	*snap.Snapshotter
}

func NewStorage(w *wal.WAL, s *snap.Snapshotter) Storage {
	return &storage{w, s}
}
// SaveSnap saves the snapshot to disk and release the locked
// wal files since they will not be used.
func (st *storage) SaveSnap(snap raftpb.Snapshot) error {
	walsnap := walpb.Snapshot{
		Index: snap.Metadata.Index,
		Term:  snap.Metadata.Term,
	}
	err := st.WAL.SaveSnapshot(walsnap)
	if err != nil {
		return err
	}
	err = st.Snapshotter.SaveSnap(snap)
	if err != nil {
		return err
	}
	return st.WAL.ReleaseLockTo(snap.Metadata.Index)
}

```

需要注意下storage这个struct,两个变量Wal,Snapshotter没有变量名，因此可以storage.Save()与storage.WAL.Save()一样
```
type storage struct {
	*wal.WAL
	*snap.Snapshotter
}
```
这是一个内嵌组合结构体？ WAL实现了Save() Close()方法，Snapshotter重载了SaveSnap()

```
func (w *WAL) Save(st raftpb.HardState, ents []raftpb.Entry) error {}
func (w *WAL) Close() error {}
//Snapshotter重载
func (s *Snapshotter) SaveSnap(snapshot raftpb.Snapshot) error {}
```

etcd server中wal,snapshot的创建与load

```
fun NewServer(){
  ss := snap.New(cfg.Logger, cfg.SnapDir())
  case !haveWAL && !cfg.NewCluster:
        		remotes = existingCluster.Members()
            cl.SetID(types.ID(0), existingCluster.ID())
            cl.SetStore(st)
            cl.SetBackend(be)
            id, n, s, w = startNode(cfg, cl, nil)
            cl.SetID(id, existingCluster.ID())
 case !haveWAL && cfg.NewCluster:
            cl.SetStore(st)
            cl.SetBackend(be)
            id, n, s, w = startNode(cfg, cl, cl.MemberIDs())
            cl.SetID(id, cl.ID())
 case haveWAL:
            snapshot, err = ss.Load()
            if !cfg.ForceNewCluster {
              id, cl, n, s, w = restartNode(cfg, snapshot)
            } else {
              id, cl, n, s, w = restartAsStandaloneNode(cfg, snapshot)
            }

            cl.SetStore(st)
            cl.SetBackend(be)
            cl.Recover(api.UpdateCapability)
 srv = &EtcdServer{
		readych:     make(chan struct{}),
		Cfg:         cfg,
		lgMu:        new(sync.RWMutex),
		lg:          cfg.Logger,
		errorc:      make(chan error, 1),
		v2store:     st,
		snapshotter: ss,
		r: *newRaftNode(
			raftNodeConfig{
				lg:          cfg.Logger,
				isIDRemoved: func(id uint64) bool { return cl.IsIDRemoved(types.ID(id)) },
				Node:        n,
				heartbeat:   heartbeat,
				raftStorage: s,
				storage:     NewStorage(w, ss),
			},
		),
		id:               id,
		attributes:       membership.Attributes{Name: cfg.Name, ClientURLs: cfg.ClientURLs.StringSlice()},
		cluster:          cl,
		stats:            sstats,
		lstats:           lstats,
		SyncTicker:       time.NewTicker(500 * time.Millisecond),
		peerRt:           prt,
		reqIDGen:         idutil.NewGenerator(uint16(id), time.Now()),
		forceVersionC:    make(chan struct{}),
		AccessController: &AccessController{CORS: cfg.CORS, HostWhitelist: cfg.HostWhitelist},
	}
	serverID.With(prometheus.Labels{"server_id": id.String()}).Set(1)

	srv.applyV2 = &applierV2store{store: srv.v2store, cluster: srv.cluster}

	srv.be = be
}
```
省略了部分代码，这里需要注意的raftNodeConfig的构造函数里边有两个store,其中raftStorage是给raft库使用的是一个内存行的
storage才是给etcd持久化存储的

先看下startnode()与restartNode（）
startnode()
```
//etcdserver/raft.go
func startNode(){
  if w, err = wal.Create(cfg.Logger, cfg.WALDir(), metadata); err != nil //创建wal
  s = raft.NewMemoryStorage()// 构造MemoryStorage，这个是内存store 供给raft库使用的
	c := &raft.Config{
		ID:              uint64(id),
		ElectionTick:    cfg.ElectionTicks,
		HeartbeatTick:   1,
		Storage:         s,
		MaxSizePerMsg:   maxSizePerMsg,
		MaxInflightMsgs: maxInflightMsgs,
		CheckQuorum:     true,
		PreVote:         cfg.PreVote,
	}
  n = raft.StartNode(c, peers)//构造raft,通过MemoryStorage转化为raftlog
	raftStatusMu.Lock()
	raftStatus = n.Status
	raftStatusMu.Unlock()
	return id, n, s, w
}
```
看下MemoryStorage到raftlog的过程
```
//raft/node.go
func StartNode(c *Config, peers []Peer) Node {
	r := newRaft(c)
}
//raft/raft.go
func newRaft(c *Config) *raft {
  raftlog := newLogWithSize(c.Storage, c.Logger, c.MaxSizePerMsg)
  	r := &raft{
		id:                        c.ID,
		lead:                      None,
		isLearner:                 false,
		raftLog:                   raftlog,
		maxMsgSize:                c.MaxSizePerMsg,
		maxInflight:               c.MaxInflightMsgs,
		prs:                       make(map[uint64]*Progress),
		learnerPrs:                make(map[uint64]*Progress),
		electionTimeout:           c.ElectionTick,
		heartbeatTimeout:          c.HeartbeatTick,
		logger:                    c.Logger,
		checkQuorum:               c.CheckQuorum,
		preVote:                   c.PreVote,
		readOnly:                  newReadOnly(c.ReadOnlyOption),
		disableProposalForwarding: c.DisableProposalForwarding,
	}
  //raft/log.go
  func newLogWithSize(storage Storage, logger Logger, maxMsgSize uint64) *raftLog {
	if storage == nil {
		log.Panic("storage must not be nil")
	}
	log := &raftLog{
		storage:    storage,
		logger:     logger,
		maxMsgSize: maxMsgSize,
	}
	firstIndex, err := storage.FirstIndex()
	if err != nil {
		panic(err) // TODO(bdarnell)
	}
	lastIndex, err := storage.LastIndex()
	if err != nil {
		panic(err) // TODO(bdarnell)
	}
	log.unstable.offset = lastIndex + 1
	log.unstable.logger = logger
	// Initialize our committed and applied pointers to the time of the last compaction.
	log.committed = firstIndex - 1
	log.applied = firstIndex - 1

	return log
}
//raft/log.go
type raftLog struct {
	// storage contains all stable entries since the last snapshot.
	storage Storage

	// unstable contains all unstable entries and snapshot.
	// they will be saved into storage.
	unstable unstable

	// committed is the highest log position that is known to be in
	// stable storage on a quorum of nodes.
	committed uint64
	// applied is the highest log position that the application has
	// been instructed to apply to its state machine.
	// Invariant: applied <= committed
	applied uint64

	logger Logger

	maxMsgSize uint64
}
}

```
 再看下restartnode()，看下raftstore与etcd store是如何联系起来的
 ```
 etcdserver/raft.go
 func restartNode(c){
 
	if snapshot != nil {
		walsnap.Index, walsnap.Term = snapshot.Metadata.Index, snapshot.Metadata.Term
	}
	w, id, cid, st, ents := readWAL(cfg.Logger, cfg.WALDir(), walsnap)
	s := raft.NewMemoryStorage()
	if snapshot != nil {
		s.ApplySnapshot(*snapshot)
	}
	s.SetHardState(st)
	s.Append(ents)//将wal中的all entry append到memorystory
	c := &raft.Config{
		ID:              uint64(id),
		ElectionTick:    cfg.ElectionTicks,
		HeartbeatTick:   1,
		Storage:         s,//这个是raft库使用的memorystore
		MaxSizePerMsg:   maxSizePerMsg,
		MaxInflightMsgs: maxInflightMsgs,
		CheckQuorum:     true,
		PreVote:         cfg.PreVote,
	}
 }
 ```
 可以看出memorystore也是从wal中append了所有entry,在重启的时候保证wal与raftlog(memorystore)数据是一致的
 
 startnode()与restartnode()返回值s,w分别是memerystore,与wal，他们与ss一起构成供raft库使用的raftstore，以及etcd持久化的storage
```
snapshotter: ss,
r: *newRaftNode(
	raftNodeConfig{
		lg:          cfg.Logger,
		isIDRemoved: func(id uint64) bool { return cl.IsIDRemoved(types.ID(id)) },
		Node:        n,
		heartbeat:   heartbeat,
		raftStorage: s,
		storage:     NewStorage(w, ss),
	},
),
```
再看下ss
```
//ss := snap.New(cfg.Logger, cfg.SnapDir())
func New(lg *zap.Logger, dir string) *Snapshotter {
	return &Snapshotter{
		lg:  lg,
		dir: dir,
	}
}
```
load snapshot

```
snapshot, err = ss.Load()
//etcdserver/api/snap/snapshotter.go
func (s *Snapshotter) Load() (*raftpb.Snapshot, error) {
	names, err := s.snapNames()
	if err != nil {
		return nil, err
	}
	var snap *raftpb.Snapshot
	for _, name := range names {
		if snap, err = loadSnap(s.lg, s.dir, name); err == nil {
			break
		}
	}
	if err != nil {
		return nil, ErrNoSnapshot
	}
	return snap, nil
}
//etcdserver/api/snap/snapshotter.go
// snapNames returns the filename of the snapshots in logical time order (from newest to oldest).
// If there is no available snapshots, an ErrNoSnapshot will be returned.
func (s *Snapshotter) snapNames() ([]string, error) {
	dir, err := os.Open(s.dir)
	if err != nil {
		return nil, err
	}
	defer dir.Close()
	names, err := dir.Readdirnames(-1)
	if err != nil {
		return nil, err
	}
	snaps := checkSuffix(s.lg, names)
	if len(snaps) == 0 {
		return nil, ErrNoSnapshot
	}
	sort.Sort(sort.Reverse(sort.StringSlice(snaps)))
	return snaps, nil
}
```
etcdserver/raft.go
```
if islead {
	// gofail: var raftBeforeLeaderSend struct{}
	r.transport.Send(r.processMessages(rd.Messages))
}

// gofail: var raftBeforeSave struct{}
if err := r.storage.Save(rd.HardState, rd.Entries); err != nil {//storege.WAL.Save?
	if r.lg != nil {
		r.lg.Fatal("failed to save Raft hard state and entries", zap.Error(err))
	} else {
		plog.Fatalf("raft save state and entries error: %v", err)
	}
}
if !raft.IsEmptyHardState(rd.HardState) {
	proposalsCommitted.Set(float64(rd.HardState.Commit))
}
// gofail: var raftAfterSave struct{}

if !raft.IsEmptySnap(rd.Snapshot) {
	// gofail: var raftBeforeSaveSnap struct{}
	if err := r.storage.SaveSnap(rd.Snapshot); err != nil {//storege.SaveSnap()?
		if r.lg != nil {
			r.lg.Fatal("failed to save Raft snapshot", zap.Error(err))
		} else {
			plog.Fatalf("raft save snapshot error: %v", err)
		}
	}
	// etcdserver now claim the snapshot has been persisted onto the disk
	notifyc <- struct{}{}

	// gofail: var raftAfterSaveSnap struct{}
	r.raftStorage.ApplySnapshot(rd.Snapshot)
	if r.lg != nil {
		r.lg.Info("applied incoming Raft snapshot", zap.Uint64("snapshot-index", rd.Snapshot.Metadata.Index))
	} else {
		plog.Infof("raft applied incoming snapshot at index %d", rd.Snapshot.Metadata.Index)
	}
	// gofail: var raftAfterApplySnap struct{}
}

r.raftStorage.Append(rd.Entries)
```


