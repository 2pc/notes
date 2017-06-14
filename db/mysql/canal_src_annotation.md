

###  MysqlConnection 
dump 日志

```
public void dump(String binlogfilename, Long binlogPosition, SinkFunction func) throws IOException {
    updateSettings();
    loadBinlogChecksum();
    sendBinlogDump(binlogfilename, binlogPosition);
    DirectLogFetcher fetcher = new DirectLogFetcher(connector.getReceiveBufferSize());
    fetcher.start(connector.getChannel());
    LogDecoder decoder = new LogDecoder(LogEvent.UNKNOWN_EVENT, LogEvent.ENUM_END_EVENT);
    LogContext context = new LogContext();
    context.setLogPosition(new LogPosition(binlogfilename));
    context.setFormatDescription(new FormatDescriptionLogEvent(4, binlogChecksum));
    while (fetcher.fetch()) {
        LogEvent event = null;
        event = decoder.decode(fetcher, context);

        if (event == null) {
            throw new CanalParseException("parse failed");
        }

        if (!func.sink(event)) {
            break;
        }
    }
}
```

metaManager

ack 服务端过程

```
SessionHandler.messageReceived-->embeddedServer.ack-->canalInstance.getMetaManager().updateCursor
```
metaManager主要有file,memory,zk等方式以及衍生的组合方式

Cluster模式Client高可用模式

```
ClientRunningMonitor ServerRunningMonitor
```

zookeeper上存储结构结点管理ZookeeperPathUtils.java

```
 * /otter
 *    canal
 *      cluster
 *      destinations
 *        dest1
 *          running (EPHEMERAL) 
 *          cluster
 *          client1
 *            running (EPHEMERAL)
 *            cluster
 *            filter
 *            cursor
 *            mark
 *              1
 *              2
 *              3
```

### position获取  

```
CanalServerWithEmbedded.subscribe()-->MemoryEventStoreWithBuffer.getFirstPosition()
```

CanalServerWithEmbedded.subscribe()  里优先从MetaManager（如ZooKeeperMetaManager）里获取Cursor，也就是Position，如果没有，则重新从EventStore获取

```
public void subscribe(ClientIdentity clientIdentity) throws CanalServerException {
    checkStart(clientIdentity.getDestination());

    CanalInstance canalInstance = canalInstances.get(clientIdentity.getDestination());
    if (!canalInstance.getMetaManager().isStart()) {
        canalInstance.getMetaManager().start();
    }

    canalInstance.getMetaManager().subscribe(clientIdentity); // 执行一下meta订阅
    //1.优先从MetaManager获取Cursor作为Position
    Position position = canalInstance.getMetaManager().getCursor(clientIdentity);
    if (position == null) {
        //2.从EventStore获取最后一条ack的Event，并构造一个positon
        position = canalInstance.getEventStore().getFirstPosition();// 获取一下store中的第一条
        if (position != null) {
            canalInstance.getMetaManager().updateCursor(clientIdentity, position); // 更新一下cursor
        }
        logger.info("subscribe successfully, {} with first position:{} ", clientIdentity, position);
    } else {
        logger.info("subscribe successfully, use last cursor position:{} ", clientIdentity, position);
    }

    // 通知下订阅关系变化
    canalInstance.subscribeChange(clientIdentity);
}
```

从EventStore中获取MemoryEventStoreWithBuffer.getFirstPosition(), 
>
1. 其中putSequence是当前put操作最后一次写操作发生的位置
2. ackSequence是当前ack操作的最后一条的位置
3. getSequence当前get操作读取的最后一条的位置
 
```
public LogPosition getFirstPosition() throws CanalStoreException {
    final ReentrantLock lock = this.lock;
    lock.lock();
    try {
        long firstSeqeuence = ackSequence.get();
        if (firstSeqeuence == INIT_SQEUENCE && firstSeqeuence < putSequence.get()) {
            // 没有ack过数据
            Event event = entries[getIndex(firstSeqeuence + 1)]; // 最后一次ack为-1，需要移动到下一条,included
                                                                 // = false
            return CanalEventUtils.createPosition(event, false);
        } else if (firstSeqeuence > INIT_SQEUENCE && firstSeqeuence < putSequence.get()) {
            // ack未追上put操作
            Event event = entries[getIndex(firstSeqeuence + 1)]; // 最后一次ack的位置数据
                                                                 // + 1
            return CanalEventUtils.createPosition(event, true);
        } else if (firstSeqeuence > INIT_SQEUENCE && firstSeqeuence == putSequence.get()) {
            // 已经追上，store中没有数据
            Event event = entries[getIndex(firstSeqeuence)]; // 最后一次ack的位置数据，和last为同一条，included
                                                             // = false
            return CanalEventUtils.createPosition(event, false);
        } else {
            // 没有任何数据
            return null;
        }
    } finally {
        lock.unlock();
    }
}
```

看下postion 的构造

```
public static LogPosition createPosition(Event event, boolean included) {
    EntryPosition position = new EntryPosition();
    position.setJournalName(event.getEntry().getHeader().getLogfileName());//当前binlog的文件名mysql-bin.000007
    position.setPosition(event.getEntry().getHeader().getLogfileOffset());//position
    position.setTimestamp(event.getEntry().getHeader().getExecuteTime());//timestamp
    position.setIncluded(included);

    LogPosition logPosition = new LogPosition();
    logPosition.setPostion(position);
    logPosition.setIdentity(event.getLogIdentity());
    return logPosition;
}
```

### CanalInstanceWithSpring  基于spring容器启动canal实例

```
CanalController(initGlobalConfig(new CanalInstanceGenerator(Spring))-->embededCanalServer.setCanalInstanceGenerator(instanceGenerator))-->ServerRunningListener-->embededCanalServer.start(destination)-->canalInstance.start();
```
canalInstance的start()方法中启动相关组件

>
1. metaManager 

```
public void start() {
    logger.info("start CannalInstance for {}-{} ", new Object[] { 1, destination });
    super.start();
}
//AbstractCanalInstance.java
public void start() {
    super.start();
    if (!metaManager.isStart()) {
        metaManager.start();
    }

    if (!alarmHandler.isStart()) {
        alarmHandler.start();
    }

    if (!eventStore.isStart()) {
        eventStore.start();
    }

    if (!eventSink.isStart()) {
        eventSink.start();
    }

    if (!eventParser.isStart()) {
        beforeStartEventParser(eventParser);
        eventParser.start();
        afterStartEventParser(eventParser);
    }
    logger.info("start successful....");
}
```
看下CanalInstanceWithSpring的配置文件
>
1. eventParser是MysqlEventParser
2. eventSink是EntryEventSink
3. eventStore是MemoryEventStoreWithBuffer
4. metaManager是PeriodMixedMetaManager，内部使用的PeriodMixedMetaManager。定时刷新到zk
5. alarmHandler是LogAlarmHandler

```
<bean id="instance" class="com.alibaba.otter.canal.instance.spring.CanalInstanceWithSpring">
        <property name="destination" value="${canal.instance.destination}" />
        <property name="eventParser">
                <ref local="eventParser" />
        </property>
        <property name="eventSink">
                <ref local="eventSink" />
        </property>
        <property name="eventStore">
                <ref local="eventStore" />
        </property>
        <property name="metaManager">
                <ref local="metaManager" />
        </property>
        <property name="alarmHandler">
                <ref local="alarmHandler" />
        </property>
</bean>
```





