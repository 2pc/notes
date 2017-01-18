#### ConsumerCoordinator

#### GroupCoordinator

添加member到group 

代码调用流程

```
KafkaApis.handle(case RequestKeys.JoinGroupKey => handleJoinGroupRequest(request))-->KafkaApis.handleJoinGroupRequest--> GroupCoordinator.handleJoinGroup()-->GroupCoordinator.doJoinGroup()-->GroupCoordinator.addMemberAndRebalance()
```

生成MemberMetaData(member)，并添加到GroupMetaData(group)

```
private def addMemberAndRebalance(sessionTimeoutMs: Int,
                                  clientId: String,
                                  clientHost: String,
                                  protocols: List[(String, Array[Byte])],
                                  group: GroupMetadata,
                                  callback: JoinCallback) = {
  // use the client-id with a random id suffix as the member-id
  val memberId = clientId + "-" + group.generateMemberIdSuffix
  val member = new MemberMetadata(memberId, group.groupId, clientId, clientHost, sessionTimeoutMs, protocols)
  member.awaitingJoinCallback = callback
  group.add(member.memberId, member)//add MemberMetadata to GroupMetadata
  maybePrepareRebalance(group)
  member
}
```

其中memberId为clientId+uuid

```
def generateMemberIdSuffix = UUID.randomUUID().toString
```

将member添加到group的时候会判断,当前group有没有leaderId,如果没有，则将当前memberId作为leaderId
```
def add(memberId: String, member: MemberMetadata) {
    assert(supportsProtocols(member.protocols))

    if (leaderId == null)
      leaderId = memberId
    members.put(memberId, member)
  }
```


[Kafka Client-side Assignment Proposal](https://cwiki.apache.org/confluence/display/KAFKA/Consumer+Client+Re-Design)   
[Consumer Client Re-Design](https://cwiki.apache.org/confluence/display/KAFKA/Consumer+Client+Re-Design)   
[Kafka 0.9 Consumer Rewrite Design](https://cwiki.apache.org/confluence/display/KAFKA/Kafka+0.9+Consumer+Rewrite+Design)
