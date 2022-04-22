#### OffsetCommit && HeartBeat

0.9.0.0心跳与offset自动提交都是单独的线程

自动提交Offset的线程ConsumerCoordinator中

```
 this.autoCommitTask = autoCommitEnabled ? new AutoCommitTask(autoCommitIntervalMs) : null;
```
0.9.0.0 AutoCommitTask实现
```
private class AutoCommitTask implements DelayedTask {
    private final long interval;
    private boolean enabled = false;
    private boolean requestInFlight = false;

    public AutoCommitTask(long interval) {
        this.interval = interval;
    }

    public void enable() {
        if (!enabled) {
            // there shouldn't be any instances scheduled, but call unschedule anyway to ensure
            // that this task is only ever scheduled once
            client.unschedule(this);
            this.enabled = true;

            if (!requestInFlight) {
                long now = time.milliseconds();
                client.schedule(this, interval + now);
            }
        }
    }

    public void disable() {
        this.enabled = false;
        client.unschedule(this);
    }

    private void reschedule(long at) {
        if (enabled)
            client.schedule(this, at);
    }

    public void run(final long now) {
        if (!enabled)
            return;

        if (coordinatorUnknown()) {
            log.debug("Cannot auto-commit offsets now since the coordinator is unknown, will retry after backoff");
            client.schedule(this, now + retryBackoffMs);
            return;
        }

        requestInFlight = true;
        commitOffsetsAsync(subscriptions.allConsumed(), new OffsetCommitCallback() {
            @Override
            public void onComplete(Map<TopicPartition, OffsetAndMetadata> offsets, Exception exception) {
                requestInFlight = false;
                if (exception == null) {
                    reschedule(now + interval);
                } else if (exception instanceof SendFailedException) {
                    log.debug("Failed to send automatic offset commit, will retry immediately");
                    reschedule(now);
                } else {
                    log.warn("Auto offset commit failed: {}", exception.getMessage());
                    reschedule(now + interval);
                }
            }
        });
    }
}
```
HeartBeat的task在抽象类AbstractCoordinator中
```
this.heartbeat = new Heartbeat(this.sessionTimeoutMs, heartbeatIntervalMs, time.milliseconds());
this.heartbeatTask = new HeartbeatTask();
```
0.9.0.0 HeartBeat的实现
```
private class HeartbeatTask implements DelayedTask {

    private boolean requestInFlight = false;

    public void reset() {
        // start or restart the heartbeat task to be executed at the next chance
        long now = time.milliseconds();
        heartbeat.resetSessionTimeout(now);
        client.unschedule(this);

        if (!requestInFlight)
            client.schedule(this, now);
    }

    @Override
    public void run(final long now) {
        if (generation < 0 || needRejoin() || coordinatorUnknown()) {
            // no need to send the heartbeat we're not using auto-assignment or if we are
            // awaiting a rebalance
            return;
        }

        if (heartbeat.sessionTimeoutExpired(now)) {
            // we haven't received a successful heartbeat in one session interval
            // so mark the coordinator dead
            coordinatorDead();
            return;
        }

        if (!heartbeat.shouldHeartbeat(now)) {
            // we don't need to heartbeat now, so reschedule for when we do
            client.schedule(this, now + heartbeat.timeToNextHeartbeat(now));
        } else {
            heartbeat.sentHeartbeat(now);//set lastHeartbeatSend
            requestInFlight = true;

            RequestFuture<Void> future = sendHeartbeatRequest();
            future.addListener(new RequestFutureListener<Void>() {
                @Override
                public void onSuccess(Void value) {
                    requestInFlight = false;
                    long now = time.milliseconds();
                    heartbeat.receiveHeartbeat(now);
                    long nextHeartbeatTime = now + heartbeat.timeToNextHeartbeat(now);
                    client.schedule(HeartbeatTask.this, nextHeartbeatTime);
                }

                @Override
                public void onFailure(RuntimeException e) {
                    requestInFlight = false;
                    client.schedule(HeartbeatTask.this, time.milliseconds() + retryBackoffMs);
                }
            });
        }
    }
}

```
client(ConsumerNetworkClient).schedule()只是将HeartbeatTask加入到了delayedTasks，会在的poll()中被调用
```
public void poll(long timeout) {
    poll(timeout, time.milliseconds());
}

private void poll(long timeout, long now) {
    // send all the requests we can send now
    trySend(now);

    // ensure we don't poll any longer than the deadline for
    // the next scheduled task
    timeout = Math.min(timeout, delayedTasks.nextTimeout(now));
    clientPoll(timeout, now);
    now = time.milliseconds();

    // handle any disconnects by failing the active requests. note that disconects must
    // be checked immediately following poll since any subsequent call to client.ready()
    // will reset the disconnect status
    checkDisconnects(now);

    // execute scheduled tasks
    delayedTasks.poll(now);

    // try again to send requests since buffer space may have been
    // cleared or a connect finished in the poll
    trySend(now);

    // fail all requests that couldn't be sent
    failUnsentRequests();
}
```
0.10.1.0中，已经看不到AutoCommitTask了，找了半天只看到如下代码

```
// this collection must be thread-safe because it is modified from the response handler
// of offset commit requests, which may be invoked from the heartbeat thread
private final ConcurrentLinkedQueue<OffsetCommitCompletion> completedOffsetCommits;
```
我蒙！ 没有线程去定期(autoCommitIntervalMs)调度?
最终发现maybeAutoCommitOffsetsAsync()与maybeAutoCommitOffsetsNow()，而
>
1. maybeAutoCommitOffsetsNow()是在KafkaConsumer.assign()里调用的
2. maybeAutoCommitOffsetsAsync()是在poll里，这点与delayedTasks有点像

```
/**
 * Poll for coordinator events. This ensures that the coordinator is known and that the consumer
 * has joined the group (if it is using group management). This also handles periodic offset commits
 * if they are enabled.
 *
 * @param now current time in milliseconds
 */
public void poll(long now) {
    invokeCompletedOffsetCommitCallbacks();

    if (subscriptions.partitionsAutoAssigned() && coordinatorUnknown()) {
        ensureCoordinatorReady();
        now = time.milliseconds();
    }

    if (needRejoin()) {
        // due to a race condition between the initial metadata fetch and the initial rebalance,
        // we need to ensure that the metadata is fresh before joining initially. This ensures
        // that we have matched the pattern against the cluster's topics at least once before joining.
        if (subscriptions.hasPatternSubscription())
            client.ensureFreshMetadata();

        ensureActiveGroup();
        now = time.milliseconds();
    }

    pollHeartbeat(now);
    maybeAutoCommitOffsetsAsync(now);
}
```
