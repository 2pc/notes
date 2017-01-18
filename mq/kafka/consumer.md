#### ConsumerCoordinator

#### GroupCoordinator

添加member到group 

代码调用流程

```
KafkaApis.handle(case RequestKeys.JoinGroupKey => handleJoinGroupRequest(request))-->KafkaApis.handleJoinGroupRequest--> GroupCoordinator.handleJoinGroup()-->GroupCoordinator.doJoinGroup()-->GroupCoordinator.addMemberAndRebalance()
```
handleJoinGroup中会首先从groupManager(GroupMetadataManager)中获取group,如果没有，则创建GroupMetaData(group),并添加到groupManager

```
var group = groupManager.getGroup(groupId)
if (group == null) {
  if (memberId != JoinGroupRequest.UNKNOWN_MEMBER_ID) {
    responseCallback(joinError(memberId, Errors.UNKNOWN_MEMBER_ID.code))
  } else {
    group = groupManager.addGroup(new GroupMetadata(groupId, protocolType))
    doJoinGroup(group, memberId, clientId, clientHost, sessionTimeoutMs, protocolType, protocols, responseCallback)
  }
} else {
  doJoinGroup(group, memberId, clientId, clientHost, sessionTimeoutMs, protocolType, protocols, responseCallback)
}

def addGroup(group: GroupMetadata): GroupMetadata = {
  val currentGroup = groupsCache.putIfNotExists(group.groupId, group)
  if (currentGroup != null) {
    currentGroup
  } else {
    group
  }
}
```

addMemberAndRebalance中生成MemberMetaData(member)，并添加到GroupMetaData(group)

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

group的GroupState默认为Stable

```
private var state: GroupState = Stable
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
另外在中，如果是已经存在的member,则应该对相应的group更新操作

```
updateMemberAndRebalance
```
但是不论是新的member添加到group还是更新，都是走的maybePrepareRebalance

```
private def maybePrepareRebalance(group: GroupMetadata) {
  group synchronized {
    if (group.canRebalance)
      prepareRebalance(group)
  }
}

private def prepareRebalance(group: GroupMetadata) {
  // if any members are awaiting sync, cancel their request and have them rejoin
  if (group.is(AwaitingSync))
    resetAndPropagateAssignmentError(group, Errors.REBALANCE_IN_PROGRESS.code)

  group.transitionTo(PreparingRebalance)
  info("Preparing to restabilize group %s with old generation %s".format(group.groupId, group.generationId))

  val rebalanceTimeout = group.rebalanceTimeout
  val delayedRebalance = new DelayedJoin(this, group, rebalanceTimeout)
  val groupKey = GroupKey(group.groupId)
  joinPurgatory.tryCompleteElseWatch(delayedRebalance, Seq(groupKey))
}
```
[Kafka Client-side Assignment Proposal](https://cwiki.apache.org/confluence/display/KAFKA/Consumer+Client+Re-Design)   
[Consumer Client Re-Design](https://cwiki.apache.org/confluence/display/KAFKA/Consumer+Client+Re-Design)   
[Kafka 0.9 Consumer Rewrite Design](https://cwiki.apache.org/confluence/display/KAFKA/Kafka+0.9+Consumer+Rewrite+Design)
