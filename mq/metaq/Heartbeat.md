心跳

GeckoHandler.onSessionIdle中发送

```
public void onSessionIdle(final Session session) {
    final Connection conn = this.remotingContext.getConnectionBySession((NioSession) session);
    try {
        conn.send(conn.getRemotingContext().getCommandFactory().createHeartBeatCommand(), new HeartBeatListener(
            conn), 5000, TimeUnit.MILLISECONDS);
    }
    catch (final NotifyRemotingException e) {
        log.error("发送心跳命令失败", e);
    }

}
```
由MetaCommandFactory创建VersionComman(继承了AbstractRequestCommand，实现HeartBeatRequestCommand接口)

```
static class MetaCommandFactory implements CommandFactory {

      @Override
      public BooleanAckCommand createBooleanAckCommand(final CommandHeader request,
              final ResponseStatus responseStatus, final String errorMsg) {
          int httpCode = -1;
          switch (responseStatus) {
          case NO_ERROR:
              httpCode = HttpStatus.Success;
              break;
          case THREADPOOL_BUSY:
          case NO_PROCESSOR:
              httpCode = HttpStatus.ServiceUnavilable;
              break;
          case TIMEOUT:
              httpCode = HttpStatus.GatewayTimeout;
              break;
          default:
              httpCode = HttpStatus.InternalServerError;
              break;
          }
          return new BooleanCommand(httpCode, errorMsg, request.getOpaque());
      }


      @Override
      public HeartBeatRequestCommand createHeartBeatCommand() {
          return new VersionCommand(OpaqueGenerator.getNextOpaque());
      }

  }
```

服务端启动的时候会注册对应的Processor

```
private void registerProcessors() {
    this.remotingServer.registerProcessor(GetCommand.class, new GetProcessor(this.brokerProcessor,
        this.executorsManager.getGetExecutor()));
    this.remotingServer.registerProcessor(PutCommand.class, new PutProcessor(this.brokerProcessor,
        this.executorsManager.getUnOrderedPutExecutor()));
    this.remotingServer.registerProcessor(OffsetCommand.class, new OffsetProcessor(this.brokerProcessor,
        this.executorsManager.getGetExecutor()));
    this.remotingServer
    .registerProcessor(HeartBeatRequestCommand.class, new VersionProcessor(this.brokerProcessor));
    this.remotingServer.registerProcessor(QuitCommand.class, new QuitProcessor(this.brokerProcessor));
    this.remotingServer.registerProcessor(StatsCommand.class, new StatsProcessor(this.brokerProcessor));
    this.remotingServer.registerProcessor(TransactionCommand.class, new TransactionProcessor(this.brokerProcessor,
        this.executorsManager.getUnOrderedPutExecutor()));
}
```

心跳请求由VersionProcessor来处理,其中的处理逻辑
```
public void handleRequest(final HeartBeatRequestCommand request, final Connection conn) {
    final ResponseCommand response =
            this.processor.processVesionCommand((VersionCommand) request,
                SessionContextHolder.getOrCreateSessionContext(conn, null));
    if (response != null) {
        RemotingUtils.response(conn, response);
    }
}
```

BrokerCommandProcessor.processVesionCommand()

```
public ResponseCommand processVesionCommand(final VersionCommand request, final SessionContext ctx) {
    return new BooleanCommand(HttpStatus.Success, BuildProperties.VERSION, request.getOpaque());

}
```
