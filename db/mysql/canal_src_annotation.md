

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


