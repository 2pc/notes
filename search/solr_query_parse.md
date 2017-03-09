### Solr Query 

Solr QueryString 最终也要转换成Lucene Query

可以从SearchHandler开始，

```
SearchHandler>handleRequestBody()-->QueryComponent.prepare()/QueryComponent.process()
```
prepare中进行参数解析，包括
>
1. 找到QParser
2. 生成对应Query
3. 生成对应Filter
4. 生成对应的Group

process中调用SolrIndexSearher的search实际调用了IndexSearcher的search()

```
SearchHandler>handleRequestBody()-->QueryComponent.process-->SolrIndexSearcher.search(result, cmd)
-->getDocSet/getDocListAndSetNC/getDocListNC-->(buildAndRunCollectorChain)()--> super.search(query, collector)
```

>
1. [全面解剖 Solr query 到lucene query](http://blog.sina.com.cn/s/blog_4d58e3c001017ynp.html)
2. [solr搜索过程解析](http://blog.csdn.net/morningsun1990/article/details/48541465)
3. [Solr 查询中fq参数的解析原理](http://blog.sina.com.cn/s/blog_56fd58ab0100v3up.html)
4. [Solr之缓存篇](https://my.oschina.net/u/1026644/blog/123957)
5. [Solr查询过程源码分析](http://blog.csdn.net/flyingpig4/article/details/6305488)
6. [Solr4.8.0源码分析(5)之查询流程分析总述](http://www.cnblogs.com/rcfeng/p/3923534.html)
7. [结合源码分析Solr&Lucene查询打分的工作流程](http://blog.csdn.net/yangbutao/article/details/9768317)
8. [solr4.2 edismax查询方式评分计算](http://fwuwen.iteye.com/blog/1870943)
9. [Solr dismax 源码详解以及使用方法](http://www.wxdl.cn/index/solr-dismax.html)
10. [Solr 的edismax与dismax比较与分析](http://www.linuxidc.com/Linux/2012-10/72373.htm)
