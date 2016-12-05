
### 下载源代码
```
git clone https://github.com/thunlp/THULAC-Java
```
### 下载模型 [thulac.thunlp.org](http://thulac.thunlp.org/)下载文件Models_v1_v2.zip,解压到THULAC-Java目录
```
cp Models_v1_v2.zip  /data/nlp/THULAC-Java/
cd /data/nlp/THULAC-Java/
unzip Models_v1_v2.zip
# ls THULAC-Java/
doc  input.txt  __MACOSX  models  Models_v1_v2.zip  output.txt  README.md  src  THULAC_lite_java_run.jar
```

### 使用  

java -jar THULAC_lite_java_run.jar [-t2s] [-seg_only] [-deli delimeter] [-user userword.txt] -input input_file -output   
* -t2s 是否繁体转换成简体   
* -seg_only 仅分词   
* -deli 分隔符   
* -user 用户自定义词典   
* -input输入文件   
* -output  输出文件

cat input.txt   
```
还珠格格第二部 青云志第二部
千載正字一夕改 如今吾輩來重光
```

```
# java -jar THULAC_lite_java_run.jar  -t2s   -deli "/"  -input input.txt 
还/d 珠/g 格格/j 第二/m 部/q 青云志/ns 第二/m 部/q 
千载正字一夕/id 改/v 如今/t 吾/r 辈/n 来/v 重光/a 
java -jar THULAC_lite_java_run.jar  -t2s   -deli "/"  -input input.txt  -output output.txt
```
