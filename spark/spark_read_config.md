--files  方式  多个文件“,”隔开

```
--files config.properties,meta.xml 
```
main()读取

```
String configFile ="config.properties";
Properties properties = new Properties();
properties.load(new FileInputStream(configFile));
```

spark-submit 提交

```
spark-submit    --master yarn --deploy-mode cluster     --files meta.xml  --class   com.spark.MainClass   bml-canal.jar  参数
```
