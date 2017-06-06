log信息的格式:

>
. 当使用org.apache.log4j.PatternLayout来自定义信息格式时，可以使用log4j.appender.A1.layout.ConversionPattern=%d{yyyy-MM-ddHH:mm:ss} %p-%m%n 来格式化信息
. %c 输出所属类的全名，可写为 %c{Num} ,Num类名输出的范围 如："com.sun.aaa.classB",%C{2}将使日志输出输出范围为：aaa.classB
. %d 输出日志时间其格式为 可指定格式 如 %d{HH:mm:ss}等
. %l 输出日志事件发生位置，包括类目名、发生线程，在代码中的行数
. %n 换行符
. %m 输出代码指定信息，如info(“message”),输出message
. %p 输出日志的优先级，即 FATAL ,ERROR 等
. %r 输出从启动到显示该条日志信息所耗费的时间（毫秒数）
. %t 输出产生该日志事件的线程名
