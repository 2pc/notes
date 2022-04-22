flink on yarn 

运行命令

```
 ./bin/yarn-session.sh -n 3 -s 8 -jm 1024 -tm 1024 -nm flink –d
```
报错

```
Caused by: org.apache.flink.configuration.IllegalConfigurationException: The number of virtual cores per node were configured with 8 but Yarn only has -1 virtual cores available. Please note that the number of virtual cores is set to the number of task slots by default unless configured in the Flink config with 'yarn.containers.vcores.'
        at org.apache.flink.yarn.AbstractYarnClusterDescriptor.isReadyForDeployment(AbstractYarnClusterDescriptor.java:290)
```

版本问题 cloudera 使用的2.6，flink的包使用2.8版本的
