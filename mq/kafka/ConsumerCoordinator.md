### ConsumerCoordinator

#### 消费者调用

```
Properties props = new Properties();
props.setProperty(ConsumerConfig.CLIENT_ID_CONFIG, "testSubscription");
props.setProperty(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9999");
props.setProperty(ConsumerConfig.METRIC_REPORTER_CLASSES_CONFIG, MockMetricsReporter.class.getName());

KafkaConsumer<byte[], byte[]> consumer = new KafkaConsumer<byte[], byte[]>(
    props, new ByteArrayDeserializer(), new ByteArrayDeserializer());
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
#### 订阅topic

主要更新patition的分配assignment，

>
1. 将订阅的topic添加到subscription，groupSubscription，
2. 设置needsPartitionAssignment=true,表示需要对当前consumer重新分配patition
3. 对于不再订阅的topic，需要将patition信息移除


```
try {
    if (topics.isEmpty()) {
        // treat subscribing to empty topic list as the same as unsubscribing
        this.unsubscribe();
    } else {
        log.debug("Subscribed to topic(s): {}", Utils.join(topics, ", "));
        this.subscriptions.subscribe(topics, listener);
        metadata.setTopics(subscriptions.groupSubscription());
    }
} finally {
    release();
}
public void subscribe(List<String> topics, ConsumerRebalanceListener listener) {
    if (listener == null)
        throw new IllegalArgumentException("RebalanceListener cannot be null");

    if (!this.userAssignment.isEmpty() || this.subscribedPattern != null)
        throw new IllegalStateException(SUBSCRIPTION_EXCEPTION_MESSAGE);

    this.listener = listener;

    changeSubscription(topics);
}
    public void changeSubscription(List<String> topicsToSubscribe) {
    if (!this.subscription.equals(new HashSet<>(topicsToSubscribe))) {
        this.subscription.clear();
        this.subscription.addAll(topicsToSubscribe);
        this.groupSubscription.addAll(topicsToSubscribe);
        this.needsPartitionAssignment = true;

        // Remove any assigned partitions which are no longer subscribed to
        for (Iterator<TopicPartition> it = assignment.keySet().iterator(); it.hasNext(); ) {
            TopicPartition tp = it.next();
            if (!subscription.contains(tp.topic()))
                it.remove();
        }
    }
}
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
