### [Primary keys](http://kudu.apache.org/docs/known_issues.html#_primary_keys)

1. 一旦表创建完成，主键不可更改，如果想选择一个新的逐渐，需要先删除表，在重新建立表
2. 构成主键的列必须位于schema的最前面
3. 不能通过update修改主键的值，需要修改主键，只能通过先删除后插入
4. DOUBLE, FLOAT, or BOOL类型的列不能被定义为主键，另外所有构成主键的列不允许为NULL
5. 不支持自动生成主键
6. 符合主键组成的单个cell,最大16k

### [Columns](http://kudu.apache.org/docs/known_issues.html#_columns)

1. DECIMAL, CHAR, VARCHAR, DATE, 和复杂类型像ARRAY都不支持
2. 列的类型与是否可为null(nullability)不能通过alter table修改
3. 最多300列

### [Tables](http://kudu.apache.org/docs/known_issues.html#_tables)

1. 副本只能是奇数(odd)个，最多为7个副本
2. 副本在创建表时设置了之后，不能在修改

### [Cells (individual values)](http://kudu.apache.org/docs/known_issues.html#_cells_individual_values)

编码与压缩之前，单个cell最大64kb,

### [Other usage limitations](http://kudu.apache.org/docs/known_issues.html#_other_usage_limitations)

1. Kudu 主要用于分析场景。如果单行包含多个千字节的数据，则可能遇到问题。
2. 不支持二级索引
3. 不支持多行事务
4. 不支持外键
5. 列名表名必须是合法的UTF-8字符，最多256字符
6. Dropping a column does not immediately reclaim space（立即回收空间）. Compaction must run first.
7. There is no way to run compaction manually(手工，手动执行compaction), but dropping the table will reclaim the space immediately.

### [Partitioning Limitations](http://kudu.apache.org/docs/known_issues.html#_partitioning_limitations)

1. Tables必须通过简单活着组合主键手动预分割成tablets，不支持自动分割；创建过的表Range partitions可以更改。
2. Tables里已经存在的数据不能再重新分区， 一种解决方案（as a workaroud）是：创建一个使用新的分区的新表，再把旧数据插入新的表
3. 大多数副本不可用时，需要手工介入(manual intervention)恢复

### [Cluster management](http://kudu.apache.org/docs/known_issues.html#_cluster_management)

1. 不支持机架感知
2. 不支持多数据中心
3. 不支持滚动重启

### [Server management](http://kudu.apache.org/docs/known_issues.html#_server_management)


1. 300 columns
2. 单个Cells大小64k,组合key 16k
3. 
4.
5. 



[kudu-#known-limitations](https://kudu.apache.org/docs/schema_design.html#known-limitations)   
[kudu-known_issues](http://kudu.apache.org/docs/known_issues.html)
