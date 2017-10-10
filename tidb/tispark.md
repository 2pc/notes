
spark2.1  jdk1.8
```
#  spark2-shell  --jars ./tispark-0.1.0-SNAPSHOT-jar-with-dependencies.jar 
scala> import org.apache.spark.sql.TiContext
import org.apache.spark.sql.TiContext

scala> val ti = new TiContext(spark, List("172.28.3.131:"+2379))
ti: org.apache.spark.sql.TiContext = org.apache.spark.sql.TiContext@1c61f9bf

scala>  ti.tidbMapDatabase("test");

scala> spark.sql("select count(*) from tidb").show
```
