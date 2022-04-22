
#### 
>
1. elastic的master选举是种子选手经过排序(intro sort THRESHOLD < 20，insertionSort else heapsort)后的第一个
2. 选举master的实现类是ElectMasterService（electMaster()方法）
3. electMaster方法会在两个地方调用，分别是在ZenDiscovery的findMaster()与handleMasterGone()中

在ZenDiscovery的doStart()会启动一个JoinThreadControl，开启join线程

```
protected void doStart() throws ElasticsearchException {
    nodesFD.setLocalNode(clusterService.localNode());
    joinThreadControl.start();
    pingService.start();

    // start the join thread from a cluster state update. See {@link JoinThreadControl} for details.
    clusterService.submitStateUpdateTask("initial_join", new ClusterStateNonMasterUpdateTask() {
        @Override
        public ClusterState execute(ClusterState currentState) throws Exception {
            // do the join on a different thread, the DiscoveryService waits for 30s anyhow till it is discovered
            joinThreadControl.startNewThreadIfNotRunning();
            return currentState;
        }

        @Override
        public void onFailure(String source, @org.elasticsearch.common.Nullable Throwable t) {
            logger.warn("failed to start initial join process", t);
        }
    });
}
```
JoinThreadControl的startNewThreadIfNotRunning()

```
public void startNewThreadIfNotRunning() {
    assertClusterStateThread();
    if (joinThreadActive()) {
        return;
    }
    threadPool.generic().execute(new Runnable() {
        @Override
        public void run() {
            Thread currentThread = Thread.currentThread();
            if (!currentJoinThread.compareAndSet(null, currentThread)) {
                return;
            }
            while (running.get() && joinThreadActive(currentThread)) {
                try {
                    innerJoinCluster();
                    return;
                } catch (Exception e) {
                    logger.error("unexpected error while joining cluster, trying again", e);
                    // Because we catch any exception here, we want to know in
                    // tests if an uncaught exception got to this point and the test infra uncaught exception
                    // leak detection can catch this. In practise no uncaught exception should leak
                    assert ExceptionsHelper.reThrowIfNotNull(e);
                }
            }
            // cleaning the current thread from currentJoinThread is done by explicit calls.
        }
    });
}
```
innerJoinCluster才是主要的逻辑
```
private void innerJoinCluster() {
    DiscoveryNode masterNode = null;
    final Thread currentThread = Thread.currentThread();
    while (masterNode == null && joinThreadControl.joinThreadActive(currentThread)) {
        masterNode = findMaster();
    }

    if (!joinThreadControl.joinThreadActive(currentThread)) {
        logger.trace("thread is no longer in currentJoinThread. Stopping.");
        return;
    }

    if (clusterService.localNode().equals(masterNode)) {
        clusterService.submitStateUpdateTask("zen-disco-join (elected_as_master)", Priority.IMMEDIATE, new ProcessedClusterStateNonMasterUpdateTask() {
            @Override
            public ClusterState execute(ClusterState currentState) {
                // Take into account the previous known nodes, if they happen not to be available
                // then fault detection will remove these nodes.

                if (currentState.nodes().masterNode() != null) {
                    // TODO can we tie break here? we don't have a remote master cluster state version to decide on
                    logger.trace("join thread elected local node as master, but there is already a master in place: {}", currentState.nodes().masterNode());
                    return currentState;
                }

                DiscoveryNodes.Builder builder = new DiscoveryNodes.Builder(currentState.nodes()).masterNodeId(currentState.nodes().localNode().id());
                // update the fact that we are the master...
                ClusterBlocks clusterBlocks = ClusterBlocks.builder().blocks(currentState.blocks()).removeGlobalBlock(discoverySettings.getNoMasterBlock()).build();
                currentState = ClusterState.builder(currentState).nodes(builder).blocks(clusterBlocks).build();

                // eagerly run reroute to remove dead nodes from routing table
                RoutingAllocation.Result result = allocationService.reroute(currentState);
                return ClusterState.builder(currentState).routingResult(result).build();
            }

            @Override
            public void onFailure(String source, Throwable t) {
                logger.error("unexpected failure during [{}]", t, source);
                joinThreadControl.markThreadAsDoneAndStartNew(currentThread);
            }

            @Override
            public void clusterStateProcessed(String source, ClusterState oldState, ClusterState newState) {
                if (newState.nodes().localNodeMaster()) {
                    // we only starts nodesFD if we are master (it may be that we received a cluster state while pinging)
                    joinThreadControl.markThreadAsDone(currentThread);
                    nodesFD.updateNodesAndPing(newState); // start the nodes FD
                } else {
                    // if we're not a master it means another node published a cluster state while we were pinging
                    // make sure we go through another pinging round and actively join it
                    joinThreadControl.markThreadAsDoneAndStartNew(currentThread);
                }
                sendInitialStateEventIfNeeded();
                long count = clusterJoinsCounter.incrementAndGet();
                logger.trace("cluster joins counter set to [{}] (elected as master)", count);

            }
        });
    } else {
        // send join request
        final boolean success = joinElectedMaster(masterNode);

        // finalize join through the cluster state update thread
        final DiscoveryNode finalMasterNode = masterNode;
        clusterService.submitStateUpdateTask("finalize_join (" + masterNode + ")", new ClusterStateNonMasterUpdateTask() {
            @Override
            public ClusterState execute(ClusterState currentState) throws Exception {
                if (!success) {
                    // failed to join. Try again...
                    joinThreadControl.markThreadAsDoneAndStartNew(currentThread);
                    return currentState;
                }

                if (currentState.getNodes().masterNode() == null) {
                    // Post 1.3.0, the master should publish a new cluster state before acking our join request. we now should have
                    // a valid master.
                    logger.debug("no master node is set, despite of join request completing. retrying pings.");
                    joinThreadControl.markThreadAsDoneAndStartNew(currentThread);
                    return currentState;
                }

                if (!currentState.getNodes().masterNode().equals(finalMasterNode)) {
                    return joinThreadControl.stopRunningThreadAndRejoin(currentState, "master_switched_while_finalizing_join");
                }

                // Note: we do not have to start master fault detection here because it's set at {@link #handleNewClusterStateFromMaster }
                // when the first cluster state arrives.
                joinThreadControl.markThreadAsDone(currentThread);
                return currentState;
            }

            @Override
            public void onFailure(String source, @Nullable Throwable t) {
                logger.error("unexpected error while trying to finalize cluster join", t);
                joinThreadControl.markThreadAsDoneAndStartNew(currentThread);
            }
        });
    }
}

```
主要看下findMaster，这里看起来是一个死循环，如果没有找到master的话会一直惊醒下去

```
private DiscoveryNode findMaster() {
    logger.trace("starting to ping");
    ZenPing.PingResponse[] fullPingResponses = pingService.pingAndWait(pingTimeout);
    if (fullPingResponses == null) {
        logger.trace("No full ping responses");
        return null;
    }
    if (logger.isTraceEnabled()) {
        StringBuilder sb = new StringBuilder("full ping responses:");
        if (fullPingResponses.length == 0) {
            sb.append(" {none}");
        } else {
            for (ZenPing.PingResponse pingResponse : fullPingResponses) {
                sb.append("\n\t--> ").append(pingResponse);
            }
        }
        logger.trace(sb.toString());
    }

    // filter responses
    List<ZenPing.PingResponse> pingResponses = Lists.newArrayList();
    for (ZenPing.PingResponse pingResponse : fullPingResponses) {
        DiscoveryNode node = pingResponse.node();
        if (masterElectionFilterClientNodes && (node.clientNode() || (!node.masterNode() && !node.dataNode()))) {
            // filter out the client node, which is a client node, or also one that is not data and not master (effectively, client)
        } else if (masterElectionFilterDataNodes && (!node.masterNode() && node.dataNode())) {
            // filter out data node that is not also master
        } else {
            pingResponses.add(pingResponse);
        }
    }

    if (logger.isDebugEnabled()) {
        StringBuilder sb = new StringBuilder("filtered ping responses: (filter_client[").append(masterElectionFilterClientNodes).append("], filter_data[").append(masterElectionFilterDataNodes).append("])");
        if (pingResponses.isEmpty()) {
            sb.append(" {none}");
        } else {
            for (ZenPing.PingResponse pingResponse : pingResponses) {
                sb.append("\n\t--> ").append(pingResponse);
            }
        }
        logger.debug(sb.toString());
    }

    final DiscoveryNode localNode = clusterService.localNode();
    List<DiscoveryNode> pingMasters = newArrayList();
    for (ZenPing.PingResponse pingResponse : pingResponses) {
        if (pingResponse.master() != null) {
            // We can't include the local node in pingMasters list, otherwise we may up electing ourselves without
            // any check / verifications from other nodes in ZenDiscover#innerJoinCluster()
            if (!localNode.equals(pingResponse.master())) {
                pingMasters.add(pingResponse.master());
            }
        }
    }

    // nodes discovered during pinging
    Set<DiscoveryNode> activeNodes = Sets.newHashSet();
    // nodes discovered who has previously been part of the cluster and do not ping for the very first time
    Set<DiscoveryNode> joinedOnceActiveNodes = Sets.newHashSet();
    if (localNode.masterNode()) {
        activeNodes.add(localNode);
        long joinsCounter = clusterJoinsCounter.get();
        if (joinsCounter > 0) {
            logger.trace("adding local node to the list of active nodes who has previously joined the cluster (joins counter is [{}})", joinsCounter);
            joinedOnceActiveNodes.add(localNode);
        }
    }

    Version minimumPingVersion = localNode.version();
    for (ZenPing.PingResponse pingResponse : pingResponses) {
        activeNodes.add(pingResponse.node());
        minimumPingVersion = Version.smallest(pingResponse.node().version(), minimumPingVersion);
        if (pingResponse.hasJoinedOnce() != null && pingResponse.hasJoinedOnce()) {
            assert pingResponse.node().getVersion().onOrAfter(Version.V_1_4_0_Beta1) : "ping version [" + pingResponse.node().version() + "]< 1.4.0 while having hasJoinedOnce == true";
            joinedOnceActiveNodes.add(pingResponse.node());
        }
    }

    if (minimumPingVersion.before(Version.V_1_4_0_Beta1)) {
        logger.trace("ignoring joined once flags in ping responses, minimum ping version [{}]", minimumPingVersion);
        joinedOnceActiveNodes.clear();
    }

    if (pingMasters.isEmpty()) {
        if (electMaster.hasEnoughMasterNodes(activeNodes)) {
            // we give preference to nodes who have previously already joined the cluster. Those will
            // have a cluster state in memory, including an up to date routing table (which is not persistent to disk
            // by the gateway)
            DiscoveryNode master = electMaster.electMaster(joinedOnceActiveNodes);
            if (master != null) {
                return master;
            }
            return electMaster.electMaster(activeNodes);
        } else {
            // if we don't have enough master nodes, we bail, because there are not enough master to elect from
            logger.trace("not enough master nodes [{}]", activeNodes);
            return null;
        }
    } else {

        assert !pingMasters.contains(localNode) : "local node should never be elected as master when other nodes indicate an active master";
        // lets tie break between discovered nodes
        return electMaster.electMaster(pingMasters);
    }
}
```
Ping了一堆结点出来，由ElectMasterService完成选举

```
public DiscoveryNode electMaster(Iterable<DiscoveryNode> nodes) {
    List<DiscoveryNode> sortedNodes = sortedMasterNodes(nodes);
    if (sortedNodes == null || sortedNodes.isEmpty()) {
        return null;
    }
    return sortedNodes.get(0);
}
private List<DiscoveryNode> sortedMasterNodes(Iterable<DiscoveryNode> nodes) {
    List<DiscoveryNode> possibleNodes = Lists.newArrayList(nodes);
    if (possibleNodes.isEmpty()) {
        return null;
    }
    // clean non master nodes
    for (Iterator<DiscoveryNode> it = possibleNodes.iterator(); it.hasNext(); ) {
        DiscoveryNode node = it.next();
        if (!node.masterNode()) {
            it.remove();
        }
    }
    //内省排序，总节点数THRESHOLD < 20，insertionSort; else heapsort
    CollectionUtil.introSort(possibleNodes, nodeComparator);
    return possibleNodes;
}
```
