### KUDU 分区

除了可以动态添加和删除范围分区外，分区不能更改。

#### Range分区

bad case :  所有写入到最新分区	

nice :  添加新的分区，新的tablets

#### Hash 分区

bad case : tablets 可以增长到很大

nice : 在 tablets 上均匀分布


多级组合分区  hash+range/hash+hash 
