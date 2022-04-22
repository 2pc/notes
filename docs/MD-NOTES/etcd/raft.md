

1.如果当候选人candidate的所拥有最新日志index和最新日志的term要小于follower的最新日志index和最新日志的term，则投反对票   
2.使用随机选举超时时间的方法来确保很少会发生选票瓜分的情况   
3.发生网络分区后，通过心跳和term等机制判断更新老leader为follower，未持久化的数据将丢失。新leader将自己已存储但follower没有的数据再次发送一遍，保证从节点与主节点的数据一致性

```
StartEtcd()-->etcdserver.NewServer(etcdserver/server.go)-->startNode(cfg, cl, cl.MemberIDs())(etcdserver/server.go)-->raft.StartNode(c, peers)(etcdserver/raft.go)
-->node.StartNode(raft/node.go--r.becomeFollower(1, None))-->
```
定时处理函数tickElection,tickHeartbeat(raft/raft.go)

```
// tickElection is run by followers and candidates after r.electionTimeout.
func (r *raft) tickElection() {
	r.electionElapsed++

	if r.promotable() && r.pastElectionTimeout() {
		r.electionElapsed = 0
		r.Step(pb.Message{From: r.id, Type: pb.MsgHup})
	}
}

// tickHeartbeat is run by leaders to send a MsgBeat after r.heartbeatTimeout.
func (r *raft) tickHeartbeat() {
	r.heartbeatElapsed++
	r.electionElapsed++

	if r.electionElapsed >= r.electionTimeout {
		r.electionElapsed = 0
		if r.checkQuorum {
			r.Step(pb.Message{From: r.id, Type: pb.MsgCheckQuorum})
		}
		// If current leader cannot transfer leadership in electionTimeout, it becomes leader again.
		if r.state == StateLeader && r.leadTransferee != None {
			r.abortLeaderTransfer()
		}
	}

	if r.state != StateLeader {
		return
	}

	if r.heartbeatElapsed >= r.heartbeatTimeout {
		r.heartbeatElapsed = 0
		r.Step(pb.Message{From: r.id, Type: pb.MsgBeat})
	}
}
```
