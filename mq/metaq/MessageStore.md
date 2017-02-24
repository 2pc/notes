#### 文件结构

每个patition对应一个文件夹，这点还与kafka一致
metaq

```
$ ls /data/metaq/metamorphosis-server-wrapper/data/PUSH_ONLINE_1-
PUSH_ONLINE_1-0/ PUSH_ONLINE_1-1/ PUSH_ONLINE_1-2/ PUSH_ONLINE_1-3/ PUSH_ONLINE_1-4/ PUSH_ONLINE_1-5/ PUSH_ONLINE_1-6/ PUSH_ONLINE_1-7/ PUSH_ONLINE_1-8/ PUSH_ONLINE_1-9/ 
```

KAFKA

```
# ls /usr/local/kafka_2.11-0.10.1.0/kafkadata/kafka-logs/test6-
test6-0/ test6-1/ test6-2/ test6-3/ test6-4/ test6-5/ 
```
没个patition下对应一个文件夹，

metaq

```
#ls /data/metaq/metamorphosis-server-wrapper/data/PUSH_ONLINE-0/
00000000000000000000.meta  00000000001073742359.meta  00000000002147484529.meta  00000000003221226515.meta
```

kafka

```
# ls /usr/local/kafka_2.11-0.10.1.0/kafkadata/kafka-logs/test6-
test6-0/ test6-1/ test6-2/ test6-3/ test6-4/ test6-5/ 
```
