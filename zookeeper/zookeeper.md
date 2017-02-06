尽管保证了多数派节点一致，由于客户端读取是随机选取节点，可能读取到的刚好是没有同步的节点，这样可能拿到的数据不是最新的一致的， 
可以通过sync强制同步来解决，给数据变化的节点添加watcher理论上也可以解决部分问题


[ZooKeeper源码分析：Quorum请求的整个流程](http://blog.csdn.net/jeff_fangji/article/details/42988439)

[ZooKeeper源码分析：Quorum请求的整个流程](http://www.linuxidc.com/Linux/2015-02/113730.htm)   

[深入浅出Zookeeper之七分布式CREATE事务处理](http://iwinit.iteye.com/blog/1777109#bc2394912)
