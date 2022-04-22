安装gcc4.9.3后编译时出现unrecognized command line option “-std=c++11”

```
cp /usr/local/lib64/libstdc++.so.6.0.20 /usr/lib64/

ln -s /usr/lib64/libstdc++.so.6.0.20 /usr/lib64/libstdc++.so

ln -s /usr/lib64/libstdc++.so.6.0.20 /usr/lib64/libstdc++.so.6

ln -s /usr/local/bin/gcc /usr/bin/gcc

ln -s /usr/local/bin/g++ /usr/bin/g++

ln -s /usr/local/bin/gcc /usr/bin/cc

ln -s /usr/local/bin/c++ /usr/bin/c++
```
