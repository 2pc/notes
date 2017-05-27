```
2017-05-27 16:53:34.167 [destination = example , address = /127.0.0.1:3306 , EventParser] INFO  c.a.otter.canal.parse.inbound.mysql.MysqlConnection - COM_BINLOG_DUMP with position:BinlogDumpCommandPacket[binlogPosition=1199597,slaveServerId=1234,binlogFileName=mysql-bin.000001,command=18]
2017-05-27 16:53:34.168 [destination = example , address = /127.0.0.1:3306 , EventParser] WARN  c.a.otter.canal.parse.inbound.mysql.MysqlEventParser - ERROR ## parse this event has an error , last position : [mysql-bin.000001,1199597]
java.lang.NullPointerException: null
	at com.alibaba.otter.canal.parse.inbound.AbstractEventParser$3$1.sink(AbstractEventParser.java:178) ~[canal.parse-1.0.25-SNAPSHOT.jar:na]
	at com.alibaba.otter.canal.parse.inbound.mysql.MysqlConnection.dump(MysqlConnection.java:130) [canal.parse-1.0.25-SNAPSHOT.jar:na]
	at com.alibaba.otter.canal.parse.inbound.AbstractEventParser$3.run(AbstractEventParser.java:210) [canal.parse-1.0.25-SNAPSHOT.jar:na]
	at java.lang.Thread.run(Thread.java:745) [na:1.8.0_77]
2017-05-27 16:53:34.168 [destination = example , address = /127.0.0.1:3306 , EventParser] ERROR c.a.otter.canal.parse.inbound.mysql.MysqlEventParser - dump address /127.0.0.1:3306 has an error, retrying. caused by 
com.alibaba.otter.canal.parse.exception.CanalParseException: java.lang.NullPointerException
Caused by: java.lang.NullPointerException: null
	at com.alibaba.otter.canal.parse.inbound.AbstractEventParser$3$1.sink(AbstractEventParser.java:178) ~[canal.parse-1.0.25-SNAPSHOT.jar:na]
	at com.alibaba.otter.canal.parse.inbound.mysql.MysqlConnection.dump(MysqlConnection.java:130) ~[canal.parse-1.0.25-SNAPSHOT.jar:na]
	at com.alibaba.otter.canal.parse.inbound.AbstractEventParser$3.run(AbstractEventParser.java:210) ~[canal.parse-1.0.25-SNAPSHOT.jar:na]
	at java.lang.Thread.run(Thread.java:745) [na:1.8.0_77]
2017-05-27 16:53:34.169 [destination = example , address = /127.0.0.1:3306 , EventParser] ERROR com.alibaba.otter.canal.common.alarm.LogAlarmHandler - destination:example[com.alibaba.otter.canal.parse.exception.CanalParseException: java.lang.NullPointerException
Caused by: java.lang.NullPointerException
	at com.alibaba.otter.canal.parse.inbound.AbstractEventParser$3$1.sink(AbstractEventParser.java:178)
	at com.alibaba.otter.canal.parse.inbound.mysql.MysqlConnection.dump(MysqlConnection.java:130)
	at com.alibaba.otter.canal.parse.inbound.AbstractEventParser$3.run(AbstractEventParser.java:210)
	at java.lang.Thread.run(Thread.java:745)
]
2017-05-27 16:53:34.169 [destination = example , address = /127.0.0.1:3306 , EventParser] INFO  c.alibaba.otter.canal.parse.driver.mysql.MysqlConnector - disConnect MysqlConnection to /127.0.0.1:3306...
2017-05-27 16:53:34.169 [destination = example , address = /127.0.0.1:3306 , EventParser] INFO  c.alibaba.otter.canal.pars
```
