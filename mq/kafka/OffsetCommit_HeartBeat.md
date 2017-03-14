#### OffsetCommit && HeartBeat

0.9.0.0心跳与offset提交都是单独的线程

自动提交Offset的线程ConsumerCoordinator中

```
 this.autoCommitTask = autoCommitEnabled ? new AutoCommitTask(autoCommitIntervalMs) : null;
```
HeartBeat的task在抽象类AbstractCoordinator中
```
this.heartbeat = new Heartbeat(this.sessionTimeoutMs, heartbeatIntervalMs, time.milliseconds());
this.heartbeatTask = new HeartbeatTask();
```


0.10.1.0中，已经看不到AutoCommitTask了，找了半天至看到如下代码

```
// this collection must be thread-safe because it is modified from the response handler
// of offset commit requests, which may be invoked from the heartbeat thread
private final ConcurrentLinkedQueue<OffsetCommitCompletion> completedOffsetCommits;
```
