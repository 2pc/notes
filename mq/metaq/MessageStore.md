#### 文件结构

每个patition对应一个文件夹，这点还与kafka一致
metaq

```
$ ls /data/metaq/metamorphosis-server-wrapper/data/PUSH_ONLINE_1-
PUSH_ONLINE_1-0/ PUSH_ONLINE_1-1/ PUSH_ONLINE_1-2/ PUSH_ONLINE_1-3/ PUSH_ONLINE_1-4/ PUSH_ONLINE_1-5/ PUSH_ONLINE_1-6/ PUSH_ONLINE_1-7/ PUSH_ONLINE_1-8/ PUSH_ONLINE_1-9/ 
```

kafka

```
# ls /usr/local/kafka_2.11-0.10.1.0/kafkadata/kafka-logs/test6-
test6-0/ test6-1/ test6-2/ test6-3/ test6-4/ test6-5/ 
```
没个patition下对应一个文件夹对应.meta文件，，新版本的kafka有index,log，timeindex三种文件
metaq

```
#ls /data/metaq/metamorphosis-server-wrapper/data/PUSH_ONLINE-0/
00000000000000000000.meta  00000000001073742359.meta  00000000002147484529.meta  00000000003221226515.meta
```

kafka

```
# ls /usr/local/kafka_2.11-0.10.1.0/kafkadata/kafka-logs/test6-5/
00000000000000000000.index  00000000000000000000.log  00000000000000000000.timeindex  00000000000000190121.index  00000000000000190121.log  00000000000000190121.timeindex
```

一个topic的每一个patition对应一个MessageStore

```
MetamorphosisStartup.main-->MetaMorphosisBroker.start()-->MessageStoreManager.init()-->MessageStoreManager.loadMessageStores-->
MessageStoreManager.loadDataDir()-->MessageStoreManager.loadStoresInParallel()/MessageStoreManager.loadStores()
```
loadStoresInParallel与loadStores差不多，loadStores为例
```
private void loadStores(List<Callable<MessageStore>> tasks) throws IOException, InterruptedException {
    for (Callable<MessageStore> task : tasks) {
        MessageStore messageStore;
        try {
            messageStore = task.call();
            ConcurrentHashMap<Integer/* partition */, MessageStore> map = this.stores.get(messageStore.getTopic());
            if (map == null) {
                map = new ConcurrentHashMap<Integer, MessageStore>();
                this.stores.put(messageStore.getTopic(), map);
            }
            map.put(messageStore.getPartition(), messageStore);
        }
        catch (IOException e) {
            throw e;
        }
        catch (InterruptedException e) {
            throw e;
        }
        catch (Exception e) {
            throw new IllegalStateException(e);
        }
    }
    tasks.clear();
}
```   
其中stores为topic与该topic的patition的映射

```
private final ConcurrentHashMap<String/* topic */, ConcurrentHashMap<Integer/* partition */, MessageStore>> stores =
            new ConcurrentHashMap<String, ConcurrentHashMap<Integer, MessageStore>>();
```

task构造的代码在MessageStoreManager.loadDataDir()中，也就是在这里生成MessageStore，对应到每个patition

```
tasks.add(new Callable<MessageStore>() {
                @Override
                public MessageStore call() throws Exception {
                    log.warn("Loading data directory:" + subDir.getAbsolutePath() + "...");
                    final String topic = name.substring(0, index);
                    final int partition = Integer.parseInt(name.substring(index + 1));
                    final MessageStore messageStore =
                            new MessageStore(topic, partition, metaConfig,
                                MessageStoreManager.this.deletePolicySelector.select(topic,
                                    MessageStoreManager.this.deletePolicy));
                    return messageStore;
                }
            });
```
