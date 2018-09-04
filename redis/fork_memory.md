
最大内存： 
一定要设置最大内存，否则物理内存用爆了就会大量使用Swap，写RDB文件时的速度慢得你想死。 
多留一倍内存是最安全的。重写AOF文件和RDB文件的进程(即使不做持久化，复制到Slave的时候也要写RDB)会fork出一条新进程来，
采用了操作系统的Copy-On-Write策略(如果父进程的内存没被修改，子进程与父进程共享Page。
如果父进程的Page被修改, 会复制一份改动前的内容给新进程)，留意Console打出来的报告，如”RDB: 1215 MB of memory used by copy-on-write”。
在系统极度繁忙时，如果父进程的所有Page在子进程写RDB过程中都被修改过了，就需要两倍内存。 按照Redis启动时的提醒，设置 vm.overcommit_memory = 1 ，
使得fork()一条10G的进程时，因为COW策略而不一定需要有10G的free memory. 
当最大内存到达时，按照配置的Policy进行处理， 默认policy为volatile-lru， 对设置了expire time的key进行LRU清除(不是按实际expire time)。
如果沒有数据设置了expire time或者policy为noeviction，则直接报错，但此时系统仍支持get之类的读操作。 
另外还有几种policy，比如volatile-ttl按最接近expire time的，allkeys-lru对所有key都做LRU。 
原来2.0版的VM(将Value放到磁盘，Key仍然放在内存)，2.4版后又不支持了。

TechTarget中国原创内容，原文链接： [searchdatabase](https://searchdatabase.techtarget.com.cn/7-21572/)   
© TechTarget中国：https://www.techtarget.com.cn   
[关于Redis的一些常识](https://searchdatabase.techtarget.com.cn/7-21572/)   
[Redis需要多少内存预留-内存占用多少才安全](https://blog.csdn.net/chenggong2dm/article/details/79306151)
