
准备数据

```
$ wget http://kudu-sample-data.s3.amazonaws.com/sfmtaAVLRawData01012013.csv.gz
$ hdfs dfs -mkdir /sfmta
$ zcat sfmtaAVLRawData01012013.csv.gz | tr -d '\r' | hadoop fs -put - /sfmta/data.csv
```

创建 EXTERNAL TABLE

```
CREATE EXTERNAL TABLE sfmta_raw (
  revision int,
  report_time string,
  vehicle_tag int,
  longitude float,
  latitude float,
  speed float,
  heading float
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LOCATION '/sfmta/'
TBLPROPERTIES ('skip.header.line.count'='1');
```
 查询impala表
 
```
[elasticsearch159:21000] > select count(*) from sfmta_raw;
Query: select count(*) from sfmta_raw
Query submitted at: 2017-09-20 23:07:27 (Coordinator: http://elasticsearch159:25000)
Query progress can be monitored at: http://elasticsearch159:25000/query_plan?query_id=d94ff49b1120b484:13e50eb400000000
+----------+
| count(*) |
+----------+
| 859086   |
+----------+
Fetched 1 row(s) in 0.13s
```
 
 创建kudu表
 
 ```
CREATE TABLE sfmta                              
PRIMARY KEY (report_time, vehicle_tag)                               
PARTITION BY HASH(report_time) PARTITIONS 8
STORED AS KUDU TBLPROPERTIES ('kudu.num_tablet_replicas' = '1')
AS SELECT  
  UNIX_TIMESTAMP(report_time,  'MM/dd/yyyy HH:mm:ss') AS report_time,
  vehicle_tag,
  longitude,   
  latitude,
  speed,
  heading
FROM sfmta_raw;
```

查询kudu表

```
[elasticsearch159:21000] > SELECT * FROM sfmta ORDER BY speed DESC LIMIT 1;
Query: select * FROM sfmta ORDER BY speed DESC LIMIT 1
Query submitted at: 2017-09-20 23:08:40 (Coordinator: http://elasticsearch159:25000)
Query progress can be monitored at: http://elasticsearch159:25000/query_plan?query_id=ce4d897e24949109:8512db7100000000
+-------------+-------------+--------------------+-------------------+-------------------+---------+
| report_time | vehicle_tag | longitude          | latitude          | speed             | heading |
+-------------+-------------+--------------------+-------------------+-------------------+---------+
| 1357022016  | 8522        | -122.4538803100586 | 37.74539184570312 | 65.27799987792969 | 24      |
+-------------+-------------+--------------------+-------------------+-------------------+---------+
Fetched 1 row(s) in 0.27s
```

删除

```
[elasticsearch159:21000] > DELETE FROM sfmta_raw WHERE vehicle_tag = 8522;           
Query: delete FROM sfmta_raw WHERE vehicle_tag = 8522
Query submitted at: 2017-09-20 23:11:27 (Coordinator: http://elasticsearch159:25000)
ERROR: AnalysisException: Impala does not support modifying a non-Kudu table: default.sfmta_raw
[elasticsearch159:21000] > DELETE FROM sfmta WHERE vehicle_tag = 8522;    
Query: delete FROM sfmta WHERE vehicle_tag = 8522
Query submitted at: 2017-09-20 23:12:04 (Coordinator: http://elasticsearch159:25000)
Query progress can be monitored at: http://elasticsearch159:25000/query_plan?query_id=49475535cb05a6c0:d052dc9900000000
Modified 1759 row(s), 0 row error(s) in 0.26s
```


[Apache Kudu Quickstart](https://kudu.apache.org/docs/quickstart.html)
