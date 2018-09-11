etcd put流程

client请求经过rpc通信之后调用Put()方法v3_server.go

```
//v3_server.go
func (s *EtcdServer) Put(ctx context.Context, r *pb.PutRequest) (*pb.PutResponse, error) {
	resp, err := s.raftRequest(ctx, pb.InternalRaftRequest{Put: r})
	if err != nil {
		return nil, err
	}
	return resp.(*pb.PutResponse), nil
}
//v3_server.go
func (s *EtcdServer) raftRequest(ctx context.Context, r pb.InternalRaftRequest) (proto.Message, error) {
	for {
		resp, err := s.raftRequestOnce(ctx, r)
		if err != auth.ErrAuthOldRevision {
			return resp, err
		}
	}
}
//v3_server.go
func (s *EtcdServer) raftRequestOnce(ctx context.Context, r pb.InternalRaftRequest) (proto.Message, error) {
	result, err := s.processInternalRaftRequestOnce(ctx, r)
	if err != nil {
		return nil, err
	}
	if result.err != nil {
		return nil, result.err
	}
	return result.resp, nil
}
//v3_server.go
func (s *EtcdServer) processInternalRaftRequestOnce(ctx context.Context, r pb.InternalRaftRequest) (*applyResult, error) {
	ai := s.getAppliedIndex()
	ci := s.getCommittedIndex()
	if ci > ai+maxGapBetweenApplyAndCommitIndex {
		return nil, ErrTooManyRequests
	}

	r.Header = &pb.RequestHeader{
		ID: s.reqIDGen.Next(),
	}

	authInfo, err := s.AuthInfoFromCtx(ctx)
	if err != nil {
		return nil, err
	}d
	if authInfo != nil {
		r.Header.Username = authInfo.Username
		r.Header.AuthRevision = authInfo.Revision
	}

	data, err := r.Marshal()
	if err != nil {
		return nil, err
	}

	if len(data) > int(s.Cfg.MaxRequestBytes) {
		return nil, ErrRequestTooLarge
	}

	id := r.ID
	if id == 0 {
		id = r.Header.ID
	}
	ch := s.w.Register(id)

	cctx, cancel := context.WithTimeout(ctx, s.Cfg.ReqTimeout())
	defer cancel()

	start := time.Now()
	err = s.r.Propose(cctx, data)
	if err != nil {
		proposalsFailed.Inc()
		s.w.Trigger(id, nil) // GC wait
		return nil, err
	}
	proposalsPending.Inc()
	defer proposalsPending.Dec()

	select {
	case x := <-ch:
		return x.(*applyResult), nil
	case <-cctx.Done():
		proposalsFailed.Inc()
		s.w.Trigger(id, nil) // GC wait
		return nil, s.parseProposeCtxErr(cctx.Err(), start)
	case <-s.done:
		return nil, ErrStopped
	}
}
```
这段主要看err = s.r.Propose(cctx, data)

```
//raft/node.go
func (n *node) Propose(ctx context.Context, data []byte) error {
	return n.stepWait(ctx, pb.Message{Type: pb.MsgProp, Entries: []pb.Entry{{Data: data}}})
}
//raft/node.go
func (n *node) stepWait(ctx context.Context, m pb.Message) error {
	return n.stepWithWaitOption(ctx, m, true)
}
//raft/node.go
func (n *node) stepWithWaitOption(ctx context.Context, m pb.Message, wait bool) error {
	if m.Type != pb.MsgProp {
		select {
		case n.recvc <- m:
			return nil
		case <-ctx.Done():
			return ctx.Err()
		case <-n.done:
			return ErrStopped
		}
	}
	ch := n.propc
	pm := msgWithResult{m: m}
	if wait {
		pm.result = make(chan error, 1)
	}
	select {
	case ch <- pm:
		if !wait {
			return nil
		}
	case <-ctx.Done():
		return ctx.Err()
	case <-n.done:
		return ErrStopped
	}
	select {
	case rsp := <-pm.result:
		if rsp != nil {
			return rsp
		}
	case <-ctx.Done():
		return ctx.Err()
	case <-n.done:
		return ErrStopped
	}
	return nil
}
```

这里将request传到channel n.propc中，
```
ch := n.propc
pm := msgWithResult{m: m}
if wait {
  pm.result = make(chan error, 1)

}
select {
case ch <- pm:
  if !wait {
    return nil
  }
```

找到对应的propc就好了，这个在node(raft/node.go)的主循环run()中

```
//raft/node.go->run()
select {
// TODO: maybe buffer the config propose if there exists one (the way
// described in raft dissertation)
// Currently it is dropped in Step silently.
case pm := <-propc:
	m := pm.m
	m.From = r.id
	err := r.Step(m)
	if pm.result != nil {
		pm.result <- err
		close(pm.result)
	}
```
raft/raft.go

```
//func (r *raft) Step(m pb.Message) error {}<-->raft/raft.go
default:
	err := r.step(r, m)
	if err != nil {
		return err
	}
}
```
这个step依据不同的角色是不同的，分别对应stepCandidate，stepFollower，stepLeader，都是在bexx中赋值的

```
func (r *raft) becomeCandidate() {
	// TODO(xiangli) remove the panic when the raft implementation is stable
	if r.state == StateLeader {
		panic("invalid transition [leader -> candidate]")
	}
	r.step = stepCandidate
	r.reset(r.Term + 1)
	r.tick = r.tickElection
	r.Vote = r.id
	r.state = StateCandidate
	r.logger.Infof("%x became candidate at term %d", r.id, r.Term)
}
func (r *raft) becomeFollower(term uint64, lead uint64) {
	r.step = stepFollower
	r.reset(term)
	r.tick = r.tickElection
	r.lead = lead
	r.state = StateFollower
	r.logger.Infof("%x became follower at term %d", r.id, r.Term)
}
func (r *raft) becomeLeader() {
	// TODO(xiangli) remove the panic when the raft implementation is stable
	if r.state == StateFollower {
		panic("invalid transition [follower -> leader]")
	}
	r.step = stepLeader
	r.reset(r.Term)
	r.tick = r.tickHeartbeat
	r.lead = r.id
	r.state = StateLeader

	// Conservatively set the pendingConfIndex to the last index in the
	// log. There may or may not be a pending config change, but it's
	// safe to delay any future proposals until we commit all our
	// pending log entries, and scanning the entire tail of the log
	// could be expensive.
	r.pendingConfIndex = r.raftLog.lastIndex()

	r.appendEntry(pb.Entry{Data: nil})
	r.logger.Infof("%x became leader at term %d", r.id, r.Term)
}
func (r *raft) becomePreCandidate() {
	// TODO(xiangli) remove the panic when the raft implementation is stable
	if r.state == StateLeader {
		panic("invalid transition [leader -> pre-candidate]")
	}
	// Becoming a pre-candidate changes our step functions and state,
	// but doesn't change anything else. In particular it does not increase
	// r.Term or change r.Vote.
	r.step = stepCandidate
	r.votes = make(map[uint64]bool)
	r.tick = r.tickElection
	r.state = StatePreCandidate
	r.logger.Infof("%x became pre-candidate at term %d", r.id, r.Term)
}
```

处理方式各不相同，对于leader而言

```
case pb.MsgProp:
	if len(m.Entries) == 0 {
		r.logger.Panicf("%x stepped empty MsgProp", r.id)
	}
	if _, ok := r.prs[r.id]; !ok {
		// If we are not currently a member of the range (i.e. this node
		// was removed from the configuration while serving as leader),
		// drop any new proposals.
		return ErrProposalDropped
	}
	if r.leadTransferee != None {
		r.logger.Debugf("%x [term %d] transfer leadership to %x is in progress; dropping proposal", r.id, r.Term, r.leadTransferee)
		return ErrProposalDropped
	}

	for i, e := range m.Entries {
		if e.Type == pb.EntryConfChange {
			if r.pendingConfIndex > r.raftLog.applied {
				r.logger.Infof("propose conf %s ignored since pending unapplied configuration [index %d, applied %d]",
					e.String(), r.pendingConfIndex, r.raftLog.applied)
				m.Entries[i] = pb.Entry{Type: pb.EntryNormal}
			} else {
				r.pendingConfIndex = r.raftLog.lastIndex() + uint64(i) + 1
			}
		}
	}
	r.appendEntry(m.Entries...)
	r.bcastAppend()
	return nil
```
主要是两步
1，将enrty添加到本地unstable
2，发送entry broadcast到其他的peers,完成log复制
```
//raft/raft.go
func (r *raft) appendEntry(es ...pb.Entry) {
	li := r.raftLog.lastIndex()
	for i := range es {
		es[i].Term = r.Term
		es[i].Index = li + 1 + uint64(i)
	}
	// use latest "last" index after truncate/append
	li = r.raftLog.append(es...)
	r.getProgress(r.id).maybeUpdate(li)
	// Regardless of maybeCommit's return, our caller will call bcastAppend.
	r.maybeCommit()
}
//raft/log.go
func (l *raftLog) append(ents ...pb.Entry) uint64 {
	if len(ents) == 0 {
		return l.lastIndex()
	}
	if after := ents[0].Index - 1; after < l.committed {
		l.logger.Panicf("after(%d) is out of range [committed(%d)]", after, l.committed)
	}
	l.unstable.truncateAndAppend(ents)
	return l.lastIndex()
}
//raft/log_unstable.go
func (u *unstable) truncateAndAppend(ents []pb.Entry) {
	after := ents[0].Index
	switch {
	case after == u.offset+uint64(len(u.entries)):
		// after is the next index in the u.entries
		// directly append
		u.entries = append(u.entries, ents...)
	case after <= u.offset:
		u.logger.Infof("replace the unstable entries from index %d", after)
		// The log is being truncated to before our current offset
		// portion, so set the offset and replace the entries
		u.offset = after
		u.entries = ents
	default:
		// truncate to after and copy to u.entries
		// then append
		u.logger.Infof("truncate the unstable entries before index %d", after)
		u.entries = append([]pb.Entry{}, u.slice(u.offset, after)...)
		u.entries = append(u.entries, ents...)
	}
}
```
broadcast entry到其他peers
```
//raft/raft.go
func (r *raft) bcastAppend() {
	r.forEachProgress(func(id uint64, _ *Progress) {
		if id == r.id {
			return
		}

		r.sendAppend(id)
	})
}
//raft/raft.go
func (r *raft) sendAppend(to uint64) {
	r.maybeSendAppend(to, true)
}
func (r *raft) maybeSendAppend(to uint64, sendIfEmpty bool) bool {
	pr := r.getProgress(to)
	if pr.IsPaused() {
		return false
	}
	m := pb.Message{}
	m.To = to

	term, errt := r.raftLog.term(pr.Next - 1)
	ents, erre := r.raftLog.entries(pr.Next, r.maxMsgSize)
	if len(ents) == 0 && !sendIfEmpty {
		return false
	}

	if errt != nil || erre != nil { // send snapshot if we failed to get term or entries
		if !pr.RecentActive {
			r.logger.Debugf("ignore sending snapshot to %x since it is not recently active", to)
			return false
		}

		m.Type = pb.MsgSnap
		snapshot, err := r.raftLog.snapshot()
		if err != nil {
			if err == ErrSnapshotTemporarilyUnavailable {
				r.logger.Debugf("%x failed to send snapshot to %x because snapshot is temporarily unavailable", r.id, to)
				return false
			}
			panic(err) // TODO(bdarnell)
		}
		if IsEmptySnap(snapshot) {
			panic("need non-empty snapshot")
		}
		m.Snapshot = snapshot
		sindex, sterm := snapshot.Metadata.Index, snapshot.Metadata.Term
		r.logger.Debugf("%x [firstindex: %d, commit: %d] sent snapshot[index: %d, term: %d] to %x [%s]",
			r.id, r.raftLog.firstIndex(), r.raftLog.committed, sindex, sterm, to, pr)
		pr.becomeSnapshot(sindex)
		r.logger.Debugf("%x paused sending replication messages to %x [%s]", r.id, to, pr)
	} else {
		m.Type = pb.MsgApp
		m.Index = pr.Next - 1
		m.LogTerm = term
		m.Entries = ents
		m.Commit = r.raftLog.committed
		if n := len(m.Entries); n != 0 {
			switch pr.State {
			// optimistically increase the next when in ProgressStateReplicate
			case ProgressStateReplicate:
				last := m.Entries[n-1].Index
				pr.optimisticUpdate(last)
				pr.ins.add(last)
			case ProgressStateProbe:
				pr.pause()
			default:
				r.logger.Panicf("%x is sending append in unhandled state %s", r.id, pr.State)
			}
		}
	}
	r.send(m)
}
//raft/raft.go
// send persists state to stable storage and then sends to its mailbox.
func (r *raft) send(m pb.Message) {
	m.From = r.id
	if m.Type == pb.MsgVote || m.Type == pb.MsgVoteResp || m.Type == pb.MsgPreVote || m.Type == pb.MsgPreVoteResp {
		if m.Term == 0 {
			// All {pre-,}campaign messages need to have the term set when
			// sending.
			// - MsgVote: m.Term is the term the node is campaigning for,
			//   non-zero as we increment the term when campaigning.
			// - MsgVoteResp: m.Term is the new r.Term if the MsgVote was
			//   granted, non-zero for the same reason MsgVote is
			// - MsgPreVote: m.Term is the term the node will campaign,
			//   non-zero as we use m.Term to indicate the next term we'll be
			//   campaigning for
			// - MsgPreVoteResp: m.Term is the term received in the original
			//   MsgPreVote if the pre-vote was granted, non-zero for the
			//   same reasons MsgPreVote is
			panic(fmt.Sprintf("term should be set when sending %s", m.Type))
		}
	} else {
		if m.Term != 0 {
			panic(fmt.Sprintf("term should not be set when sending %s (was %d)", m.Type, m.Term))
		}
		// do not attach term to MsgProp, MsgReadIndex
		// proposals are a way to forward to the leader and
		// should be treated as local message.
		// MsgReadIndex is also forwarded to leader.
		if m.Type != pb.MsgProp && m.Type != pb.MsgReadIndex {
			m.Term = r.Term
		}
	}
	r.msgs = append(r.msgs, m)
}

```
这里没有直接将enrty发送peers,只是放到msgs里边，找到它的消费处

```
func newReady(r *raft, prevSoftSt *SoftState, prevHardSt pb.HardState) Ready {
	rd := Ready{
		Entries:          r.raftLog.unstableEntries(),
		CommittedEntries: r.raftLog.nextEnts(),
		Messages:         r.msgs,
	}
	if softSt := r.softState(); !softSt.equal(prevSoftSt) {
		rd.SoftState = softSt
	}
	if hardSt := r.hardState(); !isHardStateEqual(hardSt, prevHardSt) {
		rd.HardState = hardSt
		// If we hit a size limit when loadaing CommittedEntries, clamp
		// our HardState.Commit to what we're actually returning. This is
		// also used as our cursor to resume for the next Ready batch.
		if len(rd.CommittedEntries) > 0 {
			lastCommit := rd.CommittedEntries[len(rd.CommittedEntries)-1]
			if rd.HardState.Commit > lastCommit.Index {
				rd.HardState.Commit = lastCommit.Index
			}
		}
	}
	if r.raftLog.unstable.snapshot != nil {
		rd.Snapshot = *r.raftLog.unstable.snapshot
	}
	if len(r.readStates) != 0 {
		rd.ReadStates = r.readStates
	}
	rd.MustSync = MustSync(rd.HardState, prevHardSt, len(rd.Entries))
	return rd
}
```
这个newReady是在raft.run()的主循环被调用的

```
if advancec != nil {
	readyc = nil
} else {
	rd = newReady(r, prevSoftSt, prevHardSt)
	if rd.containsUpdates() {
		readyc = n.readyc
	} else {
		readyc = nil
	}
}

case readyc <- rd:
	if rd.SoftState != nil {
		prevSoftSt = rd.SoftState
	}
	if len(rd.Entries) > 0 {
		prevLastUnstablei = rd.Entries[len(rd.Entries)-1].Index
		prevLastUnstablet = rd.Entries[len(rd.Entries)-1].Term
		havePrevLastUnstablei = true
	}
	if !IsEmptyHardState(rd.HardState) {
		prevHardSt = rd.HardState
	}
	if !IsEmptySnap(rd.Snapshot) {
		prevSnapi = rd.Snapshot.Metadata.Index
	}

	r.msgs = nil
	r.readStates = nil
	advancec = n.advancec
```
又被写入readyc了，找readyc的影子去。。。
```
//readyc的定义
var readyc chan Ready
func (n *node) Ready() <-chan Ready { return n.readyc }
```
Ready()在etcdserver/raft.go中被调用

```
case rd := <-r.Ready():
ap := apply{
	entries:  rd.CommittedEntries,
	snapshot: rd.Snapshot,
	notifyc:  notifyc,
}

updateCommittedIndex(&ap, rh)

select {
case r.applyc <- ap:
```
又被写入applyc了？且看applyc定义

```
applyc chan apply
func (r *raftNode) apply() chan apply {
	return r.applyc
}
```
最后是在中被调用的

```
case ap := <-s.r.apply():
	f := func(context.Context) { s.applyAll(&ep, &ap) }
	sched.Schedule(f)
```

applyAll()-->s.apply-->s.applyEntryNormal(&e)-->s.applyV3.Apply()/s.w.Trigger(req.ID, s.applyV2Request(req))

s.applyV3.Apply()-->
s.applyV2Request(req)-->


