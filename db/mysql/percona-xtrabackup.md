

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


[percona-xtrabackup](https://www.percona.com/doc/percona-xtrabackup/LATEST/innobackupex/innobackupex_script.html)   
[innobackupex_option_reference](https://www.percona.com/doc/percona-xtrabackup/LATEST/innobackupex/innobackupex_option_reference.html)   
[xbk_option_reference](https://www.percona.com/doc/percona-xtrabackup/LATEST/xtrabackup_bin/xbk_option_reference.html)   
[xtrabackup备份指定的库或者表与还原](http://qubaoquan.blog.51cto.com/1246748/1107780)
