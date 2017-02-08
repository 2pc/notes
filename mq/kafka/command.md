
创建topic

```
bin/kafka-topics.sh  --create --zookeeper 172.17.32.127:2181 --replication-factor 3 --partitions 6 --topic test6 
```

1. --replication-factor 副本数
2. --partitions 分区数


topic信息

```
bin/kafka-topics.sh  --describe --zookeeper 172.17.32.127:2181 --topic test6 
```

```
# bin/kafka-topics.sh  --describe --zookeeper 172.17.32.127:2181 --topic test6 
Topic:test6     PartitionCount:6        ReplicationFactor:3     Configs:
        Topic: test6    Partition: 0    Leader: 2       Replicas: 2,0,1 Isr: 2,0,1
        Topic: test6    Partition: 1    Leader: 0       Replicas: 0,1,2 Isr: 0,1,2
        Topic: test6    Partition: 2    Leader: 1       Replicas: 1,2,0 Isr: 1,2,0
        Topic: test6    Partition: 3    Leader: 2       Replicas: 2,1,0 Isr: 2,1,0
        Topic: test6    Partition: 4    Leader: 0       Replicas: 0,2,1 Isr: 0,2,1
        Topic: test6    Partition: 5    Leader: 1       Replicas: 1,0,2 Isr: 1,0,2
```

```
#  bin/kafka-topics.sh  --list --zookeeper 172.17.32.127:2181
__consumer_offsets
kafka-monitor-topic
my-replicated-topic
my-replicated-topic2
my-replicated-topic3
my-replicated-topic4
test
test6
```
