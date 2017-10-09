### check schema 

```
bin/checker  -host 172.28.3.159 -port 3306 -user canal -password canal dbname tbname
```

### syncer 增量

#### meta 

```
# cat syncer.meta 
binlog-name = "mysql-bin.000005"
binlog-pos = 17376
binlog-gtid = ""
```
#### 配置文件   

指定test库的两个表tidb,xdual5同步,sharding没用过

 ```
 # cat config.toml 
ilog-level = "info"

server-id = 101

meta = "./syncer.meta"
worker-count = 1
batch = 1

status-addr = ":10081"

skip-sqls = ["ALTER USER", "CREATE USER"]



[[replicate-do-table]]
db-name ="test"
tbl-name = "xdual5"

[[replicate-do-table]]
db-name ="test"
tbl-name = "tidb"


[from]
host = "172.28.3.159"
user = "canal"
password = "canal"
port = 3306

[to]
host = "172.28.3.131"
user = "canal"
password = "canal"
port = 4000
 ```
 
同步

```
./bin/syncer -config config.toml
```

skip-sqls: 基于前缀匹配？
 
