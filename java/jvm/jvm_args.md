jvm 参数   
>
1. -Xms java heap 的初始大小，默认物理内存的1/64
2. -Xmx java heap 的最大值，不可超过物理内存
3. -Xmn：young generation的heap大小，一般设置为Xmx的3、4分之一 。增大年轻代后,将会减小年老代大小。
