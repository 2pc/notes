SqlBuilderLoadInterceptor 中sql的拼装

执行update的时候如果没有主键变更会mergesql,走on duplicate key update语法

```
} else if (type.isUpdate()) {
    // String[] keyColumns = buildColumnNames(currentData.getKeys());
// String[] otherColumns =
// buildColumnNames(currentData.getUpdatedColumns());
// boolean existOldKeys = false;
// for (String key : keyColumns) {
// // 找一下otherColumns是否有主键，存在就代表有主键变更
// if (ArrayUtils.contains(otherColumns, key)) {
// existOldKeys = true;
// break;
// }
// }

boolean existOldKeys = !CollectionUtils.isEmpty(currentData.getOldKeys());//isNotEmpty表示存在主键变更
boolean rowMode = context.getPipeline().getParameters().getSyncMode().isRow();
String[] keyColumns = null;
String[] otherColumns = null;
if (existOldKeys) {
    // 需要考虑主键变更的场景
    // 构造sql如下：update table xxx set pk = newPK where pk = oldPk
    keyColumns = buildColumnNames(currentData.getOldKeys());
    otherColumns = buildColumnNames(currentData.getUpdatedColumns(), currentData.getKeys());
} else {
    keyColumns = buildColumnNames(currentData.getKeys());
    otherColumns = buildColumnNames(currentData.getUpdatedColumns());
}

if (rowMode && !existOldKeys) {// 如果是行记录,并且不存在主键变更，考虑merge sql
    sql = sqlTemplate.getMergeSql(schemaName,
        currentData.getTableName(),
        keyColumns,
        otherColumns,
        new String[] {},
        !dbDialect.isDRDS());
} else {// 否则进行update sql
        sql = sqlTemplate.getUpdateSql(schemaName, currentData.getTableName(), keyColumns, otherColumns);
    }
} else if (type.isDelete()) {
    sql = sqlTemplate.getDeleteSql(schemaName,
        currentData.getTableName(),
        buildColumnNames(currentData.getKeys()));
}
```
