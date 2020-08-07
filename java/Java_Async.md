No such extension org.apache.dubbo.rpc.cluster.LoadBalance by name random
报错代码
```
public  CompletableFuture<Long> processAsync(){
    return redisCacheService.getDistibutedLockAsync().thenComposeAsync(lock ->{
        return idService.getIdAsync();
    });
}
```
跟这个issue是一样的[Dubbo-5829](https://github.com/apache/dubbo/issues/5829)

暂时改成

```
public  CompletableFuture<Long> processAsync(){
    return redisCacheService.getDistibutedLockAsync().thenCompos(lock ->{
        return idService.getIdAsync();
    });
}
```
