# **pageviews**
A technology demonstrator for the "Big Data Engineering" course at Hochschule Karlsruhe.

We set up a small cluster of virtual machines and execute a small example job on them. We generate virtual data to simulate pageviews on a non-existing webserver and process this data with Batch and Stream processing. Technologies used are:
* Vagrant and Puppet
* Zookeeper, Hadoop, Cassandra, Spark and Storm
* Spring projects


# **PREPARATIONS** #
All programs are currently (February 2017) available for MacOS, Windows and GNU/Linux. I only provide the GNU/Linux commands in this file. Installation on other platforms can obviously deviate.

I recommend getting the latest official version at the projects' homepages. Versions installed via the system's package manager can obviously deviate. The software version used during the creation of this project are indicated within the respective sections.

## Installation ##
**Vagrant**  
[vagrantup.com](https://www.vagrantup.com)  
Version used during development: 1.9.1

Vagrant can be installed via Ruby's gem (if present on your machine):
```bash
gem install vagrant
```

**Virtualbox**  
[virtualbox.org](https://www.virtualbox.org)  
Version used during development: 5.1.14

Binaries for the common platforms are available at the homepage. Compare version numbers when installing via a system's package manager.

## VM ##
### Setup ###
<!-- TODO: shared directory benötigt? -->
* Move the *Vagrantfile* in the project's root directory.
* Create a sub directory called *guestData* (for shared data between host and guest system)
* If you are behind a proxy, follow the instructions in the following section *Proxy*
* start the virtual machine (via terminal from within the root directory)
```bash
vagrant up
```
The first start will take a few minutes, the image has to be downloaded and the machine set up.

#### Proxy ####
If you are behind a proxy, set an environment variable:
```bash
export HTTP_PROXY=http://USER:PASSWORD@PROXY_URL:PORT/
```

The virtual machine will need the vagrant plugin *proxyconf* to connect through a proxy:
```bash
vagrant plugin install vagrant-proxyconf
```

The *Vagrantfile* has to be edited accordingly:
```ruby
config.proxy.http     = "http://USER:PASSWORD@PROXY_URL:PORT/"
config.proxy.https    = "http://USER:PASSWORD@PROXY_URL:PORT/"
config.proxy.no_proxy = "localhost,127.0.0.1"
```

## Spring / Project ##
<!-- TODO -->




# USAGE #
## VM Controls ##
The VM has to be re-started every time the host had powered off. Besides that one, several other commands are available in order to control the VM via vagrant.

Start the VM:
```bash
vagrant up
```
Suspend or shut the VM down:
```bash
vagrant suspend
vagrant halt
```
Reload the machine (e.g. in connection with *--provision* to re-execute the provisioning scripts (see section *Puppet* below)):
```bash
vagrant reload
```

Access the VM via SSH:
```bash
vagrant ssh
```
Leave the SSH environment on the VM via *CTRL-D* or one of the following:
```bash
logout
exit
```

Delete the VM (including all used files except the box's base-image):
```bash
vagrant destroy
```

## Spring Project ##
<!-- TODO -->



# **DEVELOPMENT** #
## **Virtual Environment** ##
During this project we decided to use Vagrant combined with Puppet and therefore base the setup of the virtual environment on a *"description"*  rather than creating a big pre-configured binary VM file. Keeping in mind, that we want to be able to distribute it as easy as possible among users - namely students of the course at Hochschule Karlsruhe.

Vagrant creates the virtual machines and performs a few initial configurations while Puppet takes care of any further machine configuration in detail including the installation of all used software components.

The following setup will be achieved by executing the vagrant and puppet scripts:
<!-- TODO: create, upload and link image -->
![pageviews machine setup ](https://github.com/adam-p/markdown-here/raw/master/src/common/images/icon48.png "machine setup")

### **Vagrant** ###
The initial steps of the setup are being described within the *Vagrantfile* in the rootdirectory:

The virtualmachine will run on a so called *box* whose base image will be pulled automatically from a central repository, if not present already:
```ruby
config.vm.box = "ubuntu/trusty64"
```

The amount of memory available to a single vm is specified via a virtualbox specific variable:
```ruby
config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
end
```

All further setup, so called provisioning of the machines will be left to puppet:
```ruby
config.vm.provision :puppet do |puppet|
  puppet.manifests_path = "puppet/manifests"
  puppet.manifest_file = "example-machine.pp"
  puppet.module_path = "puppet/modules"
end
```

### **Puppet** ###
In this setup every machine has its own separate manifest-file and accesses different modules (some are shared, some only used by one machine). Below the specified module_path subdirectories for those separate modules can be created. The following scheme is being used:
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

#### Hadoop-Modul ####
https://hadoop.apache.org/docs/r2.7.3/hadoop-project-dist/hadoop-common/SingleCluster.html

web access: http://localhost:50070

if connection fails check if hadoop is listening:
  $ netstat -anlp | grep LISTEN



#### Kafka-Modul ####

https://kafka.apache.org/quickstart

port zookeper: 2181

> cd /usr/share/kafka_***
> bin/zookeeper-server-start.sh config/zookeeper.properties
> bin/kafka-server-start.sh config/server.properties

#### Cassandra-Modul ####

https://cassandra.apache.org/

https://cassandra.apache.org/doc/latest/getting_started/installing.html#installation-from-binary-tarball-files

bin/cassandra -R (-R for root) (alternativ evtl data/ und logs/ sub-dirs erstellen und dann ohne superuser starten)


#### Spark-Modul ####
https://spark.apache.org/streaming/



## **Das Projekt** ##

### Generator ###
= Kafka producer

direktes Projekt :  https://projects.spring.io/spring-kafka/
Teil von            http://cloud.spring.io/spring-cloud-stream/
Teil von            Sphttp://projects.spring.io/spring-cloud/


https://projects.spring.io/spring-kafka/
https://spring.io/blog/2015/04/15/using-apache-kafka-for-integration-and-data-processing-pipelines-with-spring
https://msvaljek.blogspot.de/2015/12/stream-processing-with-spring-kafka_44.html


### Verarbeitung ... ? ###


<!--
# TODO #
## up next ##
* Dokumentation der einzelnen Maschinen/Module ;)
* understand apache cassandra
* generator to write to kafka (spring kafka / spring stream kafka ?)
* startup scripts
  * start hadoop daemons (hadoop - start-all?)
  * start kafka + zookeeper

## VM ##
* multinode (3)
  ✔ 1x hadoop master
  ❌❌❌* 1x zookeeper
  ✔ 1x kafka
  ✔ cassandra seed
  * spark stream
  * storm batch
* Datenbank als Output für vorberechnete Daten (cass)
* Datenstream in Kafka füttern
  * rechts raus holen und in HDFS schreiben
  * links "normales" stream

### Fragen ###
* Wie kommen die Nachrichten zu Kafka und Zookeper (Input) - gibt es ein Spring Kafka "Plugin"?
* Technologie-Lookup (stream processing):
  * apache beam for google data flow
  * flink

## Beispielprojekt ##
* Generator URL Logs (in Kafka schreiben)
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
* Spring Cloud Data FLow Plattform scheinbar zu abstrakt
  * https://www.youtube.com/watch?v=L6p1pzGgadA
  * http://cloud.spring.io/spring-cloud-dataflow/
    * http://localhost:9393/dashboard
-->
