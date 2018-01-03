

#### 启动入口,模块bootstrap
[BootstrapMain.java](https://github.com/streamsets/datacollector/blob/master/bootstrap/src/main/java/com/streamsets/pipeline/BootstrapMain.java)

#### main，模块container
[DataCollectorMain.java](https://github.com/streamsets/datacollector/blob/master/container/src/main/java/com/streamsets/datacollector/main/DataCollectorMain.java)

继承自[Main.java](https://github.com/streamsets/datacollector/blob/master/container-common/src/main/java/com/streamsets/datacollector/main/Main.java),模块container-common


#### Api接口[PipelineStoreResource.java](https://github.com/streamsets/datacollector/blob/master/container/src/main/java/com/streamsets/datacollector/restapi/PipelineStoreResource.java)

创建pipeline

```
http://127.0.0.1:18630/rest/v1/pipeline/test2?autoGeneratePipelineId=true&description=ccccc
```

启动pipeline

```
http://127.0.0.1:18630/rest/v1/pipelines/start
```
