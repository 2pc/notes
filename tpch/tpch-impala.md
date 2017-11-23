
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
lineitem
```
Create external table lineitem (L_ORDERKEY INT, L_PARTKEY INT, L_SUPPKEY INT, L_LINENUMBER INT, L_QUANTITY DOUBLE, L_EXTENDEDPRICE DOUBLE, L_DISCOUNT DOUBLE, L_TAX DOUBLE, L_RETURNFLAG STRING, L_LINESTATUS STRING, L_SHIPDATE STRING, L_COMMITDATE STRING, L_RECEIPTDATE STRING, L_SHIPINSTRUCT STRING, L_SHIPMODE STRING, L_COMMENT STRING) ROW FORMAT DELIMITED FIELDS TERMINATED BY '|' STORED AS TEXTFILE LOCATION '/tmp/tpch/lineitem';
```

orders
```
create external table orders (O_ORDERKEY INT, O_CUSTKEY INT, O_ORDERSTATUS STRING, O_TOTALPRICE DOUBLE, O_ORDERDATE STRING, O_ORDERPRIORITY STRING, O_CLERK STRING, O_SHIPPRIORITY INT, O_COMMENT STRING) ROW FORMAT DELIMITED FIELDS TERMINATED BY '|' STORED AS TEXTFILE LOCATION /tmp/tpch/orders';
```

customer
```
create external table customer (C_CUSTKEY INT, C_NAME STRING, C_ADDRESS STRING, C_NATIONKEY INT, C_PHONE STRING, C_ACCTBAL DOUBLE, C_MKTSEGMENT STRING, C_COMMENT STRING) ROW FORMAT DELIMITED FIELDS TERMINATED BY '|' STORED AS TEXTFILE LOCATION '/tmp/tpch/customer';
```

nation
```
create external table nation (N_NATIONKEY INT, N_NAME STRING, N_REGIONKEY INT, N_COMMENT STRING) ROW FORMAT DELIMITED FIELDS TERMINATED BY '|' STORED AS TEXTFILE LOCATION '/tmp/tpch/nation';
```

supplier
```
create external table supplier (S_SUPPKEY INT, S_NAME STRING, S_ADDRESS STRING, S_NATIONKEY INT, S_PHONE STRING, S_ACCTBAL DOUBLE, S_COMMENT STRING) ROW FORMAT DELIMITED FIELDS TERMINATED BY '|' STORED AS TEXTFILE LOCATION '/tmp/tpch/supplier';
```

partsupp
```
create external table partsupp (PS_PARTKEY INT, PS_SUPPKEY INT, PS_AVAILQTY INT, PS_SUPPLYCOST DOUBLE, PS_COMMENT STRING) ROW FORMAT DELIMITED FIELDS TERMINATED BY '|' STORED AS TEXTFILE LOCATION'/tmp/tpch/partsupp';
```

part
```
create external table part (P_PARTKEY INT, P_NAME STRING, P_MFGR STRING, P_BRAND STRING, P_TYPE STRING, P_SIZE INT, P_CONTAINER STRING, P_RETAILPRICE DOUBLE, P_COMMENT STRING) ROW FORMAT DELIMITED FIELDS TERMINATED BY '|' STORED AS TEXTFILE LOCATION '/tmp/tpch/part';
```

orders
```
create external table orders (O_ORDERKEY INT, O_CUSTKEY INT, O_ORDERSTATUS STRING, O_TOTALPRICE DOUBLE, O_ORDERDATE STRING, O_ORDERPRIORITY STRING, O_CLERK STRING, O_SHIPPRIORITY INT, O_COMMENT STRING) ROW FORMAT DELIMITED FIELDS TERMINATED BY '|' STORED AS TEXTFILE LOCATION '/tmp/tpch/orders';
```

region
```
create external table region (R_REGIONKEY INT, R_NAME STRING, R_COMMENT STRING) ROW FORMAT DELIMITED FIELDS TERMINATED BY '|' STORED AS TEXTFILE LOCATION '/tmp/tpch/region';

```
