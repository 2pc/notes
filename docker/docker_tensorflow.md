docker install 

```
yum install https://get.docker.com/rpm/1.7.1/centos-6/RPMS/x86_64/docker-engine-1.7.1-1.el6.x86_64.rpm
service docker start
```

问题 Error response from daemon: Cannot start container xxxxxxxxxxxx: no such file or directory

解决：参考[CentOS6下docker的安装和使用](http://qicheng0211.blog.51cto.com/3958621/1582909)升级内核   

1. yum安装带aufs模块的3.10内核（或到这里下载kernel手动安装：http://down.51cto.com/data/1903250）
```
cd /etc/yum.repos.d 
wget http://www.hop5.in/yum/el6/hop5.repo
yum install kernel-ml-aufs kernel-ml-aufs-devel
```   
2. 修改grub的主配置文件/etc/grub.conf，设置default=0，表示第一个title下的内容为默认启动的kernel（一般新安装的内核在第一个位置）

```
#boot=/dev/sda
default=0
timeout=5
splashimage=(hd0,0)/grub/splash.xpm.gz
hiddenmenu
title CentOS (3.10.5-3.el6.x86_64)
```

重启

```
docker images
docker search tensorflow 
docker pull tensorflow/tensorflow
docker run -it -p 8888:8888 tensorflow/tensorflow bash
apt-get update 
apt-get install vim 
apt-get install git
docker ps
docker attach (container id)

```

centos

```
docker pull centos:6.6
docker run -i -t centos /bin/bash
```

