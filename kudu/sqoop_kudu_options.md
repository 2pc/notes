
kudu 配置项
```
kudu.table
kudu.create.table
kudu.master.url
kudu.key.cols
kudu.partition.cols
kudu.partition.buckets
kudu.replica.count
```

sqoop to kudu

```
 sqoop import  --connect jdbc:mysql://172.28.3.169/test2 --username canal -password canal --table test -m 1  --kudu-master-url 172.28.3.158 --kudu-create-table --kudu-table test3 --kudu-key-cols ID --kudu-partition-cols ID --kudu-partition-buckets 2 --kudu-replica-count 1
```
坑
1. 最大300列
impala2.8    时间类型timestamp,还不支持UNIXTIME_MICROS,  需要升级到cloudera manager 5.12.x
