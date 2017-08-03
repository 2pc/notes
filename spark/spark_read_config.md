--files  方式  多个文件“,”隔开

```
--files config.properties,meta.xml 
```
main读取

```
String configFile ="config.properties";
Properties properties = new Properties();
properties.load(new FileInputStream(configFile));
```
