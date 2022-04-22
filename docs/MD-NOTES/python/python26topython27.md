升级python2.6到2.7
安装需要的软件包
```
yum install -y zlib-devel bzip2-devel openssl-devel xz-libs wget
```
源码安装Python 2.7.8
```
wget http://www.python.org/ftp/python/2.7.8/Python-2.7.8.tar.xz
xz -d Python-2.7.8.tar.xz
tar -xvf Python-2.7.8.tar
# 进入目录:
cd Python-2.7.8
# 运行配置 configure:
./configure --prefix=/usr/local
# 编译安装:
make
make install
mv /usr/bin/python /usr/bin/pythonbak
ln -s /usr/local/bin/python2.7  /usr/bin/python
```
yum修复
```
vim /usr/bin/yum
#修改 yum中的python 
将第一行  #!/usr/bin/python  改为 #!/usr/bin/python2.7
```
[升级python3 pip3 ](http://www.jianshu.com/p/8bd6e0695d7f)

#  升级3.5之后使用yum lrzsz报错
```
Downloading packages:
  File "/usr/libexec/urlgrabber-ext-down", line 28
    except OSError, e:
                  ^
SyntaxError: invalid syntax
```   
修改   
```
vim /usr/libexec/urlgrabber-ext-down
将第一行  #!/usr/bin/python  改为 #!/usr/bin/python2.7
```
