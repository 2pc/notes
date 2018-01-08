
### otter扩展 


选择了source方式,由于某些需求，这里先过滤掉tableA,tableB，其实可以对每一列(eventData.getColumns())进行修改，增加或者减少一列都可以

```

package com.alibaba.otter.node.extend.processor;

import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.alibaba.otter.shared.etl.model.EventColumn;
import com.alibaba.otter.shared.etl.model.EventData;
import com.alibaba.otter.shared.etl.model.EventType;

public class TestEventProcessor extends AbstractEventProcessor {
	
	private static final Logger logger             = LoggerFactory.getLogger(TestEventProcessor.class);
    public boolean process(EventData eventData) {
    	List<EventColumn> columns = eventData.getColumns();
    	if((eventData.getTableName()!=null&&eventData.getTableName().equalsIgnoreCase("tableA"))||(eventData.getTableName()!=null&&eventData.getTableName().equalsIgnoreCase("tableB"))){
    		logger.warn("skip EventData"+ JSON.toJSONString(eventData));
    		/* 判断下是否包含字段settlement_bill_type, withhold_type*/
//    		if(!containSpecsColumns(columns, "settlement_bill_type")){
//    		
//
//    		}
    		return false;
    	}
  
        return true;
    }

    private JSONObject doColumn(EventColumn column) {
        JSONObject obj = new JSONObject();
        obj.put("name", column.getColumnName());
        obj.put("update", column.isUpdate());
        obj.put("key", column.isKey());
        if (column.getColumnType() != Types.BLOB && column.getColumnType() != Types.CLOB) {
            obj.put("value", column.getColumnValue());
        } else {
            obj.put("value", "");
        }
        return obj;
    }
    
    /* 判断下是否包含字段settlement_bill_type, withhold_type*/
    private boolean containSpecsColumns(List<EventColumn> columns,String columnName){
    	boolean ret =false;
    	for (EventColumn eventColumn : columns) {
    		if(columnName.equalsIgnoreCase(eventColumn.getColumnName())){
    			ret =true;
    		}
		}
		return ret;
    	
    }
}

```
