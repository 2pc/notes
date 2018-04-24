### canal
[canal源码解析系列](http://kaimingwan.com/category/canal)   
[canal设计上的一些小分析](http://www.kaimingwan.com/post/canal/canalshe-ji-shang-de-xie-xiao-fen-xi?utm_source=tuicool&utm_medium=referral)   
[Canal & Otter 的一些注意事项和最佳实践](https://my.oschina.net/dxqr/blog/524795)   
[Maxwell's daemon, a mysql-to-json kafka producer](https://github.com/zendesk/maxwell)   
[maxwells-daemon.io](http://maxwells-daemon.io/)   
[实时抓取MySQL的更新数据到Hadoop](http://bigdatadecode.club/%E5%AE%9E%E6%97%B6%E6%8A%93%E5%8F%96MySQL%E7%9A%84%E6%9B%B4%E6%96%B0%E6%95%B0%E6%8D%AE%E5%88%B0Hadoop.html)   
[ElasticSearch + Canal 开发千万级的实时搜索系统](http://www.cnblogs.com/chanshuyi/p/6669006.html)   
[Elasticsearch环境搭建和river数据导入（四）](http://xargin.com/elasticsearchhuan-jing-da-jian-he-rivershu-ju-dao-ru-si/)   
[binlog-river-es](https://github.com/cch123/binlog-river-es/blob/master/binlog_ops.go)   
[如何基于日志，同步实现数据的一致性和实时抽取?](http://weibo.com/ttarticle/p/show?id=2309351002704055141002156936)
[canal读取mysql的binlog实时同步数据到kudu的数据异构方案 ](https://blog.csdn.net/qq_20641565/article/details/79193642) 

```
格式如下：（参考了宜信的dbus方案），其中payload里面是每条数据的具体信息，schema的fields是每个字段的元信息，其中ums_id（该ID是为了防止重复操作，消费端可能重复消费一条数据多次或者某些原因可能会多次操作，ums_id是对单个库的一个操作（增删改这些）来说是唯一且不变的，到时候消费端消费数据后会先根据id查看库中是否有这个ID如果库中的ums_id小于当前这个ums_id则操作，相反就说明该操作已经执行过就丢弃，并且如果存在真实删除数据，kudu端口也只能做逻辑删除，因为如果kudu端删除了，那么以前的数据重复过来了发现没有该ID ，那消费端那边又会去执行一次）是binlog名字（比如:mysql-bin.000010）加上该条数据的偏移量（其中偏移量前面补0暂时定为偏移量长度为30，比如下面的00000000000000090222）作为单个数据库每个操作的唯一标识，ums_ts就是这条语句执行的具体时间戳
```

### binlog

[MySQL的binlog数据如何查看](http://blog.chinaunix.net/uid-16844903-id-3896711.html)   
[mysql 利用binlog增量备份，还原实例](http://blog.51yip.com/mysql/1042.html)   
[深入解析MySQL replication协议](http://siddontang.com/2015/02/02/mysql-replication-protocol/)   
[同步 MySQL 数据到 Elasticsearch](http://www.jianshu.com/p/96c7858b580f)   
[mysql 实时协议解析 第二版 (基于kafka)](http://blog.csdn.net/hackerwin7/article/details/42713271)   
[Mysql日志抽取与解析](http://blog.csdn.net/hackerwin7/article/details/39896173)   
[使用canal进行mysql数据同步到Redis](http://blog.csdn.net/tb3039450/article/details/53928351)   
[搭建并运行基于HA模式的canal](http://blog.csdn.net/hackerwin7/article/details/38044327)   
[canal源码分析系列——ErosaConnection分析](https://my.oschina.net/ywbrj042/blog/646389)   
[深入理解otter](https://wenku.baidu.com/view/930a5723227916888586d70b.html)


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


