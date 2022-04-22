
```
sqoop import  --connect jdbc:mysql://172.28.3.26:3306/test  --username root --password 123456  --table agreement --target-dir  /tmp/agreement  --as-avrodatafile --null-non-string 'NULL' --null-string 'NULL' --compression-codec snappy
```
调用信息

```
at org.apache.hadoop.mapreduce.Job.submit(Job.java:1304)
at org.apache.hadoop.mapreduce.Job.waitForCompletion(Job.java:1325)
at org.apache.sqoop.mapreduce.ImportJobBase.doSubmitJob(ImportJobBase.java:203)
at org.apache.sqoop.mapreduce.ImportJobBase.runJob(ImportJobBase.java:176)
at org.apache.sqoop.mapreduce.ImportJobBase.runImport(ImportJobBase.java:273)
at org.apache.sqoop.manager.SqlManager.importTable(SqlManager.java:692)
at org.apache.sqoop.manager.MySQLManager.importTable(MySQLManager.java:127)
at org.apache.sqoop.tool.ImportTool.importTable(ImportTool.java:513)
at org.apache.sqoop.tool.ImportTool.run(ImportTool.java:621)
at org.apache.sqoop.Sqoop.run(Sqoop.java:147)
at org.apache.hadoop.util.ToolRunner.run(ToolRunner.java:70)
at org.apache.sqoop.Sqoop.runSqoop(Sqoop.java:183)
at org.apache.sqoop.Sqoop.runTool(Sqoop.java:234)
at org.apache.sqoop.Sqoop.runTool(Sqoop.java:243)
at org.apache.sqoop.Sqoop.main(Sqoop.java:252)
```

 main 函数入口位于Sqoop.java中
 
```
public class Sqoop extends Configured implements Tool {}
```

main()-->ToolRunner.run() 过程
```
public static void main(String [] args) {
  if (args.length == 0) {
    System.err.println("Try 'sqoop help' for usage.");
    System.exit(1);
  }

  int ret = runTool(args);
  System.exit(ret);
}
public static int runTool(String [] args) {
  return runTool(args, new Configuration());
}
public static int runTool(String [] args, Configuration conf) {
  // Expand the options
  String[] expandedArgs = null;
  try {
    expandedArgs = OptionsFileUtil.expandArguments(args);
  } catch (Exception ex) {
    LOG.error("Error while expanding arguments", ex);
    System.err.println(ex.getMessage());
    System.err.println("Try 'sqoop help' for usage.");
    return 1;
  }

  String toolName = expandedArgs[0];
  Configuration pluginConf = SqoopTool.loadPlugins(conf);
  SqoopTool tool = SqoopTool.getTool(toolName);
  if (null == tool) {
    System.err.println("No such sqoop tool: " + toolName
        + ". See 'sqoop help'.");
    return 1;
  }

  Sqoop sqoop = new Sqoop(tool, pluginConf);
  return runSqoop(sqoop,
      Arrays.copyOfRange(expandedArgs, 1, expandedArgs.length));
}
public static int runSqoop(Sqoop sqoop, String [] args) {
  String[] toolArgs = sqoop.stashChildPrgmArgs(args);
  try {
    return ToolRunner.run(sqoop.getConf(), sqoop, toolArgs);
  } catch (Exception e) {
    LOG.error("Got exception running Sqoop: " + e.toString());
    e.printStackTrace();
    rethrowIfRequired(toolArgs, e);
    return 1;
  }
}
```
注意这里的tool的获取

```
SqoopTool tool = SqoopTool.getTool(toolName);
public static final SqoopTool getTool(String toolName) {
  return (SqoopTool)org.apache.sqoop.tool.SqoopTool.getTool(toolName);
}
public static SqoopTool getTool(String toolName) {
  Class<? extends SqoopTool> cls = TOOLS.get(toolName);
  try {
    if (null != cls) {
      SqoopTool tool = cls.newInstance();
      tool.setToolName(toolName);
      return tool;
    }
  } catch (Exception e) {
    LOG.error(StringUtils.stringifyException(e));
    return null;
  }

  return null;
}
```
TOOLS是个TreeMap，在SqoopTool中的static通过registerTool()部分初始化

```
static {
  // All SqoopTool instances should be registered here so that
  // they can be found internally.
  TOOLS = new TreeMap<String, Class<? extends SqoopTool>>();
  DESCRIPTIONS = new TreeMap<String, String>();

  registerTool("codegen", CodeGenTool.class,
      "Generate code to interact with database records");
  registerTool("create-hive-table", CreateHiveTableTool.class,
      "Import a table definition into Hive");
  registerTool("eval", EvalSqlTool.class,
      "Evaluate a SQL statement and display the results");
  registerTool("export", ExportTool.class,
      "Export an HDFS directory to a database table");
  registerTool("import", ImportTool.class,
      "Import a table from a database to HDFS");
  registerTool("import-all-tables", ImportAllTablesTool.class,
      "Import tables from a database to HDFS");
  registerTool("import-mainframe", MainframeImportTool.class,
          "Import datasets from a mainframe server to HDFS");
  registerTool("help", HelpTool.class, "List available commands");
  registerTool("list-databases", ListDatabasesTool.class,
      "List available databases on a server");
  registerTool("list-tables", ListTablesTool.class,
      "List available tables in a database");
  registerTool("merge", MergeTool.class,
      "Merge results of incremental imports");
  registerTool("metastore", MetastoreTool.class,
      "Run a standalone Sqoop metastore");
  registerTool("job", JobTool.class,
      "Work with saved jobs");
  registerTool("version", VersionTool.class,
      "Display version information");
}
```

上边使用的import，register的就是ImportTool了，回到上边的ToolRunner.run(）

这个是在hadoop里面实现的这个run方法,可以找到实现类

```
public static int run(Configuration conf, Tool tool, String[] args) 
  throws Exception{
  if(conf == null) {
    conf = new Configuration();
  }
  GenericOptionsParser parser = new GenericOptionsParser(conf, args);
  //set the configuration back, so that Tool can configure itself
  tool.setConf(conf);

  //get the args w/o generic hadoop args
  String[] toolArgs = parser.getRemainingArgs();
  return tool.run(toolArgs);
}
```
这里的实现类就是sqoop

```
public int run(String [] args) {
  if (options.getConf() == null) {
    // Configuration wasn't initialized until after the ToolRunner
    // got us to this point. ToolRunner gave Sqoop itself a Conf
    // though.
    options.setConf(getConf());
  }

  try {
    options = tool.parseArguments(args, null, options, false);
    tool.appendArgs(this.childPrgmArgs);
    tool.validateOptions(options);
  } catch (Exception e) {
    // Couldn't parse arguments.
    // Log the stack trace for this exception
    LOG.debug(e.getMessage(), e);
    // Print exception message.
    System.err.println(e.getMessage());
    return 1; // Exit on exception here.
  }

  return tool.run(options);
}
```
又回到了这个tool了，上边看到是import,使用的是ImportTool类

```
public int run(SqoopOptions options) {
  HiveImport hiveImport = null;

  if (allTables) {
    // We got into this method, but we should be in a subclass.
    // (This method only handles a single table)
    // This should not be reached, but for sanity's sake, test here.
    LOG.error("ImportTool.run() can only handle a single table.");
    return 1;
  }

  if (!init(options)) {
    return 1;
  }

  codeGenerator.setManager(manager);

  try {
    if (options.doHiveImport()) {
      hiveImport = new HiveImport(options, manager, options.getConf(), false);
    }

    // Import a single table (or query) the user specified.
    importTable(options, options.getTableName(), hiveImport);
  } catch (IllegalArgumentException iea) {
      LOG.error(IMPORT_FAILED_ERROR_MSG + iea.getMessage());
    rethrowIfRequired(options, iea);
    return 1;
  } catch (IOException ioe) {
    LOG.error(IMPORT_FAILED_ERROR_MSG + StringUtils.stringifyException(ioe));
    rethrowIfRequired(options, ioe);
    return 1;
  } catch (ImportException ie) {
    LOG.error(IMPORT_FAILED_ERROR_MSG + ie.toString());
    rethrowIfRequired(options, ie);
    return 1;
  } catch (AvroSchemaMismatchException e) {
    LOG.error(IMPORT_FAILED_ERROR_MSG, e);
    rethrowIfRequired(options, e);
    return 1;
  } finally {
    destroy(options);
  }

  return 0;
}
```

[关于开源工具Sqoop源码解读----Mysql字符串作为主键主键分片](https://blog.csdn.net/fyhailin/article/details/79069475)   
[sqoop系列-TextSplitter踩坑记](https://blog.csdn.net/MuQianHuanHuoZhe/article/details/80585672)   
[Sqoop中通过hadoop mapreduce从关系型数据库import数据分析](https://blog.csdn.net/lyn1539815919/article/details/52400555)   
[sqoop导入数据map-reduce job分析](http://blog.51cto.com/dwf07223/1440256)

