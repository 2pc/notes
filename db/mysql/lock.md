
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

