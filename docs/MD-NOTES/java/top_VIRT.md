top查看java进程的VIRT 偏高（远远超出了-Xmx的设置）

关注glibc的版本

注意export MALLOC_ARENA_MAX=1的设置，hadoop环境要求export MALLOC_ARENA_MAX=4


[64位Linux下Java进程堆外内存迷之64M问题](http://blog.11034.org/2016-09/64bits_linux_arena_memory.html)

[Java 进程占用 VIRT 虚拟内存超高的问题研究](http://www.cnblogs.com/seasonsluo/p/java_virt.html)

