需要先安装[mono](https://www.telerik.com/download/fiddler/fiddler-osx-beta)

环境变量加上

```
export MONO_HOME=/Library/Frameworks/Mono.framework/Versions/5.14.0
export PATH=$PATH:$MONO_HOME/bin
```
安装完后下载证书

```
/Library/Frameworks/Mono.framework/Versions/5.14.0/bin/mozroots  --import --sync
```

解压fiddler-mac.zip到指定目录

```
unzip fiddler-mac.zip
```

在fiddler目录执行

```
mono --arch=32 Fiddler.exe 
```

注意前面的参数：--arch=32

