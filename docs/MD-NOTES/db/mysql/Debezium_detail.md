
# Debezium 详细设计

###  topic设计

1. 每个表对应一个topic,topic的格式：serverName.databaseName.tableName，其中serverName是配置项“database.server.name”的值
2. Schema change topic: serverName，这个值也是配置项“database.server.name”
3. database history topic：这个值是配置项“database.history.kafka.topic”的值

### key设计

key基于primary或者unique key约束，

###  模式

snapshot.mode 

1. initial
2. when_needed
3. never
4. schema_only

### 产生消息

还是从MySqlConnectorTask.poll()看起，最终调用的是AbstractReader.poll()

```
MySqlConnectorTask.poll()-->ChainedReader.poll()-->AbstractReader.poll()
```
AbstractReader可以是SnapshotReader或者BinlogReader,增量是BinlogReader，全量是SnapshotReader

poll() 主要逻辑代码

```
logger.trace("Polling for next batch of records");
List<SourceRecord> batch = new ArrayList<>(maxBatchSize);
while (running.get() && (records.drainTo(batch, maxBatchSize) == 0) && !success.get()) {}
return batch;
```

就是从records队列一次获取maxBatchSize量的SourceRecord，这个records是一个LinkedBlockingDeque

```
 this.records = new LinkedBlockingDeque<>(context.maxQueueSize());
```
既然是BlockingDeque,直接看入队列好了，在AbstractReader.enqueueRecord()中可以找到put入队列

```
protected void enqueueRecord(SourceRecord record) throws InterruptedException {
    if (record != null) {
        if (logger.isTraceEnabled()) {
            logger.trace("Enqueuing source record: {}", record);
        }
        this.records.put(record);
    }
}
```

这个enqueueRecord在很多地方调用到

```
BinlogReader.handleInsert(Event event)
BinlogReader.handleUpdate(Event event)
BinlogReader.handleDelete(Event event)
SnapshotReader.handleQueryEvent(Event event)
SnapshotReader.execute() 
SnapshotReader.enqueueSchemaChanges
```

看下insert,update,delete事件的处理,handleUpdate为例,代码略去很多logger代码

```
protected void handleUpdate(Event event) throws InterruptedException {
    UpdateRowsEventData update = unwrapData(event);
    long tableNumber = update.getTableId();
    BitSet includedColumns = update.getIncludedColumns();
    // BitSet includedColumnsBefore = update.getIncludedColumnsBeforeUpdate();
    RecordsForTable recordMaker = recordMakers.forTable(tableNumber, includedColumns, super::enqueueRecord);
    if (recordMaker != null) {
        List<Entry<Serializable[], Serializable[]>> rows = update.getRows();
        Long ts = context.clock().currentTimeInMillis();
        int count = 0;
        int numRows = rows.size();
        if (startingRowNumber < numRows) {
            for (int row = startingRowNumber; row != numRows; ++row) {
                Map.Entry<Serializable[], Serializable[]> changes = rows.get(row);
                Serializable[] before = changes.getKey();
                Serializable[] after = changes.getValue();
                count += recordMaker.update(before, after, ts, row, numRows);
            }

        } else {
            // All rows were previously processed ...
            logger.debug("Skipping previously processed update event: {}", event);
        }
    } else {
        logger.debug("Skipping update row event: {}", event);
    }
    startingRowNumber = 0;
}
```

重要的是两行

```
RecordsForTable recordMaker = recordMakers.forTable(tableNumber, includedColumns, super::enqueueRecord)
count += recordMaker.update(before, after, ts, row, numRows);
```
recordMaker

```
public int update(Object[] before, Object[] after, long ts, int rowNumber, int numberOfRows) throws InterruptedException {
    return converter.update(source, before, after, rowNumber, numberOfRows, includedColumns, ts, consumer);
}
```
Converter

```
public int update(SourceInfo source, Object[] before, Object[] after, int rowNumber, int numberOfRows, BitSet includedColumns,
                  long ts,
                  BlockingConsumer<SourceRecord> consumer)
        throws InterruptedException {
    int count = 0;
    Object key = tableSchema.keyFromColumnData(after);
    Struct valueAfter = tableSchema.valueFromColumnData(after);
    logger.info("valueAfter: {},key {}",valueAfter,key);
    if (valueAfter != null || key != null) {
        Object oldKey = tableSchema.keyFromColumnData(before);
        Struct valueBefore = tableSchema.valueFromColumnData(before);
        Schema keySchema = tableSchema.keySchema();
        Map<String, ?> partition = source.partition();
        Map<String, ?> offset = source.offsetForRow(rowNumber, numberOfRows);
        Struct origin = source.struct(id);
        if (key != null && !Objects.equals(key, oldKey)) {
            // The key has changed, so we need to deal with both the new key and old key.
            // Consumers may push the events into a system that won't allow both records to exist at the same time,
            // so we first want to send the delete event for the old key... 
            logger.info("update record oldkey: {},key: {} "+oldKey,key);
            SourceRecord record = new SourceRecord(partition, offset, topicName, partitionNum,
                    keySchema, oldKey, envelope.schema(), envelope.delete(valueBefore, origin, ts));
            consumer.accept(record);
            ++count;

            // Next send a tombstone event for the old key ...
            record = new SourceRecord(partition, offset, topicName, partitionNum, keySchema, oldKey, null, null);
            consumer.accept(record);
            ++count;

            // And finally send the create event ...
            record = new SourceRecord(partition, offset, topicName, partitionNum,
                    keySchema, key, envelope.schema(), envelope.create(valueAfter, origin, ts));
            consumer.accept(record);
            ++count;
        } else {
            // The key has not changed, so a simple update is fine ...
            SourceRecord record = new SourceRecord(partition, offset, topicName, partitionNum,
                    keySchema, key, envelope.schema(), envelope.update(valueBefore, valueAfter, origin, ts));
            logger.info("update record {}",record.toString());
            consumer.accept(record);
            ++count;
        }
    }
    return count;
}
```

这里有个逻辑是如果key 发生了变化，会将生成多个SourceRecord，就是想删后insert新的
eg;

建表语句
```
CREATE TABLE `test` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `X` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=102 DEFAULT CHARSET=utf8
insert into test(id,x) values(null,now());
```
sql
```
mysql> select * from test where id=100;
+-----+---------------------+
| ID  | X                   |
+-----+---------------------+
| 100 | 2017-09-15 00:34:20 |
+-----+---------------------+
1 row in set (0.03 sec)
mysql> update test set x=now() where id =100;
Query OK, 1 row affected (0.02 sec)
mysql> select * from test where id =100;
+-----+---------------------+
| ID  | X                   |
+-----+---------------------+
| 100 | 2017-09-15 00:47:43 |
+-----+---------------------+
1 row in set (0.00 sec)
```

Binlog解析事件, 明显差了8个小时，UTC吧

```
{before=[100, 2017-09-14T16:47:05+08:00[PRC]], after=[100, 2017-09-14T16:47:43+08:00[PRC]]}
```

key 这里id是Primary key,100

```
valueAfter: Struct{ID=100,X=2017-09-14T16:47:43+08:00},key Struct{ID=100} 
```
生成的SourceRecord

```
[2017-09-15 00:47:53,078] INFO update record SourceRecord{sourcePartition={server=b555533}, sourceOffset={ts_sec=1505407663, file=mysql-bin.000022, pos=26544, row=1, server_id=2, event=2}} ConnectRecord{topic='b555533.test2.test', kafkaPartition=null, key=Struct{ID=100}, value=Struct{before=Struct{ID=100,X=2017-09-14T16:47:05+08:00},after=Struct{ID=100,X=2017-09-14T16:47:43+08:00},source=Struct{name=b555533,server_id=2,ts_sec=1505407663,file=mysql-bin.000022,pos=26666,row=0,thread=694,db=test2,table=test},op=u,ts_ms=1505407673078}, timestamp=null} (io.debezium.connector.mysql.RecordMakers:269)

```

tableSchema

```
{ key : {"name" : "b555533.test.xdual.Key", "type" : "STRUCT", "optional" : "false", "fields" : [{"name" : "ID", "index" : "0", "schema" : {"type" : "INT32", "optional" : "false"}}]}, value : {"name" : "b555533.test.xdual.Value", "type" : "STRUCT", "optional" : "true", "fields" : [{"name" : "ID", "index" : "0", "schema" : {"type" : "INT32", "optional" : "false"}}, {"name" : "X", "index" : "1", "schema" : {"name" : "io.debezium.time.ZonedTimestamp", "type" : "STRING", "optional" : "false", "version" : "1"}}]} }
```

启动多个connect,配置修改 config/connect-standalone.properties

```
rest.port=20100
offset.storage.file.filename=/tmp/connect.offsets
```

日志文件config/connect-log4j.properties 







