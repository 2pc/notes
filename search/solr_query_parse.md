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

