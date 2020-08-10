redis 大key删除

Large Hash Key 可使用hscan命令，每次获取500个字段，再用hdel命令，每次删除1个字段。

Large Set Key 可使用sscan命令，每次扫描集合中500个元素，再用srem命令每次删除一个键。

Large List Key可通过ltrim命令每次删除少量元素

Large Sorted Set Key使用sortedset自带的zremrangebyrank命令,每次删除top 100个元素

[Deleting Large Objects in Redis](https://www.redisgreen.net/blog/deleting-large-objects/)

[Redis4.x-UNLINK](https://redis.io/commands/unlink)

[Redis 4.0 非阻塞删除](http://russellluo.com/2018/08/async-del-since-redis-4-0.html)

[Is the UNLINK command always better than DEL command?
](https://stackoverflow.com/questions/45818371/is-the-unlink-command-always-better-than-del-command)
