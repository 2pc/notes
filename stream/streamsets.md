

#### 启动入口,模块bootstrap
[BootstrapMain.java](https://github.com/streamsets/datacollector/blob/master/bootstrap/src/main/java/com/streamsets/pipeline/BootstrapMain.java)

#### main，模块container
[DataCollectorMain.java](https://github.com/streamsets/datacollector/blob/master/container/src/main/java/com/streamsets/datacollector/main/DataCollectorMain.java)

继承自[Main.java](https://github.com/streamsets/datacollector/blob/master/container-common/src/main/java/com/streamsets/datacollector/main/Main.java),模块container-common


#### Api接口

创建pipeline[PipelineStoreResource.java](https://github.com/streamsets/datacollector/blob/master/container/src/main/java/com/streamsets/datacollector/restapi/PipelineStoreResource.java)

```
http://127.0.0.1:18630/rest/v1/pipeline/test2?autoGeneratePipelineId=true&description=ccccc
```

启动pipeline[ManagerResource.java](https://github.com/streamsets/datacollector/blob/master/container/src/main/java/com/streamsets/datacollector/restapi/ManagerResource.java)

```
http://127.0.0.1:18630/rest/v1/pipelines/start
```
[StandaloneRunner.java](https://github.com/streamsets/datacollector/blob/master/container/src/main/java/com/streamsets/datacollector/execution/runner/standalone/StandaloneRunner.java)
```
ManagerResource.start()--> runner.start()(Runner runner = manager.getRunner(pipelineId, rev))-->StandaloneRunner.start()
```
stack
```
2018-01-03 01:02:21,988 [user:*admin] [pipeline:test/test19628fc5-95de-42cd-ba29-f55760e1d2
56] [runner:] [thread:ProductionPipelineRunnable-test19628fc5-95de-42cd-ba29-f55760e1d256-t
est] ERROR MysqlSource - Error connecting to MySql binlog: BinaryLogClient was unable to co
nnect in 5000ms
java.util.concurrent.TimeoutException: BinaryLogClient was unable to connect in 5000ms
        at com.github.shyiko.mysql.binlog.BinaryLogClient.connect(BinaryLogClient.java:644)
        at com.streamsets.pipeline.stage.origin.mysql.MysqlSource.init(MysqlSource.java:103
)
        at com.streamsets.pipeline.api.base.BaseStage.init(BaseStage.java:52)
        at com.streamsets.datacollector.runner.StageRuntime.init(StageRuntime.java:156)
        at com.streamsets.datacollector.runner.StagePipe.init(StagePipe.java:105)
        at com.streamsets.datacollector.runner.StagePipe.init(StagePipe.java:53)
        at com.streamsets.datacollector.runner.Pipeline.initPipe(Pipeline.java:299)
        at com.streamsets.datacollector.runner.Pipeline.init(Pipeline.java:214)
        at com.streamsets.datacollector.execution.runner.common.ProductionPipeline.run(Prod
uctionPipeline.java:96)
        at com.streamsets.datacollector.execution.runner.common.ProductionPipelineRunnable.
run(ProductionPipelineRunnable.java:79)
        at com.streamsets.datacollector.execution.runner.standalone.StandaloneRunner.start(
StandaloneRunner.java:668)
        at com.streamsets.datacollector.execution.runner.common.AsyncRunner.lambda$start$3(
AsyncRunner.java:149)
        at com.streamsets.datacollector.execution.runner.common.AsyncRunner$$Lambda$30/1593
004381.call(Unknown Source)
        at com.streamsets.pipeline.lib.executor.SafeScheduledExecutorService$SafeCallable.c
all(SafeScheduledExecutorService.java:233)
        at java.util.concurrent.FutureTask.run(FutureTask.java:266)
```
