J.U.C中的实现ThreadPoolExecutor 

>
* 当前线程数小于corePoolSize，直接执行addWorker方法创建线程   
* offer到queue
* queue满了，执行addWorker方法创建新的线程执行任务


```
int c = ctl.get();
if (workerCountOf(c) < corePoolSize) {
    if (addWorker(command, true))
        return;
    c = ctl.get();
}
if (isRunning(c) && workQueue.offer(command)) {
    int recheck = ctl.get();
    if (! isRunning(recheck) && remove(command))
        reject(command);
    else if (workerCountOf(recheck) == 0)
        addWorker(null, false);
}
else if (!addWorker(command, false))
    reject(command);
```
1. [Tomcat的实现StandardThreadExecutor](https://github.com/apache/tomcat/blob/trunk/java/org/apache/catalina/core/StandardThreadExecutor.java) [Tomcat中ThreadPoolExecutor实现](https://github.com/apache/tomcat/blob/trunk/java/org/apache/tomcat/util/threads/ThreadPoolExecutor.java)
2. motan参考了tomcat的StandardThreadExecutor[motan的实现StandardThreadExecutor](https://github.com/weibocom/motan/blob/master/motan-transport-netty/src/main/java/com/weibo/api/motan/transport/netty/StandardThreadExecutor.java)

3. [点评pigeon的实现DefaultThreadPool](https://github.com/dianping/pigeon/blob/master/pigeon-common/src/main/java/com/dianping/pigeon/threadpool/DefaultThreadPool.java)

4. [dubbo实现](https://github.com/alibaba/dubbo/tree/master/dubbo-common/src/main/java/com/alibaba/dubbo/common/threadpool)

5. [Tomcat线程池详解](http://blog.csdn.net/wxq544483342/article/details/53162311)


几种的弊端


Executors.newCachedThreadPool();线程数最大Integer.MAX_VALUE，为不受限制，

```
public static ExecutorService newCachedThreadPool() {
        return new ThreadPoolExecutor(0, Integer.MAX_VALUE,
                                      60L, TimeUnit.SECONDS,
                                      new SynchronousQueue<Runnable>());
    }
```

Executors.newFixedThreadPool();对列大小为Integer.MAX_VALUE

```
public static ExecutorService newFixedThreadPool(int nThreads) {
    return new ThreadPoolExecutor(nThreads, nThreads,
                                  0L, TimeUnit.MILLISECONDS,
                                  new LinkedBlockingQueue<Runnable>());
}
public LinkedBlockingQueue() {
    this(Integer.MAX_VALUE);
}
```

Executors.newSingleThreadExecutor();

```
public static ExecutorService newSingleThreadExecutor() {
    return new FinalizableDelegatedExecutorService
        (new ThreadPoolExecutor(1, 1,
                                0L, TimeUnit.MILLISECONDS,
                                new LinkedBlockingQueue<Runnable>()));
}
```

Executors.newScheduledThreadPool();

```
public static ScheduledExecutorService newScheduledThreadPool(int corePoolSize) {
    return new ScheduledThreadPoolExecutor(corePoolSize);
}
public ScheduledThreadPoolExecutor(int corePoolSize) {
    super(corePoolSize, Integer.MAX_VALUE, 0, NANOSECONDS,
          new DelayedWorkQueue());
}
```
