#### BootStrap ClassLoader

```
import java.net.URL;

public class LibTest {

        public static void main(String[] args) {

                URL[] urls =sun.misc.Launcher.getBootstrapClassPath().getURLs();
                //URL[] urls = sun.misc.Launcher.getBootstrapClassPath().getURLs();  
                for (int i = 0; i < urls.length; i++) {  
                    System.out.println(urls[i].toExternalForm());  
                }  
                System.out.println("================");
                System.out.println(System.getProperty("sun.boot.class.path"));  
        }

}
```
输出

```
file:/usr/lib/jvm/jdk1.7.0_21/jre/lib/resources.jar
file:/usr/lib/jvm/jdk1.7.0_21/jre/lib/rt.jar
file:/usr/lib/jvm/jdk1.7.0_21/jre/lib/sunrsasign.jar
file:/usr/lib/jvm/jdk1.7.0_21/jre/lib/jsse.jar
file:/usr/lib/jvm/jdk1.7.0_21/jre/lib/jce.jar
file:/usr/lib/jvm/jdk1.7.0_21/jre/lib/charsets.jar
file:/usr/lib/jvm/jdk1.7.0_21/jre/lib/jfr.jar
file:/usr/lib/jvm/jdk1.7.0_21/jre/classes
================
/usr/lib/jvm/jdk1.7.0_21/jre/lib/resources.jar:/usr/lib/jvm/jdk1.7.0_21/jre/lib/rt.jar:/usr/lib/jvm/jdk1.7.0_21/jre/lib/sunrsasign.jar:/usr/lib/jvm/jdk1.7.0_21/jre/lib/jsse.jar:/usr/lib/jvm/jdk1.7.0_21/jre/lib/jce.jar:/usr/lib/jvm/jdk1.7.0_21/jre/lib/charsets.jar:/usr/lib/jvm/jdk1.7.0_21/jre/lib/jfr.jar:/usr/lib/jvm/jdk1.7.0_21/jre/classes
```

#### Extension ClassLoader

#### App ClassLoader


### 双亲委托 

>
1. 自底向上检查类是否已经加载
2. 自顶向下尝试加载类

[深入分析Java ClassLoader原理](http://blog.csdn.net/xyang81/article/details/7292380)
