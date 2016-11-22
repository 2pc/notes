
 地址[paxos和分布式系统-知行学社](http://v.youku.com/v_show/id_XMTI4NTUxNzMwNA==.html?from=s1.8-1-1.2&spm=a2h0k.8191407.0.0)

###  确定一个不可变的变量取值

#### Paxos在方案2的基础上多Acceptor   
   Acceptor的实现不变，仍采用“喜新厌旧”的原则运行   
#### Paxos采用“少数多数服从的思路”   
   一旦某个epoch的取值f被半数以上acceptor接受，则认为此var的取值确认为f，不再更改
  
