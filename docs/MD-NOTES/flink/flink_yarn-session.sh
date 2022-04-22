flink  yarn session的启动

```
bin/yarn-session.sh -n 3 -s 4 -jm 4096m -tm 4096m -nm flink-1.6.0 –d
```
脚本yarn-session.sh的内容
```
bin=`dirname "$0"`
bin=`cd "$bin"; pwd`

# get Flink config
. "$bin"/config.sh

if [ "$FLINK_IDENT_STRING" = "" ]; then
        FLINK_IDENT_STRING="$USER"
fi

JVM_ARGS="$JVM_ARGS -Xmx512m"

CC_CLASSPATH=`manglePathList $(constructFlinkClassPath):$INTERNAL_HADOOP_CLASSPATHS`

log=$FLINK_LOG_DIR/flink-$FLINK_IDENT_STRING-yarn-session-$HOSTNAME.log
log_setting="-Dlog.file="$log" -Dlog4j.configuration=file:"$FLINK_CONF_DIR"/log4j-yarn-session.properties -Dlogback.configurationFile=file:"$FLINK_CONF_DIR"/logback-yarn.xml"

export FLINK_CONF_DIR

$JAVA_RUN $JVM_ARGS -classpath "$CC_CLASSPATH" $log_setting org.apache.flink.yarn.cli.FlinkYarnSessionCli -j "$FLINK_LIB_DIR"/flink-dist*.jar "$@"

```

执行的主类是FlinkYarnSessionCli,

```
public int run(String[] args) throws CliArgsException, FlinkException {
  //
  //	Command Line Options
  //
  final CommandLine cmd = parseCommandLineOptions(args, true);

  if (cmd.hasOption(help.getOpt())) {
    printUsage();
    return 0;
  }
  //initialize and start a YarnClient
  final AbstractYarnClusterDescriptor yarnClusterDescriptor = createClusterDescriptor(cmd);

  try {
    // Query cluster for metrics
    if (cmd.hasOption(query.getOpt())) {
      final String description = yarnClusterDescriptor.getClusterDescription();
      System.out.println(description);
      return 0;
    } else {
      final ClusterClient<ApplicationId> clusterClient;
      final ApplicationId yarnApplicationId;

      if (cmd.hasOption(applicationId.getOpt())) {
        yarnApplicationId = ConverterUtils.toApplicationId(cmd.getOptionValue(applicationId.getOpt()));

        clusterClient = yarnClusterDescriptor.retrieve(yarnApplicationId);
      } else {
        final ClusterSpecification clusterSpecification = getClusterSpecification(cmd);
        //create an application, and get its application id. 
        clusterClient = yarnClusterDescriptor.deploySessionCluster(clusterSpecification);

        //------------------ ClusterClient deployed, handle connection details
        yarnApplicationId = clusterClient.getClusterId();

        try {
          final LeaderConnectionInfo connectionInfo = clusterClient.getClusterConnectionInfo();

          System.out.println("Flink JobManager is now running on " + connectionInfo.getHostname() +
            ':' + connectionInfo.getPort() + " with leader id " + connectionInfo.getLeaderSessionID() + '.');
          System.out.println("JobManager Web Interface: " + clusterClient.getWebInterfaceURL());

          writeYarnPropertiesFile(
            yarnApplicationId,
            clusterSpecification.getNumberTaskManagers() * clusterSpecification.getSlotsPerTaskManager(),
            yarnClusterDescriptor.getDynamicPropertiesEncoded());
        } catch (Exception e) {
          try {
            clusterClient.shutdown();
          } catch (Exception ex) {
            LOG.info("Could not properly shutdown cluster client.", ex);
          }

          try {
            yarnClusterDescriptor.killCluster(yarnApplicationId);
          } catch (FlinkException fe) {
            LOG.info("Could not properly terminate the Flink cluster.", fe);
          }

          throw new FlinkException("Could not write the Yarn connection information.", e);
        }
```

具体步骤参考[Hadoop: Writing YARN Applications](http://hadoop.apache.org/docs/stable/hadoop-yarn/hadoop-yarn-site/WritingYarnApplications.html)

#### 1, 初始化创建yarnclient

```
//FlinkYarnSessionCli.java  initialize and start a YarnClient
final AbstractYarnClusterDescriptor yarnClusterDescriptor = createClusterDescriptor(cmd);
public AbstractYarnClusterDescriptor createClusterDescriptor(CommandLine commandLine) throws FlinkException {
  final Configuration effectiveConfiguration = applyCommandLineOptionsToConfiguration(commandLine);

  return createDescriptor(
    effectiveConfiguration,
    yarnConfiguration,
    configurationDirectory,
    commandLine);
}
//FlinkYarnSessionCli.java 
private AbstractYarnClusterDescriptor createDescriptor(
			Configuration configuration,
			YarnConfiguration yarnConfiguration,
			String configurationDirectory,
			CommandLine cmd) {

		AbstractYarnClusterDescriptor yarnClusterDescriptor = getClusterDescriptor(
			configuration,
			yarnConfiguration,
			configurationDirectory);
//FlinkYarnSessionCli.java 
private AbstractYarnClusterDescriptor getClusterDescriptor(
    Configuration configuration,
    YarnConfiguration yarnConfiguration,
    String configurationDirectory) {
  final YarnClient yarnClient = YarnClient.createYarnClient();
  yarnClient.init(yarnConfiguration);
  yarnClient.start();
```
#### 2，有了这个yarnClient就可以create an application, and get its application id

```
clusterClient = yarnClusterDescriptor.deploySessionCluster(clusterSpecification);
public ClusterClient<ApplicationId> deploySessionCluster(ClusterSpecification clusterSpecification) throws ClusterDeploymentException {
  try {//阻塞直到YarnApplicationMasterRunner启动起来，
    return deployInternal(
      clusterSpecification,
      "Flink session cluster",
      getYarnSessionClusterEntrypoint(),
      null,
      false);
  } catch (Exception e) {
    throw new ClusterDeploymentException("Couldn't deploy Yarn session cluster", e);
  }
}
//org.apache.flink.yarn.AbstractYarnClusterDescriptor.java
protected ClusterClient<ApplicationId> deployInternal(){
   ...
    // Create application via yarnClient
  final YarnClientApplication yarnApplication = yarnClient.createApplication();
  final GetNewApplicationResponse appResponse = yarnApplication.getNewApplicationResponse();
  //appResponse.getApplicationId();
  ...
}

```
#### 3,两个主要的context: ApplicationSubmissionContext与ContainerLaunchContext,

```
//org.apache.flink.yarn.AbstractYarnClusterDescriptor.java：部分代码
public ApplicationReport startAppMaster(){
		ApplicationSubmissionContext appContext = yarnApplication.getApplicationSubmissionContext();
    
    final ContainerLaunchContext amContainer = setupApplicationMasterContainer(
			yarnClusterEntrypoint,
			hasLogback,
			hasLog4j,
			hasKrb5,
			clusterSpecification.getMasterMemoryMB());
      
    amContainer.setLocalResources(localResources);
    amContainer.setEnvironment(appMasterEnv);
    
    appContext.setApplicationName(customApplicationName);
		appContext.setApplicationType("Apache Flink");
		appContext.setAMContainerSpec(amContainer);
		appContext.setResource(capability);

}
```

#### 4，有了yarnclient与appcontext就可以submit the application

```
yarnClient.submitApplication(appContext);

```
在此之后会启动一个amcontainer来启动ApplicationMaster,flink里的am是启动YarnApplicationMasterRunner

#### 5,Get application report

```
try {
				report = yarnClient.getApplicationReport(appId);
			} catch (IOException e) {
				throw new YarnDeploymentException("Failed to deploy the cluster.", e);
			}
			YarnApplicationState appState = report.getYarnApplicationState();
			LOG.debug("Application State: {}", appState);
			switch(appState) {
				case FAILED:
				case FINISHED:
				case KILLED:
					throw new YarnDeploymentException("The YARN application unexpectedly switched to state "
						+ appState + " during deployment. \n" +
						"Diagnostics from YARN: " + report.getDiagnostics() + "\n" +
						"If log aggregation is enabled on your cluster, use this command to further investigate the issue:\n" +
						"yarn logs -applicationId " + appId);
					//break ..
				case RUNNING:
					LOG.info("YARN application has been deployed successfully.");
					break loop;
				default:
					if (appState != lastAppState) {
						LOG.info("Deploying cluster, current state " + appState);
					}
					if (System.currentTimeMillis() - startTime > 60000) {
						LOG.info("Deployment took more than 60 seconds. Please check if the requested resources are available in the YARN cluster");
					}

			}
```
