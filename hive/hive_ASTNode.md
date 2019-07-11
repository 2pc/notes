hive_ASTNode

```
ParseDriver pd = new ParseDriver();
ASTNode node = findRootNonNullToken(pd.parse(sql));
System.out.println("dump: "+node.dump());
```
### eg

sql
```
			System.out.println("add columns: "+JSON.toJSON(hiveparse.getAlterTablesMap("alter table  dp_eco_mart.eco_user_basic_info  add columns(fpd_label int,fpd_label_str string)")
			));
			System.out.println("CHANGE columns: "+JSON.toJSON(hiveparse.getAlterTablesMap("ALTER TABLE employee CHANGE name ename String")
					));
//			System.out.println("DROP columns: "+JSON.toJSON(hiveparse.getAlterTablesMap("ALTER TABLE employee DROP name")
//					));
			
			System.out.println("DROP/REPLACE columns : "+JSON.toJSON(hiveparse.getAlterTablesMap(" ALTER TABLE emp REPLACE COLUMNS( name string, dept string) ")
					));
			
			System.out.println("drop partition: "+JSON.toJSON(hiveparse.getAlterTablesMap("ALTER TABLE login DROP IF EXISTS PARTITION (dt='2008-08-08')")
					));
			System.out.println("ADD PARTITION : "+JSON.toJSON(hiveparse.getAlterTablesMap("ALTER TABLE table_name ADD PARTITION (partCol = 'value1') location 'loc1'")
					));

			
			System.out.println("rename: "+JSON.toJSON(hiveparse.getAlterTablesMap("alter table  dp_eco_mart.eco_user_basic_info  rename to dp_eco_mart.eco_user_basic_info_test")
					));
```
dump
```
dump: 
TOK_ALTERTABLE
   TOK_TABNAME
      dp_eco_mart
      eco_user_basic_info
   TOK_ALTERTABLE_ADDCOLS
      TOK_TABCOLLIST
         TOK_TABCOL
            fpd_label
            TOK_INT
         TOK_TABCOL
            fpd_label_str
            TOK_STRING

add columns: {"src_db_tb_name":"dp_eco_mart.eco_user_basic_info"}
dump: 
TOK_ALTERTABLE
   TOK_TABNAME
      employee
   TOK_ALTERTABLE_RENAMECOL
      name
      ename
      TOK_STRING

CHANGE columns: {"src_db_tb_name":"employee"}
dump: 
TOK_ALTERTABLE
   TOK_TABNAME
      emp
   TOK_ALTERTABLE_REPLACECOLS
      TOK_TABCOLLIST
         TOK_TABCOL
            name
            TOK_STRING
         TOK_TABCOL
            dept
            TOK_STRING

DROP/REPLACE columns : {"src_db_tb_name":"emp"}
dump: 
TOK_ALTERTABLE
   TOK_TABNAME
      login
   TOK_ALTERTABLE_DROPPARTS
      TOK_PARTSPEC
         TOK_PARTVAL
            dt
            =
            '2008-08-08'
      TOK_IFEXISTS

drop partition: {"src_db_tb_name":"login"}
dump: 
TOK_ALTERTABLE
   TOK_TABNAME
      table_name
   TOK_ALTERTABLE_ADDPARTS
      TOK_PARTSPEC
         TOK_PARTVAL
            partCol
            'value1'
      TOK_PARTITIONLOCATION
         'loc1'

ADD PARTITION : {"src_db_tb_name":"table_name"}
dump: 
TOK_ALTERTABLE
   TOK_TABNAME
      dp_eco_mart
      eco_user_basic_info
   TOK_ALTERTABLE_RENAME
      TOK_TABNAME
         dp_eco_mart
         eco_user_basic_info_test

rename: {"new_db_tb_name":"dp_eco_mart.eco_user_basic_info_test","src_db_tb_name":"dp_eco_mart.eco_user_basic_info"}
```
