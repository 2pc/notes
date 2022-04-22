```
 wget https://storage.googleapis.com/golang/go${version}.tar.gz 
 tar zxvf go${version}.tar.gz  -C ${GOROOT} 
 mkdir  ${GOPATH}
 cd ${GOPATH} 
 mkdir -p bin src pkg
```

环境变量配置

```
#根目录
export GOROOT=${GOROOT} 
#bin目录
export GOBIN=$GOROOT/bin
#工作目录
export GOPATH=${GOPATH}
export PATH=$PATH:$GOPATH:$GOBIN:$GOPATH
```
