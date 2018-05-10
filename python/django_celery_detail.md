
配置Celery把[django-celery-results](https://github.com/celery/django-celery-results/blob/master/django_celery_results/backends/database.py)当作backend,只需要在setting.py中添加

```
CELERY_RESULT_BACKEND = 'django-db'
```

beat_scheduler配置

默认为："celery.beat:PersistentScheduler"，   
如果使用了django-celery-beat扩展，这个就是："django_celery_beat.schedulers:DatabaseScheduler"   
[DatabaseScheduler](https://github.com/celery/django-celery-beat/blob/master/django_celery_beat/schedulers.py#L169)

定时任务调度的文章可以参考[Celery 源码解析四： 定时任务的实现](http://www.mamicode.com/info-detail-2090861.html   
[Github 开源了一个基于 Redis 的实现](https://github.com/liuliqiang/celerybeatredis)

### 消息broker分析的文章包括consumer与producer

消息的publish[Celery 源码解析六：Events 的实现](http://www.bubuko.com/infodetail-2403523.html)   
消息的消费consumer[Celery 源码解析七：Worker 之间的交互](https://www.colabug.com/1932713.html)
