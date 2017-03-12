# TODO #
## up next ##

# HINWEISE #
* STORM 
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

* hadoop
  * make flume (re)connect to kafka (even if it didn't work during startup ...)
  * output to Cassandra (outputs überschreiben oder neu strukturieren)
  * TODO: rm old hdfs://outputdir entfernen, wenn direkt nach cassandra schreibt etc

  <!-- 
  https://www.packtpub.com/books/content/writing-cassandra-hdfs-using-hadoop-map-reduce-job

  # CASSANDRA MAPREDUCE  
    > maven install on mapreduce job
    > cp *.jar to hdp_node
    > bin/hadoop jar hdfsreader-0.0.1-SNAPSHOT-jar-with-dependencies.jar de.hska.bdelab.Pageviews /input/00test /output/00test
  -->

  
* READER
  * Anleitung in README anpassen (mvn package && java -jar /target/**.jar) zum starten, statt mvn exec:java
  * URL und Uhrzeit als Parameter (VON BIS !!!) > eventuell Cassandras Struktur anpassen
  * Ausgabe beide Seiten getrennt (führen atm die selbe Verarbeitung durch)
  * dashboard? dashing.io

* maven
  * alle projekte zusammenfassen in einer "parent pom"

## Letzte Schritte #
* CLEANUP
  * remove tar.gz files etc. from puppet directories
  * remove "local test" sections from init.pp's and activate "real downloads"
  
* TEST TEST TEST :)
