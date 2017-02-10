
 ```
 bin/kafka-topics.sh  --list --zookeeper 172.17.32.127:2181
  bin/kafka-producer-perf-test.sh --num-records 100000 --record-size 10000 --topic test6 --throughput 1000000 --producer-props bootstrap.servers=172.17.32.128:9092
 1070  bin/kafka-producer-perf-test.sh --num-records 100000 --record-size 2000 --topic test6 --throughput 1000000 --producer-props bootstrap.servers=172.17.32.128:9092
 1071  bin/kafka-producer-perf-test.sh --num-records 1000000 --record-size 5000 --topic test6 --throughput 1000000 --producer-props bootstrap.servers=172.17.32.128:9092
 ```
 
 >
 1. --num-records 总消息记录数
 2. --record-size 消息大小 单位bytes
 
 
 
