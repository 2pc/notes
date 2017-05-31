在mac环境下，只需要以下简单的设置就可以查看了 

```
mysql>set global general_log=on;  
mysql> show variables like 'general_log_file'

```

在Mac OS X 中默认是没有my.cnf 文件，可以拷贝如下文件夹里的

```
/usr/local/mysql/support-files/
```
