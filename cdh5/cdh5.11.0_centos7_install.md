
初始化数据库   
参数格式：数据库类型 数据库名称 -h数据库主机名 -u数据库用户名 -p数据库密码--scm-host cmserver主机名 scm scm scm

``` 
/opt/cm-5.11.0/share/cmf/schema/scm_prepare_database.sh mysql cm -hnode5 -uroot -p123456 --scm-host node5 scm scm scm 
```


```
[14/Jun/2017 23:36:13 +0000] 11024 MainThread agent        ERROR    Caught unexpected exception in main loop.
Traceback (most recent call last):
  File "/opt/cm-5.11.0/lib64/cmf/agent/build/env/lib/python2.7/site-packages/cmf-5.11.0-py2.7.egg/cmf/agent.py", line 710, in __issue_heartbeat
    self._init_after_first_heartbeat_response(resp_data)
  File "/opt/cm-5.11.0/lib64/cmf/agent/build/env/lib/python2.7/site-packages/cmf-5.11.0-py2.7.egg/cmf/agent.py", line 948, in _init_after_first_heartbeat_re
sponse
    self.client_configs.load()
  File "/opt/cm-5.11.0/lib64/cmf/agent/build/env/lib/python2.7/site-packages/cmf-5.11.0-py2.7.egg/cmf/client_configs.py", line 713, in load
    new_deployed.update(self._lookup_alternatives(fname))
  File "/opt/cm-5.11.0/lib64/cmf/agent/build/env/lib/python2.7/site-packages/cmf-5.11.0-py2.7.egg/cmf/client_configs.py", line 434, in _lookup_alternatives
    return self._parse_alternatives(alt_name, out)
  File "/opt/cm-5.11.0/lib64/cmf/agent/build/env/lib/python2.7/site-packages/cmf-5.11.0-py2.7.egg/cmf/client_configs.py", line 446, in _parse_alternatives
    path, _, _, priority_str = line.rstrip().split(" ")
ValueError: too many values to unpack
```

解决方法： 修改/opt/cm-5.11.0/lib64/cmf/agent/build/env/lib/python2.7/site-packages/cmf-5.11.0-py2.7.egg/cmf/client_configs.py的_parse_alternatives()函数相关代码

ref [Linux7 下Hadoop集群用户管理方案之五 安装Hadoop集群遇到的坑](http://blog.csdn.net/line_aijava/article/details/71374391)

```
436   def _parse_alternatives(self, name, output):
437     """
438     Parses output from "update-alternatives --display". Returns a dictionary
439     mapping ClientConfigKey to ClientConfigValue.
440 
441     Alternatives not managed by CM are ignored.
442     """
443     ret = {}
444     for line in output.splitlines():
445       if line.startswith("/"):
446         path, _, _, priority_str = line.rstrip().split(" ")
447 
448         # Ignore the alternative if it's not managed by CM.
449         if CM_MAGIC_PREFIX not in os.path.basename(path):
450           continue
451 
452         try:
453           priority = int(priority_str)
454         except ValueError:
455           THROTTLED_LOG.info("Failed to parse %s: %s", name, line)
456 
457         key = ClientConfigKey(name, path)
458         value = ClientConfigValue(priority, self._read_generation(path))
459         ret[key] = value
460 
461     return ret
```
为,  即增加了446／461行的 for line in output.splitlines(): else: 判断

```
436   def _parse_alternatives(self, name, output):
437     """
438     Parses output from "update-alternatives --display". Returns a dictionary
439     mapping ClientConfigKey to ClientConfigValue.
440 
441     Alternatives not managed by CM are ignored.
442     """
443     ret = {}
444     for line in output.splitlines():
445       if line.startswith("/"):
446         if len(line.rstrip().split(" "))<=4:
447           path, _, _, priority_str = line.rstrip().split(" ")
448 
449           # Ignore the alternative if it's not managed by CM.
450           if CM_MAGIC_PREFIX not in os.path.basename(path):
451             continue
452 
453           try:
454             priority = int(priority_str)
455           except ValueError:
456             THROTTLED_LOG.info("Failed to parse %s: %s", name, line)
457 
458           key = ClientConfigKey(name, path)
459           value = ClientConfigValue(priority, self._read_generation(path))
460           ret[key] = value
461         else:
462           pass
463     return ret
```

### ERROR    Error, CM server guid updated, expected 5c4b5784-f99b-4f02-ba76-2f2445f245bc, received 26d8630e-3aa5-45c4-a0ee-b299fc937cc9

解决方法

```
 rm -rf  /opt/cm-5.11.0/lib/cloudera-scm-agent/cm_guid 
```


