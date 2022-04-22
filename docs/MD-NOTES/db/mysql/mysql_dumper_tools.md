[mypumpkin-让mysqldump变成并发导出导入的魔法](https://yq.aliyun.com/articles/64667?spm=5176.100239.blogcont45739.12.TYwbpP)   
[mypumpkin-github](https://github.com/seanlook/mypumpkin)   
[]()


mydumper

```
./mydumper  -h 172.28.3.26 -u root -p root123 -B oml -T c002_acct_payment_schedule -t 8 -F 1000 -o ./c002_acct_payment_schedule
```
参数：

>
. -B database
. -T table
. -t 线程顺
. -F 单个大小

```
 ./myloader   -u canal -p canal -B oml   -d ./c002_acct_payment_schedule  -h 172.28.3.131
```
