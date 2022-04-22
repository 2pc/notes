[]()


### Split-brain(脑裂)问题

可依据有资格参加选举的节点数，设置法定票数属性的值，来避免爆裂的发生

```
discovery.zen.minimum_master_nodes = int(# of master eligible nodes/2)+1
```

[Elasticsearch 2.x 升级经验](http://www.chepoo.com/elasticsearch-2-x-upgrade-experience.html)   
[ElasticSearch优化系列一：集群节点规划](http://www.jianshu.com/p/4c57a246164c)   
[ElasticSearch优化系列二：机器设置（内存）](http://www.jianshu.com/p/a2b682e5c1ab)   
[ElasticSearch优化系列三：机器设置（内存）](http://www.jianshu.com/p/59acd190aa41)   
[ElasticSearch优化系列四：ES的heap是如何被瓜分掉的](http://www.jianshu.com/p/f41b706db6c7)   
[ElasticSearch优化系列五：机器设置（硬盘、CPU）](http://www.jianshu.com/p/919f191acc94)   
[ElasticSearch优化系列六：索引过程](http://www.jianshu.com/p/b4eda49583b5)   
[ElasticSearch优化系列七：优化建议](http://www.jianshu.com/p/29ffce0850af)   

