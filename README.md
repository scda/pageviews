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

Vagrant can be installed via Ruby (if present on your machine):
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
Leave the SSH environment on the VM via *CTRL-D* or:
```bash
logout
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
The initial
Alle anfänglichen Schritte der Einrichtung werden in der *Vagrantfile* beschrieben:
Es wird ein Ubuntu-Image für VirtualBox als Basis-System angegeben, welches bei der Einrichtung automatisch bezogen wird.
```ruby
config.vm.box = "ubuntu/trusty64"
```

Es werden definierte Ports von der Gastmaschine nach außen freigegeben.
```ruby
config.vm.network "forwarded_port", guest: 8080, host: 8080
```

<!-- TODO: notwending? -->
Es werden Ordner definiert, die einen manuellen Dateiaustausch zwischen der Gast- und der Hostmaschine erlauben.
```ruby
config.vm.synced_folder "./guestData/", "/vagrant_data"
```

Die Menge des zur Verfügung gestellten Speichers wird definiert und die Eigenschaft an VirtualBox übergeben.
```ruby
config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
end
```
Die weiterführende Einrichtung wird wie beschrieben Puppet überlassen, worüber Vagrant an dieser Stelle ebenfalls informiert wird.
```ruby
config.vm.provision :puppet do |puppet|
  puppet.manifests_path = "puppet/manifests"
  puppet.manifest_file = "hadoop-machine.pp"
  puppet.module_path = "puppet/modules"
end
```

### **Puppet** ###
Die zuletzt in der *Vagrantfile* angegebenen Verzeichnisse und Dateien müssen konsequent eingehalten werden. Die weiterführende Einrichtung der virtuellen Maschinen wird über die angegebene *manifests*-Datei begonnen und anschließend in logisch abgetrennte Module unterteilt.

Unterhalb des zuvor angegebenen module_paths können Unterordner für einzelne Module angelegt werden. Das jeweils obere Verzeichnis kann dabei einen beliebigen Namen tragen, während die folgenden Unterordner dann dem vorgegebenen Schema folgen sollten, damit die Module automatisch als solche erkannt werden können.
```
  puppet
  |
  └── manifests
  |   | hadoop-machine.pp
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

web access: http://localhost:50070

if connection fails check if hadoop is listening:
  $ netstat -anlp | grep LISTEN



#### Kafka-Modul ####



## **Das Projekt** ##

### Spring XY ###


<!--
# TODO #
## aktuell ##
* combine puppet scripts for hadoop (modules)
* Dokumentation der letzten Schritte (alles ab "Einrichtung Vagrant" > ändert sich ja jetzt ohnehin noch einmal wegen multinode)
* welche ports nach außen durchreichen?
* aus puppet entfernen, was nach jedem start laufen soll:
  * start daemons (hadoop - start-all?)
  * 
* Probleme mit Proxy (speziell der Download von Hadoop etc.)
* https://kafka.apache.org/quickstart

## VM ##
* multinode (3)
  * 1x hadoop master
  * 1x zookeeper
  * 1x kafka
  * cassandra seed
  * spark stream
  * storm batch
* Datenbank als Output für vorberechnete Daten
* links in Kafka füttern
* rechts HDFS schreiben (optional vorher aus Kafka holen)
* config von hadoop über xml

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
## proxy ##
https://hadoop.apache.org/docs/r2.7.3/hadoop-project-dist/hadoop-common/SingleCluster.html

## virtual environment ##
https://dzone.com/articles/setting-hadoop-virtual-cluster
https://hadoop.apache.org/docs/r2.7.3/hadoop-project-dist/hadoop-common/SingleCluster.html
https://docs.puppet.com/puppet/latest/type.html#exec-attribute-timeout

## actual work with hadoop ##
https://www.petrikainulainen.net/programming/apache-hadoop/creating-hadoop-mapreduce-job-with-spring-data-apache-hadoop/

## Spark ##
http://www.michael-noll.com/blog/2014/10/01/kafka-spark-streaming-integration-example-tutorial/



# Alte Anmkerungen #
evtl. für die Doku noch relevant ... (?)
* Pig und Hive veraltet
* Spring zu weit abstrahiert ("von der Praxis")?
* spring Cloud Data FLow Plattform scheinbar zu abstrakt
  * https://www.youtube.com/watch?v=L6p1pzGgadA
  * http://cloud.spring.io/spring-cloud-dataflow/
    * http://localhost:9393/dashboard
-->
