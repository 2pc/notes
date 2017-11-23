
数据准备，拷贝tpch的dbgen产生的100G数据到hdfs

```
hadoop fs -mkdir /tmp/tpch
hadoop fs -mkdir /tmp/tpch/customer
hadoop fs -mkdir /tmp/tpch/orders
hadoop fs -mkdir /tmp/tpch/part
hadoop fs -mkdir /tmp/tpch/partsupp
hadoop fs -mkdir /tmp/tpch/region
hadoop fs -mkdir /tmp/tpch/supplier

hadoop fs -copyFromLocal customer.tbl /tmp/tpch/customer/
hadoop fs -copyFromLocal lineitem.tbl /tmp/tpch/lineitem/
hadoop fs -copyFromLocal nation.tbl /tmp/tpch/nation/
hadoop fs -copyFromLocal orders.tbl /tmp/tpch/orders/
hadoop fs -copyFromLocal part.tbl /tmp/tpch/part/
hadoop fs -copyFromLocal partsupp.tbl /tmp/tpch/partsupp/
hadoop fs -copyFromLocal region.tbl /tmp/tpch/region/
hadoop fs -copyFromLocal supplier.tbl /tmp/tpch/supplier/
```

建立外部表

```

```
