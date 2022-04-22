```
package com.alibaba.otter.canal.example;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang.SystemUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import org.springframework.util.Assert;
import org.springframework.util.CollectionUtils;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.alibaba.otter.canal.client.CanalConnector;
import com.alibaba.otter.canal.example.util.ValueConvertUtil;
import com.alibaba.otter.canal.protocol.CanalEntry.Column;
import com.alibaba.otter.canal.protocol.CanalEntry.Entry;
import com.alibaba.otter.canal.protocol.CanalEntry.EntryType;
import com.alibaba.otter.canal.protocol.CanalEntry.EventType;
import com.alibaba.otter.canal.protocol.CanalEntry.RowChange;
import com.alibaba.otter.canal.protocol.CanalEntry.RowData;
import com.alibaba.otter.canal.protocol.CanalEntry.TransactionBegin;
import com.alibaba.otter.canal.protocol.CanalEntry.TransactionEnd;
import com.alibaba.otter.canal.protocol.Message;
//import com.fasterxml.jackson.core.JsonProcessingException;
//import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.protobuf.InvalidProtocolBufferException;
import com.mljr.otter.canal.log.CanalLogger;

/**
 * 测试基类
 * 
 * @author jianghang 2013-4-15 下午04:17:12
 * @version 1.0.4
 */
public class AbstractCanalClientTest {

    protected final static Logger             logger             = LoggerFactory.getLogger(AbstractCanalClientTest.class);
    protected static final String             SEP                = SystemUtils.LINE_SEPARATOR;
    protected static final String             DATE_FORMAT        = "yyyy-MM-dd HH:mm:ss";
    protected volatile boolean                running            = false;
    protected Thread.UncaughtExceptionHandler handler            = new Thread.UncaughtExceptionHandler() {

                                                                     public void uncaughtException(Thread t, Throwable e) {
                                                                         logger.error("parse events has an error", e);
                                                                     }
                                                                 };
    protected Thread                          thread             = null;
    protected CanalConnector                  connector;
    protected static String                   context_format     = null;
    protected static String                   row_format         = null;
    protected static String                   transaction_format = null;
    protected String                          destination;

    static {
        context_format = SEP + "****************************************************" + SEP;
        context_format += "* Batch Id: [{}] ,count : [{}] , memsize : [{}] , Time : {}" + SEP;
        context_format += "* Start : [{}] " + SEP;
        context_format += "* End : [{}] " + SEP;
        context_format += "****************************************************" + SEP;

        row_format = SEP
                     + "----------------> binlog[{}:{}] , name[{},{}] , eventType : {} , executeTime : {} , delay : {}ms"
                     + SEP;

        transaction_format = SEP + "================> binlog[{}:{}] , executeTime : {} , delay : {}ms" + SEP;

    }
    
//	private static final String CANAL_LOG_FILE_NAME = "canalLog.log";
//	private static final String CANAL_LOG_PATH = "/home/deproot/luping/test-example/logs";
   	

//    protected static File canalLogFile = null;
    
    public AbstractCanalClientTest(String destination){
        this(destination, null);
    }

    public AbstractCanalClientTest(String destination, CanalConnector connector){
        this.destination = destination;
        this.connector = connector;
    }
//    private FileWriter fileWritter;
//    private BufferedWriter bufferWritter;
    protected void start() {
	
    	
        Assert.notNull(connector, "connector is null");
        thread = new Thread(new Runnable() {

            public void run() {
                process();
            }
        });

        thread.setUncaughtExceptionHandler(handler);
        thread.start();
        running = true;
    }

    protected void stop() {
        if (!running) {
            return;
        }
        running = false;
        
        if (thread != null) {
            try {
                thread.join();
            } catch (InterruptedException e) {
                // ignore
            }
        }

        MDC.remove("destination");
    }

    protected void process() {
//    	try {
////    		String canalLogFileFullName = CANAL_LOG_PATH+"/"+ CANAL_LOG_FILE_NAME;
//    		canalLogFile = new File(canalLogFileFullName);
//    		
//			//append first,need support roll
//			fileWritter = new FileWriter(canalLogFile.getName(),true);
//			bufferWritter = new BufferedWriter(fileWritter);
//			
//			logger.warn("fw open canalLogFileFullName"+canalLogFileFullName);
//			
//		} catch (IOException e1) {
//			logger.warn("fw open error"+e1.getMessage());
//		}
        int batchSize = 5 * 1024;
        while (running) {
            try {
                MDC.put("destination", destination);
                connector.connect();
                /** 必须在这里设置filter才会生效？, see https://github.com/alibaba/canal/issues/311*/
                connector.subscribe(""); 
                while (running) {
                    Message message = connector.getWithoutAck(batchSize); // 获取指定数量的数据
                    long batchId = message.getId();
                    try {
						
					} catch (Exception e) {
						// TODO: handle exception
					}
                    int size = message.getEntries().size();
                    if (batchId == -1 || size == 0) {
                        // try {
                        // Thread.sleep(1000);
                        // } catch (InterruptedException e) {
                        // }
                    } else {
                        printSummary(message, batchId, size);
                        printEntry(message.getEntries());
                    }

                    connector.ack(batchId); // 提交确认
                    // connector.rollback(batchId); // 处理失败, 回滚数据
                }
            } catch (Exception e) {
            	
                logger.error("process error!", e);
            } finally {
            	
                connector.disconnect();
//                try {
//        			bufferWritter.close();
//        		} catch (IOException e) {
//        			// TODO Auto-generated catch block
//        			e.printStackTrace();
//        		}
                MDC.remove("destination");
            }
        }
    }

    private void printSummary(Message message, long batchId, int size) {
        long memsize = 0;
        for (Entry entry : message.getEntries()) {
            memsize += entry.getHeader().getEventLength();
        }

        String startPosition = null;
        String endPosition = null;
        if (!CollectionUtils.isEmpty(message.getEntries())) {
            startPosition = buildPositionForDump(message.getEntries().get(0));
            endPosition = buildPositionForDump(message.getEntries().get(message.getEntries().size() - 1));
        }

        SimpleDateFormat format = new SimpleDateFormat(DATE_FORMAT);
        logger.info(context_format, new Object[] { batchId, size, memsize, format.format(new Date()), startPosition,
                endPosition });
    }

    protected String buildPositionForDump(Entry entry) {
        long time = entry.getHeader().getExecuteTime();
        Date date = new Date(time);
        SimpleDateFormat format = new SimpleDateFormat(DATE_FORMAT);
        return entry.getHeader().getLogfileName() + ":" + entry.getHeader().getLogfileOffset() + ":"
               + entry.getHeader().getExecuteTime() + "(" + format.format(date) + ")";
    }

    protected void printEntry(List<Entry> entrys) {
    	
        for (Entry entry : entrys) {
            long executeTime = entry.getHeader().getExecuteTime();
            long delayTime = new Date().getTime() - executeTime;
            logger.info("#######3"+ entry.getEntryType()+"\n");
            if (entry.getEntryType() == EntryType.TRANSACTIONBEGIN || entry.getEntryType() == EntryType.TRANSACTIONEND) {
                if (entry.getEntryType() == EntryType.TRANSACTIONBEGIN) {
                    TransactionBegin begin = null;
                    try {
                        begin = TransactionBegin.parseFrom(entry.getStoreValue());
                    } catch (InvalidProtocolBufferException e) {
                        throw new RuntimeException("parse event has an error , data:" + entry.toString(), e);
                    }
                    // 打印事务头信息，执行的线程id，事务耗时
                    logger.info(transaction_format,
                        new Object[] { entry.getHeader().getLogfileName(),
                                String.valueOf(entry.getHeader().getLogfileOffset()),
                                String.valueOf(entry.getHeader().getExecuteTime()), String.valueOf(delayTime) });
                    logger.info(" BEGIN ----> Thread id: {}", begin.getThreadId());
                } else if (entry.getEntryType() == EntryType.TRANSACTIONEND) {
                    TransactionEnd end = null;
                    try {
                        end = TransactionEnd.parseFrom(entry.getStoreValue());
                    } catch (InvalidProtocolBufferException e) {
                        throw new RuntimeException("parse event has an error , data:" + entry.toString(), e);
                    }
                    // 打印事务提交信息，事务id
                    logger.info("----------------\n");
                    logger.info(" END ----> transaction id: {}", end.getTransactionId());
                    logger.info(transaction_format,
                        new Object[] { entry.getHeader().getLogfileName(),
                                String.valueOf(entry.getHeader().getLogfileOffset()),
                                String.valueOf(entry.getHeader().getExecuteTime()), String.valueOf(delayTime) });
                }

                continue;
            }
            
            if (entry.getEntryType() == EntryType.ROWDATA) {
                RowChange rowChage = null;
                try {
                    rowChage = RowChange.parseFrom(entry.getStoreValue());
                   // logger.info("  ROWDATA##### "+JSON.toJSONString(rowChage)+"\n");
                } catch (Exception e) {
                    throw new RuntimeException("parse event has an error , data:" + entry.toString(), e);
                }

                EventType eventType = rowChage.getEventType();
               
                logger.info(row_format,
                    new Object[] { entry.getHeader().getLogfileName(),
                            String.valueOf(entry.getHeader().getLogfileOffset()), entry.getHeader().getSchemaName(),
                            entry.getHeader().getTableName(), eventType,
                            String.valueOf(entry.getHeader().getExecuteTime()), String.valueOf(delayTime) });

                logger.info(" sql ----> " + rowChage.getSql() + SEP);

                if (eventType == EventType.QUERY || rowChage.getIsDdl()) {
                    logger.info(" sql ----> " + rowChage.getSql() + SEP);
                    continue;
                }
                
                JSONObject json =  new JSONObject();
                StringBuilder sb = new StringBuilder();
                for (RowData rowData : rowChage.getRowDatasList()) {
                	
                    if (eventType == EventType.DELETE) {
                    	String jsonStr = buildDeleteData(rowData, entry.getHeader().getSchemaName(), entry.getHeader().getTableName());
                    	//sb.append(jsonStr).append("\n");
                        CanalLogger.canalLog(jsonStr);
                      //  logger.info("###: " +jsonStr+SEP+"");
                        
                        printColumn(rowData.getBeforeColumnsList());
                        
                    } else if (eventType == EventType.INSERT) {
                        printColumn(rowData.getAfterColumnsList());
                        
                    	String jsonStr = buildInsertData(rowData, entry.getHeader().getSchemaName(), entry.getHeader().getTableName());
                    	sb.append(jsonStr).append("\n");
                    	CanalLogger.canalLog(jsonStr);
//                        logger.info("###: " +jsonStr+SEP);
                    } else {
                        printColumn(rowData.getBeforeColumnsList());
                      //  logger.info(" ######### update sql ----> ");
                        printColumn(rowData.getAfterColumnsList());
                        
                    	String jsonStr = buildUpdateData(rowData, entry.getHeader().getSchemaName(), entry.getHeader().getTableName());
                    	sb.append(jsonStr).append("\n");
                    	
                    	CanalLogger.canalLog(jsonStr);
                     //   logger.info("###: " +jsonStr+SEP);
                        
                    }
                    
                    
       
                    
                }
                
                String str = sb.toString();
                str = str.substring(0, str.length()-1);
//                try {
//   						bufferWritter.write(str);
//   						bufferWritter.write("\n");
//   						bufferWritter.flush();
//   					} catch (IOException e) {
//   						logger.warn("bf write error" +e.getMessage());
//   					}
            }
        }
        
        

    }
    
    private String buildDeleteData(RowData rowData, String database,String table){
    	JSONObject json=new JSONObject();
    	json.put("type", "delete");
        json.put("database", database);
        json.put("table", table);
        JSONObject data=new JSONObject();
        for (Column column : rowData.getBeforeColumnsList()) { 
//        	data.put("SqlType", column.getSqlType());
//        	data.put("MySqlType", column.getMysqlType());
    		data.put(column.getName(), ValueConvertUtil.convert2JavaTypeValue(column.getSqlType(), column.getValue()));  
         }  
        json.put("data", data);
        
        return json.toJSONString();
    }
    
    private String buildInsertData(RowData rowData, String database,String table){
    	JSONObject json=new JSONObject();
    	json.put("type", "insert");
    	json.put("database", database);
        json.put("table", table);
        JSONObject data=new JSONObject();
        for (Column column : rowData.getAfterColumnsList()) { 
    		data.put(column.getName(), ValueConvertUtil.convert2JavaTypeValue(column.getSqlType(), column.getValue()));  
         }  
        json.put("data", data);
        return json.toJSONString();
    }
    private String buildUpdateData(RowData rowData, String database,String table){
    	 JSONObject json=new JSONObject();
     	json.put("type", "update");
     	json.put("database", database);
         json.put("table", table);
         
         JSONObject data=new JSONObject();
         JSONObject old=new JSONObject();
         
         for (Column column : rowData.getAfterColumnsList()) {  
     		data.put(column.getName(), ValueConvertUtil.convert2JavaTypeValue(column.getSqlType(), column.getValue()));  

          }  
         for (Column column : rowData.getBeforeColumnsList()) {  
      		old.put(column.getName(), ValueConvertUtil.convert2JavaTypeValue(column.getSqlType(), column.getValue()));  

           }
         
         json.put("data", data);
         json.put("old", old);
         
         return json.toJSONString();
    	
    }

    protected void printColumn(List<Column> columns) {
        for (Column column : columns) {
            StringBuilder builder = new StringBuilder();
            builder.append(column.getName() + " : " + column.getValue());
            builder.append("    type=" + column.getMysqlType());
            if (column.getUpdated()) {
                builder.append("    update=" + column.getUpdated());
            }
            builder.append(SEP);
            logger.info(builder.toString());
            
        }
    }

    public void setConnector(CanalConnector connector) {
        this.connector = connector;
    }

}

```
