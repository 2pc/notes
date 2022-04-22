create

```
 bin/kafka-topics.sh  --create --zookeeper 172.28.3.158:2181 --replication-factor 2 --partitions 8 --topic topictest
 bin/kafka-topics.sh  --create --zookeeper 172.28.3.158:2181 --replication-factor 2 --partitions 2  --topic topictest3
```

describe 

```
 bin/kafka-topics.sh  --describe --topic topictest --zookeeper 172.28.3.158
 bin/kafka-topics.sh  --describe --topic topictest3  --zookeeper 172.28.3.158
```

修改分区

```
bin/kafka-reassign-partitions.sh --zookeeper 172.28.3.158:2181 --reassignment-json-file canal.json  --execute
```

其中canal.json 为replicas 与patition相关数据，如

```

```
