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

#### 获取topic的消息

>
1. 从pollOnce可以看出，首先是从fetch中获取之前已经获取的消息records，如果没有,fetch发送一次FETCH请求
2. 如果获取到了数据记录，在记录返回之前，也需要在发送一次FETCH请求，快速返回。
3. 如果没有获取到records，或者超时，直接返回空

```
ConsumerRecords<byte[], byte[]> records = consumer.poll(1000)
public ConsumerRecords<K, V> poll(long timeout) {
    acquire();
    try {
        if (timeout < 0)
            throw new IllegalArgumentException("Timeout must not be negative");

        // poll for new data until the timeout expires
        long start = time.milliseconds();
        long remaining = timeout;
        do {
            Map<TopicPartition, List<ConsumerRecord<K, V>>> records = pollOnce(remaining);
            if (!records.isEmpty()) {
                // if data is available, then return it, but first send off the
                // next round of fetches to enable pipelining while the user is
                // handling the fetched records.
                fetcher.initFetches(metadata.fetch());
                client.poll(0);
                return new ConsumerRecords<>(records);
            }

            long elapsed = time.milliseconds() - start;
            remaining = timeout - elapsed;
        } while (remaining > 0);

        return ConsumerRecords.empty();
    } finally {
        release();
    }
}
private Map<TopicPartition, List<ConsumerRecord<K, V>>> pollOnce(long timeout) {
    // TODO: Sub-requests should take into account the poll timeout (KAFKA-1894)
    coordinator.ensureCoordinatorKnown();

    // ensure we have partitions assigned if we expect to
    if (subscriptions.partitionsAutoAssigned())
        coordinator.ensurePartitionAssignment();

    // fetch positions if we have partitions we're subscribed to that we
    // don't know the offset for
    if (!subscriptions.hasAllFetchPositions())
        updateFetchPositions(this.subscriptions.missingFetchPositions());

    // init any new fetches (won't resend pending fetches)
    Cluster cluster = this.metadata.fetch();
    Map<TopicPartition, List<ConsumerRecord<K, V>>> records = fetcher.fetchedRecords();
    // Avoid block waiting for response if we already have data available, e.g. from another API call to commit.
    if (!records.isEmpty()) {
        client.poll(0);
        return records;
    }
    fetcher.initFetches(cluster);
    client.poll(timeout);
    return fetcher.fetchedRecords();
}
```
 fetcher.fetchedRecords 获取fetch中已经获取的消息记录
 
 ```
public Map<TopicPartition, List<ConsumerRecord<K, V>>> fetchedRecords() {
if (this.subscriptions.partitionAssignmentNeeded()) {
    return Collections.emptyMap();
} else {
    Map<TopicPartition, List<ConsumerRecord<K, V>>> drained = new HashMap<>();
    throwIfOffsetOutOfRange();
    throwIfUnauthorizedTopics();
    throwIfRecordTooLarge();

    for (PartitionRecords<K, V> part : this.records) {
        if (!subscriptions.isAssigned(part.partition)) {
            // this can happen when a rebalance happened before fetched records are returned to the consumer's poll call
            log.debug("Not returning fetched records for partition {} since it is no longer assigned", part.partition);
            continue;
        }

        // note that the consumed position should always be available
        // as long as the partition is still assigned
        long consumed = subscriptions.consumed(part.partition);
        if (!subscriptions.isFetchable(part.partition)) {
            // this can happen when a partition consumption paused before fetched records are returned to the consumer's poll call
            log.debug("Not returning fetched records for assigned partition {} since it is no longer fetchable", part.partition);

            // we also need to reset the fetch positions to pretend we did not fetch
            // this partition in the previous request at all
            subscriptions.fetched(part.partition, consumed);
        } else if (part.fetchOffset == consumed) {
            long nextOffset = part.records.get(part.records.size() - 1).offset() + 1;

            log.trace("Returning fetched records for assigned partition {} and update consumed position to {}", part.partition, nextOffset);

            List<ConsumerRecord<K, V>> records = drained.get(part.partition);
            if (records == null) {
                records = part.records;
                drained.put(part.partition, records);
            } else {
                records.addAll(part.records);
            }
            subscriptions.consumed(part.partition, nextOffset);
        } else {
            // these records aren't next in line based on the last consumed position, ignore them
            // they must be from an obsolete request
            log.debug("Ignoring fetched records for {} at offset {}", part.partition, part.fetchOffset);
        }
    }
    this.records.clear();
    return drained;
}
}
 ```
 
 如果fetch有记录会发送一次poll,
 
 ```
 if (!records.isEmpty()) {
        client.poll(0);
        return records;
    }
 ```
 
 如果Fetcher中没有数据，需要通过Fetcher发送一次FETCH请求
 
 ```
fetcher.initFetches(cluster);
client.poll(timeout);
return fetcher.fetchedRecords();
 
 ```
 
 
