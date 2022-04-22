CPU 使用前N的进程

```
ps aux | sort -k3nr | head -n N
```
内存使用前N的进程

```
ps aux | sort -k4nr | head -n 10 
```

cat  /proc/pid/status
