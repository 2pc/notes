#### canal 订阅消费CanalEmbedSelector

#### insert/update/delete 语句构造 SqlBuilderLoadInterceptor

#### 异构

```
DataBatchLoader.load()-->DataBatchLoader.submitRowBatch()/submitFileBatch->DbLoadAction.load()-->DbLoadAction.doTwoPhase()-->
DbLoadWorker.call()-->DbLoadWorker.doCall()-->JdbcTemplate
```

####  value转化
因为canal生产数据均为string类型，需要做一个转化SqlUtils.java

```
public static Object stringToSqlValue(String value, int sqlType, boolean isRequired, boolean isEmptyStringNulled) {
      // 设置变量
      String sourceValue = value;
      if (SqlUtils.isTextType(sqlType)) {
          if ((sourceValue == null) || (StringUtils.isEmpty(sourceValue) && isEmptyStringNulled)) {
              return isRequired ? REQUIRED_FIELD_NULL_SUBSTITUTE : null;
          } else {
              return sourceValue;
          }
      } else {
          if (StringUtils.isEmpty(sourceValue)) {
              return isEmptyStringNulled ? null : sourceValue;// oracle的返回null，保持兼容
          } else {
              Class<?> requiredType = sqlTypeToJavaTypeMap.get(sqlType);
              if (requiredType == null) {
                  throw new IllegalArgumentException("unknow java.sql.Types - " + sqlType);
              } else if (requiredType.equals(String.class)) {
                  return sourceValue;
              } else if (true == isNumeric(sqlType)) {
                  return convertUtilsBean.convert(sourceValue.trim(), requiredType);
              } else {
                  return convertUtilsBean.convert(sourceValue, requiredType);
              }
          }
      }
  }
```
