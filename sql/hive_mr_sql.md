
词法分析，生成AST树，ParseDriver完成。   
分析AST树，AST拆分成查询子块，信息记录在QB，这个QB在下面几个阶段都需要用到，SemanticAnalyzer.doPhase1完成。   
从metastore中获取表的信息，SemanticAnalyzer.getMetaData完成。   
生成逻辑执行计划，SemanticAnalyzer.genPlan完成。   
优化逻辑执行计划，Optimizer完成，ParseContext作为上下文信息进行传递。   
生成物理执行计划，SemanticAnalyzer.genMapRedTasks完成。   
物理计划优化，PhysicalOptimizer完成，PhysicalContext作为上下文信息进行传递


#### Parse:  解析sql生成ASTNode

```
Driver.run()->Driver.runInternal()-->Driver.compileInternal()-->Driver.compile()-->ParseUtils.parse()
-->ParseDriver.parse()-->

```
生成ASTNode

```
//Driver.java
ASTNode tree;
try {
  tree = ParseUtils.parse(command, ctx);//  1，parse sql  to ASTNode
} catch (ParseException e) {}
//ParseUtils.java
/** Parses the Hive query. */
public static ASTNode parse(
    String command, Context ctx, String viewFullyQualifiedName) throws ParseException {
  ParseDriver pd = new ParseDriver();
  ASTNode tree = pd.parse(command, ctx, viewFullyQualifiedName);
  tree = findRootNonNullToken(tree);
  handleSetColRefs(tree);
  return tree;
}
```
ParseDriver.parse代码(省略部分代码)

```
public ASTNode parse(String command, Context ctx, String viewFullyQualifiedName){
  HiveLexerX lexer = new HiveLexerX(new ANTLRNoCaseStringStream(command));
  TokenRewriteStream tokens = new TokenRewriteStream(lexer);
  HiveParser parser = new HiveParser(tokens);
  
  if (ctx != null) {
  parser.setHiveConf(ctx.getConf());
  }
  parser.setTreeAdaptor(adaptor);
  
  HiveParser.statement_return r = null;
  try {
  r = parser.statement();
  } catch (RecognitionException e) {}
  
  ASTNode tree = (ASTNode) r.getTree();
  tree.setUnknownTokenBoundaries();
  return tree;
}
```
HiveParser的代码太长了，暂且不看

#### 抽象语法树(AST)变成一个QB（Query Block） 

```
//Driver.java
BaseSemanticAnalyzer sem = SemanticAnalyzerFactory.get(queryState, tree);

if (!retrial) {
  openTransaction();
  generateValidTxnList();
}

sem.analyze(tree, ctx);// 2,BaseSemanticAnalyzer.analyze

//BaseSemanticAnalyzer.java
public void analyze(ASTNode ast, Context ctx) throws SemanticException {
  initCtx(ctx);
  init(true);
  analyzeInternal(ast);
}
//BaseSemanticAnalyzer.java
public void init(boolean clearPartsCache) {
  // clear most members
  reset(clearPartsCache);

  // init
  QB qb = new QB(null, null, false);
  this.qb = qb;
}
```

#### 生成Operator

```
Operator sinkOp = genOPTree(ast, plannerCtx);

Operator genOPTree(ASTNode ast, PlannerContext plannerCtx) throws SemanticException {
  // fetch all the hints in qb
  List<ASTNode> hintsList = new ArrayList<>();
  getHintsFromQB(qb, hintsList);
  getQB().getParseInfo().setHintList(hintsList);
  return genPlan(qb);
}
public Operator genPlan(QB qb) throws SemanticException {
  return genPlan(qb, false);
}

public Operator genPlan(QB qb, boolean skipAmbiguityCheck){
...
Operator<?> operator = genPlan(qb, qbexpr);
...
}
```

[HiveSQL解析过程详解](http://www.cnblogs.com/yaojingang/p/5446310.html)

