
```
bin/spark-submit  --class com.pingcap.tispark.TiSparkTest --master local[1] tispark-0.1.0-SNAPSHOT-jar-with-dependencies.jar  
```

```
package com.pingcap.tispark                                         
                                                                    
import org.apache.spark.sql.SparkSession                            
                                                                    
                                                                    
                                                                    
import org.apache.spark.sql.TiContext                               
                                                                    
                                                                    
object  TiSparkTest{                                                
                                                                    
  def main(args: Array[String]) {                                   
    val spark = SparkSession                                        
      .builder()                                                    
      .appName("Spark SQL basic example")                           
      .config("spark.some.config.option", "some-value")             
       //.master("spark://172.28.3.158:7070")                       
      .getOrCreate()                                                
                                                                    
                                                                    
    // For implicit conversions like converting RDDs to DataFrames  
    //import spark.implicits._                                      
                                                                    
    val ti = new TiContext (spark, List ("172.28.3.131:2379"))      
    ti.tidbMapDatabase ("test")                                     
    spark.sql("select * from a left join d on a.bid=d.aid").show    
                                                                    
  }                                                                 
                                                                    
}                                                                   
                                                                    
```
