

### 全量备份整个DB

全量三步即可[The Backup Cycle - Full Backups](https://www.percona.com/doc/percona-xtrabackup/2.4/innobackupex/innobackupex_script.html)   
1. [Creating a Backup with innobackupex](https://www.percona.com/doc/percona-xtrabackup/2.4/innobackupex/creating_a_backup_ibk.html)   
2. [Preparing a Full Backup with innobackupex](https://www.percona.com/doc/percona-xtrabackup/2.4/innobackupex/preparing_a_backup_ibk.html)   
3. [Restoring a Full Backup with innobackupex](https://www.percona.com/doc/percona-xtrabackup/2.4/innobackupex/restoring_a_backup_ibk.html)

```
innobackupex   --user=root  --password=123456 ./full
mv /var/lib/mysql /var/lib/mysqlbak2
service mysqld stop
# 尝试删除所有的表，最后只剩下information_schema提示没权限删除
rm -rf /var/lib/mysql
innobackupex --apply-log full/2017-08-25_15-10-50/
innobackupex --copy-back  full/2017-08-25_15-10-50/
chown -R mysql:mysql  /var/lib/mysql
service mysqld start
```

### 备份与还原单个库
```
innobackupex  --user=root  --password=123456  --databases=oel    ./full
```
prepare

```
innobackupex --apply-log  ./full/2017-08-25_14-14-03/
```

还原一个数据库数据库

```
service mysqld stop

rm -rf /var/lib/mysql/ibdata1 
rm -rf /var/lib/mysql/ib_logfile1
rm -rf /var/lib/mysql/ib_logfile0

cp full/2017-08-25_14-14-03/ibdata1 /var/lib/mysql
cp full/2017-08-25_14-14-03/ib_logfile0  /var/lib/mysql
cp full/2017-08-25_14-14-03/ib_logfile1  /var/lib/mysql
cp -rf full/2017-08-25_14-14-03/oel /var/lib/mysql/oel

chown -R mysql:mysql  /var/lib/mysql
service mysqld restart
```

### 备份还原多个库
多个表, --databases中间空格隔开.

```
innobackupex  --user=root  --password=123456  --databases="oel test2"  ./full

mysql>drop database oel;
mysql>drop database test2;
service mysqld stop 

innobackupex --apply-log  full/2017-08-25_14-46-53/
rm -rf /var/lib/mysql/ibdata1  
rm -rf /var/lib/mysql/ib_logfile0 
rm -rf /var/lib/mysql/ib_logfile1 
cp  full/2017-08-25_14-46-53/ibdata1 /var/lib/mysql
cp full/2017-08-25_14-46-53/ib_logfile0 /var/lib/mysql
cp full/2017-08-25_14-46-53/ib_logfile1 /var/lib/mysql
cp full/2017-08-25_14-46-53/oel /var/lib/mysql/oel
cp -rf full/2017-08-25_14-46-53/oel /var/lib/mysql/oel
cp -rf full/2017-08-25_14-46-53/test2 /var/lib/mysql/test2

chown -R mysql:mysql  /var/lib/mysql
service mysqld start 
```

另外多个数据库, 使用文件形式没生效，会报错xtrabackup: name `./databases.txt` is not valid.

```
# cat databases.txt 
oel
test2.xdual
```

[percona-xtrabackup](https://www.percona.com/doc/percona-xtrabackup/LATEST/innobackupex/innobackupex_script.html)   
[innobackupex_option_reference](https://www.percona.com/doc/percona-xtrabackup/LATEST/innobackupex/innobackupex_option_reference.html)   
[xbk_option_reference](https://www.percona.com/doc/percona-xtrabackup/LATEST/xtrabackup_bin/xbk_option_reference.html)   
[xtrabackup备份指定的库或者表与还原](http://qubaoquan.blog.51cto.com/1246748/1107780)
[使用Percona Xtrabackup对数据库进行部分备份](http://www.ttlsa.com/mysql/the-database-part-of-backup-using-percona-xtrabackup/)
