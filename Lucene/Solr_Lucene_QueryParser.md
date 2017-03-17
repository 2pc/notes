语法解析

QueryParser类的parse函数在其父类SolrQueryParserBase中定义

```
public Query parse(String query) throws SyntaxError {
  ReInit(new FastCharStream(new StringReader(query)));
  try {
    // TopLevelQuery is a Query followed by the end-of-input (EOF)
    Query res = TopLevelQuery(null);  // pass null so we can tell later if an explicit field was provided or not
    return res!=null ? res : newBooleanQuery(false);
  }
  catch (ParseException | TokenMgrError tme) {
    throw new SyntaxError("Cannot parse '" +query+ "': " + tme.getMessage(), tme);
  } catch (BooleanQuery.TooManyClauses tmc) {
    throw new SyntaxError("Cannot parse '" +query+ "': too many boolean clauses", tmc);
  }
}
final public Query Query(String field) throws ParseException, SyntaxError {
List<BooleanClause> clauses = new ArrayList<BooleanClause>();
Query q, firstQuery=null;
int conj, mods;
  mods = Modifiers();
  q = Clause(field);
  addClause(clauses, CONJ_NONE, mods, q);
  if (mods == MOD_NONE)
      firstQuery=q;
  label_1:
  while (true) {
    switch ((jj_ntk==-1)?jj_ntk():jj_ntk) {
    case AND:
    case OR:
    case NOT:
    case PLUS:
    case MINUS:
    case BAREOPER:
    case LPAREN:
    case STAR:
    case QUOTED:
    case TERM:
    case PREFIXTERM:
    case WILDTERM:
    case REGEXPTERM:
    case RANGEIN_START:
    case RANGEEX_START:
    case LPARAMS:
    case NUMBER:
      ;
      break;
    default:
      jj_la1[4] = jj_gen;
      break label_1;
    }
    conj = Conjunction();
    mods = Modifiers();
    q = Clause(field);
    addClause(clauses, conj, mods, q);
  }
    if (clauses.size() == 1 && firstQuery != null)
      {if (true) return firstQuery;}
    else {
{if (true) return getBooleanQuery(clauses);}
    }
  throw new Error("Missing return statement in function");
}
```
>
1. Modifiers()返回修饰符号"+"或"-"
2. Conjunction() 返回关联关系(AND OR )
3. Clause生成一个字查询
4. addClause多个clause生成一个BooleanQuery

QueryParser(SolrQueryParserBase).parse()-->QueryParser.TopLevelQuery()-->QueryParser.Query()-->QueryParser.Modifiers()
```
final public int Modifiers() throws ParseException {
int ret = MOD_NONE;
  switch ((jj_ntk==-1)?jj_ntk():jj_ntk) {
  case NOT:
  case PLUS:
  case MINUS:
    switch ((jj_ntk==-1)?jj_ntk():jj_ntk) {
    case PLUS:
      jj_consume_token(PLUS);
            ret = MOD_REQ;
      break;
    case MINUS:
      jj_consume_token(MINUS);
               ret = MOD_NOT;
      break;
    case NOT:
      jj_consume_token(NOT);
             ret = MOD_NOT;
      break;
    default:
      jj_la1[2] = jj_gen;
      jj_consume_token(-1);
      throw new ParseException();
    }
    break;
  default:
    jj_la1[3] = jj_gen;
    ;
  }
  {if (true) return ret;}
  throw new Error("Missing return statement in function");
}
```
这里先看下一些变量的定义，关联与修饰
```
/** 这个查询对象和前一个查询对象之间的关联关系符号   苹果 AND iphone, 苹果 OR iphone, (苹果 iphone) */
static final int CONJ_NONE   = 0;
static final int CONJ_AND    = 1;
static final int CONJ_OR     = 2;
/** 查询对象的修饰符 "+title:netty权威指南"， */
static final int MOD_NONE    = 0;
static final int MOD_NOT     = 10;
static final int MOD_REQ     = 11;
```

[Lucene学习总结之八：Lucene的查询语法，JavaCC及QueryParser(2)](http://forfuture1978.iteye.com/blog/661680)
[lucene源码分析—QueryParser的parse函数](http://blog.csdn.net/conansonic/article/details/52021137)
