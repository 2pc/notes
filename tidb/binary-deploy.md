

一段时间没启动cluster,玩半天tidb起不来了，被自己坑了。所以记录下。而且官网已经不支持binary部署了。

错误的写法

```
# cat start-tidb.sh 
nohup  bin/tidb-server  --store=tikv  --path=="172.28.3.131:2379" --log-file=tidb.log &  2>&1
```
正确的写法

```
# cat start-tidb.sh 
nohup  bin/tidb-server  --store=tikv  --path="172.28.3.131:2379" --log-file=tidb.log &  2>&1
```

好了，规划

pd,tidb同一机器

tikv分布在不同的三台机器

pd server
```
# cat pd-start.sh 
./bin/pd-server --name=pd1 --data-dir=pd1 --client-urls="http://172.28.3.131:2379" --peer-urls="http://172.28.3.131:2380" --initial-cluster="pd1=http://172.28.3.131:2380" --log-file=pd.log  & 2>&1 
```

tikv

```
# cat tikv-start.sh 
 nohup   ./bin/tikv-server --pd="172.28.3.131:2379" --addr="172.28.3.132:20160" --data-dir=tikv132 --log-file=tikv.log  & 2>&1
 # cat tikv-start.sh 
nohup   ./bin/tikv-server --pd="172.28.3.131:2379" --addr="172.28.3.133:20160" --data-dir=tikv133 --log-file=tikv.log  & 2>&1
# cat tikv-start.sh 
nohup   ./bin/tikv-server --pd="172.28.3.131:2379" --addr="172.28.3.134:20160" --data-dir=tikv134 --log-file=tikv.log  & 2>&1
```

tidb

```
# cat tidb-start.sh 
nohup  bin/tidb-server  --store=tikv  --path="172.28.3.131:2379" --log-file=tidb.log &  2>&1
```
