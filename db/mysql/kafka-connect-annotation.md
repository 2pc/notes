### kafka-connect 原理源码流程梳理


以使用Debezium同步binlog至kafka为例

```
 bin/connect-standalone.sh  config/connect-standalone.properties  mysql.properties 
```

其中connector的配置mysql.properties，其中MySqlConnector继承自SourceConnector，也就是说MySqlConnector是一个SourceConnector

```
connector.class=io.debezium.connector.mysql.MySqlConnector
database.hostname=127.0.0.1
database.port=3306
database.user=canal
database.password=canal
database.server.id=67777
database.server.name=127.0.0.1:3306
database.whitelist=test
database.history.kafka.bootstrap.servers=127.0.0.1:9092
database.history.kafka.topic=dbhistory.fullfillment
include.schema.changes=true
```

在kafka-connect启动脚本中,最后是类[ConnectStandalone](https://github.com/apache/kafka/blob/trunk/connect/runtime/src/main/java/org/apache/kafka/connect/cli/ConnectStandalone.java)


```
exec $(dirname $0)/kafka-run-class.sh $EXTRA_ARGS org.apache.kafka.connect.cli.ConnectStandalone "$@"
```

ConnectStandalone的代码逻辑并不多，主要是通过Herder把work,connect的信息关联起来了

```
 Worker worker = new Worker(workerId, time, plugins, config, new FileOffsetBackingStore());

Herder herder = new StandaloneHerder(worker);
final Connect connect = new Connect(herder, rest);

try {
    connect.start();
    for (final String connectorPropsFile : Arrays.copyOfRange(args, 1, args.length)) {
        Map<String, String> connectorProps = Utils.propsToStringMap(Utils.loadProps(connectorPropsFile));
        FutureCallback<Herder.Created<ConnectorInfo>> cb = new FutureCallback<>(new Callback<Herder.Created<ConnectorInfo>>() {
            @Override
            public void onCompletion(Throwable error, Herder.Created<ConnectorInfo> info) {
                if (error != null)
                    log.error("Failed to create job for {}", connectorPropsFile);
                else
                    log.info("Created connector {}", info.result().name());
            }
        });
        herder.putConnectorConfig(
                connectorProps.get(ConnectorConfig.NAME_CONFIG),
                connectorProps, false, cb);
        cb.get();
    }
} catch (Throwable t) {
    log.error("Stopping after connector error", t);
    connect.stop();
}
```
Connect的start方法，其实就是启动herder，rest

```
public void start() {
    try {
        log.info("Kafka Connect starting");
        Runtime.getRuntime().addShutdownHook(shutdownHook);

        herder.start();
        rest.start(herder);

        log.info("Kafka Connect started");
    } finally {
        startLatch.countDown();
    }
}
```

在[StandaloneHerder.java](https://github.com/apache/kafka/blob/trunk/connect/runtime/src/main/java/org/apache/kafka/connect/runtime/standalone/StandaloneHerder.java)的putConnectorConfig()调用了

```
if (!startConnector(config)) {
    callback.onCompletion(new ConnectException("Failed to start connector: " + connName), null);
    return;
}
updateConnectorTasks(connName);
callback.onCompletion(null, new Created<>(created, createConnectorInfo(connName)));

//startConnector
private boolean startConnector(Map<String, String> connectorProps) {
    String connName = connectorProps.get(ConnectorConfig.NAME_CONFIG);
    configBackingStore.putConnectorConfig(connName, connectorProps);
    TargetState targetState = configState.targetState(connName);
    return worker.startConnector(connName, connectorProps, new HerderConnectorContext(this, connName), this, targetState);
}
```
Worker的startConnector方法主要代码

```
final ConnectorConfig connConfig = new ConnectorConfig(plugins, connProps);
final String connClass = connConfig.getString(ConnectorConfig.CONNECTOR_CLASS_CONFIG);
log.info("Creating connector {} of type {}", connName, connClass);
final Connector connector = plugins.newConnector(connClass);
workerConnector = new WorkerConnector(connName, connector, ctx, statusListener);
log.info("Instantiated connector {} with version {} of type {}", connName, connector.version(), connector.getClass());
savedLoader = plugins.compareAndSwapLoaders(connector);
workerConnector.initialize(connConfig);
workerConnector.transitionTo(initialState);

```

workerConnector的doStart()会调用

```
connector.start(config);
```

看了一圈还是没到任务执行逻辑，主要逻辑不是connector(MySqlConnector),而是task(MySqlConnectorTask)
好吧回到Worker里边看到个方法buildWorkerTask(),没错是在这里边启动sourceTask与sinkTask

```
private WorkerTask buildWorkerTask(ConnectorConfig connConfig,
                                   ConnectorTaskId id,
                                   Task task,
                                   TaskStatus.Listener statusListener,
                                   TargetState initialState,
                                   Converter keyConverter,
                                   Converter valueConverter,
                                   ClassLoader loader) {
    // Decide which type of worker task we need based on the type of task.
    if (task instanceof SourceTask) {
        TransformationChain<SourceRecord> transformationChain = new TransformationChain<>(connConfig.<SourceRecord>transformations());
        OffsetStorageReader offsetReader = new OffsetStorageReaderImpl(offsetBackingStore, id.connector(),
                internalKeyConverter, internalValueConverter);
        OffsetStorageWriter offsetWriter = new OffsetStorageWriter(offsetBackingStore, id.connector(),
                internalKeyConverter, internalValueConverter);
        KafkaProducer<byte[], byte[]> producer = new KafkaProducer<>(producerProps);
        return new WorkerSourceTask(id, (SourceTask) task, statusListener, initialState, keyConverter,
                valueConverter, transformationChain, producer, offsetReader, offsetWriter, config, loader, time);
    } else if (task instanceof SinkTask) {
        TransformationChain<SinkRecord> transformationChain = new TransformationChain<>(connConfig.<SinkRecord>transformations());
        return new WorkerSinkTask(id, (SinkTask) task, statusListener, initialState, config, keyConverter,
                valueConverter, transformationChain, loader, time);
    } else {
        log.error("Tasks must be a subclass of either SourceTask or SinkTask", task);
        throw new ConnectException("Tasks must be a subclass of either SourceTask or SinkTask");
    }
}
//Worker.startTask()
executor.submit(workerTask);
```
顺藤摸瓜startTask()又是之前的herder的createConnectorTasks()里开始调用的,又被updateConnectorTasks(connName)调用，

```
private void updateConnectorTasks(String connName) {
      if (!worker.isRunning(connName)) {
          log.info("Skipping reconfiguration of connector {} since it is not running", connName);
          return;
      }

      List<Map<String, String>> newTaskConfigs = recomputeTaskConfigs(connName);
      List<Map<String, String>> oldTaskConfigs = configState.allTaskConfigs(connName);

      if (!newTaskConfigs.equals(oldTaskConfigs)) {
          removeConnectorTasks(connName);
          configBackingStore.putTaskConfigs(connName, newTaskConfigs);
          createConnectorTasks(connName, configState.targetState(connName));
      }
  }
private void createConnectorTasks(String connName, TargetState initialState) {
    Map<String, String> connConfigs = configState.connectorConfig(connName);

    for (ConnectorTaskId taskId : configState.tasks(connName)) {
        Map<String, String> taskConfigMap = configState.taskConfig(taskId);
        worker.startTask(taskId, connConfigs, taskConfigMap, this, initialState);
    }
}
```
调用流程清楚了，直接找task调用的地方，那重点就是executor.submit(workerTask)了,MySqlConnectorTask是SourceTask
直接找[WorkerSourceTask](https://github.com/apache/kafka/blob/trunk/connect/runtime/src/main/java/org/apache/kafka/connect/runtime/WorkerSourceTask.java)
,没错直接找execute()

```
@Override
public void execute() {
    try {
        task.initialize(new WorkerSourceTaskContext(offsetReader));
        task.start(taskConfig);
        log.info("{} Source task finished initialization and start", this);
        synchronized (this) {
            if (startedShutdownBeforeStartCompleted) {
                task.stop();
                return;
            }
            finishedStart = true;
        }

        while (!isStopping()) {
            if (shouldPause()) {
                onPause();
                if (awaitUnpause()) {
                    onResume();
                }
                continue;
            }

            if (toSend == null) {
                log.debug("{} Nothing to send to Kafka. Polling source for additional records", this);
                toSend = task.poll();
            }
            if (toSend == null)
                continue;
            log.debug("{} About to send " + toSend.size() + " records to Kafka", this);
            if (!sendRecords())
                stopRequestedLatch.await(SEND_FAILED_BACKOFF_MS, TimeUnit.MILLISECONDS);
        }
    } catch (InterruptedException e) {
        // Ignore and allow to exit.
    } finally {
        // It should still be safe to commit offsets since any exception would have
        // simply resulted in not getting more records but all the existing records should be ok to flush
        // and commit offsets. Worst case, task.flush() will also throw an exception causing the offset commit
        // to fail.
        commitOffsets();
    }
}
```

拉取binlog 以及发送给kafka的逻辑都在这里面，重要的两行

```
if (toSend == null) {
    log.debug("{} Nothing to send to Kafka. Polling source for additional records", this);
    toSend = task.poll();
}
if (toSend == null)
    continue;
log.debug("{} About to send " + toSend.size() + " records to Kafka", this);
if (!sendRecords())
```

sendRecords()不用看也是kafkaproduce发送给broker的逻辑(确实也是)，再看下task.poll(),这里很熟悉在sourceTask的方法，这里就是MySqlConnectorTask

```
public List<SourceRecord> poll() throws InterruptedException {
    Reader currentReader = readers;
    if (currentReader == null) {
        return null;
    }
    PreviousContext prevLoggingContext = this.taskContext.configureLoggingContext("task");
    try {
        logger.trace("Polling for events");
        return currentReader.poll();
    } finally {
        prevLoggingContext.restore();
    }
}
```

readers是一个链式ChainedReader，可能包含两个reader(SnapshotReader,BinlogReader),首先会依据是否需要支持snapshot来添加SnapshotReader

```
BinlogReader binlogReader = new BinlogReader("binlog", taskContext);
if (startWithSnapshot) {
    // We're supposed to start with a snapshot, so set that up ...
    SnapshotReader snapshotReader = new SnapshotReader("snapshot", taskContext);
    snapshotReader.useMinimalBlocking(taskContext.useMinimalSnapshotLocking());
    if (snapshotEventsAreInserts) snapshotReader.generateInsertEvents();
    readers.add(snapshotReader);

    if (taskContext.isInitialSnapshotOnly()) {
        logger.warn("This connector will only perform a snapshot, and will stop after that completes.");
        readers.uponCompletion("Connector configured to only perform snapshot, and snapshot completed successfully. Connector will terminate.");
    } else {
        if (!rowBinlogEnabled) {
            throw new ConnectException("The MySQL server is not configured to use a row-level binlog, which is "
                    + "required for this connector to work properly. Change the MySQL configuration to use a "
                    + "row-level binlog and restart the connector.");
        }
        readers.add(binlogReader);
    }
} else {
    if (!rowBinlogEnabled) {
        throw new ConnectException(
                "The MySQL server does not appear to be using a row-level binlog, which is required for this connector to work properly. Enable this mode and restart the connector.");
    }
    // We're going to start by reading the binlog ...
    readers.add(binlogReader);
}

// And start the chain of readers ...
this.readers.start();
```

SnapshotReader是一个全量快照，BinlogReader可以认为是一个增量快照
