InternalNode的start()

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

start gateway

```
injector.getInstance(GatewayService.class).start();
```
