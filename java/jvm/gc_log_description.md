```
{Heap before GC invocations=5 (full 0):
 par new generation   total 1747648K, used 1747648K [0x00000005fae00000, 0x000000067ae00000, 0x000000067ae00000)
  eden space 1398144K, 100% used [0x00000005fae00000, 0x0000000650360000, 0x0000000650360000)
  from space 349504K, 100% used [0x00000006658b0000, 0x000000067ae00000, 0x000000067ae00000)
  to   space 349504K,   0% used [0x0000000650360000, 0x0000000650360000, 0x00000006658b0000)
 concurrent mark-sweep generation total 6291456K, used 1131344K [0x000000067ae00000, 0x00000007fae00000, 0x00000007fae00000)
 concurrent-mark-sweep perm gen total 32768K, used 32581K [0x00000007fae00000, 0x00000007fce00000, 0x0000000800000000)
2016-09-06T15:58:42.350+0800: 323.021: [GC 323.022: [ParNew
Desired survivor size 322102880 bytes, new threshold 8 (max 8)
- age   1:  274482200 bytes,  274482200 total
: 1747648K->347577K(1747648K), 0.4539530 secs] 2878992K->1809287K(8039104K), 0.4550950 secs] [Times: user=1.43 sys=0.08, real=0.46 secs] 
Heap after GC invocations=6 (full 0):
 par new generation   total 1747648K, used 347577K [0x00000005fae00000, 0x000000067ae00000, 0x000000067ae00000)
  eden space 1398144K,   0% used [0x00000005fae00000, 0x00000005fae00000, 0x0000000650360000)
  from space 349504K,  99% used [0x0000000650360000, 0x00000006656ce620, 0x00000006658b0000)
  to   space 349504K,   0% used [0x00000006658b0000, 0x00000006658b0000, 0x000000067ae00000)
 concurrent mark-sweep generation total 6291456K, used 1461709K [0x000000067ae00000, 0x00000007fae00000, 0x00000007fae00000)
 concurrent-mark-sweep perm gen total 32768K, used 32581K [0x00000007fae00000, 0x00000007fce00000, 0x0000000800000000)
}
```

2016-09-06T15:58:42.350+0800: 323.021: [GC 323.022: [ParNew
Desired survivor size 322102880 bytes, new threshold 8 (max 8) - age   1:  274482200 bytes,  274482200 total
: 1747648K->347577K(1747648K), 0.4539530 secs] 2878992K->1809287K(8039104K), 0.4550950 secs] [Times: user=1.43 sys=0.08, real=0.46 secs] 

>
* "[GC" 或者"[FullGC" 说明了这次垃圾收集停顿的类型，而不是用来区分新生代GC还是年老代GC的，
如果有"FullGC"，说明这次GC发生了Stop-The-World(STW)
* "[DefNew(Default New Generation)","ParNew(Parallel New Generation)","PSYoungGen(Parallel Scavenge)" 新生代
* 1747648K->347577K(1747648K) GC前该内存区域已使用容量->GC后该内存区域已使用容量(该内存区域总容量)
* 2878992K->1809287K(8039104K) GC前Java堆使用容量->GC后Java堆使用容量(Java堆总容量)
