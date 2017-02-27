
1. -XX:+PrintGCTimeStamps 记录以Jvm启动为起点的相对时间   
2. -XX:+PrintGCDateStamps 记录的是系统时间

```
2017-02-27T14:26:17.071+0800: [GC (Allocation Failure) 2017-02-27T14:26:17.071+0800: [ParNew: 9185K->961K(9216K), 0.0068960 secs] 15952K->16109K(29696K), 0.0069661 secs] [Times: user=0.00 sys=0.00, real=0.01 secs] 
2017-02-27T14:26:17.078+0800: [GC (CMS Initial Mark) [1 CMS-initial-mark: 15148K(20480K)] 16173K(29696K), 0.0002581 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
2017-02-27T14:26:17.078+0800: [CMS-concurrent-mark-start]
2017-02-27T14:26:17.079+0800: [CMS-concurrent-mark: 0.001/0.001 secs] [Times: user=0.03 sys=0.00, real=0.00 secs] 
2017-02-27T14:26:17.079+0800: [CMS-concurrent-preclean-start]
2017-02-27T14:26:17.079+0800: [CMS-concurrent-preclean: 0.000/0.000 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
2017-02-27T14:26:17.080+0800: [GC (CMS Final Remark) [YG occupancy: 1025 K (9216 K)]2017-02-27T14:26:17.080+0800: [Rescan (parallel) , 0.0002056 secs]2017-02-27T14:26:17.080+0800: [weak refs processing, 0.0000244 secs]2017-02-27T14:26:17.080+0800: [class unloading, 0.0002925 secs]2017-02-27T14:26:17.080+0800: [scrub symbol table, 0.0006281 secs]2017-02-27T14:26:17.081+0800: [scrub string table, 0.0002065 secs][1 CMS-remark: 15148K(20480K)] 16173K(29696K), 0.0014827 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
2017-02-27T14:26:17.081+0800: [CMS-concurrent-sweep-start]
2017-02-27T14:26:17.082+0800: [CMS-concurrent-sweep: 0.000/0.000 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
2017-02-27T14:26:17.082+0800: [CMS-concurrent-reset-start]
2017-02-27T14:26:17.082+0800: [CMS-concurrent-reset: 0.000/0.000 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
```
>
1. 初始标记(CMS-initial-mark) 会暂停应用，单线程
2. 并发标记(CMS-concurrent-mark)
3. 并发预清理（CMS-concurrent-preclean）
4. 重新标记（CMS-remark）会暂停应用，多线程
5. 并发清除（CMS-concurrent-sweep）
6. 并发重置（CMS-concurrent-reset）cms数据结构重新初始化，为下一次cms准备。


CMS GC时出现promotion failed和concurrent mode failure,对于采用CMS进行旧生代GC的程序而言，   
尤其要注意GC日志中是否有promotion failed和concurrent mode failure两种状况，当这两种状况出现时可能会触发Full GC。
>
1. promotion failed是在进行Minor GC时，survivor space放不下、对象只能放入旧生代，而此时旧生代也放不下造成的；
2. concurrent mode failure是在执行CMS GC的过程中同时有对象要放入旧生代，而此时旧生代空间不足造成的。



1. [CMS GC日志详细分析](http://blog.csdn.net/a417930422/article/details/16948933)   
2. [JAVA垃圾收集器](http://blog.csdn.net/ffm83/article/category/2845293)
3. [一次CMS GC问题排查过程（理解原理+读懂GC日志）](http://itindex.net/detail/47030-cms-gc-%E9%97%AE%E9%A2%98)
4. [讨论-JVM日志和参数的理解](http://hllvm.group.iteye.com/group/topic/34182)
5. [JVM日志和参数的理解](http://hot66hot.iteye.com/blog/2075819)
