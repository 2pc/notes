
### common op
```
git clone https://github.com/2pc/kcws
git add README.md 
git commit -m "add doc for run web service"
git push origin master
git remote set-url origin https://2pc@github.com/2pc/kcws.git
git push origin master
```
### error1: The requested URL returned error: 403 while accessing https://github.com/2pc/kcws.git/info/refs fatal: HTTP request failed
```
git remote set-url origin https://2pc@github.com/2pc/kcws.git
```

[Git 的origin和master分析](http://www.cnblogs.com/0616--ataozhijia/p/4165444.html)

### config

#### global config

```
git config global user.name youname
git config global user.email yourmail

```

#### repo config

```
git config user.name yourname
git config user.email yourmail
git config --list
```
