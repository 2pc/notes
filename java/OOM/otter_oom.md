记一次otter的OOM

内存从默认的3072m升级到8192m ,还是会出现oom,还好产生了dump文件，关键这个文件有点大6.8g，

太大了不好下载下来，跳板机限速的，尝试过好几次都没成功，压缩完881M,传到200-200m网络就断了。

体验差，于是只能用jhat本地。jhat感觉效果还是不是太好。


```
# ls -lh  java_pid119697.hprof
-rw------- 1 data data 6.8G 4月   2 04:37 java_pid119697.hprof
```

最后想到了tar不是可以分包压缩解压缩么。

```
tar czf - java_pid119697.hprof  | split -b 100m  - test.tar.gz
# ls test.tar.gza* -lh
-rw-r--r-- 1 root root 100M 4月   2 11:31 test.tar.gzaa
-rw-r--r-- 1 root root 100M 4月   2 11:32 test.tar.gzab
-rw-r--r-- 1 root root 100M 4月   2 11:32 test.tar.gzac
-rw-r--r-- 1 root root 100M 4月   2 11:32 test.tar.gzad
-rw-r--r-- 1 root root 100M 4月   2 11:33 test.tar.gzae
-rw-r--r-- 1 root root 100M 4月   2 11:33 test.tar.gzaf
-rw-r--r-- 1 root root 100M 4月   2 11:33 test.tar.gzag
-rw-r--r-- 1 root root 100M 4月   2 11:33 test.tar.gzah
-rw-r--r-- 1 root root  81M 4月   2 11:34 test.tar.gzai
```

每个大小100m,总共分9个文件，都慢慢传下来，然后解压缩得到整个文件java_pid119697.hprof

```
cat test.tar.gza* | tar -jx
```
