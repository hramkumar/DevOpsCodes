# Artifact Repository Manager - Nexus

What is Nexus Repository Manager?
It is an open source repository that supports many artifact formats, including Docker, Helm, Java, and npm. With the Nexus tool integration, pipelines in your toolchain can publish and retrieve versioned apps and their dependencies by using central repositories that are accessible from other environments.

# Benefits
 - Host own repositories
 - Proxy repository
	 - company internal
	 - public
 - Two Variants: Open source and Commercial
 - Multiple repositories for different formats

## Features

 - Integrate with LDAP
 - Flexible and powerful REST API for integration with other tools like Jenkins
 - Backup and restore
 - Metadata Tagging (labelling and tagging artifacts)
 - Cleanup policies
 - Search functionality
 - User token support for system user authentication

# Install and Run Nexus

The pre-requisite for installing Nexus is it needs Java 8. The VM should also support SSH on port 22.

## Install Java 8

 1. Check which version of the JDK your system is using:

    java -version

If Oracle Java is used, the results should look like:

    java version "1.8.0_241"
    Java(TM) SE Runtime Environment (build 1.8.0_241-b07)
    Java HotSpot(TM) 64-Bit Server VM (build 25.241-b07, mixed mode)

 2. Update the repositories:

    sudo apt-get update

3. Install OpenJDK:

    sudo apt-get install openjdk-8-jdk

4. Verify the version of the JDK:

    java -version
    
openjdk version "1.8.0_242"
OpenJDK Runtime Environment (build 1.8.0_242-b09)
OpenJDK 64-Bit Server VM (build 25.242-b09, mixed mode)

Once installed we can go ahead with Nexus Installation.

## Installing nexus

    wget https://download.sonatype.com/nexus/3/latest-unix.tar.gz

Un-tar the file

    tar -zxvf latest-unix.tar.gz

We see 2 folders that are un-tared.

 - nexus-3.28.1-01
 - sonatype-work

In the earlier versions of nexus there was just one folder : `nexus-3.xx.xx` and everything was stored in there.
In newer versions we have two folders.

##### Nexus folder:
Contains runtime and application of Nexus

    ls  nexus-3.36.0-01/
    NOTICE.txt  OSS-LICENSE.txt  PRO-LICENSE.txt  bin  deploy  etc  lib  public  replicator  system
##### Sonatype-work folder:
Contains your own configuration for Nexus and data.
If you upgrade to new version of nexus only the nexus folder get changed and sonatype-work will remain as is.
You can think of sonatype folder as sibling to nexus directory.

    ls  nexus-3.36.0-01/
    admin.password  db             generated-bundles  keystores  orient               tmp blobs           lasticsearch  instances          lock       port cache           etc            karaf.pid          log        restore-from-backup

 - You can use it as Plugins directory
 - This directory also has a file that has log of all the IP addresses that accessed Nexus
 - Also contains logs of Nexus app itself
 - Your uploaded files and metadata
 - You can use sonatype-work folder to backup all Nexus data

## Starting Nexus

 - Nexus service should not run with `root` user permissions

**Best Practice:** Create own user for Service (e.g. nexus)

 - Create a new linux user with only the permission it needs for that
   specific service.

***Create nexus user in Linux:***

    adduser nexus

Provide necessary password and other details.

### Changing the permission of the folders nexus and sonatype to nexus user

    chown -R nexus:nexus nexus-3.36.0-01
    chown -R nexus:nexus sonatype-work
Verify if the permissions are changed to nexus user instead of root.

    root@xxx:/opt~ ls -l
    total 199928
    drwxr-xr-x  4 root  root       4096 Nov 20 04:55 digitalocean
    -rw-r--r--  1 root  root  204710060 Oct 27 13:24 latest-unix.tar.gz
    drwxr-xr-x 10 nexus nexus      4096 Nov 20 05:08 nexus-3.36.0-01
    drwxr-xr-x  3 nexus nexus      4096 Nov 20 05:08 sonatype-work

### Set nexus configuration so that nexus service will run as nexus user

    vi nexus-3.36.0-01/bin/nexus.rc

    run_as_user="nexus"
    :wq

### Starting Nexus service

First of all, switch from `root` to `nexus` user.

    su - nexus

Now, let us start the ***nexus*** service.

    /opt/nexus-3.36.0-01/bin/nexus start

    Starting nexus
    nexus@xxx:~$ ps aux | grep nexus
    root        6856  0.0  0.0  10132  3796 pts/2    S    05:29   0:00 su - nexus
    nexus       6857  0.0  0.0  10156  5304 pts/2    S    05:29   0:00 -bash
    nexus       7096  254 15.4 6404724 1257924 pts/2 Sl   05:30   1:21 /usr/lib/jvm/

Check on which `port` nexus has been started and update firewall rules to access Nexus Repository on that port.

    netstat -tunlp
    (Not all processes could be identified, non-owned process info
     will not be shown, you would have to be root to see it all.)
    Active Internet connections (only servers)
    Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
    tcp        0      0 0.0.0.0:8081            0.0.0.0:*               LISTEN      7096/java
    tcp        0      0 127.0.0.1:36499         0.0.0.0:*               LISTEN      7096/java
    tcp        0      0 127.0.0.53:53           0.0.0.0:*               LISTEN      -
    tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      -
    tcp6       0      0 :::22                   :::*                    LISTEN      -
    udp        0      0 127.0.0.53:53           0.0.0.0:*                           -

Nexus is running on port **8081** as we can compare the PID from the `ps aux` with `netstat`.

### Accessing Nexus on web browser
http://1.1.0.187:8081/
Replace this IP with your IP.

# Login to Nexus - Administration and Repository

There is a default user created when we install nexus. This is the admin.password user.

    ls /opt/sonatype-work/nexus3/
    admin.password  db             generated-bundles  keystores  orient               tmp
    blobs           elasticsearch  instances          lock       port
    cache           etc            karaf.pid          log        restore-from-backup

Password for this is located under:

    cat /opt/sonatype-work/nexus3/admin.password
    f48ava88-688f-4aga-84eb-13760b254863

## Managing repositories

Important features:

- Repository
- Blob Stores
- Cleanup Policies

### Repository Management

By default we have some repositories already been created for us by Nexus. They are created out of the box when we deploy Nexus. (It creates them because these are probably the most used ones.)

Each repository has a type. They are:

 - proxy
 - group and
 - hosted

#### Repository Types:
*Proxy Repository:* 
This is a repository that is linked to a remote repository. For example, maven-central repository is a remote public repository for maven artifacts. It is a link to the remote repository.

If a component is requested from a remote repository by your application, it will go through this proxy instead of directory going through the remote.

Here, Nexus will act as a cache. Next time the request is made it get served by Nexus itself.

*Hosted Repository:*
This is the primary storage for artifacts and components. For example, for company owned components. (this is the typical use case.)

By default, we get maven-releases and maven-snapshots and nuget-hosted repositories.

 - maven-releases are immutable
 - maven-snapshots are mutable

*Group Repository:*
This is a powerful feature of Nexus Repository Manager, because you may have multiple individual repositories in Nexus and each one has its own purpose.

However,  you need to use multiple of these repositories in your application, obviously you don't want to create your endpoints of all of these different repositories.

So you create 1 endpoint and have all those repos behind that endpoint.

Group Repository allows you to combine other repositories and other repository groups as a single repository.

## Code Changes to create the Artifact
Invoke the pom.xml file and add the below piece of code just above `</plugins>`:

    <plugin>
	    <groupId>org.apache.maven.plugins</groupId>
	    <artifactId>maven-deploy-plugins</artifactId>
	    <version>2.8.2</version>
	</plugin>
	<plugin>
		<groupId>org.apache.maven.plugins</groupId>
		<artifactId>maven-deploy-plugins</artifactId>
	</plugin>

 Now, above your `<dependencies>` add the below piece of code:

    <distributionManagement>    
	    <snapshotRepository>    
		    <id>nexus-snapshots</id>    
		    <url>http://192.59.0.187:8081/repository/maven-snapshots/</url>    
	    </snapshotRepository>    
    </distributionManagement>

Now, Update the Username and Password details in Maven's `settings.xml` file above the `</servers>` ending tag.

Example path of settings.xml in windows `Program Files\apache-maven-3.8.1\conf\`

    <server>
      <id>nexus-snapshots</id>
      <username>user</username>
      <password>Password123</password>
    </server>


**NOTE:** The ID in settings.xml should match the ID mentioned in the `distributionManagement` section in `pom.xml`.

## Building the Artifact .jar file and pushing it to Nexus

From your terminal, navigate to the project's location and run the commands `mvn package` and `mvn deploy` to build the artifact and push it to Nexus repo.

    mvn package
    . . .
    . . .
    [INFO] Building jar: D:\xxx\java-maven-app\target\java-maven-app-1.1.0-SNAPSHOT.jar
    [INFO]
    [INFO] --- spring-boot-maven-plugin:2.3.5.RELEASE:repackage (default) @ java-maven-app ---
    [INFO] Replacing main artifact with repackaged archive
    [INFO] ------------------------------------------------------------------------
    [INFO] BUILD SUCCESS
    [INFO] ------------------------------------------------------------------------
    [INFO] Total time:  10.512 s
    [INFO] Finished at: 2021-11-20T16:08:51+05:30
    [INFO] ------------------------------------------------------------------------

We have successfully built the package. Next up we will pust the `.jar` file to Nexus repository "maven-snapshots",

    mvn deploy
    [INFO] Scanning for projects...
    [WARNING]
    [WARNING] Some problems were encountered while building the effective model for com.example:java-maven-app:jar:1.1.0-SNAPSHOT
    [WARNING] 'build.plugins.plugin.(groupId:artifactId)' must be unique but found duplicate declaration of plugin org.apache.maven.plugins:maven-deploy-plugins @ line 43, column 21
    [WARNING]
    [WARNING] It is highly recommended to fix these problems because they threaten the stability of your build.
    [WARNING]
    [WARNING] For this reason, future Maven versions might no longer support building such malformed projects.
    [WARNING]
    [INFO]
    [INFO] ---------------------< com.example:java-maven-app >---------------------
    [INFO] Building java-maven-app 1.1.0-SNAPSHOT
    [INFO] --------------------------------[ jar ]---------------------------------
    Downloading from central: https://repo.maven.apache.org/maven2/org/apache/maven/plugins/maven-deploy-plugin/2.7/maven-deploy-plugin-2.7.pom
    Downloaded from central: https://repo.maven.apache.org/maven2/org/apache/maven/plugins/maven-deploy-plugin/2.7/maven-deploy-plugin-2.7.pom (5.6 kB at 2.0 kB/s)
    [INFO]
    [INFO] --- maven-resources-plugin:2.6:resources (default-resources) @ java-maven-app ---
    [WARNING] Using platform encoding (Cp1252 actually) to copy filtered resources, i.e. build is platform dependent!
    [INFO] Copying 1 resource
    [INFO]
    [INFO] --- maven-compiler-plugin:3.6.0:compile (default-compile) @ java-maven-app ---
    [INFO] Nothing to compile - all classes are up to date
    [INFO]
    [INFO] --- maven-resources-plugin:2.6:testResources (default-testResources) @ java-maven-app ---
    [WARNING] Using platform encoding (Cp1252 actually) to copy filtered resources, i.e. build is platform dependent!
    [INFO] skip non existing resourceDirectory D:\xxx\java-maven-app\src\test\resources
    [INFO]
    [INFO] --- maven-compiler-plugin:3.6.0:testCompile (default-testCompile) @ java-maven-app ---
    [INFO] No sources to compile
    [INFO]
    [INFO] --- maven-surefire-plugin:2.12.4:test (default-test) @ java-maven-app ---
    [INFO]
    [INFO] --- maven-jar-plugin:2.4:jar (default-jar) @ java-maven-app ---
    [INFO]
    [INFO] --- spring-boot-maven-plugin:2.3.5.RELEASE:repackage (default) @ java-maven-app ---
    [INFO] Replacing main artifact with repackaged archive
    [INFO]
    [INFO] --- maven-install-plugin:2.4:install (default-install) @ java-maven-app ---
    [INFO] Installing D:\xxx\java-maven-app\target\java-maven-app-1.1.0-SNAPSHOT.jar to C:\Users\xxx\.m2\repository\com\example\java-maven-app\1.1.0-SNAPSHOT\java-maven-app-1.1.0-SNAPSHOT.jar
    [INFO] Installing D:\xxx\java-maven-app\pom.xml to C:\Users\xxx\.m2\repository\com\example\java-maven-app\1.1.0-SNAPSHOT\java-maven-app-1.1.0-SNAPSHOT.pom
    [INFO]
    [INFO] --- maven-deploy-plugin:2.7:deploy (default-deploy) @ java-maven-app ---
    Downloading from nexus-snapshots: http://192.59.0.187:8081/repository/maven-snapshots/com/example/java-maven-app/1.1.0-SNAPSHOT/maven-metadata.xml
    Uploading to nexus-snapshots: http://192.59.0.187:8081/repository/maven-snapshots/com/example/java-maven-app/1.1.0-SNAPSHOT/java-maven-app-1.1.0-20211120.104016-1.jar
    Uploaded to nexus-snapshots: http://192.59.0.187:8081/repository/maven-snapshots/com/example/java-maven-app/1.1.0-SNAPSHOT/java-maven-app-1.1.0-20211120.104016-1.jar (17 MB at 14 MB/s)
    Uploading to nexus-snapshots: http://192.59.0.187:8081/repository/maven-snapshots/com/example/java-maven-app/1.1.0-SNAPSHOT/java-maven-app-1.1.0-20211120.104016-1.pom
    Uploaded to nexus-snapshots: http://192.59.0.187:8081/repository/maven-snapshots/com/example/java-maven-app/1.1.0-SNAPSHOT/java-maven-app-1.1.0-20211120.104016-1.pom (2.7 kB at 12 kB/s)
    Downloading from nexus-snapshots: http://192.59.0.187:8081/repository/maven-snapshots/com/example/java-maven-app/maven-metadata.xml
    Uploading to nexus-snapshots: http://192.59.0.187:8081/repository/maven-snapshots/com/example/java-maven-app/1.1.0-SNAPSHOT/maven-metadata.xml
    Uploaded to nexus-snapshots: http://192.59.0.187:8081/repository/maven-snapshots/com/example/java-maven-app/1.1.0-SNAPSHOT/maven-metadata.xml (775 B at 6.2 kB/s)
    Uploading to nexus-snapshots: http://192.59.0.187:8081/repository/maven-snapshots/com/example/java-maven-app/maven-metadata.xml
    Uploaded to nexus-snapshots: http://192.59.0.187:8081/repository/maven-snapshots/com/example/java-maven-app/maven-metadata.xml (285 B at 1.7 kB/s)
    [INFO] ------------------------------------------------------------------------
    [INFO] BUILD SUCCESS
    [INFO] ------------------------------------------------------------------------
    [INFO] Total time:  12.155 s
    [INFO] Finished at: 2021-11-20T16:10:18+05:30
    [INFO] ------------------------------------------------------------------------


