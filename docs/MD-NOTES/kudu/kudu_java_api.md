
kudu UNIXTIME_MICROS 注意addLong是microseconds

```
String tableName = "test3";
KuduClient client =new KuduClient.KuduClientBuilder("172.28.3.159").build();
try {
      KuduTable table = client.openTable(tableName);
      KuduSession session = client.newSession();
      Update update  = table.newUpdate();
      PartialRow partialRow = update.getRow();
      partialRow.addInt("ID", 4);
      partialRow.addLong("X", new Date().getTime()*1000);
      session.apply(update);
} catch (Exception e) {
```
