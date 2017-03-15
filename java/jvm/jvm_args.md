jvm 参数   
>
1. -Xms：java Heap初始大小， 默认是物理内存的1/64。
2. -Xmx：java Heap最大值，不可超过物理内存。
3. -Xmn：young generation的heap大小，一般设置为Xmx的3、4分之一 。增大年轻代后,将会减小年老代大小，可以根据监控合理设置。
4. -Xss：每个线程的Stack大小，而最佳值应该是128K,默认值好像是512k。
5. -XX:PermSize：设定内存的永久保存区初始大小，缺省值为64M。
6. -XX:MaxPermSize：设定内存的永久保存区最大大小，缺省值为64M。
7. -XX:SurvivorRatio：Eden区与Survivor区的大小比值,设置为8,则两个Survivor区与一个Eden区的比值为2:8,一个Survivor区占整个年轻代的1/10
8. -XX:+UseParallelGC：F年轻代使用并发收集,而年老代仍旧使用串行收集.
9. -XX:+UseParNewGC：设置年轻代为并行收集,JDK5.0以上,JVM会根据系统配置自行设置,所无需再设置此值。
10. -XX:ParallelGCThreads：并行收集器的线程数，值最好配置与处理器数目相等 同样适用于CMS。
11. -XX:+UseParallelOldGC：年老代垃圾收集方式为并行收集(Parallel Compacting)。
12. -XX:MaxGCPauseMillis：每次年轻代垃圾回收的最长时间(最大暂停时间)，如果无法满足此时间,JVM会自动调整年轻代大小,以满足此值。
13. -XX:+ScavengeBeforeFullGC：Full GC前调用YGC,默认是true。



### -XX:NewRatio  年轻代(包括Eden和两个Survivor区)与年老代的比值(除去持久代)

-XX:NewRatio=4表示年轻代与年老代所占比值为1:4,年轻代占整个堆栈的1/5
Xms=Xmx并且设置了Xmn的情况下，该参数不需要进行设置

### -XX:SurvivorRatio Eden区与Survivor区的大小比值

设置为8,则两个Survivor区与一个Eden区的比值为2:8,一个Survivor区占整个年轻代的1/10   


[ 【总结】JVM模型](http://blog.csdn.net/zhiguozhu/article/details/50517467)

