
```

```

启动nameServer(172.17.32.127,172.17.32.128)

```
bash mqnamesrv & 
```


设置好ROCKETMQ_HOME
```
export ROCKETMQ_HOME=/data/RocketMQ/devenv
```

启动一个2Master+2Slave模式集群，异步复制   

### 先启动Name Server(172.17.32.127:9876/172.17.32.128:9876)
```
cd /data/RocketMQ/devenv
nohup sh bin/mqnamesrv >namesrv.log 2>&1 & 
```
### 在机器 A，启动第一个 Master
```
cd /data/RocketMQ/devenv
nohup sh bin/mqbroker -c conf/2m-2s-async/broker-a.properties  >broker-a.log 2>&1 & 
```
cat conf/2m-2s-async/broker-a.properties

```
# cat conf/2m-2s-async/broker-a.properties
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
namesrvAddr=172.17.32.127:9876;172.17.32.128:9876
brokerClusterName=DefaultCluster
brokerName=broker-a
brokerId=0
deleteWhen=04
fileReservedTime=48
brokerRole=ASYNC_MASTER
flushDiskType=ASYNC_FLUSH
```
### 在机器 B，启动第二个 Master

```
cd /data/RocketMQ/devenv
nohup sh bin/mqbroker -c conf/2m-2s-async/broker-b.properties  >broker-b.log 2>&1 & 
```
cat conf/2m-2s-async/broker-b.properties

```
# cat conf/2m-2s-async/broker-b.properties
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
namesrvAddr=172.17.32.127:9876;172.17.32.128:9876
brokerClusterName=DefaultCluster
brokerName=broker-b
brokerId=0
deleteWhen=04
fileReservedTime=48
brokerRole=ASYNC_MASTER
flushDiskType=ASYNC_FLUSH
```
### 在机器 C，启动第一个 Slave

```
cd /data/RocketMQ/devenv
nohup sh bin/mqbroker -c conf/2m-2s-async/broker-a-s.properties  >broker-a-s.log 2>&1 & 
```
cat conf/2m-2s-async/broker-a-s.properties

```
# cat conf/2m-2s-async/broker-a-s.properties
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
namesrvAddr=172.17.32.127:9876;172.17.32.128:9876
brokerClusterName=DefaultCluster
brokerName=broker-a
brokerId=1
deleteWhen=04
fileReservedTime=48
brokerRole=SLAVE
flushDiskType=ASYNC_FLUSH
```

### 在机器 D，启动第二个 Slave

```
cd /data/RocketMQ/devenv
nohup sh bin/mqbroker -c conf/2m-2s-async/broker-b-s.properties  >broker-b-s.log 2>&1 & 
```

cat conf/2m-2s-async/broker-b-s.properties

```
# cat conf/2m-2s-async/broker-b-s.properties
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
namesrvAddr=172.17.32.127:9876;172.17.32.128:9876
brokerClusterName=DefaultCluster
brokerName=broker-b
brokerId=1
deleteWhen=04
fileReservedTime=48
brokerRole=SLAVE
flushDiskType=ASYNC_FLUSH
```

### rocketmq-console

这里用的[嘀嗒拼车基于rocketmq-tools 3.5.8版本开发的一个RocketMQ console](https://github.com/didapinchegit/rocket-console)

```
git clone  https://github.com/didapinchegit/rocket-console
cd rocket-console
mvn clean install -Dmaven.test.skip=true
cp target/rocketmq-console-1.0.0-SNAPSHOT.war  /data/jetty/webapps/
```
打包之前需要修改namesrv的配置，位于src/main/resources/config.properties

```
rocketmq.namesrv.addr=172.17.32.127:9876
```
使用到jetty启动，增加了jetty的配置文件src/main/webapp/WEB-INF/jetty-web.xml

```
<?xml version="1.0"  encoding="ISO-8859-1"?>
<!DOCTYPE Configure PUBLIC "-//Mort Bay Consulting//DTD Configure//EN" "http://www.eclipse.org/jetty/configure_9_0.dtd">

<!-- This is the jetty specific web application configuration file. When starting a Web Application, the WEB-INF/jetty-web.xml file is looked for and if found, treated as a org.eclipse.jetty.server.server.xml.XmlConfiguration 
	file and is applied to the org.eclipse.jetty.servlet.WebApplicationContext object -->

<Configure class="org.eclipse.jetty.webapp.WebAppContext">
	<Set name="contextPath">/</Set>
	<Set name="maxFormContentSize" type="int">10000000</Set>
	<Set name="extractWAR">true</Set>
	<Set name="copyWebDir">false</Set>
	<!--
	<Set name="virtualHosts">
		<Array type="String">
			<Item>conf.meizu.com</Item>
		</Array>
	</Set>
-->
</Configure>
```
访问地址 

```
http://ip:8080/cluster.html
http://ip:8080/topic.html
http://ip:8080/consumer.html
http://ip:8080/producer.html
http://ip:8080/message.html
```
