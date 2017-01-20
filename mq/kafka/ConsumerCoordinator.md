#### ConsumerCoordinator

消费者调用

```
consumer.subscribe(Collections.singletonList(topic), new NoOpConsumerRebalanceListener());
ConsumerRecords<byte[], byte[]> records = consumer.poll(1000);//nioSelector.select(timeout) or nioSelector.selectNow()
for (ConsumerRecord<byte[], byte[]>  record: records) {
    System.out.print(record.offset());
    System.out.print(record.topic());
    System.out.print(record.offset());
    System.out.print(record.key());
    System.out.print(record.value());
}
consumer.commitSync();
```
ConsumerCoordinator完成joinGroup后，在回调函数JoinGroupResponseHandler.handle()里进行请求相应其后的处理

```
  short errorCode = joinResponse.errorCode();
  if (errorCode == Errors.NONE.code()) {
      log.debug("Joined group: {}", joinResponse.toStruct());
      AbstractCoordinator.this.memberId = joinResponse.memberId();
      AbstractCoordinator.this.generation = joinResponse.generationId();
      AbstractCoordinator.this.rejoinNeeded = false;
      AbstractCoordinator.this.protocol = joinResponse.groupProtocol();
      sensors.joinLatency.record(response.requestLatencyMs());
      if (joinResponse.isLeader()) {
          onJoinLeader(joinResponse).chain(future);
      } else {
          onJoinFollower().chain(future);
      }
  }
```
依据是不是leader处理逻辑存在差异

```
private RequestFuture<ByteBuffer> onJoinLeader(JoinGroupResponse joinResponse) {
    try {
        // perform the leader synchronization and send back the assignment for the group
        Map<String, ByteBuffer> groupAssignment = performAssignment(joinResponse.leaderId(), joinResponse.groupProtocol(),
                joinResponse.members());

        SyncGroupRequest request = new SyncGroupRequest(groupId, generation, memberId, groupAssignment);
        log.debug("Issuing leader SyncGroup ({}: {}) to coordinator {}", ApiKeys.SYNC_GROUP, request, this.coordinator.id());
        return sendSyncGroupRequest(request);
    } catch (RuntimeException e) {
        return RequestFuture.failure(e);
    }
}

private RequestFuture<ByteBuffer> onJoinFollower() {
    // send follower's sync group with an empty assignment
    SyncGroupRequest request = new SyncGroupRequest(groupId, generation,
            memberId, Collections.<String, ByteBuffer>emptyMap());
    log.debug("Issuing follower SyncGroup ({}: {}) to coordinator {}", ApiKeys.SYNC_GROUP, request, this.coordinator.id());
    return sendSyncGroupRequest(request);
}
```
可以看出leader会将分区信息一起相应给server端，非leader，则分区信息为空集合
