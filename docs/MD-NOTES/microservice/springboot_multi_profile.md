
### 使用spring-boot-maven-plugin插件的坑

springboot默认使用@作为变量占用符号，对于使用${}的来说简直是坑

使用maven-resources-plugin来解决

```
 <profiles>
       <!-- 开发环境，默认激活 -->
       <profile>
           <id>dev</id>
           <properties>
              <env>dev</env>
           </properties>
           <activation>
              <activeByDefault>true</activeByDefault><!--默认启用的是dev环境配置-->
           </activation>
       </profile>
       <!-- 生产环境 -->
       <profile>
           <id>prod</id>
           <properties>
              <env>prod</env>
           </properties>
       </profile>
       <!-- 测试环境 -->
       <profile>
           <id>test</id>
           <properties>
              <env>test</env>
           </properties>
       </profile>
    </profiles>
		
	
	<build>
    	 <finalName>databml</finalName> 
    	 
		<plugins>
		
			<plugin>
				<groupId>org.springframework.boot</groupId>
				<artifactId>spring-boot-maven-plugin</artifactId>
			</plugin>
			<!-- 注意，默认使用@，修改兼${} -->
			 <plugin>
				<groupId>org.apache.maven.plugins</groupId>
				<artifactId>maven-resources-plugin</artifactId>
				<configuration>
				<delimiters>
				<delimiter>${*}</delimiter>
				</delimiters>
				</configuration>
			</plugin>
		</plugins>
		
		 <filters>
            <filter>auto-configs/${env}/auto-${env}.properties</filter>
        </filters>
        
         <resources>
        <resource>
            <directory>src/main/resources</directory>
            <filtering>true</filtering>
             <includes>
                    <include>**/*.properties</include>
                    <include>**/*.xml</include>
                    <include>**/*.groovy</include>
                    <include>*.properties</include>
                </includes>
        </resource>
    </resources>
	</build>
```

当执行mvn命令大包时会用auto-configs/${env}/auto-${env}.properties替换resources的内容
