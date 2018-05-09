
配置Celery把[django-celery-results](https://github.com/celery/django-celery-results/blob/master/django_celery_results/backends/database.py)当作backend,只需要在setting.py中添加

```
CELERY_RESULT_BACKEND = 'django-db'
```

beat_scheduler配置

默认为："celery.beat:PersistentScheduler"，   
如果使用了django-celery-beat扩展，这个就是："django_celery_beat.schedulers:DatabaseScheduler"   
[DatabaseScheduler](https://github.com/celery/django-celery-beat/blob/master/django_celery_beat/schedulers.py#L169)
