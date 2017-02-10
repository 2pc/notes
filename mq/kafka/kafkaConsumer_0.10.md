
消费代码 0.10.1.0

```
public static void main(String[] args){
    Properties props = new Properties();
    props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "172.17.32.127:9092");
    props.put(ConsumerConfig.GROUP_ID_CONFIG, "test6");
    props.put("enable.auto.commit", "true");  //自动commit
    props.put("auto.commit.interval.ms", "1000"); //定时commit的周期
    props.put("session.timeout.ms", "30000"); //consumer活性超时时间
    props.put("key.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
    props.put("value.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
    KafkaConsumer<String, String> consumer = new KafkaConsumer<>(props);
    consumer.subscribe(Collections.singletonList("test6")); //subscribe，foo，bar，两个topic
    while (true) {
        ConsumerRecords<String, String> records = consumer.poll(100);  //100是超时等待时间
        for (ConsumerRecord<String, String> record : records)
            System.out.printf("offset = %d, key = %s, value = %s", record.offset(), record.key(), record.value());
    }
}
```

看下poll中的逻辑,与0.9.0.0的相差无几，主要调用pollOnce,如果pollOnce()返回消息记录，发送一次fetch快速请求，但是比0.9.0.0多了interceptors

```
public ConsumerRecords<K, V> poll(long timeout) {
    acquire();
    try {
        if (timeout < 0)
            throw new IllegalArgumentException("Timeout must not be negative");

        if (this.subscriptions.hasNoSubscriptionOrUserAssignment())
            throw new IllegalStateException("Consumer is not subscribed to any topics or assigned any partitions");

        // poll for new data until the timeout expires
        long start = time.milliseconds();
        long remaining = timeout;
        do {
            Map<TopicPartition, List<ConsumerRecord<K, V>>> records = pollOnce(remaining);
            if (!records.isEmpty()) {
                // before returning the fetched records, we can send off the next round of fetches
                // and avoid block waiting for their responses to enable pipelining while the user
                // is handling the fetched records.
                //
                // NOTE: since the consumed position has already been updated, we must not allow
                // wakeups or any other errors to be triggered prior to returning the fetched records.
                fetcher.sendFetches();
                client.pollNoWakeup();

                if (this.interceptors == null)
                    return new ConsumerRecords<>(records);
                else
                    return this.interceptors.onConsume(new ConsumerRecords<>(records));
            }

            long elapsed = time.milliseconds() - start;
            remaining = timeout - elapsed;
        } while (remaining > 0);

        return ConsumerRecords.empty();
    } finally {
        release();
    }
}
```
来看下pollOnce，差不多也是：
>
1. 发送GroupCoordinatorRequest请求，获取coordinator
2. 发送JoinGroupRequest请求，加入consumer group选举consumer group's leader等
3. 发送SyncGroupRequest请求同步partition assignments分区分配
4. 发送OffsetFetchRequest请求获取offset
5. 从Fetcher获取已经Cache到本地的记录
6. 发送FetchRequest请求获取消息记录

```
private Map<TopicPartition, List<ConsumerRecord<K, V>>> pollOnce(long timeout) {
    /*
    *  1. send GroupCoordinatorRequest: poll()-->ensureCoordinatorReady()-->lookupCoordinator()-->sendGroupCoordinatorRequest()
    *  2. send JoinGroupRequest: poll()-->ensureActive()-->GroupjoinGroupIfNeeded()-->initiateJoinGroup()-->sendJoinGroupRequest()
    *  3. send SyncGroupRequest: after send JoinGroupRequest，JoinGroupResponseHandler.handle()-->onJoinLeader()/onJoinFollower()-->sendSyncGroupRequest
    * */
    coordinator.poll(time.milliseconds());

    // fetch positions if we have partitions we're subscribed to that we
    // don't know the offset for
    if (!subscriptions.hasAllFetchPositions())
        /*
        *  4. send OffsetFetchRequest:refreshCommittedOffsetsIfNeeded()-->fetchCommittedOffsets()-->sendOffsetFetchRequest()
        * */
        updateFetchPositions(this.subscriptions.missingFetchPositions());

    // if data is available already, return it immediately
    /*
    *  5. get record from Fetcher Cache
    * */
    Map<TopicPartition, List<ConsumerRecord<K, V>>> records = fetcher.fetchedRecords();
    if (!records.isEmpty())
        return records;

    // send any new fetches (won't resend pending fetches)
    /*
    *  6.send FetchRequest
    * */
    fetcher.sendFetches();

    long now = time.milliseconds();
    long pollTimeout = Math.min(coordinator.timeToNextPoll(now), timeout);

    client.poll(pollTimeout, now, new PollCondition() {
        @Override
        public boolean shouldBlock() {
            // since a fetch might be completed by the background thread, we need this poll condition
            // to ensure that we do not block unnecessarily in poll()
            return !fetcher.hasCompletedFetches();
        }
    });

    // after the long poll, we should check whether the group needs to rebalance
    // prior to returning data so that the group can stabilize faster
    if (coordinator.needRejoin())
        return Collections.emptyMap();

    return fetcher.fetchedRecords();
}

```
与0.9.0.0的逻辑也差不多：
1. 新版本中第一步直接改名叫ensureCoordinatorReady/lookupCoordinator，看来的多直接，就想知道Coordinator(ip+port)，
反正感觉比ensureCoordinatorKnown()/sendGroupMetadataRequest()
2. 0.10.1.0中将1，2，3步 重新封装一个poll()中
3. fetch record请求也直接多了fetcher.sendFetches()

```
private Map<TopicPartition, List<ConsumerRecord<K, V>>> pollOnce(long timeout) {
    // TODO: Sub-requests should take into account the poll timeout (KAFKA-1894)
    /*
          1. send GroupCoordinatorRequest, get/know coordinator Node
    */
    coordinator.ensureCoordinatorKnown();

    // ensure we have partitions assigned if we expect to
    if (subscriptions.partitionsAutoAssigned())
        /*
        * 2. send JoinGroupRequest
        * 3. send SyncGroupRequest
        * */
        coordinator.ensurePartitionAssignment();

    // fetch positions if we have partitions we're subscribed to that we
    // don't know the offset for
    if (!subscriptions.hasAllFetchPositions())
        /*
        * 4. send OffsetFetchRequest
        * */
        updateFetchPositions(this.subscriptions.missingFetchPositions());

    // init any new fetches (won't resend pending fetches)
    /*
    *  5. get records from fetcher
    * */
    Cluster cluster = this.metadata.fetch();
    Map<TopicPartition, List<ConsumerRecord<K, V>>> records = fetcher.fetchedRecords();
    // Avoid block waiting for response if we already have data available, e.g. from another API call to commit.
    if (!records.isEmpty()) {
        client.poll(0);
        return records;
    }
    /*
    * 6. send FetchRequest
    * */
    fetcher.initFetches(cluster);
    client.poll(timeout);
    return fetcher.fetchedRecords();
}
```
