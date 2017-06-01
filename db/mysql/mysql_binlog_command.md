在mac环境下，只需要以下简单的设置就可以查看了 

```
mysql>set global general_log=on;  
mysql> show variables like 'general_log_file'

```

在Mac OS X 中默认是没有my.cnf 文件，可以拷贝如下文件夹里的

```
/usr/local/mysql/support-files/
```

```
mysql> show variables like 'general_log_file';
mysql> show binlog events;
```
### 登录到mysql查看binlog
只查看第一个binlog文件的内容

```
show binlog events;
```
查看指定binlog文件的内容

```
show binlog events in 'mysql-bin.000002';
```
查看当前正在写入的binlog文件

```
show master status\G
```
获取binlog文件列表

```
show binary logs;
```

### 用mysqlbinlog工具查看
注意:
>
1. 不要查看当前正在写入的binlog文件
2. 不要加--force参数强制访问
3. 如果binlog格式是行模式的,请加 -vv参数

#### 本地查看
基于开始/结束时间

```
mysqlbinlog --start-datetime='2013-09-10 00:00:00' --stop-datetime='2013-09-10 01:01:01' -d 库名 二进制文件
```
基于pos值

```
mysqlbinlog --start-postion=107 --stop-position=1000 -d 库名 二进制文件
```
转换为可读文本

```
mysqlbinlog –base64-output=DECODE-ROWS -v -d 库名 二进制文件
```
#### 远程查看
指定开始/结束时间,并把结果重定向到本地t.binlog文件中.

```
mysqlbinlog -u username -p password -hl-db1.dba.beta.cn6.qunar.com -P3306 \
--read-from-remote-server --start-datetime='2013-09-10 23:00:00' --stop-datetime='2013-09-10 23:30:00' mysql-bin.000001 > t.binlog
``

