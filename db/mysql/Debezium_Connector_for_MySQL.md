## 使用Debezium同步binlog至少kafka

### 下载debezium解压

```
wget https://github.com/debezium/debezium/archive/v0.5.0.tar.gz
tar zxvf debezium-connector-mysql-0.5.0-plugin.tar.gz 
cd kafka_2.11-0.11.0.0
cp ../debezium-connector-mysql/*.jar ./libs/
```

### 配置mysql-connect

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
include.schema.changes=tr
```

### standalone模式启动kafka-connect

```
 bin/connect-standalone.sh  config/connect-standalone.properties  mysql.properties 
```
