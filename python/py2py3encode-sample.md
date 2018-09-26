python 正常print不乱码的包含中文的map或者list

```
import json
print "result: "+ json.dumps(map, encoding="UTF-8", ensure_ascii=False)
print '\n'.join(list)
```

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

#print ','.join(['中文1','中文2'])
>>> print ["中文"]
['\xe4\xb8\xad\xe6\x96\x87']
>>> print ["asdf", "中文"]
['asdf', '\xe4\xb8\xad\xe6\x96\x87']
>>> print '[' + ', '.join(["asdf", "中文"]) + ']'
[asdf, 中文]
>>> print ", ".join(["asdf", "中文"])
asdf, 中文
```

python3.5.1 
[解决Python3下打印utf-8字符串出现UnicodeEncodeError的问题](http://www.binss.me/blog/solve-problem-of-python3-raise-unicodeencodeerror-when-print-utf8-string/)
```
[root@2983432b47f6 char-rnn-cn]# python
Python 3.5.1 (default, Dec  1 2016, 16:04:10) 
[GCC 4.8.5 20150623 (Red Hat 4.8.5-4)] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> print('\u8266')
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
UnicodeEncodeError: 'ascii' codec can't encode character '\u8266' in position 0: ordinal not in range(128)
>>> sys.stdout
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
NameError: name 'sys' is not defined
>>> import sys
>>> sys.stdout
<_io.TextIOWrapper name='<stdout>' mode='w' encoding='ANSI_X3.4-1968'>
>>> sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
NameError: name 'io' is not defined
>>> import io
>>> print('\u8266')
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
UnicodeEncodeError: 'ascii' codec can't encode character '\u8266' in position 0: ordinal not in range(128)
>>> sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
>>> sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')^[[A^[[B
  File "<stdin>", line 1
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
                                                                      ^
SyntaxError: invalid syntax
>>> print('\u8266')
艦

```
