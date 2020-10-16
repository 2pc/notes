Kafka的选主要可以分为三类

1. Controller选举   
2. Partition Leader选举   
3. 消费者相关的选举,比如GroupCoordinator,ConsumerCoordinator

### Kafka Controller选举 

类似抢占式，节点成功注册就算

### Kafka 分区Partition Leader选举
ISR机制

### Kafka Consumer Coordinator
第一个？

```
def add(member: MemberMetadata, callback: JoinCallback = null): Unit = {
  if (members.isEmpty)
    this.protocolType = Some(member.protocolType)

  assert(groupId == member.groupId)
  assert(this.protocolType.orNull == member.protocolType)
  assert(supportsProtocols(member.protocolType, MemberMetadata.plainProtocolSet(member.supportedProtocols)))
//没有直接认为是leaderId
  if (leaderId.isEmpty)
    leaderId = Some(member.memberId)
  members.put(member.memberId, member)
  member.supportedProtocols.foreach{ case (protocol, _) => supportedProtocols(protocol) += 1 }
  member.awaitingJoinCallback = callback
  if (member.isAwaitingJoin)
    numMembersAwaitingJoin += 1
}
//移除memberId之后，也是取head
def remove(memberId: String): Unit = {
  members.remove(memberId).foreach { member =>
    member.supportedProtocols.foreach{ case (protocol, _) => supportedProtocols(protocol) -= 1 }
    if (member.isAwaitingJoin)
      numMembersAwaitingJoin -= 1
  }

  if (isLeader(memberId))
    leaderId = members.keys.headOption
}
```
