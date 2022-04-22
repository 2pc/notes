
>   
1. HW(HightWatermark): 所有ISR中的LEO最小的,所有ISR都复制已经复制完的消息的offset,也是消费者能获取到的消息的最大offset
2. LEO(LogEndOffset): 

代码逻辑: KafkaApis.handle(RequestKeys.ProduceKey)-->KafkaApis.handleProducerRequest()-->ReplicaManager.appendMessages()
-->ReplicaManager.appendToLocalLog-->Partition.appendMessagesToLeader-->Partition.maybeIncrementLeaderHW()

```
private def maybeIncrementLeaderHW(leaderReplica: Replica): Boolean = {
  val allLogEndOffsets = inSyncReplicas.map(_.logEndOffset)//所有ISR的LEO
  val newHighWatermark = allLogEndOffsets.min(new LogOffsetMetadata.OffsetOrdering)//最小的LEO作为新的HW(HighWatermark)
  val oldHighWatermark = leaderReplica.highWatermark
  if(oldHighWatermark.precedes(newHighWatermark)) {//小于oldHighWatermark.messageOffset< newHighWatermark.messageOffset
    leaderReplica.highWatermark = newHighWatermark
    debug("High watermark for partition [%s,%d] updated to %s".format(topic, partitionId, newHighWatermark))
    true
  } else {
    debug("Skipping update high watermark since Old hw %s is larger than new hw %s for partition [%s,%d]. All leo's are %s"
      .format(oldHighWatermark, newHighWatermark, topic, partitionId, allLogEndOffsets.mkString(",")))
    false
  }
}
```
