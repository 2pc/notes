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

process中

```
SearchHandler>handleRequestBody()-->QueryComponent.process-->SolrIndexSearcher.search(result, cmd)
-->getDocSet/getDocListAndSetNC/getDocListNC-->(buildAndRunCollectorChain)()--> super.search(query, collector)
```

