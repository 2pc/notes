

#### 需要配置advertised.listeners=PLAINTEXT://host:9092

```
 Error for partition [my-replicated-topic2,0] to broker 2:org.apache.kafka.common.errors.UnknownServerException: The server experienced an unexpected error when processing the request (kafka.server.ReplicaFetcherThread)
[2017-02-08 22:33:47,096] ERROR [KafkaApi-1] Error when handling request Name: FetchRequest; Version: 3; CorrelationId: 263; ClientId: ReplicaFetcherThread-0-2; ReplicaId: 1; MaxWait: 500 ms; MinBytes: 1 bytes; MaxBytes:10485760 bytes; RequestInfo: ([my-replicated-topic2,0],PartitionFetchInfo(0,1048576)) (kafka.server.KafkaApis)
kafka.common.KafkaException: Should not set log end offset on partition [my-replicated-topic2,0]'s local replica 1
        at kafka.cluster.Replica.logEndOffset_$eq(Replica.scala:66)
```

否则注册的broker的host可能都是hostname 

```
[zk: localhost:2181(CONNECTED) 24] get  /brokers/ids/0
{"jmx_port":-1,"timestamp":"1486534914916","endpoints":["PLAINTEXT://localhost:9092"],"host":"localhost","version":3,"port":9092}
cZxid = 0x254c
ctime = Wed Feb 08 14:21:54 CST 2017
mZxid = 0x254c
mtime = Wed Feb 08 14:21:54 CST 2017
pZxid = 0x254c
cversion = 0
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x15746f92ec30033
dataLength = 129
numChildren = 0
[zk: localhost:2181(CONNECTED) 25] get  /brokers/ids/1
{"jmx_port":-1,"timestamp":"1486563591616","endpoints":["PLAINTEXT://localhost:9092"],"host":"localhost","version":3,"port":9092}
cZxid = 0x253d
ctime = Wed Feb 08 14:17:26 CST 2017
mZxid = 0x253d
mtime = Wed Feb 08 14:17:26 CST 2017
pZxid = 0x253d
cversion = 0
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x15746f92ec3002f
dataLength = 129
numChildren = 0
[zk: localhost:2181(CONNECTED) 26] get  /brokers/ids/2
{"jmx_port":-1,"timestamp":"1486564105086","endpoints":["PLAINTEXT://localhost:9092"],"host":"localhost","version":3,"port":9092}
cZxid = 0x2554
ctime = Wed Feb 08 14:25:26 CST 2017
mZxid = 0x2554
mtime = Wed Feb 08 14:25:26 CST 2017
pZxid = 0x2554
cversion = 0
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x15746f92ec30034
dataLength = 129
numChildren = 0
[zk: localhost:2181(CONNECTED) 27]
```
