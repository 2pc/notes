

#### 全量备份

备份
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
