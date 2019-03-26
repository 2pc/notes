web项目node可能会出现 not permit错位，执行下npm cache clean --force
```
cd code/github/blink/
git branch -a
git checkout blink
pwd
mvn clean package -Dmaven.test.skip=true -Dcheckstyle.skip=true -Denforcer.skip=true
npm cache clean --force
mvn clean package -Dmaven.test.skip=true -Dcheckstyle.skip=true -Denforcer.skip=true
pwd
ls target/
ls flink-dist/
ls flink-dist/target/
```
