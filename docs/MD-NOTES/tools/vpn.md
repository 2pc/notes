
### 登陆VPN出现“未能正确打开SANGFOR SSL Virtual网卡，暂时不能提供SSL CS服务，请联系管理员”

```
$ sudo kextstat |grep tun
148    0 0xffffff7f83207000 0x5000     0x5000     net.sf.tuntaposx.tap (1) AA13DE34-83EB-3A07-A845-11B5841905BB <5 4 1>
149    0 0xffffff7f8320c000 0x5000     0x5000     net.sf.tuntaposx.tun (1) 56286E58-CD9F-3166-86BD-4D7E1856E0A5 <5 4 1>
```


```
sudo  kextunload -b net.sf.tuntaposx.tun
$ sudo kextstat |grep tun
148    0 0xffffff7f83207000 0x5000     0x5000     net.sf.tuntaposx.tap (1) AA13DE34-83EB-3A07-A845-11B5841905BB <5 4 1>

```
