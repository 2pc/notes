
### 活锁   
   1，概念： 当一proposer提交的poposal被拒绝时，可能是因为acceptor promise了更大编号的proposal，因此proposer提高编号继续提交。   
如果2个proposer都发现自己的编号过低转而提出更高编号的proposal，会导致死循环，也称为活锁。   
   2, 活锁的解决方案   
   选举出一个proposer作leader，所有的proposal都通过leader来提交，当Leader宕机时马上再选举其他的Leader   
   这种极端情况如果有"无限次"出现的话,那就永远无法达成一致了.引入一个"时间窗口"的机制:算法开始之前,选定一个足够的值t表示时间.每一个acceptor收到prepare消息以后的t之内,不再收任何prepare消息.所以假定上面的极端情况不再发生.或者说有如下结论成立:

   
   
   
   [Paxos算法2-算法过程](http://blog.csdn.net/chen77716/article/details/6170235)   
   [可靠分布式系统基础 Paxos 的直观解释](http://www.slideshare.net/drmingdrmer/paxos-51731377)
   [Paxos算法的一个容易理解的数学证明 ](http://blog.chinaunix.net/uid-12023855-id-4096558.html)
