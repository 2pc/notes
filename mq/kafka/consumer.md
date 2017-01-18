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

这个将在ConsumerCoordinator端用来判断当前自己是不是ConsumerCoordinator的leader判断,coordinator(AbstractCoordinator).performGroupJoin-->JoinGroupResponseHandler.handle()

```
if (joinResponse.isLeader()) {
    onJoinLeader(joinResponse).chain(future);
} else {
    onJoinFollower().chain(future);
}
public boolean isLeader() {
    return memberId.equals(leaderId); //当前memberId与leaderId一致则为ConsumerCoordinator的leader
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
首先这里的是joinPurgatory是DelayedOperationPurgatory[DelayedJoin]的，也就是关联了DelayedJoin
其中tryCompleteElseWatch设计的不有点奇异哈，调用了两次

```
var isCompletedByMe = operation synchronized operation.tryComplete()
```

这个operation当然就是DelayedJoin,DelayedJoin也只是包装了下coordinator

```
private[coordinator] class DelayedJoin(coordinator: GroupCoordinator,
                                            group: GroupMetadata,
                                            sessionTimeout: Long)
  extends DelayedOperation(sessionTimeout) {

  override def tryComplete(): Boolean = coordinator.tryCompleteJoin(group, forceComplete)
  override def onExpiration() = coordinator.onExpireJoin()
  override def onComplete() = coordinator.onCompleteJoin(group)
}
```

言归正传,回到tryCompleteElseWatch

```
/* Check if the operation can be completed, if not watch it based on the given watch keys
*
* Note that a delayed operation can be watched on multiple keys. It is possible that
* an operation is completed after it has been added to the watch list for some, but
* not all of the keys. In this case, the operation is considered completed and won't
* be added to the watch list of the remaining keys. The expiration reaper thread will
* remove this operation from any watcher list in which the operation exists.
*/
def tryCompleteElseWatch(operation: T, watchKeys: Seq[Any]): Boolean = {
    assert(watchKeys.size > 0, "The watch key list can't be empty")

    // The cost of tryComplete() is typically proportional to the number of keys. Calling
    // tryComplete() for each key is going to be expensive if there are many keys. Instead,
    // we do the check in the following way. Call tryComplete(). If the operation is not completed,
    // we just add the operation to all keys. Then we call tryComplete() again. At this time, if
    // the operation is still not completed, we are guaranteed that it won't miss any future triggering
    // event since the operation is already on the watcher list for all keys. This does mean that
    // if the operation is completed (by another thread) between the two tryComplete() calls, the
    // operation is unnecessarily added for watch. However, this is a less severe issue since the
    // expire reaper will clean it up periodically.

    var isCompletedByMe = operation synchronized operation.tryComplete()
    if (isCompletedByMe)
      return true

    var watchCreated = false
    for(key <- watchKeys) {
      // If the operation is already completed, stop adding it to the rest of the watcher list.
      if (operation.isCompleted())
        return false
      watchForOperation(key, operation)

      if (!watchCreated) {
        watchCreated = true
        estimatedTotalOperations.incrementAndGet()
      }
    }

    isCompletedByMe = operation synchronized operation.tryComplete()
    if (isCompletedByMe)
      return true

    // if it cannot be completed by now and hence is watched, add to the expire queue also
    if (! operation.isCompleted()) {
      timeoutTimer.add(operation)
      if (operation.isCompleted()) {
        // cancel the timer task
        operation.cancel()
      }
    }

    false
  }
```
注释大意是? 这个调用的消耗与key的数量是相对应的,就是key多了消耗自然也就大了,
于是：
>
1. 优先做一次尝试看是不是join完成了   
2. 1如果没成功则需要添加watch，监听事件咯，谁知道他啥时候完成触发呢，反正先watch   
3. 然后再尝试是不是join完成了   
4. 最后，还是没有的话只好交给(超时收割机reaper)timeoutTimer去调度去执行。   

DelayedJoin与GroupCoordinator的调用流程
```
DelayedJoin.tryComplete-->GroupCoordinator.tryCompleteJoin()-->DelayedJoin.forceComplete()-->
DelayedJoin.cancel()-->DelayedJoin.onComplete()-->GroupCoordinator.onCompleteJoin()
```

>
1. DelayedJoin.tryComplete()这个操作很简单，只是在GroupCoordinator中判断下每个member是不是有回调函数为null的，
2. 主要还是在GroupCoordinator.onCompleteJoin()

```
def onCompleteJoin(group: GroupMetadata) {
    group synchronized {
      /**
        * 1.如果有join失败(其实就是callback=null)的member,需要将这些member从group中移除
        * 2.同时，如果group里没有member,首先需要将group转换为Dead状态，然后从groupManager中移除
        */
      val failedMembers = group.notYetRejoinedMembers
      if (group.isEmpty || !failedMembers.isEmpty) {
        failedMembers.foreach { failedMember =>
          group.remove(failedMember.memberId)
          // TODO: cut the socket connection to the client
        }

        // TODO KAFKA-2720: only remove group in the background thread
        if (group.isEmpty) {
          group.transitionTo(Dead)
          groupManager.removeGroup(group)
          info("Group %s generation %s is dead and removed".format(group.groupId, group.generationId))
        }
      }
      if (!group.is(Dead)) {
        /**
          * 1. group的generationId增1，设置改group状态为AwaitingSync
          * 2. 构造JoinGroupResult，并设置给callback
          * 3. 这里构造函数是不是leader member存在差异，如果是leader需要返回所有members'Metadata
          */
        group.initNextGeneration()
        info("Stabilized group %s generation %s".format(group.groupId, group.generationId))

        // trigger the awaiting join group response callback for all the members after rebalancing
        for (member <- group.allMemberMetadata) {
          assert(member.awaitingJoinCallback != null)
          val joinResult = JoinGroupResult(
            members=if (member.memberId == group.leaderId) { group.currentMemberMetadata } else { Map.empty },
            memberId=member.memberId,
            generationId=group.generationId,
            subProtocol=group.protocol,
            leaderId=group.leaderId,
            errorCode=Errors.NONE.code)

          member.awaitingJoinCallback(joinResult)
          member.awaitingJoinCallback = null
          /*心跳超时调度处理*/
          completeAndScheduleNextHeartbeatExpiration(group, member)
        }
      }
    }
  }
```
[Kafka Client-side Assignment Proposal](https://cwiki.apache.org/confluence/display/KAFKA/Consumer+Client+Re-Design)   
[Consumer Client Re-Design](https://cwiki.apache.org/confluence/display/KAFKA/Consumer+Client+Re-Design)   
[Kafka 0.9 Consumer Rewrite Design](https://cwiki.apache.org/confluence/display/KAFKA/Kafka+0.9+Consumer+Rewrite+Design)
