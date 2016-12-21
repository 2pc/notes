
### 活锁   
   当一proposer提交的poposal被拒绝时，可能是因为acceptor promise了更大编号的proposal，因此proposer提高编号继续提交。   
如果2个proposer都发现自己的编号过低转而提出更高编号的proposal，会导致死循环，也称为活锁。
