S.E.T.L

解析canal数据过程

```
OtterLauncher-->OtterController.start()-->NodeTaskServiceImpl.addListener(OtterController)-->NodeTaskServiceImpl.notifyListener()
-->NodeTaskListener.process()-->OtterController.process()-->OtterController.startPipeline()
-->OtterController.startTask()(SelectTask/ExtractTask/TransformTask/LoadTask)-->SelectTask.start/run()-->SelectTask.startup
-->SelectTask.startProcessSelect()-->SelectTask.startProcessSelect()-->otterSelector.selector()-->CanalServerWithEmbedded.getWithoutAck
```
