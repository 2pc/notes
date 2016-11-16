### Lucene Query parse

```
public static void main(String[] args) {
		try {
			System.out.println(getQuery("solrlucene").getClass().getName()+" : "+getQuery("solrlucene").toString());
			System.out.println(getQuery("solr*lucene").getClass().getName()+" : "+getQuery("solr*lucene").toString());
			System.out.println(getQuery("solr?lucene").getClass().getName()+" : "+getQuery("solr?lucene").toString());
			System.out.println(getQuery("solrlucene*").getClass().getName()+" : "+getQuery("solrlucene*").toString());
			//会报 : Cannot parse '*软件': '*' or '?' not allowed as first character in WildcardQuery
			//System.out.println(getQuery("*solrlucene").getClass().getName());
			System.out.println(getQuery("content:solr").getClass().getName()+" : "+getQuery("content:solr").toString());
			System.out.println(getQuery("solr lucene").getClass().getName()+" : "+getQuery("solr lucene").toString());
			System.out.println(getQuery("solr AND lucene").getClass().getName()+" : "+getQuery("solr AND lucene").toString());
			System.out.println(getQuery("solr OR lucene").getClass().getName()+" : "+getQuery("solr OR lucene").toString());
			System.out.println(getQuery("+solr -lucene").getClass().getName()+" : "+getQuery("+solr -lucene&fq=cpId:7").toString());
			System.out.println(getQuery("date:[1334550379955 TO 1334550379955]").getClass().getName()+" : "+getQuery("date:[1334550379955 TO 1334550379955]").toString());
			System.out.println(getQuery("name:xava~0.74").getClass().getName()+" : "+getQuery("name:xava~0.74").toString());
			System.out.println(getQuery("name:xava^0.74 AND age:18^100").getClass().getName()+" : "+getQuery("name:xava^0.74").toString());
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

  public static Query getQuery(String queryString) throws ParseException{  
      QueryParser parse = new QueryParser("content", new StandardAnalyzer());  
      Query query = null;  
      query = parse.parse(queryString);  
      return query;  
  }  
```
结果

```
org.apache.lucene.search.TermQuery : content:solrlucene
org.apache.lucene.search.WildcardQuery : content:solr*lucene
org.apache.lucene.search.WildcardQuery : content:solr?lucene
org.apache.lucene.search.PrefixQuery : content:solrlucene*
org.apache.lucene.search.TermQuery : content:solr
org.apache.lucene.search.BooleanQuery : content:solr content:lucene
org.apache.lucene.search.BooleanQuery : +content:solr +content:lucene
org.apache.lucene.search.BooleanQuery : content:solr content:lucene
org.apache.lucene.search.BooleanQuery : +content:solr -lucene&fq=cpId:7
org.apache.lucene.search.TermRangeQuery : date:[1334550379955 TO 1334550379955]
org.apache.lucene.search.FuzzyQuery : name:xava~1
org.apache.lucene.search.BooleanQuery : +name:xava^0.74 +age:18^100.0
```
