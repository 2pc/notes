### django集成celery

```
python2.7.12
django1.9.8
celery4.0.2
```
还需要安装mysql,django-celery-results,django-celery-beat

```
pip install celery
pip install django-celery-results 
pip install django-celery-beat
```
创建celery的project以及对应的task()也就是django的app

```
django-admin startproject  celeryproj
django-admin startapp celerytaskapp1
```
工程结构

```
$ tree
.
├── celerybeat.pid
├── celeryproj
│   ├── __init__.py
│   ├── __init__.pyc
│   ├── celery.py
│   ├── celery.pyc
│   ├── settings.py
│   ├── settings.pyc
│   ├── urls.py
│   ├── urls.pyc
│   └── wsgi.py
├── celerytaskapp1
│   ├── __init__.py
│   ├── admin.py
│   ├── apps.py
│   ├── migrations
│   │   └── __init__.py
│   ├── models.py
│   ├── tasks.py
│   ├── tests.py
│   └── views.py
└── manage.py
```


启动work

```
celery worker   -A celeryproj  -l info
```

启动beat
```
$ celery -A celeryproj  beat -l info -S django
celery beat v4.0.2 (latentcall) is starting.
__    -    ... __   -        _
LocalTime -> 2018-04-28 09:44:30
Configuration ->
    . broker -> redis://172.28.3.158:6379/0
    . loader -> celery.loaders.app.AppLoader
    . scheduler -> django_celery_beat.schedulers.DatabaseScheduler

    . logfile -> [stderr]@%INFO
    . maxinterval -> 5.00 seconds (5s)
[2018-04-28 09:44:30,156: INFO/MainProcess] beat: Starting...
[2018-04-28 09:44:30,157: INFO/MainProcess] Writing entries...
[2018-04-28 09:44:30,311: INFO/MainProcess] DatabaseScheduler: Schedule changed.
[2018-04-28 09:44:30,311: INFO/MainProcess] Writing entries...
[2018-04-28 09:44:35,274: INFO/MainProcess] Writing entries...
[2018-04-28 09:44:35,300: INFO/MainProcess] Scheduler: Sending due task task-one (celerytaskapp1.tasks.print_hello)
[2018-04-28 09:44:40,286: INFO/MainProcess] Scheduler: Sending due task task-one (celerytaskapp1.tasks.print_hello)
[2018-04-28 09:44:45,285: INFO/MainProcess] Scheduler: Sending due task task-one (celerytaskapp1.tasks.print_hello)
[2018-04-28 09:44:50,286: INFO/MainProcess] Scheduler: Sending due task task-one (celerytaskapp1.tasks.print_hello)

```
