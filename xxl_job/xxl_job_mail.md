
JobFailMonitorHelper

```
public void start(){
  monitorThread = new Thread(new Runnable() {

    @Override
    public void run() {
      while (!toStop) {
        try {
          logger.debug(">>>>>>>>>>> job monitor beat ... ");
          Integer jobLogId = JobFailMonitorHelper.instance.queue.take();
          if (jobLogId != null && jobLogId > 0) {
            logger.debug(">>>>>>>>>>> job monitor heat success, JobLogId:{}", jobLogId);
            XxlJobLog log = XxlJobDynamicScheduler.xxlJobLogDao.load(jobLogId);
            if (log!=null) {
              if (ReturnT.SUCCESS_CODE==log.getTriggerCode() && log.getHandleCode()==0) {
                // running
                try {
                  TimeUnit.SECONDS.sleep(10);
                } catch (InterruptedException e) {
                  e.printStackTrace();
                }
                JobFailMonitorHelper.monitor(jobLogId);
              }
              if (ReturnT.SUCCESS_CODE==log.getTriggerCode() && ReturnT.SUCCESS_CODE==log.getHandleCode()) {
                // pass
              }
              if (ReturnT.FAIL_CODE == log.getTriggerCode()|| ReturnT.FAIL_CODE==log.getHandleCode()) {
                XxlJobInfo info = XxlJobDynamicScheduler.xxlJobInfoDao.loadById(log.getJobId());
                if (info!=null && info.getAlarmEmail()!=null && info.getAlarmEmail().trim().length()>0) {

                  Set<String> emailSet = new HashSet<String>(Arrays.asList(info.getAlarmEmail().split(",")));
                  for (String email: emailSet) {
                    String title = "《调度监控报警》(任务调度中心XXL-JOB)";
                    XxlJobGroup group = XxlJobDynamicScheduler.xxlJobGroupDao.load(Integer.valueOf(info.getJobGroup()));
                    String content = MessageFormat.format("任务调度失败, 执行器名称:{0}, 任务描述:{1}.", group!=null?group.getTitle():"null", info.getJobDesc());
                    MailUtil.sendMail(email, title, content, false, null);
                  }
                }
              }
            }
          }
        } catch (Exception e) {
          logger.error("job monitor error:{}", e);
        }
      }
    }
  });
  monitorThread.setDaemon(true);
  monitorThread.start();
}
```
