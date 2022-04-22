
kudu 配置项
```
kudu.table
kudu.create.table
kudu.master.url
kudu.key.cols
kudu.partition.cols
kudu.partition.buckets
kudu.replica.count

--kudu-master-url 172.28.3.158 
--kudu-create-table 
--kudu-table test3 
--kudu-key-cols ID (多个key用‘,’隔开)
--kudu-partition-cols ID (多个partition key用‘,’隔开)
--kudu-partition-buckets 2 
```

kudu Type, 需要升级cloudera manager 5.12.x，impala要支持包含unixtime_micros类型的列的kudu外表，

```
INT8(DataType.INT8, "int8"),
INT16(DataType.INT16, "int16"),
INT32(DataType.INT32, "int32"),
INT64(DataType.INT64, "int64"),
BINARY(DataType.BINARY, "binary"),
STRING(DataType.STRING, "string"),
BOOL(DataType.BOOL, "bool"),
FLOAT(DataType.FLOAT, "float"),
DOUBLE(DataType.DOUBLE, "double"),
UNIXTIME_MICROS(DataType.UNIXTIME_MICROS, "unixtime_micros");
```

sqoop to kudu

```
 sqoop import  --connect jdbc:mysql://172.28.3.169/test2 --username canal -password canal --table test -m 1  --kudu-master-url 172.28.3.158 --kudu-create-table --kudu-table test3 --kudu-key-cols ID --kudu-partition-cols ID --kudu-partition-buckets 2 --kudu-replica-count 1
```
坑
1. 最大300列
impala2.8    时间类型timestamp,还不支持UNIXTIME_MICROS,  需要升级到cloudera manager 5.12.x
