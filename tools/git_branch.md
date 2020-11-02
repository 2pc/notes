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

git merge branch_name 之后可能出现冲突

可以用git status查看冲突的是哪些文件,比如

```
$ git status                                            
On branch xxx                                     
Your branch is up to date with 'origin/xxx'.         
                                                        
You have unmerged paths.                                
  (fix conflicts and run "git commit")                  
  (use "git merge --abort" to abort the merge)          
                                                        
Changes to be committed:                                
                                                        
        modified:   dispatcher-spark-streaming/pom.xml  
        deleted:    dispatcher-spark-streaming/src/main/
        deleted:    dispatcher-spark-streaming/src/main/
        deleted:    dispatcher-spark-streaming/src/main/
        modified:   dispatcher-spark-streaming/src/main/
        new file:   dispatcher-spark-streaming/src/main/
        modified:   dispatcher-spark-streaming/src/main/
        modified:   dispatcher-structured-streaming/src/
        modified:   dispatcher-structured-streaming/src/
        modified:   dispatcher-structured-streaming/src/
        modified:   dispatcher-structured-streaming/src/
        modified:   dispatcher-structured-streaming/src/
        new file:   dispatcher-structured-streaming/src/
        modified:   dispatcher-structured-streaming/src/
                                                        
Unmerged paths:                                         
  (use "git add/rm <file>..." as appropriate to mark res
                                                        
        both modified:   dispatcher-static-table/pom.xml
        both modified:   dispatcher-structured-streaming
        deleted by us:   dispatcher-structured-streaming

```
删除分支

```
git push --delete origin deletebranch
```

