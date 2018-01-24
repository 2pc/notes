

### otter监控

#### 位点position更新监控 PositionTimeoutRuleMonitor

这里的latestSyncTime，也就是modifiedTime,取的是zookeeper上保存位点的节点的Stat的mtime

 ```
public void explore(List<AlarmRule> rules) {
    if (CollectionUtils.isEmpty(rules)) {
        return;
    }
    Long pipelineId = rules.get(0).getPipelineId();
    Pipeline pipeline = pipelineService.findById(pipelineId);
    PositionEventData data = arbitrateViewService.getCanalCursor(pipeline.getParameters().getDestinationName(),
                                                                 pipeline.getParameters().getMainstemClientId());

    long latestSyncTime = 0L;
    if (data != null && data.getModifiedTime() != null) {
        Date modifiedDate = data.getModifiedTime();
        latestSyncTime = modifiedDate.getTime();
    } else {
        return;
    }

    long now = System.currentTimeMillis();
    long elapsed = now - latestSyncTime;
    boolean flag = false;
    for (AlarmRule rule : rules) {
        flag |= checkTimeout(rule, elapsed);
    }

    if (flag) {
        logRecordAlarm(pipelineId, MonitorName.POSITIONTIMEOUT,
                       String.format(TIME_OUT_MESSAGE, pipelineId, (elapsed / 1000)));
    }
}
 ```


客户端 StatisticsClientServiceImpl
远端 StatsRemoteServiceImpl
