### canal
[canal源码解析系列](http://kaimingwan.com/category/canal)   
[canal设计上的一些小分析](http://www.kaimingwan.com/post/canal/canalshe-ji-shang-de-xie-xiao-fen-xi?utm_source=tuicool&utm_medium=referral)   
[Canal & Otter 的一些注意事项和最佳实践](https://my.oschina.net/dxqr/blog/524795)   
[Maxwell's daemon, a mysql-to-json kafka producer](https://github.com/zendesk/maxwell)   
[maxwells-daemon.io](http://maxwells-daemon.io/)


### binlog

[]()   
[]()   
[深入解析MySQL replication协议](http://siddontang.com/2015/02/02/mysql-replication-protocol/)   
[同步 MySQL 数据到 Elasticsearch](http://www.jianshu.com/p/96c7858b580f)   
[mysql 实时协议解析 第二版 (基于kafka)](http://blog.csdn.net/hackerwin7/article/details/42713271)   
[Mysql日志抽取与解析](http://blog.csdn.net/hackerwin7/article/details/39896173)   
[使用canal进行mysql数据同步到Redis](http://blog.csdn.net/tb3039450/article/details/53928351)
[搭建并运行基于HA模式的canal](http://blog.csdn.net/hackerwin7/article/details/38044327)


###  字段类型处理

1. canal 定义在LogEvent类中（1-19 245-255）
2. maxwell  相关的主要在ColumnDef中，内部实际用的google项目的代码 类型主要MySQLConstants类（1-19，246-255）

### Mysql5.7

#### Your password does not satisfy the current policy requirements

```
mysql> SHOW VARIABLES LIKE 'validate_password%';
mysql> set global validate_password_policy=0;
mysql> set global validate_password_length=0;
```

### maxwell

#### package
 
```
git clone https://github.com/zendesk/maxwell
cd maxwell
make package
```
#### mysql user 

```
CREATE USER maxwell IDENTIFIED BY 'maxwell';
GRANT SELECT, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'maxwell'@'%';
GRANT ALL PRIVILEGES ON *.* TO 'maxwell'@'%'      
FLUSH PRIVILEGES;

####
GRANT ALL on maxwell.* to 'maxwell'@'%' identified by 'XXXXXX';
GRANT SELECT, REPLICATION CLIENT, REPLICATION SLAVE on *.* to 'maxwell'@'%';
```
#### STDOUT producer

```
bin/maxwell --user='maxwell' --password='XXXXXX' --host='127.0.0.1' --producer=stdout
```

#### Kafka producer

```
bin/maxwell --user='maxwell' --password='XXXXXX' --host='127.0.0.1' \
   --producer=kafka --kafka.bootstrap.servers=localhost:9092
```


