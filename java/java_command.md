
java -cp 

windows 
```
 java -cp xxx.jar[;]yyy.jar x.y.z.mainClass
```





linux 

```
java -cp xxx.jar[:]yyy.jar x.y.z.mainClass
```

zookeeper日志文件可视化

```

java -cp ../zookeeper-3.4.6.jar:./slf4j-api-1.6.1.jar  org.apache.zookeeper.server.LogFormatter   ../data/version-2/log.60000f313 
```

日志格式

```
10/24/16 3:59:22 PM CST session 0x357f4d08184037c cxid 0x23655 zxid 0x60000f594 multi v{s{13,#0003d2f656c61737469636a6f622d6578616d706c652f7468726f75676870757444617461466c6f77456c617374696344656d6f4a6f622f6f66667365742f390012ffffffec},s{5,#0003d2f656c61737469636a6f622d6578616d706c652f7468726f75676870757444617461466c6f77456c617374696344656d6f4a6f622f6f66667365742f39000239390012ffffffec}}

10/24/16 3:59:22 PM CST session 0x357f4d08184037c cxid 0x23657 zxid 0x60000f595 multi v{s{13,#000532f656c61737469636a6f622d6578616d706c652f7468726f75676870757444617461466c6f77456c617374696344656d6f4a6f622f736572766572732f3136392e3235342e3133342e3132322f73746174757300058},s{5,#000532f656c61737469636a6f622d6578616d706c652f7468726f75676870757444617461466c6f77456c617374696344656d6f4a6f622f736572766572732f3136392e3235342e3133342e3132322f7374617475730005524541445900058}}

```
zookeeper快照文件可视化

```
java -cp ../zookeeper-3.4.6.jar:./slf4j-api-1.6.1.jar org.apache.zookeeper.server.SnapshotFormatter  ../data/version-2/snapshot.8000f46fb

```

snap格式

```
----
/photos
  cZxid = 0x000003000a302e
  ctime = Wed Sep 07 19:24:25 CST 2016
  mZxid = 0x000003000a302e
  mtime = Wed Sep 07 19:24:25 CST 2016
  pZxid = 0x000003000a302f
  cversion = 1
  dataVersion = 0
  aclVersion = 0
  ephemeralOwner = 0x00000000000000
  no data
----
/photos/kiev
  cZxid = 0x000003000a302f
  ctime = Wed Sep 07 19:24:25 CST 2016
  mZxid = 0x000003000a302f
  mtime = Wed Sep 07 19:24:25 CST 2016
  pZxid = 0x000003000a3030
  cversion = 1
  dataVersion = 0
  aclVersion = 0
  ephemeralOwner = 0x00000000000000
  no data
----
```


```
-Djava.ext.dirs
```
