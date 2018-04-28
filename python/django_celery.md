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
