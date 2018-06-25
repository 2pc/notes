
起初发现show processlist找不到锁表的进程

然后用
```
show full processlist
```

再grep 似乎也不行

然后结合

```
show open tables where in_use>0;
```

还可以看下information_schema了

[ERROR 1205 (HY000): Lock wait timeout exceeded; try restarting transaction](https://www.cnblogs.com/topicjie/p/7323248.html)

这个是大致行数

```
MySQL [information_schema]> select TABLE_SCHEMA as dbname,TABLE_NAME tableName, TABLE_ROWS count from tables where TABLE_NAME = 'e001_t_act_activity_history' and TABLE_SCHEMA='afs';
+--------+-----------------------------+---------+
| dbname | tableName                   | count   |
+--------+-----------------------------+---------+
| afs    | e001_t_act_activity_history | 6326611 |
+--------+-----------------------------+---------+
1 row in set (0.01 sec)

MySQL [information_schema]>
```
PROCESSLIST表
```
MySQL [information_schema]> desc PROCESSLIST;
+---------------+---------------------+------+-----+---------+-------+
| Field         | Type                | Null | Key | Default | Extra |
+---------------+---------------------+------+-----+---------+-------+
| ID            | bigint(21) unsigned | NO   |     | 0       |       |
| USER          | varchar(32)         | NO   |     |         |       |
| HOST          | varchar(64)         | NO   |     |         |       |
| DB            | varchar(64)         | YES  |     | NULL    |       |
| COMMAND       | varchar(16)         | NO   |     |         |       |
| TIME          | int(7)              | NO   |     | 0       |       |
| STATE         | varchar(64)         | YES  |     | NULL    |       |
| INFO          | longtext            | YES  |     | NULL    |       |
| TIME_MS       | bigint(21)          | NO   |     | 0       |       |
| ROWS_SENT     | bigint(21) unsigned | NO   |     | 0       |       |
| ROWS_EXAMINED | bigint(21) unsigned | NO   |     | 0       |       |
+---------------+---------------------+------+-----+---------+-------+
11 rows in set (0.05 sec)
```

```
 select count(*) from PROCESSLIST where db='afs' and STATE='update'  \G;
```

The following statements are equivalent[23.16 The INFORMATION_SCHEMA PROCESSLIST Table](https://dev.mysql.com/doc/refman/8.0/en/processlist-table.html)
```
SELECT * FROM INFORMATION_SCHEMA.PROCESSLIST
SHOW FULL PROCESSLIST
```

查询执行sql的ip 的连接数量[关于查询mysql processlist的建议](http://blog.51cto.com/liuminkun/1685492)
```
select left(host,instr(host,':')-1) as ip,count(*) as num from information_schema.processlist group by ip order by num desc;
```
