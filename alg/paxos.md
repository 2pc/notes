
### 活锁   
   1，概念： 当一proposer提交的poposal被拒绝时，可能是因为acceptor promise了更大编号的proposal，因此proposer提高编号继续提交。   
如果2个proposer都发现自己的编号过低转而提出更高编号的proposal，会导致死循环，也称为活锁。   
   2, 活锁的解决方案： 选举出一个proposer作leader，所有的proposal都通过leader来提交，当Leader宕机时马上再选举其他的Leader
   
   
   
   [Paxos算法2-算法过程](http://blog.csdn.net/chen77716/article/details/6170235)
