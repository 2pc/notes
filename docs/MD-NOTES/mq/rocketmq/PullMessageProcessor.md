
### Broker端处理消费请求

PullMessageProcessor.processRequest-->DefaultMessageStore.getMessage()

```
final GetMessageResult getMessageResult =
    this.brokerController.getMessageStore().getMessage(requestHeader.getConsumerGroup(), requestHeader.getTopic(),
        requestHeader.getQueueId(), requestHeader.getQueueOffset(), requestHeader.getMaxMsgNums(), messageFilter);
```

