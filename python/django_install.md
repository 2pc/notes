用的python3.5.2

```
# python
Python 3.5.2 (default, Jul 24 2017, 23:46:37) 
[GCC 4.4.7 20120313 (Red Hat 4.4.7-18)] on linux
```
安装django

```
pip install Django
```
安装完,发现用会找不到django-admin命令

```
# django-admin startproject mysite
-bash: django-admin: command not found
```
应该是路径不对，找到django路径
```
# python  
Python 3.5.2 (default, Jul 24 2017, 23:46:37) 
[GCC 4.4.7 20120313 (Red Hat 4.4.7-18)] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import django
>>> django
<module 'django' from '/usr/local/python3/lib/python3.5/site-packages/django/__init__.py'>
```

做一个链接

```
ln -s /usr/local/python3/lib/python3.5/site-packages/django/bin/django-admin.py  /usr/local/bin/django-admin.py
```

创建project,app

```
[root@bigdata169 django]# django-admin.py  startproject firstproject
c[root@bigdata169 django]# cd firstproject/
[root@bigdata169 firstproject]# 
[root@bigdata169 firstproject]# django-admin.py  startapp firstapp
# tree
.
├── firstapp
│   ├── admin.py
│   ├── apps.py
│   ├── __init__.py
│   ├── migrations
│   │   └── __init__.py
│   ├── models.py
│   ├── tests.py
│   └── views.py
├── firstproject
│   ├── __init__.py
│   ├── settings.py
│   ├── urls.py
│   └── wsgi.py
└── manage.py

3 directories, 12 files
```

django默认的数据库是sqlite,修改为mysql,修改firstproject/settings.py文件的DATABASES的配置即可

```
 grep -C 10 DATABA  firstproject/settings.py 
 DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql', #设置为mysql数据库
        'NAME': 'djangodb',  #mysql数据库名
        'USER': 'canal',  #mysql用户名，留空则默认为当前linux用户名
        'PASSWORD': 'canal',   #mysql密码
        'HOST': '172.28.3.159',  #留空默认为localhost
        'PORT': '3306',  #留空默认为3306端口
    }
}
```

修改完后执行python manage.py migrate,就可以看到生成的表了

```
mysql> use djangodb;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> show tables;
+----------------------------+
| Tables_in_djangodb         |
+----------------------------+
| auth_group                 |
| auth_group_permissions     |
| auth_permission            |
| auth_user                  |
| auth_user_groups           |
| auth_user_user_permissions |
| django_admin_log           |
| django_content_type        |
| django_migrations          |
| django_session             |
+----------------------------+
10 rows in set (0.01 sec)
```

[Django 教程](https://code.ziqiangxuetang.com/django/django-tutorial.html)
