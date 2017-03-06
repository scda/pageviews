# **pageviews**
A technology demonstrator for the "Big Data Engineering" course at Hochschule Karlsruhe.

This project contains a small cluster of virtual machines and small jobs to be executed on them with batch and stream processing. The input data is being randomly generated to simulate pageviews on a webserver. Technologies used are:
* Virtualbox, Vagrant and Puppet
* Zookeeper, Kafka, Hadoop, Cassandra, Spark and Storm
* Spring projects (Spring Cloud, Stream, ...)


# **PREPARATIONS** #
All of the used software is currently (early 2017) available for MacOS, Windows and GNU/Linux and largely open source, meaning you should be able to download the sources and build them for your platform if there are no binaries available already. I recommend getting the latest official version at the projects' homepages. Versions installed via a system's package manager can obviously deviate. The software versions used during the creation of this project are indicated within the respective sections.

## Software Installation ##
**Virtualbox**
[virtualbox.org](https://www.virtualbox.org)
Version used during development: 5.1.14

**Vagrant**
[vagrantup.com](https://www.vagrantup.com)
Version used during development: 1.9.1

**Puppet**
[puppet.com](https://puppet.com/)
Version used during development: 4.8.2

**Maven**
[maven.apache.org](https://maven.apache.org/)
Version used during development: 3.3.9



## VM ##
### Setup ###
* If you enabled the shared directory between a guest and the host system, create the respective sub directory
* If you are behind a proxy, follow the instructions in the section *Proxy* first
* Start the virtual machine (via terminal from within the root directory which contains the *Vagrantfile*) :
```bash
vagrant up
```
The first start will take a few minutes, all necessary files such as the OS images and all other programs running inside the virtual machines have to be downloaded and the machines need to be set up.

#### Proxy ####
Set an environment variable first:
```bash
export HTTP_PROXY=http://USER:PASSWORD@PROXY_URL:PORT/
```

The virtual machine will need the vagrant plugin *proxyconf* to connect through a proxy, which can be installed directly from the command line:
```bash
vagrant plugin install vagrant-proxyconf
```

The *Vagrantfile* has to be edited accordingly (simply uncomment and edit the given lines according to your needs):
```ruby
config.proxy.http     = "http://USER:PASSWORD@PROXY_URL:PORT/"
config.proxy.https    = "http://USER:PASSWORD@PROXY_URL:PORT/"
config.proxy.no_proxy = "localhost,127.0.0.1"
```


# USAGE #
## VM Controls ##
The *Vagrantfile* sets up multiple virtual machines. Some of the commands to control them need the name of a specific machine to work (like *vagrant ssh*) and some can be called without any specified name and are then executed for all machines inside the *Vagrantfile* (like *vagrant up*). The machines need to be re-started every time the host had powered off. The following list is only a selection of frequently needed commands.

Start the VMs:
```bash
vagrant up [NAME optional]
```
Suspend or shut the VMs down:
```bash
vagrant suspend [NAME optional]
vagrant halt [NAME optional]
```
Restart the machines (e.g. in connection with *--provision* to re-execute the provisioning scripts (see section *Puppet* below)):
```bash
vagrant reload [NAME optional]
```

Access the VM *NAME* via SSH:
```bash
vagrant ssh NAME
```
Leave the SSH environment on the VM via *CTRL-D* or one of the following:
```bash
logout
exit
```
You will by default be logged in as user *vagrant* with password *vagrant* and sudo rights.

Delete the VMs (including all used files except the box's base-image):
```bash
vagrant destroy [NAME optional]
```

# **DEVELOPMENT** #
## **Virtual Environment** ##
During this project's course the decision was met to use Vagrant combined with Puppet and therefore base the setup of the virtual environment on a *description* rather than creating a big pre-filled binary file for the VM - keeping in mind that the project aims towards being able to be distributed as easy as possible to the students.

Vagrant creates the virtual machines and performs the basic initial configurations while Puppet takes care of any further machine configuration in detail including the installation of all used software components.

The following setup will be achieved by executing the vagrant and puppet scripts:
<!-- TODO: create, upload and link image -->
![pageviews machine setup ](https://github.com/adam-p/markdown-here/raw/master/src/common/images/icon48.png "machine setup")

### **Vagrant** ###
The initial steps of the setup are being described within the *Vagrantfile* in the root directory:

All virtual machines will run a so called *box* which is the base image that will be pulled automatically from a central repository (if not present already):
```ruby
config.vm.box = "ubuntu/trusty64"
```

The amount of memory available to a single vm is specified via a virtualbox specific variable:
```ruby
config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
end
```

All further setup, the so called provisioning of the machines will be left to puppet.

### **Puppet** ###
In this setup every machine has its own separate manifest-file and accesses different modules (some of which are shared, some only used by one machine). The separate machines are created and their puppet configuration is set individually:
```ruby
config.vm.define "machine01" do |mach01|
  # enable provisioning via puppet
  mach01.vm.provision :puppet do |puppet|
    puppet.manifests_path = "puppet/manifests"
    puppet.manifest_file = "machine01.pp"
    puppet.module_path = "puppet/modules"
  end
end

config.vm.define "machine02" do |mach02|
[...]
```

Inside the specified module_path subdirectories for those separate modules are created. The following scheme is being used:
```
  puppet
  |
  └── manifests
  |   | example-machine.pp
  |
  └── modules
      |
      └── "module01"
      |   |
      |   └── manifests
      |   |   | init.pp
      |   |
      |   └── files
      |       | ...
      |
      └── "module02"
          | ...
```

Puppet offers many different options that help the user to achieve the desired state of the targeted machine. The Documentation for all Puppet Resource Types can be found here: [Puppet Reference](https://docs.puppet.com/puppet/4.8/type.html)

#### Hadoop ####
The Apache Hadoop software library focuses on reliable, scalable, distributed computing and the processing of large data sets.

One component of Hadoop is HDFS, the Hadoop File System, which is a special distributed filesystem that will allow for big amounts of data to be written on an abstract file space. This filesystem stores the data that was read from the input stream before batch processing the received data with map/reduce jobs.

In this scope a single machine "cluster" is used for Hadoop to run on. The Hadoop master only needs java to be installed in order to run. The full documentation for this setup can be found here: [Hadoop Single Cluster](https://hadoop.apache.org/docs/r2.7.3/hadoop-project-dist/hadoop-common/SingleCluster.html).

SSH is configured before setting up Hadoop so that it will not perform strict host checking or ask for the adding of unknown hosts since the Hadoop scripts are supposed to run headless without any user interaction. These settings simplify the setup for this demo's purpose, but would be unfitting for any other environment since they create a serious security concern.

During the setup of the Hadoop machine the following steps are performed:
* Install Java
* Download and unpack Hadoop
* Create or replace settings files
  * set JAVA_HOME
  * set filesystem replication to 1 and make it accessible on port **9000**
  * make the map/reduce job tracker accessible via port **9001**
  * format HDFS
  * start the Name- and DataNode daemons
  * create the first HDFS directories
  * create cron jobs for the Node daemons, so they start automatically every time the machine boots

The status of the NameNode can be viewed via the web interface on [localhost:50070](http://localhost:50070).

If the connection to Hadoop fails, ssh into the machine and check whether Hadoop is listening:
```bash
  $ netstat -anlp | grep LISTEN
```
### Flume ###
Apache Flume aims to be a distributed service to collect, aggregate and move large amounts of data (usually used for logs) with a focus on streaming data flows. This is the second software component that resides on the same node as Hadoop in this setup.

This application is redirecting data from an input ("source") via a buffer ("channel") to an output ("sink"). All of the three components there (source, channel and sink) can be configured to take on various forms. The input can be an input file, a data stream, a HTTP source and others. In this case we will use the connector to read from a kafka topic (the one where the generator put the simulated HTTP logs). The sink can also be configured in different ways. We will use it to write the data to the HDFS so that Hadoop can process it from there. The directories required for Flume's output do not need to be preformatted with Hadoop, but will be created on the HDFS dynamically. The current Flume version [1.7.0] restricts the kafka-version to [0.9.x] which is not the latest version but has so far not made a noticeable difference.

<!-- TODO: config files from flume erklären + welche Schritte werden ausgeführt -->



<!--
flume guides:
  https://flume.apache.org/FlumeUserGuide.html
  > unterstützt nur kafka 0.9.x bisher !!

needed before:
  // set "systemwide" for all users !
  export HADOOP_HOME=/opt/hadoop-2.7.3
run flume:
    /opt/apache-flume-1.7.0-bin/bin/flume-ng agent --conf /opt/apache-flume-1.7.0-bin/conf -conf-file /opt/apache-flume-1.7.0-bin/conf/flume-kafka-source-hdfs-sink.conf --name agent1

    bin/flume-ng agent --conf conf -conf-file conf/flume-kafka-source-hdfs-sink.conf --name agent1 -Dflume.root.logger=INFO,console

  DEBUG:
    bin/flume-ng agent --conf conf -conf-file conf/test-kafka.conf --name agent1 -Dflume.root.logger=INFO,console


end flume (forcefully):
  ps -ef|grep flume
  kill -9 pid

CHECK HADOOP:
  /opt/hadoop-2.7.3/bin/hadoop fs -ls  hdfs://10.10.33.11:9000/
  > neue directories werden automatisch angelegt, müssen nicht vor-formatiert werden.



-->

#### Kafka Machine ####
Kafka is a distributed message broker for real-time data feeds with high throughput. In this setup it will run on a single node for the sake of simplicity. The very small amounts of data put in allow for this to work out well. Kafka depends on Apache Zookeeper, a distributed configuration and synchronization service. Zookeeper stores information about topics, brokers, consumers etc. for Kafka.

An instruction for a basic setup can be found here: [Kafka Single Node](https://kafka.apache.org/quickstart). Java and Scala need to be installed beforehand. The Scala version is important for the choice of the Kafka ver
```

Kafka's server settings also need to be edited, so that it will also accept connections from outside inside the *config/serer.properties*
```properties
  listeners=PLAINTEXT://0.0.0.0:9092
```

Kafka comes with a ready-to-use Zookeeper executable which is needed to run Kafka. In this scenario one Zookeeper server instance runs along with a Kafka server instance, both in daemon mode. Zookeeper will be accessible via the forwarded port **2181** and Kafka's broker list can be accessed on port **9092**. Those server daemons will also be started via cron every time the machine boots.

<!--
local test:

> cd /opt/kafka_***
> bin/zookeeper-server-start.sh config/zookeeper.properties
> bin/kafka-server-start.sh config/server.properties

> bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic output
> bin/kafka-topics.sh --list --zookeeper localhost:2181

> bin/kafka-console-producer.sh --broker-list localhost:9092 --topic output
> bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --zookeeper localhost:2181 --topic output --from-beginning
-->




#### Cassandra ####
Cassandra is a reliable distributed database system.

Cassandra runs on a single node as well. Cassandra requires Java (JDK 8) and Python (curently 2.7) to be installed before going to work. The steps for a basic setup can be found here: [Cassandra Setup](https://cassandra.apache.org/doc/latest/getting_started/installing.html#installation-from-binary-tarball-files)

Running the application as root user is not recommended and will probably lead to errors. Therefore the user *cassandra* is created to start the service. For this service to run after every boot a cron job is set up. One *cassandra* directory is created inside */var/lib/* and */var/log* each. *cassandra* is assigned as owner of the created directories and also the applications home directory (where it was unpacked to).

<!-- https://www.digitalocean.com/community/tutorials/how-to-install-cassandra-and-run-a-single-node-cluster-on-a-ubuntu-vps -->

<!-- TODO
evtl. listen Adresse ändern, damit von außen auf cass zugegriffen werden kann (bisher nicht getestet)
-->



#### Storm ####

https://spark.apache.org/streaming/



## **External Apps** ##

### Generator ###
The generator uses the Kafka [Producer API](https://kafka.apache.org/090/documentation.html#producerapi) for version 0.9.0 and pulls it via maven. The generator produces messages containing
  * timestamp
  * visited URL
  * visitor IP
  * visitor UID

The configuration of the application happens right inside the code file: Most importantly the address of the Kafka node and the port of its message broker need to be specified.

The data is sent via a *KafkaProducer*. The Producer sends a *ProducerRecord* containing a key, value pair - both consisting of strings - to the *output* topic on Kafka for as long as it is not interrupted.
```java
  producer.send(new ProducerRecord<String, String>("output", "pageviews", NewMessage()));
```

The generator can be started via Maven :
```bash
  $ mvn package
  $ mvn exec:java
```

In Eclipse you have to execute it with *Run As* > *Maven Build*. The build goal has to be set to *exec:java*.


### Batch Processing ###



<!--
  * https://hadoop.apache.org/docs/r2.7.3/hadoop-mapreduce-client/hadoop-mapreduce-client-core/MapReduceTutorial.html

  * HAVE JDK installed (not only headless JRE) !!!

set via puppet (automated):
  $ export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64
  $ export PATH=${JAVA_HOME}/bin:${PATH}
  $ export HADOOP_CLASSPATH=${JAVA_HOME}/lib/tools.jar

compile and create jar:
  $ bin/hadoop com.sun.tools.javac.Main WordCount.java
  $ jar cf wc.jar WordCount*.class

move files to hdfs:
  $ bin/hdfs dfs -mkdir /input
  $ bin/hdfs dfs -copyFromLocal /opt/hadoop-2.7.3/input01 /input
  $ bin/hdfs dfs -copyFromLocal /opt/hadoop-2.7.3/input02 /input

output file contents from hdfs:
  $ bin/hadoop fs -cat /input/input01

start job on hadoop via prepared jar:
  $ bin/hadoop jar wc.jar WordCount /input /output

output the results:
  $ bin/hadoop fs -cat /output/part-r-00000

cleanup to go again:
  $ bin/hdfs dfs -rm -r /output




konkret:
  nano PageViews.java
  bin/hadoop com.sun.tools.javac.Main PageViews.java
  jar cf pv.jar PageViews*.class
  bin/hdfs dfs -rm -r /output
  bin/hadoop jar pv.jar PageViews /input /output
  bin/hadoop fs -cat /output/part-r-00000


automatisch startender batch-job:
  - processed alle 5 minuten die aufrufe der aktuellen Stunde
  - überschreibt die alten Aufrufe

Notizen:
  - die job dateien werden direkt im Hadoop verzeichnis abgelegt, obwohl unschön, weil undesired behaviour auftritt, wenn die Dateien außerhalb angelegt / compiled werden etc
  - Der job failt mit Exception, wenn das entsprechende input directory nicht existiert > beispielsweise, weil der generator in der aktuellen stunde noch nicht aktiv gewesen ist.


-->


### Stream Processing ###



<!--
# TODO #
## up next ##
* map/reduce job
  * DOCUMENTATION

## after that ... #
* storm (stream processing)
  * read from kafka
  * process
  * write to cassandra  https://endocode.com/blog/2015/04/08/building-a-stream-processing-pipeline-with-kafka-storm-and-cassandra-part-1-introducing-the-components/
  https://storm.apache.org/releases/current/Tutorial.html
  https://storm.apache.org/releases/current/Setting-up-development-environment.html
  https://storm.apache.org/releases/current/Creating-a-new-Storm-project.html

* cassandra
  * Verteilung? je einen mit auf hadoop und storm nodes? extra mit "doppelter" Datenbank?
  * > wie viel RAM brauchen die Maschinen wirklich ... evtl. reduzieren?

* hadoop
  * make flume (re)connect to kafka (even if it didn't work during startup ...)
  * output
    * in Cassandra schreiben
    * erster key? (partition = url)
    * range abfragen möglich machen? (damit zeitspannen ausgegeben werden können)
    * output überschreiben > job läuft alle 5 minuten, fasst aber die gesamte vergangene Stunde zusammen

* Daten auslesen
  * command line tool (Java App) für manuelle Abfrage mit URL und Uhrzeit als Parameter
  * Ausgabe beide Seiten getrennt (führen atm die selbe Verarbeitung durch)

* README ausbauen:
  * Beschreibung der Verwendungszwecke der einzelnen Programme
  * wie/wo werden sie in dieser Konstellation eingesetzt? (+Bild)

* generator:
  * TEST mit vorgegebener Liste von Zugriffen zur Validierung (bestehende Liste erweitern!)
  * > muss eigentlich nicht über den generator geschehen, kann einfach in den hdfs://input ordner gepackt werden und dann den batch manuell starten

## Letzte Schritte #
* README
  * TODOs bearbeiten und raus
  * Kommentare raus

* CLEANUP
  * remove tar.gz files etc. from puppet directories

* MANIFESTS
  * remove "local test" sections from init.pp's and activate "real downloads"

* TEST TEST TEST :)

* ABGABE
  * README.md als .PDF mit Slides zusammenzippen und ins Intranet hochladen
  * Präsentation mit ein paar Slides vorbereiten (Darstellung Nodes und Ablauf etc.)
  * github neu aufsetzen > ohne history übergeben

> 14:00 Donnerstag E206 (20-30 min)
  > "praktische" Präsentation
  > Demo wie zu benutzen ist, wie eingerichtet wird/wurde, Konsolen: was läuft wo wie durch?
  > Systemübersicht
    * Wo sind welche Dateien und Anwendungen
    * Wie können laufende Prozesse "beobachtet" werden
-->
