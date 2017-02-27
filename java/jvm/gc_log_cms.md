
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
1. 初始标记(CMS-initial-mark) 会暂停应用，单线程
2. 并发标记(CMS-concurrent-mark)
3. 并发预清理（CMS-concurrent-preclean）
4. 重新标记（CMS-remark）会暂停应用，多线程
5. 并发清除（CMS-concurrent-sweep）
6. 并发重置（CMS-concurrent-reset）cms数据结构重新初始化，为下一次cms准备。




[CMS GC日志详细分析](http://blog.csdn.net/a417930422/article/details/16948933)   
[JAVA垃圾收集器](http://blog.csdn.net/ffm83/article/category/2845293)
