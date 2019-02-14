创建本地分支

```
git checkout master //进入master分支
git checkout -b dev //以master为源创建分支dev
git checkout dev
git checkout -b fromdev //以dev为源创建分支fromdev
git push origin fromdev //将本地fromdev分支作为远程fromdev分支
git add -A .
git commit 'test fromdev'
git  --set-upstream origin fromdev
合并fromdev到dev
git checkout dev //先切换到dev
git merge fromdev
```
