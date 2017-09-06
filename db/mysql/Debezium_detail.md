
# Debezium 详细设计

###  topic设计

1. 每个表对应一个topic,topic的格式：serverName.databaseName.tableName，其中serverName是配置项“database.server.name”的值
2. Schema change topic: serverName，这个值也是配置项“database.server.name”
3. database history topic：这个值是配置项“database.history.kafka.topic”的值

### key设计

key基于primary或者unique key约束，

