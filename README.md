# **pageviews**
A technology demonstrator for the "Big Data Engineering" course at Hochschule Karlsruhe.

This project contains a small cluster of virtual machines and small jobs to be executed on them with batch and stream processing. The input data is being randomly generated to simulate pageviews on a webserver. Technologies used are:
* Virtualbox, Vagrant and Puppet
* Zookeeper, Kafka, Hadoop, Cassandra, Spark and Storm
* Spring projects (Spring Cloud, Stream, ...)


# **PREPARATIONS** #
All programs are currently (February 2017) available for MacOS, Windows and GNU/Linux. I only provide the GNU/Linux commands in this file. Installation on other platforms can obviously deviate.

I recommend getting the latest official version at the projects' homepages. Versions installed via the system's package manager can obviously deviate. The software versions used during the creation of this project are indicated within the respective sections.

## Software Installation ##
**Virtualbox**
[virtualbox.org](https://www.virtualbox.org)
Version used during development: 5.1.14

**Vagrant**
[vagrantup.com](https://www.vagrantup.com)
Version used during development: 1.9.1

Vagrant can be installed via Ruby's gem (if present on your machine):
```bash
gem install vagrant
```

**Puppet**
[puppet.com](https://puppet.com/)
Version used during development: 4.8.2

**Maven**
[maven.apache.org](https://maven.apache.org/)
Version used during development: 3.3.9

Binaries and sources can be downloaded from the given homepage. An installation via a system's package manager usually works fine.



## VM ##
### Setup ###
* If you enabled the shared directory between a guest and the host system, create the respective sub directory
* If you are behind a proxy, follow the instructions in the following section *Proxy* first
* Start the virtual machine (via terminal from within the root directory which contains the *Vagrantfile*) :
```bash
vagrant up
```
The first start will take a few minutes, all necessary files such as the OS images and all other programs have to be downloaded and the machines need to be set up.

#### Proxy ####
If you are behind a proxy, set an environment variable:
```bash
export HTTP_PROXY=http://USER:PASSWORD@PROXY_URL:PORT/
```

The virtual machine will need the vagrant plugin *proxyconf* to connect through a proxy:
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
The *Vagrantfile* contains multiple virtual machines. Some of the commands need the name of a specific machine to work (like *vagrant ssh*) and some can be called without any specified name and are then executed for all machines inside the *Vagrantfile* (like *vagrant up*). The machines need to be re-started every time the host had powered off. Besides that one, several other commands are available in order to control the VM via vagrant.

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
The initial steps of the setup are being described within the *Vagrantfile* in the rootdirectory:

All virtual machines will run on a so called *box* which is a base image that will be pulled automatically from a central repository (if not present already):
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
```

Below the specified module_path subdirectories for those separate modules are created. The following scheme is being used:
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

#### Hadoop ####
In this scope a single machine cluster is used for hadoop to run on. The Hadoop master only needs java to be installed beforehand in order to run. The full documentation for this setup can be found here: [Hadoop Single Cluster](https://hadoop.apache.org/docs/r2.7.3/hadoop-project-dist/hadoop-common/SingleCluster.html). The version matches the one specified in the manifest for the hadoop machine.

SSH is configured before setting up hadoop so that it does not perform strict host checking or asks for the adding of unknown hosts since the hadoop scripts are supposed to run headless without any user interaction. These settings are needed for this demo's purpose, but would be unfitting for any other environment than the one at hand!

During the setup of the hadoop machine the following steps are performed:
* Install Java
* Download and unpack Hadoop
* Create or replace settings files
  * set JAVA_HOME
  * set filesystem replication to 1 and make it accessible on port **9000**
  * make the map/reduce job tracker accessible via port **9001**
  * format the HDFS file system
  * start the NameNode and DataNode daemons
  * create the HDFS directories needed for any map/reduce jobs
  * create cron jobs for the Node daemons, so they start automatically every time the machine boots

The status of the NameNode can be viewed via the web interface on [localhost:50070](http://localhost:50070).

If the connection to hadoop fails, ssh into the machine and check whether hadoop is listening:
```bash
  $ netstat -anlp | grep LISTEN
```

#### Kafka-Modul ####
Kafka also runs on a single node in this setup. The basic instructions for this can be found here: [Kafka Single Node](https://kafka.apache.org/quickstart). Java and Scala need to be installed beforehand. The Scala version is important for the choice of the Kafka version so it is downloaded from the project's homepage explicitely instead of using the system's package manager.

This node receives its own private network IP, so that the stream can be accessed from the host system. Using *localhost* leads to undesired behaviour, such as error and warning outputs (although most actions can be performed successfully nonetheless):
```ruby
  kfk.vm.network "private_network", ip: "10.10.33.22"
```

Kafka's server settings also need to be edited, so that it will also accept connections from outside inside the *config/serer.properties*
```
  listeners=PLAINTEXT://0.0.0.0:9092
```

Kafka comes with a ready-to-use Zookeeper executable which is needed to run Kafka. In this scenario one Zookeeper server instance runs along with a Kafka server instance, both in daemon mode. Zookeeper will be accessible via the forwarded port **2181** and Kafka's broker list can be accessed on port **9092**. Those server daemons will also be started via cron every time the machine boots.

<!--
local test:

> cd /opt/kafka_***
> bin/zookeeper-server-start.sh config/zookeeper.properties
> bin/kafka-server-start.sh config/server.properties

> bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic test
> bin/kafka-topics.sh --list --zookeeper localhost:2181

> bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test
> bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --from-beginning
-->

#### Cassandra-Modul ####

https://cassandra.apache.org/

https://cassandra.apache.org/doc/latest/getting_started/installing.html#installation-from-binary-tarball-files

bin/cassandra -R (-R for root) (alternativ evtl data/ und logs/ sub-dirs erstellen und dann ohne superuser starten)


#### Spark-Modul ####
https://spark.apache.org/streaming/



## **Spring Apps** ##

### Generator ###
The project template for this application can be created via the Spring Initializr Tool on [start.spring.io](https://start.spring.io). The Spring Cloud Stream Binder for Kafka is needed.

The Generator is a Spring Boot / Spring Cloud application that creates a set of random strings to simulate pageviews on a webserver with
* timestamp
* visitor IP
* visitor UID
* visited URL
The created data are then being sent to a Kafka Topic named *Output* with the help of [Spring Cloud Stream](http://cloud.spring.io/spring-cloud-stream/).

The main application class is annotated with
```java
  @SpringBootApplication
```

The generator class is annotated to get connectivity to a message broker (Kafka in this case) as a producer:
```java
  @EnableBinding(Source.class)
```

The generating function is annotated to write to Kafka's *Output* topic repeatedly in a fixed time interval:
```java
  @InboundChannelAdapter(value = Source.OUTPUT, poller = @Poller(fixedDelay = "5000", maxMessagesPerPoll = "1"))
```

Inside the *application.yml* IP and port of Kafka's brokers are set (see above):
```yml
  spring:
    cloud:
      stream:
        kafka:
          binder:
            brokers: 10.10.33.22
            defaultBrokerPort: 9092
            zkNodes: 10.10.33.22
```

### Stream Processing ###

### Batch Processing ###


<!--
# TODO #
## up next ##
* understand apache cassandra
* startup scripts
  * start hadoop daemons (hadoop - start-all?)

## VM ##
* multinode (3)
  ✔ 1x hadoop master
  ✔ 1x zookeeper + kafka
  ✔ cassandra seed
  ❌ spark stream
  ❌ storm batch
* Datenstream in Kafka füttern
  * rechts raus holen und in HDFS schreiben
  * links "normales" stream

### Fragen ###
* Technologie-Lookup (stream processing):
  * apache beam for google data flow
  * flink

## Beispielprojekt ##
* Maven Projekt Spring Cloud Data Flow
  * Szenario Web Analytics (Clickstream Analyse mit Pageviews pro Zeitintervall)
  * Programmierung außerhalb
  * Job starten mit lokalen Daten und auf "virtueller remote hadoop" ausführen (java Dateien auf remote hadoop ausführen, ohne die Dateien direkt auf das Dateisystem der virtuellen Maschine ablegen zu müssen?)

# SOURCES #
## actual work with hadoop ##
  https://www.petrikainulainen.net/programming/apache-hadoop/creating-hadoop-mapreduce-job-with-spring-data-apache-hadoop/

## Spark ##
  http://www.michael-noll.com/blog/2014/10/01/kafka-spark-streaming-integration-example-tutorial/



# Alte Anmkerungen #
evtl. für die Doku noch relevant ... (?)
* Pig und Hive veraltet
* Spring Cloud Data FLow Plattform scheinbar zu abstrakt (web interface und custom CommandLineInterface mit spezifischen Funktionen)
  * https://www.youtube.com/watch?v=L6p1pzGgadA
  * http://cloud.spring.io/spring-cloud-dataflow/
    * http://localhost:9393/dashboard
-->
