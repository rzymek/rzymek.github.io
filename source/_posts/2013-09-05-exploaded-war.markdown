---
layout: post
title: "Exploaded WAR with Maven and Eclipse"
date: 2013-09-05 16:07
comments: true
categories: 
x: You need to setup the deployment scanner to look for exploaded war's in your project directory. As well the exploaded directory name need to end with `.war`
---

The aim: setup a maven war project and JBoss7/WildFly so that the only thing needed to see your changes is `touch my.war.dodeploy` and `F5` in the browser.

## Setting up Maven
	
First thing to do is to setup `outputDirectory`, so that Eclipse will put the class files instantly in the right place:

	<project>
		<build>
			<outputDirectory>${basedir}/src/main/webapp/WEB-INF/classes</outputDirectory>
		...		

Now you need to update Eclipse `.project` file:

    mvn eclipse:eclipse
If you haven't done that already, now's the time to do `File > Import > Existing Projects into Workspace` in Eclipse. Otherwize just refresh your project.
    
Setup the complete exploaded web app in `src/main/webapp` using [war:inplace](https://maven.apache.org/plugins/maven-war-plugin/inplace-mojo.html)

    mvn war:inplace
This will essentially copy declared runtime dependencies to `src/main/webapp/WEB-INF/lib`

### Keepeing it clean

Make sure not to commit `lib` and `classes` from `src/main/webapp/WEB-INF/` to your source control. 
If you're using `git` then put the follwing lines in the projects root `.gitignore`:

    /src/main/webapp/WEB-INF/lib
    /src/main/webapp/WEB-INF/classes

One more thing - let's tell the `clean` plugin to remove the generated `WEB-INF/lib` directory:
	<project>
		<build>
			<plugins>
				<plugin>
					<groupId>org.apache.maven.plugins</groupId>
					<artifactId>maven-clean-plugin</artifactId>
					<version>2.4.1</version>
					<configuration>
						<filesets>
							<fileset>
								<directory>${basedir}/src/main/webapp/WEB-INF/lib</directory>
								<includes>
									<include>**/*</include>
								</includes>
							</fileset>
						</filesets>
					</configuration>
				</plugin>		
		...
Note that `WEB-INF/classes` will be removed by default as is declared as `outputDirectory`.

## Setting up JBoss/WildFly

Linux users have it easy (MacOS probaly too) - just symlink `src/main/webapp` in `standalone/deployments`:

    cd $WILDFLY/standalone/deployments
    ln -s $MY_PROJECT/src/main/webapp my.war

Now the only thing to do after you've changes some Java files is to

    touch $WILDFLY/standalone/deployments/my.war.dodeploy
    
If you don't have symlinks on your system (e.g. Windows) - you'll need to do some additional setup. I'll describe it in another post. 

## Development cycle

All static file changes are instantly visible in the browser. 
After changing Java sources do

    touch $WILDFLY/standalone/deployments/my.war.dodeploy
After changing dependencies in the `pom.xml` do 

    mvn clean compile war:inplace
    touch $WILDFLY/standalone/deployments/my.war.dodeploy

