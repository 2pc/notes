
### 启动入口
Elasticsearch.java／Elasticsearch.java
```
public class Elasticsearch extends Bootstrap {

  public static void close(String[] args) {
      Bootstrap.close(args);
  }

  public static void main(String[] args) {
      Bootstrap.main(args);
  }
}
```

Bootstrap.java

```
public static void main(String[] args) {
    System.setProperty("es.logger.prefix", "");
    bootstrap = new Bootstrap();
    final String pidFile = System.getProperty("es.pidfile", System.getProperty("es-pidfile"));

    if (pidFile != null) {
        try {
            File fPidFile = new File(pidFile);
            if (fPidFile.getParentFile() != null) {
                FileSystemUtils.mkdirs(fPidFile.getParentFile());
            }
            FileOutputStream outputStream = new FileOutputStream(fPidFile);
            outputStream.write(Long.toString(JvmInfo.jvmInfo().pid()).getBytes(Charsets.UTF_8));
            outputStream.close();

            fPidFile.deleteOnExit();
        } catch (Exception e) {
            String errorMessage = buildErrorMessage("pid", e);
            System.err.println(errorMessage);
            System.err.flush();
            System.exit(3);
        }
    }

    boolean foreground = System.getProperty("es.foreground", System.getProperty("es-foreground")) != null;
    // handle the wrapper system property, if its a service, don't run as a service
    if (System.getProperty("wrapper.service", "XXX").equalsIgnoreCase("true")) {
        foreground = false;
    }

    Tuple<Settings, Environment> tuple = null;
    try {
        tuple = initialSettings();
        setupLogging(tuple);
    } catch (Exception e) {
        String errorMessage = buildErrorMessage("Setup", e);
        System.err.println(errorMessage);
        System.err.flush();
        System.exit(3);
    }

    if (System.getProperty("es.max-open-files", "false").equals("true")) {
        ESLogger logger = Loggers.getLogger(Bootstrap.class);
        logger.info("max_open_files [{}]", JmxProcessProbe.getMaxFileDescriptorCount());
    }

    // warn if running using the client VM
    if (JvmInfo.jvmInfo().vmName().toLowerCase(Locale.ROOT).contains("client")) {
        ESLogger logger = Loggers.getLogger(Bootstrap.class);
        logger.warn("jvm uses the client vm, make sure to run `java` with the server vm for best performance by adding `-server` to the command line");
    }

    String stage = "Initialization";
    try {
        if (!foreground) {
            Loggers.disableConsoleLogging();
            System.out.close();
        }
        bootstrap.setup(true, tuple);

        stage = "Startup";
        bootstrap.start();

        if (!foreground) {
            System.err.close();
        }

        keepAliveLatch = new CountDownLatch(1);
        // keep this thread alive (non daemon thread) until we shutdown
        Runtime.getRuntime().addShutdownHook(new Thread() {
            @Override
            public void run() {
                keepAliveLatch.countDown();
            }
        });

        keepAliveThread = new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    keepAliveLatch.await();
                } catch (InterruptedException e) {
                    // bail out
                }
            }
        }, "elasticsearch[keepAlive/" + Version.CURRENT + "]");
        keepAliveThread.setDaemon(false);
        keepAliveThread.start();
    } catch (Throwable e) {
        ESLogger logger = Loggers.getLogger(Bootstrap.class);
        if (bootstrap.node != null) {
            logger = Loggers.getLogger(Bootstrap.class, bootstrap.node.settings().get("name"));
        }
        String errorMessage = buildErrorMessage(stage, e);
        if (foreground) {
            System.err.println(errorMessage);
            System.err.flush();
        } else {
            logger.error(errorMessage);
        }
        Loggers.disableConsoleLogging();
        if (logger.isDebugEnabled()) {
            logger.debug("Exception", e);
        }
        System.exit(3);
    }
}
```

bootstrap.start();

```
public void start() {
      node.start();
  }
```
NodeBuilder
```
public Node build() {
    return new InternalNode(settings.build(), loadConfigSettings);
}
```
InternalNode.start()
```
public Node start() {
  if (!lifecycle.moveToStarted()) {
      return this;
  }

  ESLogger logger = Loggers.getLogger(Node.class, settings.get("name"));
  logger.info("starting ...");

  // hack around dependency injection problem (for now...)
  injector.getInstance(Discovery.class).setAllocationService(injector.getInstance(AllocationService.class));

  for (Class<? extends LifecycleComponent> plugin : pluginsService.services()) {
      injector.getInstance(plugin).start();
  }

  injector.getInstance(MappingUpdatedAction.class).start();
  injector.getInstance(IndicesService.class).start();
  injector.getInstance(IndexingMemoryController.class).start();
  injector.getInstance(IndicesClusterStateService.class).start();
  injector.getInstance(IndicesTTLService.class).start();
  injector.getInstance(RiversManager.class).start();
  injector.getInstance(SnapshotsService.class).start();
  injector.getInstance(TransportService.class).start();
  injector.getInstance(ClusterService.class).start();
  injector.getInstance(RoutingService.class).start();
  injector.getInstance(SearchService.class).start();
  injector.getInstance(MonitorService.class).start();
  injector.getInstance(RestController.class).start();
  DiscoveryService discoService = injector.getInstance(DiscoveryService.class).start();
  discoService.waitForInitialState();

  // gateway should start after disco, so it can try and recovery from gateway on "start"
  injector.getInstance(GatewayService.class).start();

  if (settings.getAsBoolean("http.enabled", true)) {
      injector.getInstance(HttpServer.class).start();
  }
  injector.getInstance(BulkUdpService.class).start();
  injector.getInstance(ResourceWatcherService.class).start();
  injector.getInstance(TribeService.class).start();

  logger.info("started");

  return this;
}
```
