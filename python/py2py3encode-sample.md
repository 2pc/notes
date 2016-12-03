
python2

```
Python 2.7.5 (default, Sep 15 2016, 22:37:39) 
[GCC 4.8.5 20150623 (Red Hat 4.8.5-4)] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> import sys
>>> print sys.getdefaultencoding()
ascii
>>> a='\u4f5c'
>>> a
'\\u4f5c'
>>> print a.encode('utf-8')
\u4f5c
>>> a=u'\u4f5c'
>>> a
u'\u4f5c'
>>> print a.encode('utf-8')
作
```
