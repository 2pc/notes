###  配置项说明
#### canal.consumer.destination=example
描述：canal server destination
示例：canal.consumer.destination=example

#### canal.consumer.zkserver
描述：canal server的zk地址
示例：canal.consumer.zkserver=172.28.3.169:2181,172.28.3.170:2181

#### canal.kafka.server
描述：canal 接收canal消息的kafka地址
示例：canal.kafka.server=172.28.3.169:9092,172.28.3.170:9092

#### canal.kafka.topic
描述：接受canal消息的topic
示例：canal.kafka.topic=canal
当配置为database或者table时，表示依据database或者table名动态生成topic

#### canal.producer.mode
描述： canal  的方式，kafka／local  kafka或者本地日志方式
示例：canal.producer.mode=kafka

#### canal client filter
描述：需要过滤的数据(数据库，表)
示例：canal.consumer.filter=test\.xdual,test\.xdual1,

#### canal.data.format
描述：是否保留canal 原有格式，
示例：canal.data.format=canal

#### canal.kafka.key.type
描述：patition 对应的key
示例：canal.kafka.key.type=id
1.  当为database,table 表示按database,table 分区
2.  当为pks 时，所有主键组合成 分区的key
3.   其他，表示指定pk字段分区，多个 主键用","分割
