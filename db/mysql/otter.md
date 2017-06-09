#### canal 订阅消费CanalEmbedSelector

#### insert/update/delete 语句构造 SqlBuilderLoadInterceptor

#### 异构

```
DataBatchLoader.load()-->DataBatchLoader.submitRowBatch()/submitFileBatch->DbLoadAction.load()-->DbLoadAction.doTwoPhase()-->
DbLoadWorker.call()-->DbLoadWorker.doCall()-->JdbcTemplate
```

####  value转化
因为canal生产数据均为string类型，需要做一个转化

```

```
