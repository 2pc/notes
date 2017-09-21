
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
 查询impala
 
 
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

[Apache Kudu Quickstart](https://kudu.apache.org/docs/quickstart.html)
