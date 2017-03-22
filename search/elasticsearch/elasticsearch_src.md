
gradle idea

#### JAVA_HOME must be set to build Elasticsearch

echo $JAVA_HOME 明明是有的，怎么会没有呢。

看到了这个[Build: can not find JAVA_HOME in eclipse gradle plugin. (#17645)](https://github.com/elastic/elasticsearch/commit/88fa4840cb385dd78b7702e53918d6d4efeec796)

懒得搞了，直接改groovy源码，给个值写死算了。

```
private static String findJavaHome() {
    String javaHome = System.getenv('JAVA_HOME')
    println "=================================================="
    println "" +javaHome
    javaHome = "/Library/Java/JavaVirtualMachines/jdk1.8.0_77.jdk/Contents/Home/"
    if (javaHome == null) {
        if (System.getProperty("idea.active") != null || System.getProperty("eclipse.launcher") != null) {
            // intellij doesn't set JAVA_HOME, so we use the jdk gradle was run with
            javaHome = Jvm.current().javaHome
        } else {
            throw new GradleException('JAVA_HOME must be set to build Elasticsearch')
        }
    }
    return javaHome
}
```
