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

topic下得每个目录（文件夹）对应一个patition的，对应到代码就是一个MessageStore,而每个文件夹又是多个文件（多个段），对应到代码就是多个Segment
```
#ls /data/metaq/metamorphosis-server-wrapper/data/PUSH_ONLINE-0/
00000000000000000000.meta  00000000001073742359.meta  00000000002147484529.meta  00000000003221226515.meta
```
MessageStore中段文件的加载,
>
1. 加载所有的meta文件，每个meta文件作为一个Segment，先都作为不可变的加载进来
2. 如果加载不到meta文件，就创建一个
3. 对加载到的文件进行排序
4. 校验文件,因为做了排序，所以此时文件应该是连续的，依据（curr.start+curr.SegmentSize=next.start），上边的maxSegmentSize=1073742359
5. 将最后一个Segment的变为可变，以便append消息到最后一个文件，保证了消息的顺序？

```
/**
     * 加载并校验文件
     */
    private void loadSegments(final long offsetIfCreate) throws IOException {
        final List<Segment> accum = new ArrayList<Segment>();
        final File[] ls = this.partitionDir.listFiles();

        if (ls != null) {
            for (final File file : ls) {
                if (file.isFile() && file.toString().endsWith(FILE_SUFFIX)) {
                    if (!file.canRead()) {
                        throw new IOException("Could not read file " + file);
                    }
                    final String filename = file.getName();
                    final long start = Long.parseLong(filename.substring(0, filename.length() - FILE_SUFFIX.length()));
                    // 先作为不可变的加载进来
                    accum.add(new Segment(start, file, false));
                }
            }
        }

        if (accum.size() == 0) {
            // 没有可用的文件，创建一个，索引从offsetIfCreate开始
            final File newFile = new File(this.partitionDir, this.nameFromOffset(offsetIfCreate));
            accum.add(new Segment(offsetIfCreate, newFile));
        }
        else {
            // 至少有一个文件，校验并按照start升序排序
            Collections.sort(accum, new Comparator<Segment>() {
                @Override
                public int compare(final Segment o1, final Segment o2) {
                    if (o1.start == o2.start) {
                        return 0;
                    }
                    else if (o1.start > o2.start) {
                        return 1;
                    }
                    else {
                        return -1;
                    }
                }
            });
            // 校验文件
            this.validateSegments(accum);
            // 最后一个文件修改为可变
            final Segment last = accum.remove(accum.size() - 1);
            last.fileMessageSet.close();
            log.info("Loading the last segment in mutable mode and running recover on " + last.file.getAbsolutePath());
            final Segment mutable = new Segment(last.start, last.file);
            accum.add(mutable);
            log.info("Loaded " + accum.size() + " segments...");
        }

        this.segments = new SegmentList(accum.toArray(new Segment[accum.size()]));
    }


    private void validateSegments(final List<Segment> segments) {
        this.writeLock.lock();
        try {
            for (int i = 0; i < segments.size() - 1; i++) {
                final Segment curr = segments.get(i);
                final Segment next = segments.get(i + 1);
                if (curr.start + curr.size() != next.start) {
                    throw new IllegalStateException("The following segments don't validate: "
                            + curr.file.getAbsolutePath() + ", " + next.file.getAbsolutePath());
                }
            }
        }
        finally {
            this.writeLock.unlock();
        }
    }

```
