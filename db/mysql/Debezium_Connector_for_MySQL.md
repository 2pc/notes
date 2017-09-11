## 使用Debezium同步binlog至kafka

### 下载debezium解压

```
wget https://github.com/debezium/debezium/archive/v0.5.0.tar.gz
tar zxvf debezium-connector-mysql-0.5.0-plugin.tar.gz 
cd kafka_2.11-0.11.0.0
cp ../debezium-connector-mysql/*.jar ./libs/
```

### 配置mysql-connect

```
name=inventory-connector
connector.class=io.debezium.connector.mysql.MySqlConnector
database.hostname=172.28.3.170
database.port=3306
database.user=canal
database.password=canal
database.server.id=67777
database.server.name=hhhhhhh
database.whitelist=test
database.history.kafka.bootstrap.servers=127.0.0.1:9092
database.history.kafka.topic=dbhistory.fullfillment
include.schema.changes=true
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

扫了一眼 [issues](https://issues.jboss.org/projects/DBZ/issues)关于snapshot居然有个坑   
[MySQL snapshotter is not guaranteed to give a consistent snapshot](https://issues.jboss.org/projects/DBZ/issues/DBZ-210?filter=allopenissues)

参照mysqldump -single-transaction  -master-data修改snapshot逻辑  0.6版本才会fix

参考[mysqldump.c](https://bazaar.launchpad.net/~mysql/mysql-server/5.7/view/head:/client/mysqldump.c)文件

mysqldump  -single-transaction  -master-data的执行顺序

1.  执行FLUSH TABLES
2.  执行FLUSH TABLES WITH READ LOCK
3.  SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ
4.  SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
5.  SHOW MASTER STATUS
6.  UNLOCK TABLES

main主流程

```
if (!path)
    write_header(md_result_file, *argv);

  if (opt_slave_data && do_stop_slave_sql(mysql))
    goto err;

  if ((opt_lock_all_tables || opt_master_data ||
       (opt_single_transaction && flush_logs)) &&
      do_flush_tables_read_lock(mysql))
    goto err;

  /*
    Flush logs before starting transaction since
    this causes implicit commit starting mysql-5.5.
  */
  if (opt_lock_all_tables || opt_master_data ||
      (opt_single_transaction && flush_logs) ||
      opt_delete_master_logs)
  {
    if (flush_logs || opt_delete_master_logs)
    {
      if (mysql_refresh(mysql, REFRESH_LOG))
        goto err;
      verbose_msg("-- main : logs flushed successfully!\n");
    }

    /* Not anymore! That would not be sensible. */
    flush_logs= 0;
  }

  if (opt_delete_master_logs)
  {
    if (get_bin_log_name(mysql, bin_log_name, sizeof(bin_log_name)))
      goto err;
  }

  if (opt_single_transaction && start_transaction(mysql))
    goto err;

  /* Add 'STOP SLAVE to beginning of dump */
  if (opt_slave_apply && add_stop_slave())
    goto err;


  /* Process opt_set_gtid_purged and add SET @@GLOBAL.GTID_PURGED if required. */
  if (process_set_gtid_purged(mysql))
    goto err;


  if (opt_master_data && do_show_master_status(mysql))
    goto err;
  if (opt_slave_data && do_show_slave_status(mysql))
    goto err;
  if (opt_single_transaction && do_unlock_tables(mysql)) /* unlock but no commit! */
    goto err;

  if (opt_alltspcs)
    dump_all_tablespaces();

  if (opt_alldbs)
  {
    if (!opt_alltspcs && !opt_notspcs)
      dump_all_tablespaces();
    dump_all_databases();
  }
```

do_flush_tables_read_lock()里执行两次flush(FLUSH TABLES,FLUSH TABLES WITH READ LOCK)

```
static int do_flush_tables_read_lock(MYSQL *mysql_con)
{
  /*
    We do first a FLUSH TABLES. If a long update is running, the FLUSH TABLES
    will wait but will not stall the whole mysqld, and when the long update is
    done the FLUSH TABLES WITH READ LOCK will start and succeed quickly. So,
    FLUSH TABLES is to lower the probability of a stage where both mysqldump
    and most client connections are stalled. Of course, if a second long
    update starts between the two FLUSHes, we have that bad stall.
  */
  return
    ( mysql_query_with_error_report(mysql_con, 0, 
                                    ((opt_master_data != 0) ? 
                                        "FLUSH /*!40101 LOCAL */ TABLES" : 
                                        "FLUSH TABLES")) ||
      mysql_query_with_error_report(mysql_con, 0,
                                    "FLUSH TABLES WITH READ LOCK") );
}
```

 依据single_transaction transaction (SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ,START TRANSACTION /*!40100 WITH CONSISTENT SNAPSHOT */)
 
 ```
 static int start_transaction(MYSQL *mysql_con)
{
  verbose_msg("-- Starting transaction...\n");
  /*
    We use BEGIN for old servers. --single-transaction --master-data will fail
    on old servers, but that's ok as it was already silently broken (it didn't
    do a consistent read, so better tell people frankly, with the error).

    We want the first consistent read to be used for all tables to dump so we
    need the REPEATABLE READ level (not anything lower, for example READ
    COMMITTED would give one new consistent read per dumped table).
  */
  if ((mysql_get_server_version(mysql_con) < 40100) && opt_master_data)
  {
    fprintf(stderr, "-- %s: the combination of --single-transaction and "
            "--master-data requires a MySQL server version of at least 4.1 "
            "(current server's version is %s). %s\n",
            opt_force ? "Warning" : "Error",
            mysql_con->server_version ? mysql_con->server_version : "unknown",
            opt_force ? "Continuing due to --force, backup may not be "
            "consistent across all tables!" : "Aborting.");
    if (!opt_force)
      exit(EX_MYSQLERR);
  }

  return (mysql_query_with_error_report(mysql_con, 0,
                                        "SET SESSION TRANSACTION ISOLATION "
                                        "LEVEL REPEATABLE READ") ||
          mysql_query_with_error_report(mysql_con, 0,
                                        "START TRANSACTION "
                                        "/*!40100 WITH CONSISTENT SNAPSHOT */"));
}

 ```
do_show_master_status



