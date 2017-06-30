#### go-mysql-elasticsearch

####    要求必须有PK 字段 desc (Key Pri)

```
go get github.com/siddontang/go-mysql-elasticsearch 
cd $GOPATH/src/github.com/siddontang/go-mysql-elasticsearch
bin/go-mysql-elasticsearch  
```

配置文件示例, 主要修改的配置项

>
1. source   指定要同步的表
2. rule 中schema对应要同步的数据库名，table对应数据库表明，index es中的indexName, type es中的type

```
my_addr = "172.28.3.26:3306"
my_user = "root"
my_pass = "root123"

es_addr = "172.28.3.158:9200"

[[source]]
schema = "test"
tables = ["work_order_flow"]

[[rule]]
schema = "test"
table = "work_order_flow"
index = "test"
type = "work_order_flow"

```

还可以指定同步的字段

```
[[rule]]
schema = "test"
table = "tfilter"
index = "test"
type = "tfilter"

# Only sync following columns
filter = ["id", "name"]

```

指定作为id的列

```
[[rule]]
id = ["id", "tag"]
```

