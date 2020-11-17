
Window下使用goland调试v2ray-core


```
PS E:\code\github\v2ray-core> echo $HOME
C:\Users\Administrator
PS E:\code\github\v2ray-core> $env:CGO_ENABLED=0
PS E:\code\github\v2ray-core> go build -o $HOMEv2ray.exe -trimpath -ldflags "-s -w -buildid=" ./main
PS E:\code\github\v2ray-core> go build -o $HOME/v2ctl.exe -trimpath -ldflags "-s -w -buildid=" -tags confonly ./infra/control/main
```


golang配置 切记，首先要编译出v2ctl.exe


```
Run kind --> Package
Package Path --> v2ray.com/core/main
Enviroment --> v2ray.location.tool=C:\Users\Administrator
```
