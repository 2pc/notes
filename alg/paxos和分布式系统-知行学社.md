
 地址[paxos和分布式系统-知行学社](http://v.youku.com/v_show/id_XMTI4NTUxNzMwNA==.html?from=s1.8-1-1.2&spm=a2h0k.8191407.0.0)

###  确定一个不可变的变量取值（方案三Paxos）

#### Paxos在方案2的基础上多Acceptor   
   Acceptor的实现不变，仍采用“喜新厌旧”的原则运行   
#### Paxos采用“少数多数服从的思路”   
   一旦某个epoch的取值f被半数以上acceptor接受，则认为此var的取值确认为f，不再更改   

#### Propose(var,V)第一阶段 选定epoch,获取epoch的访问权和的对应var的值   
   获取半数以上的acceptor的访问权和对应的一组var的取值   
#### Propose(var,V)第二阶段 采用“后者认同前者”的原则   
   在肯定旧的epoch无法生成确定性取值情况下，新epoch会提交自己的取值，不会冲突   
   一旦旧的epoch形成确定性取值，新epoch肯定可以获取此值，并且会认同此取值，不会破坏   
 1. 如果获取的var取值都为空，则旧epoch无法形成确定性取值，此时努力使(epoch,V)成为确定性取值   
    向epoch对应的所有acceptor提交取值(epoch,V)   
    如果收到半数以上成功，则返回(ok,V)   
    否则返回<error>(被新epoch抢占或者acceptor故障)
 2. 如果获取的var取值存在，认同最大accepted_epoch的对应的取值f，努力使(epoch,f)成为确定性取值   
    如果f出现半数以上，则说明已经使确定性取值了，直接返回(ok,f)   
     否则，像所有epoch对应的所有acceptor提交取值(epoch,f)，使f成为确定性取值
  
