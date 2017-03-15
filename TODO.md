# TODO #

* STORM 



* ALTE ANMERKUNGEN
    * install maven, git, ruby, python, nodejs
    * install java-8 and set it as $JAVA_HOME   ->    export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
    * git clone
    * "mvn clean install -DskipTests=true" from storm-top-level directory (package will fail otherwise with "cannot resolve dependencies")
    * "mvn package" from $STORM$/examples/storm-starter
    
  https://storm.apache.org/releases/current/Running-topologies-on-a-production-cluster.html
    * /opt/apache-storm-1.0.3/bin/storm jar /root/storm-master/examples/storm-starter/target/storm-starter-2.0.0-SNAPSHOT.jar org.apache.storm.starter.ExclamationTopology -local

  INPUT FROM KAFKA
  https://storm.apache.org/releases/1.0.3/storm-kafka.html > angegebene kafka version = 0.8.x 
    * version 0.8 ... testen!

* storm (stream processing)
  * process
  * read from kafka
  * write to cassandra  https://endocode.com/blog/2015/04/08/building-a-stream-processing-pipeline-with-kafka-storm-and-cassandra-part-1-introducing-the-components/
  https://storm.apache.org/releases/current/Tutorial.html
  https://storm.apache.org/releases/current/Setting-up-development-environment.html
  https://storm.apache.org/releases/current/Creating-a-new-Storm-project.html
  
* eine parent pom für alle projekte

## Letzte Schritte #
* CLEANUP
  * remove tar.gz files etc. from puppet directories
  * remove "local test" sections from init.pp's and activate "real downloads"
  
* TEST TEST TEST :) (mit echten und finalen files etc.)
