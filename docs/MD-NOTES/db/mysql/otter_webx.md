### Otter 项目webx相关

一堆配置文件，真多, 直接看url映射

配置在webx-component-and-root.xml中

```
	<!-- 名称查找规则。 -->
    <services:mapping-rules>
		<!-- 输入映射 -->
        <!-- External target name => Internal target name -->
        <mapping-rules:extension-rule id="extension.input">
            <!-- 默认后缀 -->
            <mapping extension="" to="" />

            <!-- JSP -->
            <mapping extension="jhtml" to="" />
            <mapping extension="jsp" to="" />
            <mapping extension="jspx" to="" />
            <mapping extension="php" to="" />

            <!-- Velocity -->
            <mapping extension="htm" to="" />
            <mapping extension="vhtml" to="" />
            <mapping extension="vm" to="" />
        </mapping-rules:extension-rule>
		<!-- extension.output 输出映射 -->
        <!-- Internal target name => External target name -->
        <mapping-rules:extension-rule id="extension.output">
            <!-- 默认后缀 -->
            <mapping extension="" to="htm" />

            <!-- JSP -->
            <mapping extension="jhtml" to="jhtml" />
            <mapping extension="jsp" to="jhtml" />
            <mapping extension="jspx" to="jhtml" />
            <mapping extension="php" to="jhtml" />

            <!-- Velocity -->
            <mapping extension="htm" to="htm" />
            <mapping extension="vhtml" to="htm" />
            <mapping extension="vm" to="htm" />
        </mapping-rules:extension-rule>
```

1. extension.input 输入映射   
2. extension.output 输出映射


登录为例http://10.8.49.156:8080/login.htm

映射到login.vm,

```
<form method="post" name="login">
              <input type="hidden" name="action" value="user_action"/>
              <input type="hidden" name="event_submit_do_login" value="1" />
			  
			<table border="0" cellspacing="0" cellpadding="0">
				#set ($userGroup = $form.login.defaultInstance)
                <tr>
                   <td align="right">用户名：</td>
                   <td><input name="$userGroup.name.key" value="$!userGroup.name.value" type="text" class="login_input"/></td>
                </tr>
                <tr>
                   <td align="right">密码：</td>
                  <td><input name="$userGroup.password.key" type="password" class="login_input"/></td>
                </tr>
				<br />
                <span class="red">#loginMessage ($userGroup.loginError)</span>
					
                <tr>
                    <td>&nbsp;</td>
                    <td><div class="login_btn right"><a href="javascript:document.login.submit();">登&nbsp;&nbsp;&nbsp;录</a></div></td>
                </tr>
			</table>
         </form>
```

依据配置，找到UserAction的doLogin方法处理

UserAction.doLogin

```
public void doLogin(@FormGroup("login") User user,
                        @FormField(name = "loginError", group = "login") CustomErrors err, @Param("Done") String url,
                        Navigator nav, HttpSession session, ParameterParser params) throws Exception {

        user = userService.login(user.getName(), SecurityUtils.getPassword(user.getPassword()));

        if (user != null) {
            // 在session中创建User对象
            session.setAttribute(WebConstant.USER_SESSION_KEY, user);

            // 跳转到return页面
            if (null == url) {
                nav.redirectTo(WebConstant.CHANNEL_LIST_LINK);
            } else {
                nav.redirectToLocation(url);
            }

        } else {
            err.setMessage("invalidUserOrPassword");
        }
    }
```

然后跳转至channelListLink，这个定义在uris.xml中,对应channelList.vm

```
<services:uris>
		<uris:uri id="server">
            <serverURI>http://${otter.domainName}:${otter.port}/</serverURI>
		</uris:uri>
		<uris:turbine-uri id="homeModule" exposed="true" extends="server">
			<componentPath>/</componentPath>
		</uris:turbine-uri>

		<uris:turbine-content-uri id="homeContent" exposed="true"
			extends="homeModule" />
		<!-- ================================================================ -->
		<!-- Link Level： 继承前述各类links。 -->
		<!-- -->
		<!-- 使用方法： link -->
		<!-- ================================================================ -->
		<uris:turbine-uri id="channelListLink" exposed="true" extends="homeModule">
			<target>channelList.vm</target>
		</uris:turbine-uri>
		<uris:turbine-uri id="selectDataMediaSourceLink" exposed="true"
			extends="homeModule">
			<target>selectDataSource.vm</target>
		</uris:turbine-uri>
		<uris:turbine-uri id="channelAddLink" exposed="true" extends="homeModule">
			<target>addChannel.vm</target>
		</uris:turbine-uri>
		<uris:turbine-uri id="dataMediaListLink" exposed="true"
			extends="homeModule">
			<target>dataMediaList.vm</target>
		</uris:turbine-uri>
		<uris:turbine-uri id="dataMediaSourceListLink" exposed="true"
			extends="homeModule">
			<target>dataSourceList.vm</target>
		</uris:turbine-uri>
		<uris:turbine-uri id="userListLink" exposed="true" extends="homeModule">
			<target>userManager.vm</target>
		</uris:turbine-uri>
		<uris:turbine-uri id="systemReductionLink" exposed="true"
			extends="homeModule">
			<target>systemReduction.vm</target>
		</uris:turbine-uri>
		<uris:turbine-uri id="nodeListLink" exposed="true" extends="homeModule">
			<target>nodeList.vm</target>
		</uris:turbine-uri>
		<uris:turbine-uri id="otterLoginLink" exposed="true" extends="homeModule">
			<target>login.vm</target>
		</uris:turbine-uri>
		<uris:turbine-uri id="errorForbiddenLink" exposed="true" extends="homeModule">
			<target>forbidden.vm</target>
		</uris:turbine-uri>
		<uris:turbine-uri id="userAddLink" exposed="true" extends="homeModule">
			<target>addUser.vm</target>
		</uris:turbine-uri>
		<uris:turbine-uri id="nodeAddLink" exposed="true" extends="homeModule">
			<target>addNode.vm</target>
		</uris:turbine-uri>
		<uris:turbine-uri id="analysisDelayStatLink" exposed="true"
			extends="homeModule">
			<target>analysisDelayStat.vm</target>
		</uris:turbine-uri>
		<uris:turbine-uri id="analysisThroughputHistoryLink" exposed="true"
			extends="homeModule">
			<target>analysisThroughputHistory.vm</target>
		</uris:turbine-uri>
		<uris:turbine-uri id="systemParameterLink" exposed="true"
			extends="homeModule">
			<target>systemParameter.vm</target>
		</uris:turbine-uri>
		<uris:turbine-uri id="conflictStatListLink" exposed="true"
			extends="homeModule">
			<target>conflictStatList.vm</target>
		</uris:turbine-uri>
		<uris:turbine-uri id="conflictDetailStatListLink" exposed="true"
			extends="homeModule">
			<target>conflictDetailStatList.vm</target>
		</uris:turbine-uri>
		<uris:turbine-uri id="logRecordLink" exposed="true" extends="homeModule">
			<target>logRecordList.vm</target>
		</uris:turbine-uri>
		<uris:turbine-uri id="behaviorHistoryCurveLink" exposed="true"
			extends="homeModule">
			<target>behaviorHistoryCurve.vm</target>
		</uris:turbine-uri>
		<uris:turbine-uri id="canalListLink" exposed="true" extends="homeModule">
			<target>canalList.vm</target>
		</uris:turbine-uri>
		<uris:turbine-uri id="dataMatrixListLink" exposed="true"
			extends="homeModule">
			<target>dataMatrixList.vm</target>
		</uris:turbine-uri>
		<uris:turbine-uri id="canalAddLink" exposed="true" extends="homeModule">
			<target>addCanal.vm</target>
		</uris:turbine-uri>
		<uris:turbine-uri id="alarmRuleListLink" exposed="true"
			extends="homeModule">
			<target>alarmRuleList.vm</target>
		</uris:turbine-uri>
		<uris:turbine-uri id="alarmLogLink" exposed="true" extends="homeModule">
			<target>alarmSystemList.vm</target>
		</uris:turbine-uri>
		<uris:turbine-uri id="analysisTopStatLink" exposed="true"
			extends="homeModule">
			<target>analysisTopStat.vm</target>
		</uris:turbine-uri>
		<uris:turbine-uri id="autoKeeperClustersListLink" exposed="true"
			extends="homeModule">
			<target>autoKeeperClustersList.vm</target>
		</uris:turbine-uri>
		<uris:turbine-uri id="autoKeeperClustersDetailLink" exposed="true"
			extends="homeModule">
			<target>autoKeeperClustersDetail.vm</target>
		</uris:turbine-uri>
		<uris:turbine-uri id="autoKeeperClientPathLink" exposed="true"
			extends="homeModule">
			<target>autoKeeperClientPath.vm</target>
		</uris:turbine-uri>
		<uris:turbine-uri id="zookeeperAddLink" exposed="true" extends="homeModule">
			<target>addZookeeper.vm</target>
		</uris:turbine-uri>
		<uris:turbine-uri id="sqlInitLink" exposed="true" extends="homeModule">
			<target>initSql.vm</target>
		</uris:turbine-uri>
		<uris:turbine-uri id="wikiLink" exposed="true" extends="homeModule">
			<target>wikiGuide.vm</target>
		</uris:turbine-uri>
	</services:uris>
</beans:beans>
```

channelList.vm直接找ChannelList的execute()

