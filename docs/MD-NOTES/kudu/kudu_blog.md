### [kudu性能测试报告-网易大数据](https://bigdata.163.com/product/article/2)

### install 

 之前用的cdh5.12.x,是5.10以上版本，直接配置就好了。这次使用以下版本5.9

#### CDH 集成
[kudu和kudu-impala的安装流程](http://blog.csdn.net/weixin_39478115/article/details/78469962)   
[CDH集成KUDU](http://blog.csdn.net/qq_26398033/article/details/55099591)

修改为默认的impala-shell

 ```
 #  alternatives --display impala-shell
impala-shell - 状态是手工。
 链接目前指向 /opt/cloudera/parcels/IMPALA_KUDU-2.7.0-1.cdh5.9.0.p0.23/bin/impala-shell
/opt/cloudera/parcels/CDH-5.9.0-1.cdh5.9.0.p0.23/bin/impala-shell - 优先度 10
/opt/cloudera/parcels/IMPALA_KUDU-2.7.0-1.cdh5.9.0.p0.23/bin/impala-shell - 优先度 5
当前“最佳”版本是 /opt/cloudera/parcels/CDH-5.9.0-1.cdh5.9.0.p0.23/bin/impala-shell。
#-----------
 alternatives --set impala-shell /opt/cloudera/parcels/IMPALA_KUDU-2.7.0-1.cdh5.9.0.p0.23/bin/impala-shell  
 ```

#### rpm安装

[安装Impala](https://www.cnblogs.com/ciade/p/6221387.html)   
[impala-kudu安装](http://blog.csdn.net/mr_jack_xu/article/details/54135150)
