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
### 看到如下日志

```
[2017-08-30 09:11:38,627] INFO Starting snapshot for jdbc:mysql://127.0.0.1:3306/?useInformationSchema=true&nullCatalogMeansCurrent=false&useSSL=false&useUnicode=true&characterEncoding=UTF-8&characterSetResults=UTF-8&zeroDateTimeBehavior=convertToNull with user 'canal' (io.debezium.connector.mysql.SnapshotReader:139)
[2017-08-30 09:11:38,631] INFO Snapshot is using user 'canal' with these MySQL grants: (io.debezium.connector.mysql.SnapshotReader:670)
[2017-08-30 09:11:38,632] INFO  GRANT ALL PRIVILEGES ON *.* TO 'canal'@'%' IDENTIFIED BY PASSWORD '*E3619321C1A937C46A0D8BD1DAC39F93B27D4458' (io.debezium.connector.mysql.SnapshotReader:671)
[2017-08-30 09:11:38,632] INFO MySQL server variables related to change data capture: (io.debezium.connector.mysql.SnapshotReader:643)
[2017-08-30 09:11:38,644] INFO  binlog_cache_size                             = 32768                                         (io.debezium.connector.mysql.SnapshotReader:646)
[2017-08-30 09:11:38,644] INFO  binlog_direct_non_transactional_updates       = OFF                                           (io.debezium.connector.mysql.SnapshotReader:646)
[2017-08-30 09:11:38,644] INFO  binlog_format                                 = ROW                                           (io.debezium.connector.mysql.SnapshotReader:646)
[2017-08-30 09:11:38,644] INFO  character_set_client                          = utf8                                          (io.debezium.connector.mysql.SnapshotReader:646)
[2017-08-30 09:11:38,644] INFO  character_set_connection                      = utf8                                          (io.debezium.connector.mysql.SnapshotReader:646)
[2017-08-30 09:11:38,644] INFO  character_set_database                        = utf8                                          (io.debezium.connector.mysql.SnapshotReader:646)
[2017-08-30 09:11:38,644] INFO  character_set_filesystem                      = binary                                        (io.debezium.connector.mysql.SnapshotReader:646)
[2017-08-30 09:11:38,645] INFO  character_set_results                         = utf8                                          (io.debezium.connector.mysql.SnapshotReader:646)
[2017-08-30 09:11:38,645] INFO  character_set_server                          = utf8                                          (io.debezium.connector.mysql.SnapshotReader:646)
[2017-08-30 09:11:38,645] INFO  character_set_system                          = utf8                                          (io.debezium.connector.mysql.SnapshotReader:646)
[2017-08-30 09:11:38,645] INFO  character_sets_dir                            = /usr/share/mysql/charsets/                    (io.debezium.connector.mysql.SnapshotReader:646)
[2017-08-30 09:11:38,645] INFO  collation_connection                          = utf8_unicode_ci                               (io.debezium.connector.mysql.SnapshotReader:646)
[2017-08-30 09:11:38,645] INFO  collation_database                            = utf8_unicode_ci                               (io.debezium.connector.mysql.SnapshotReader:646)
[2017-08-30 09:11:38,645] INFO  collation_server                              = utf8_unicode_ci                               (io.debezium.connector.mysql.SnapshotReader:646)
[2017-08-30 09:11:38,645] INFO  innodb_locks_unsafe_for_binlog                = OFF                                           (io.debezium.connector.mysql.SnapshotReader:646)
[2017-08-30 09:11:38,645] INFO  max_binlog_cache_size                         = 18446744073709547520                          (io.debezium.connector.mysql.SnapshotReader:646)
[2017-08-30 09:11:38,645] INFO  max_binlog_size                               = 1073741824                                    (io.debezium.connector.mysql.SnapshotReader:646)
[2017-08-30 09:11:38,646] INFO  protocol_version                              = 10                                            (io.debezium.connector.mysql.SnapshotReader:646)
[2017-08-30 09:11:38,646] INFO  sync_binlog                                   = 0                                             (io.debezium.connector.mysql.SnapshotReader:646)
[2017-08-30 09:11:38,646] INFO  system_time_zone                              = CST                                           (io.debezium.connector.mysql.SnapshotReader:646)
[2017-08-30 09:11:38,646] INFO  time_zone                                     = SYSTEM                                        (io.debezium.connector.mysql.SnapshotReader:646)
[2017-08-30 09:11:38,646] INFO  tx_isolation                                  = REPEATABLE-READ                               (io.debezium.connector.mysql.SnapshotReader:646)
[2017-08-30 09:11:38,646] INFO  version                                       = 5.1.73-log                                    (io.debezium.connector.mysql.SnapshotReader:646)
[2017-08-30 09:11:38,646] INFO  version_comment                               = Source distribution                           (io.debezium.connector.mysql.SnapshotReader:646)
[2017-08-30 09:11:38,646] INFO  version_compile_machine                       = x86_64                                        (io.debezium.connector.mysql.SnapshotReader:646)
[2017-08-30 09:11:38,646] INFO  version_compile_os                            = redhat-linux-gnu                              (io.debezium.connector.mysql.SnapshotReader:646)
[2017-08-30 09:11:38,646] INFO Step 0: disabling autocommit and enabling repeatable read transactions (io.debezium.connector.mysql.SnapshotReader:162)
[2017-08-30 09:11:38,650] INFO Step 1: start transaction with consistent snapshot (io.debezium.connector.mysql.SnapshotReader:181)
[2017-08-30 09:11:38,653] INFO Step 2: flush and obtain global read lock to prevent writes to database (io.debezium.connector.mysql.SnapshotReader:194)
[2017-08-30 09:15:20,490] INFO Step 3: read binlog position of MySQL master (io.debezium.connector.mysql.SnapshotReader:579)
[2017-08-30 09:15:20,528] INFO   using binlog 'mysql-bin.000019' at position '16889' (io.debezium.connector.mysql.SnapshotReader:594)
[2017-08-30 09:15:20,529] INFO Step 4: read list of available databases (io.debezium.connector.mysql.SnapshotReader:219)
[2017-08-30 09:15:20,579] INFO   list of available databases is: [information_schema, mysql, oml, otter, retl, test, test2] (io.debezium.connector.mysql.SnapshotReader:227)
[2017-08-30 09:15:20,579] INFO Step 5: read list of available tables in each database (io.debezium.connector.mysql.SnapshotReader:236)


[2017-08-30 09:15:21,222] INFO Step 7: releasing global read lock to enable MySQL writes (io.debezium.connector.mysql.SnapshotReader:362)
[2017-08-30 09:15:21,242] INFO Step 7: blocked writes to MySQL for a total of 00:00:00.732 (io.debezium.connector.mysql.SnapshotReader:368)
[2017-08-30 09:15:21,248] INFO Step 8: scanning contents of 4 tables while still in transaction (io.debezium.connector.mysql.SnapshotReader:383)
[2017-08-30 09:15:21,347] INFO Step 8: - scanning table 'test.xdual' (1 of 4 tables) (io.debezium.connector.mysq
```
