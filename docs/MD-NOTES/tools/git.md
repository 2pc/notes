
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

git config --global user.name youname
git config --global user.email yourmail

```

#### repo config

```
git config user.name yourname
git config user.email yourmail
git config --list
```

####  远程地址

```
git remote -v
```


remote: Permission to B/Demo.git denied to A.fatal: unable to access 'https://github.com/A/Demo.git/': The requested URL returned error: 403   
. [Git push/pull的时候报403或者提交时报错：Permission to XXX.git denied to user](https://blog.csdn.net/ltstud/article/details/77895382?locationNum=10&fps=1)   
. [Git 最著名报错 “ERROR: Permission to XXX.git denied to user”终极解决方案](https://www.jianshu.com/p/12badb7e6c10)

####  reset

```
git reset --hard commitid
git push -f
```

### 查询commit位于那个分支

```
$ git branch -r --contains fdb11c52f1d0f39abceee02f4ad5beaf1034e05f
  origin/release-1.6

```

### 删除分支
```
git push origin --delete tmp
git branch -D tmp
```

### book 

[Pro Git book](https://git-scm.com/book/zh/v2)


