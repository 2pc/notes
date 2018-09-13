otter  statistics 主要在load之后发送中，具体代码见OtterLoaderFactory

```
 public List<LoadContext> load(DbBatch dbBatch) {
    try {
        return dataBatchLoader.load(dbBatch);
    } finally {
        try {
            sendStat(dbBatch.getRowBatch().getIdentity());
        } finally {
            loadStatsTracker.removeStat(dbBatch.getRowBatch().getIdentity());
        }
    }

}
```
主要是这个方法sendStat()里会构造各种统计数据

```
private void sendStat(Identity identity) {
  LoadThroughput throughput = loadStatsTracker.getStat(identity);
  Collection<LoadCounter> counters = throughput.getStats();
  Date endTime = new Date();
  // 处理table stat
  long fileSize = 0L;
  long fileCount = 0L;
  long rowSize = 0L;
  long rowCount = 0L;
  long mqSize = 0L;
  long mqCount = 0L;
  List<TableStat> tableStats = new ArrayList<TableStat>();
  for (LoadCounter counter : counters) {
      TableStat stat = new TableStat();
      stat.setPipelineId(identity.getPipelineId());
      stat.setDataMediaPairId(counter.getPairId());
      stat.setFileCount(counter.getFileCount().longValue());
      stat.setFileSize(counter.getFileSize().longValue());
      stat.setInsertCount(counter.getInsertCount().longValue());
      stat.setUpdateCount(counter.getUpdateCount().longValue());
      stat.setDeleteCount(counter.getDeleteCount().longValue());
      stat.setStartTime(new Date(throughput.getStartTime()));
      stat.setEndTime(endTime);
      // 5项中有一项不为空才通知
      if (!(stat.getFileCount().equals(0L) && stat.getFileSize().equals(0L) && stat.getInsertCount().equals(0L)
            && stat.getDeleteCount().equals(0L) && stat.getUpdateCount().equals(0L))) {
          tableStats.add(stat);
      }

      fileSize += counter.getFileSize().longValue();
      fileCount += counter.getFileCount().longValue();
      rowSize += counter.getRowSize().longValue();
      rowCount += counter.getRowCount().longValue();

      mqSize += counter.getMqSize().longValue();
      mqCount += counter.getMqCount().longValue();
  }
  if (!CollectionUtils.isEmpty(tableStats)) {
      statisticsClientService.sendTableStats(tableStats);
  }
    List<ThroughputStat> throughputStats = new ArrayList<ThroughputStat>();
    if (!(rowCount == 0 && rowSize == 0)) {
        // 处理Throughput stat
        ThroughputStat rowThroughputStat = new ThroughputStat();
        rowThroughputStat.setType(ThroughputType.ROW);
        rowThroughputStat.setPipelineId(identity.getPipelineId());
        rowThroughputStat.setNumber(rowCount);
        rowThroughputStat.setSize(rowSize);
        rowThroughputStat.setStartTime(new Date(throughput.getStartTime()));
        rowThroughputStat.setEndTime(endTime);
        throughputStats.add(rowThroughputStat);
    }
    if (!(fileCount == 0 && fileSize == 0)) {
        ThroughputStat fileThroughputStat = new ThroughputStat();
        fileThroughputStat.setType(ThroughputType.FILE);
        fileThroughputStat.setPipelineId(identity.getPipelineId());
        fileThroughputStat.setNumber(fileCount);
        fileThroughputStat.setSize(fileSize);
        fileThroughputStat.setStartTime(new Date(throughput.getStartTime()));
        fileThroughputStat.setEndTime(endTime);
        throughputStats.add(fileThroughputStat);
    }

    // add by 2012-07-06 for mq loader
    if (!(mqCount == 0 && mqSize == 0)) {
        ThroughputStat mqThroughputStat = new ThroughputStat();
        mqThroughputStat.setType(ThroughputType.MQ);
        mqThroughputStat.setPipelineId(identity.getPipelineId());
        mqThroughputStat.setNumber(mqCount);
        mqThroughputStat.setSize(mqSize);
        mqThroughputStat.setStartTime(new Date(throughput.getStartTime()));
        mqThroughputStat.setEndTime(endTime);
        throughputStats.add(mqThroughputStat);
    }

    if (!CollectionUtils.isEmpty(throughputStats)) {
        statisticsClientService.sendThroughputs(throughputStats);
    }
}
```
