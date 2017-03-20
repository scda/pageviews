# **pageviews**
A technology demonstrator for the "Big Data Engineering" course at Hochschule Karlsruhe.

This project contains a small cluster of virtual machines and small jobs to be executed on them with batch and stream processing. The input data is being randomly generated to simulate pageviews on a webserver. Technologies used are:
* Virtualbox, Vagrant and Puppet
* Zookeeper, Kafka, Hadoop, Flume, Cassandra, Storm


# **QUICKSTART** #
## Preparations ##
All of the used software is currently (early 2017) available for MacOS, Windows and GNU/Linux and largely open source, meaning you should be able to download the sources and build them for your platform if there are no binaries available already. I recommend getting the latest official version at the projects' homepages. Versions installed via a system's package manager can obviously deviate. The software versions used during the creation of this project are indicated within the respective sections.

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

**Ruby**
[ruby-lang.org](https://www.ruby-lang.org/)
Version used during development: 2.4.0
*- only needed for the dashboard -*


## Go! ##
### VMs ###
Change into the *vm* directory containing the *Vagrantfile* and start all the virtual machines 
```bash
$ vagrant up
```

### Generator ###
This application will produce somewhat random inputs for the batch and stream processing. 

Change into the *generator* directory and run it 
```bash
$ mvn package
$ java -jar target/pv-generator-*-jar-with-dependencies.jar
```

### Reader ###
This application will give you the output from the batch processing. 

Change into the *dbreader* directory and run it 
```bash
$ mvn package
$ java -jar target/dbreader-*-jar-with-dependencies.jar ${DATE} ${START-TIME} ${END-TIME}
```
The *{DATE}* has to be provided in the format *yyyymmdd* (e.g. "20170317") without any separators. *{START-TIME}* and *{END-TIME}* have to be provided as numbers in the format *hh* (e.g. "04").s

### Dashboard ###
This application will give you the output from the stream processing.

Preparations:
```bash
$ gem install dashing
$ gem install bundler
```
You will probably need to add the installation directory of the ruby gems to your *PATH*.
```bash
$ gem environment
$ export PATH=$PATH:{PATH OF THE "USER INSTALLATION DIRECTORY" GIVEN BY THE LAST COMMAND}
```

Change into the *dashboard* directory and run it 
```bash
$ bundle
$ dashing start
```

You can now open [localhost:3030](localhost:3030) in your browser and should see a dashboard. The data inside the dashboard will appear, when the stream application has processed its first datasets.

### Other Addresses ###
| machine | address | port of web-ui |
| Hadoop node | 10.10.33.11 | 50070 |
| Kafka node | 10.10.33.22 | -- |
| Storm node | 10.10.33.33 | 8080 |
| Cassandra node | 10.10.33.44 | -- |
 




# VIRTUAL ENVIRONMENT #
During this project's course the decision was met to use Vagrant combined with Puppet and therefore base the setup of the virtual environment on a *description* rather than creating a big pre-filled binary file for the VM - keeping in mind that the project aims towards being able to be distributed as easy as possible to the students.

Vagrant creates the virtual machines and performs the basic initial configurations while Puppet takes care of any further machine configuration in detail including the installation of all used software components.

The following setup will be achieved by executing the vagrant and puppet scripts:
![system overview](https://raw.githubusercontent.com/scda/pageviews/master/documentation/images/architecture.png)

## Vagrant ##
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

*Sidenote: Please make sure, you have at least 10GB of free space on your host's hard drive. The virtual machines by default have a virtual drive with a maximum size of 40GB, which could potentially lead to problems on your machine. Since the storage for the drive will be allocated dynamically and the current configuration allows the drives to be around 2GB each, there should not be any problem.*

All further setup, the so called provisioning of the machines will be left to puppet (see chapter below).

### Detailed Instructions ###
In addition to the instructions from the *Quickstart* above, I want to give a little more extensive set of instructions for the Setup and Usage of Vagrant.

#### Setup ####
* If you enabled the shared directory between a guest and the host system, create the respective sub directory
* If you are behind a proxy, follow the instructions in the section *Proxy* first

Start the virtual machine (via terminal from within the root directory which contains the *Vagrantfile*) :
```bash
$ vagrant up
```
The first start will take a few minutes since all necessary files such as the OS images and all other programs running inside the virtual machines have to be downloaded and the machines need to be set up.

#### Proxy ####
Set an environment variable first:
```bash
$ export HTTP_PROXY=http://USER:PASSWORD@PROXY_URL:PORT/
```

The virtual machine will need the vagrant plugin *proxyconf* to connect through a proxy, which can be installed directly from the command line:
```bash
$ vagrant plugin install vagrant-proxyconf
```

The *Vagrantfile* then has to be edited accordingly (simply uncomment and edit the already given lines according to your needs):
```ruby
config.proxy.http     = "http://USER:PASSWORD@PROXY_URL:PORT/"
config.proxy.https    = "http://USER:PASSWORD@PROXY_URL:PORT/"
config.proxy.no_proxy = "localhost,127.0.0.1"
```

#### Usage ####
The *Vagrantfile* contains multiple virtual machines to be set up. Some of the commands to control them need the name of a specific machine to work (like *vagrant ssh*) and some can be called without any specified name and are then executed for all machines inside the *Vagrantfile* (like *vagrant up*). The machines need to be re-started every time the host had powered off. The following list is only a selection of frequently needed commands.

Start the VMs:
```bash
$ vagrant up [NAME optional]
```
Suspend or shut the VMs down:
```bash
$ vagrant suspend [NAME optional]
$ vagrant halt [NAME optional]
```
Restart the machines (e.g. in connection with *--provision* to re-execute the provisioning scripts (see section *Puppet* below)):
```bash
$ vagrant reload [NAME optional]
```

Access the VM *NAME* via SSH:
```bash
$ vagrant ssh NAME
```
Leave the SSH environment on the VM via *CTRL-D* or one of the following:
```bash
$ logout
$ exit
```
You will by default be logged in as user *vagrant* with password *vagrant* and sudo rights.

Delete the VMs (including all used files except the box's base-image):
```bash
$ vagrant destroy [NAME optional]
```

See more commands and get infos about them (as usual):
```bash
$ vagrant [COMMAND optional] -h
```

## **Puppet** ##
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



# **INPUT** #
The input consists of two components: An instance of a Kafka message broker and a Java Application writing somewhat randomly generated data into one of the topics to simulate logs of pageviews on a webserver. Kafka then holds those messages for the other components of the overall system to come and get them.

## Kafka ##
Kafka is a distributed message broker for real-time data feeds with high throughput. In this setup it will run on a single node for the sake of simplicity. The very small amounts of data put in allow for this to work out well. Kafka depends on Apache Zookeeper, a distributed configuration and synchronization service. Zookeeper stores information about topics, brokers, consumers etc. for Kafka.

An instruction for a basic setup can be found here: [Kafka Single Node](https://kafka.apache.org/quickstart). Java and Scala need to be installed beforehand. The Scala version is important for the choice of the Kafka version.

For this simple setup the server settings for Kafka need to be edited only in a minimal way. The address for the listener needs to be edited, so that it will accept connections from outside the local machine and it needs to be told the address of the zookeeper instance (which runs on the same machine as Kafka in this setup):
*config/server.properties*
```properties
listeners=PLAINTEXT://0.0.0.0:9092
zookeeper.connect=10.10.33.22:2181
```

Kafka comes with a ready-to-use Zookeeper executable which is needed to run Kafka. In this scenario one Zookeeper server instance runs along with a Kafka server instance, both in daemon mode. Zookeeper will be accessible via the forwarded port **2181** and Kafka's broker list can be accessed on port **9092**. Those server daemons will be started via a bash startupscript and a cron entry every time the machine boots.


The applications are started from the KAFKA_HOME directory via:
```bash
bin/zookeeper-server-start.sh config/zookeeper.properties
bin/kafka-server-start.sh config/server.properties
```

You can create a new topic and check upon the creation with:
```bash
bin/kafka-topics.sh --create --zookeeper 10.10.33.22:2181 --replication-factor 1 --partitions 1 --topic output
bin/kafka-topics.sh --list --zookeeper 10.10.33.22:2181
```

There are two command line tools, that allow you to write to or read from a given topic very easily:
```bash
bin/kafka-console-producer.sh --broker-list 10.10.33.22:9092 --topic output
bin/kafka-console-consumer.sh --bootstrap-server 10.10.33.22:9092 --zookeeper 10.10.33.22:2181 --topic output --from-beginning
```


## Generator ##
The generator is a Java application using the [Producer API](https://kafka.apache.org/090/documentation.html#producerapi) for version 0.9.0 to access the Kafka stream. The required dependencies are pulled via maven. 

The generator produces messages containing
* timestamp
* visited URL
* visitor IP
* visitor UID

A sample output line looks like this:
```
Sun Mar 05 11:49:51 CET 2017,http://bdelab.hska.de/batch,200.85.175.21,f1ecc1e3-bdd8-40de-9477-e2dba56af7a5
```

The configuration of the application happens right inside the code file: Most importantly the address of the Kafka node and the port of its message broker need to be specified.
```java
Properties props = new Properties();
props.put("bootstrap.servers", "10.10.33.22:9092");
```

The data is sent via a *KafkaProducer* that sends a *ProducerRecord* containing a key, value pair (both consisting of strings in this case) to Kafka's *output* topic. 
```java
producer.send(new ProducerRecord<String, String>("output", "pageviews", NewMessage()));
```

The generator can be started via Maven :
```bash
$ mvn package
$ mvn exec:java
```
In Eclipse you have to execute it with *Run As* > *Maven Build*. The build goal has to be set to *exec:java*. The application will run in a loop until it is interrupted.

*Sidenote: The generator was first written using the Spring Stream Connector for Kafka. This approach was interestingly more complicated to implement and brought other difficulties with it as well: The format of the output was extended by some special characters that did not belong to the message and complicated parsing. On top of that the setup required a specific version of Kafka, that did not match the one required by Flume. The version discrepancy was the final reason why I dropped the Spring approach.*



# **BATCH PROCESSING** #
The main component to this part of the system is the Apache Hadoop software, that provides the distributed file system HDFS for the storage of incoming data and processes the data in regular intervals via map/reduce jobs. In addition to that a Flume Agent will run on the same machine. Flume is responsible for reading the data from the Kafka stream and write it to the HDFS, from where Hadoop's map/reduce jobs will read it.

## Flume ##
Apache Flume aims to be a distributed service to collect, aggregate and move large amounts of data (usually logs) with a focus on streaming data flows.

This application is redirecting data from an input ("source") via a buffer ("channel") to an output ("sink"). All of the three components there (source, channel and sink) can be configured to take on various forms. The input can be an input file, a data stream, a HTTP source and others. In this case I use the connector to read from a kafka topic (the one where the generator put the simulated HTTP logs). The sink can also be configured in different ways. I use it to write the data to the HDFS so that Hadoop can process it from there. The directories required for Flume's output do not need to be preformatted with Hadoop, but will be created on the HDFS dynamically. The current Flume version [1.7.0] restricts the kafka-version to [0.9.x] which is not the latest version but has so far not made a noticeable difference. The basic user guide can be found on the [project's homepage](https://flume.apache.org/FlumeUserGuide.html). 

The application requires the directory containing Hadoop to be accessible via the environment variable:
```bash
$ export HADOOP_HOME=/opt/hadoop-2.7.3
```

The source (input) is configured to read from the Kafka node and its specified topic:
```conf
agent1.sources.kafka-source.type = org.apache.flume.source.kafka.KafkaSource
agent1.sources.kafka-source.kafka.bootstrap.servers = 10.10.33.22:9092
agent1.sources.kafka-source.kafka.topics = output
```

The sink (output) is configured to write to the HDFS instance into a specified directory:
```conf
agent1.sinks.hdfs-sink.type = hdfs
agent1.sinks.hdfs-sink.hdfs.path = hdfs://10.10.33.11:9000/input/%y-%m-%d/%H
```

Flume starts when the created cron job runs a startup-script shared with the Hadoop Daemons at every boot of the virtual machine. The created config file and the contained *agent* need to be specified explicitely. For debug purposes the Flume Agent can be started manually with additional options:
```bash
$ /opt/apache-flume-1.7.0-bin/bin/flume-ng agent --conf /opt/apache-flume-1.7.0-bin/conf -conf-file /opt/apache-flume-1.7.0-bin/conf/flume-kafka-source-hdfs-sink.conf --name agent1 -Dflume.root.logger=INFO,console
```

The easiest way to exit Flume while it is running in the background:
```bash
$ ps -ef|grep flume
$ kill -9 pid
```


## Hadoop ##
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

The status of the NameNode can be viewed via the web interface on port [50070](http://10.10.33.11:50070), where you can also find a very helpful browser for the filesystem.

If the connection to Hadoop fails, you can ssh into the machine and check whether Hadoop is listening on the ports given above.
```bash
$ netstat -anlp | grep LISTEN
```

### MapReduce ###
The MapReduce job is a small program that is applied to a set of data by Hadoop. The job is written in some language, compiled, packaged and then passed to Hadoop to be executed. In this case I wrote Java Code, compiled and packed it. Hadoop then receives the packed jar. I give a short introduction to the different steps of the processing and very quick explanations on their general behaviour. A much more extensive explanation for the jobs, functions etc. are available at the project's homepage: [MapReduce tutorial](https://hadoop.apache.org/docs/r2.7.3/hadoop-mapreduce-client/hadoop-mapreduce-client-core/MapReduceTutorial.html).

Hadoop runs the MapReduce job in regular intervals that are triggered by a cron task. Due to the very minimal scope of this setup the jobs run every five minutes and compute the number of calls for every called URL since the last full hour: A job running at 14:30 will process all log files from 14:00 to 14:30 and overwrite the output of any previous jobs run after 14:00 o'clock. This procedure is quite "unrealistic" (as in it does not match the processes in a production environment), but it is an an easy way to make progress and outputs visible without making anyone wait for hours to see any results from the batch jobs - despite the extremely small amounts of data being processed.

To run the jobs a Java JKD is required as well as the following environment variables:
```bash
$ export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64
$ export PATH=${JAVA_HOME}/bin:${PATH}
$ export HADOOP_CLASSPATH=${JAVA_HOME}/lib/tools.jar
```

The MapReduce jobs process the data stored on HDFS in the way the job was programmed to. In this case the input data consists of multiple files with multiple lines of logentries. Each line contains one message with one set of data the generator puts out (see above). The job currently only receives the input and output directories as parameter and goes to work from there.
```java
FileInputFormat.addInputPath(job, new Path(args[0]));
FileOutputFormat.setOutputPath(job, new Path(args[1]));
```

The job receives a class that contains the job functions and that is to be read from the built jar. The subclasses for the Mapper, Combiner and Reducer are also specified. 
```java
job.setJarByClass(PageViews.class);
job.setMapperClass(TokenizerMapper.class);
job.setCombinerClass(IntSumReducer.class);
job.setReducerClass(IntSumReducer.class);
```

The first step to the batch job is the map phase. The implementation of this class extends an existing *Mapper* class whose *map()* function receives and outputs key-value pairs. This Mapper is very straight forward: It receives lines from the files inside the specified directories (see above) and splits those up. Since the input sets (lines) contain much more data than we actually need, only one of the split portions is used. The HDFS directories already sort the logs as desired by time of creation so that the Mapper only needs to process the URLs and count count their occurences. This mapper will output a pair of *&lt;String, Number&gt;* where the String represents the URL. The number is always "one", since at this stage no accumulation takes place and every single input is processed individually.
```java
public static class TokenizerMapper extends Mapper<Object, Text, Text, IntWritable>{
  private final static IntWritable one = new IntWritable(1);
  private Text word = new Text();

  public void map(Object key, Text value, Context context)
  throws IOException, InterruptedException {
    if (value.toString() != "" ) {
      String[] result = value.toString().split(",");
      if (result.length > 1) {
        word.set(result[1]);
        context.write(word, one);
      }
    }
  }
}
```
An example for the output of this function:
  &lt;URL1, 1&gt;  
  &lt;URL2, 1&gt;  
  &lt;URL3, 1&gt;  
  &lt;URL1, 1&gt;  

The second step to the batch job is the combine phase. Since multiple files are being processed, there will be a map output for every single file. The combiner takes the output for single files and "reduces" those: In this example the CombinerClass is set to the same class the ReducerClass is set to. For an explanation of the class see the next section. The Combiner receives all pairs that the Mapper produced for a single file and puts pairs out again.

The thirt step to the batch job is the reduce phase.  The implementation of this class extends an existing *Reducer* class whose *reduce()* function receives and outputs key-value pairs. In contrast to the combine phase this one receives the pairs for all the files together and accumulates the numbers for all of them.
```java
public static class IntSumReducer extends Reducer<Text,IntWritable,Text,IntWritable> {
  private IntWritable result = new IntWritable();

  public void reduce(Text key, Iterable<IntWritable> values, Context context)
  throws IOException, InterruptedException {
    int sum = 0;
    for (IntWritable val : values) {
      sum += val.get();
    }
    result.set(sum);
    context.write(key, result);
  }
}
```
An example for the output of this function:
  &lt;URL1, 2&gt;  
  &lt;URL2, 1&gt;  
  &lt;URL3, 1&gt;  


This *.java* file is compiled with Hadoop and the Javac compiler and then packed into a *.jar*:
```bash
$ bin/hadoop com.sun.tools.javac.Main WordCount.java
$ jar cf wc.jar WordCount*.class
```

The job is then started with the created *.jar* file:
```bash
$ bin/hadoop jar pv.jar PageViews /input /output
```

*Sidenote: In this setup the source files and all the compiled, packed etc. files are stored directly inside Hadoop's home directory. This is quite messy, but putting them into separate directories, like a 'jobs' subdirectory lead to a lot of undesired behaviour and errors.*

For testing purposes separate directories can be created and filled with files from the local file system:
```bash
$ bin/hdfs dfs -mkdir /input
$ bin/hdfs dfs -copyFromLocal input01 /input
```

The results can then be viewed via:
```bash
$ bin/hadoop fs -cat /output/.../part-r-00000
```

*Sidenote: If the specified input directory DOES NOT exist or the output directory DOES already exist the job will fail.*

## HDFS to Cassandra ##
At first I made the MapReduce job directly write to Cassandra, which proved to be highly inperformant and probabl somewhat besides the point of a MapReduce job. Therefore now a second application will be run as part of the batch-process after the MapReduce job is finished. This application will read from HDFS and write to Cassandra. It uses the Datastax Java Driver for Cassandra and the Java API for Hadoops HDFS. 

The details of the part of reading from and writing to Cassandra can be found within the chapter *Cassandra* within *Output*.

In order to read from HDFS a Stream to a DistributedFileSystem has to be established from which the data can then be extracted:
```java
DistributedFileSystem dfs = new DistributedFileSystem();
dfs.initialize(new URI("hdfs://10.10.33.11:9000"), new Configuration());
FSDataInputStream streamReader = dfs.open(path);
```


# **STREAM PROCESSING** #
On the stream processing node only Apache Storm is running.

## Storm ##
Apache Storm is a free and open source distributed realtime computation system. It continuously processes unbounded incoming streams of data. A Storm cluster runs *topologies*, which are somewhat compareable to Hadoops *MapReduce jobs*.

In this case there is only one node for all the Storm components, but usually there are master and worker nodes. The master node runs a daemon called *Nimbus* (similar to Hadoop's *JobTracker*). Nimbus is responsible for distributing code around the cluster, assigning tasks to machines, and monitoring for failures. Each worker node runs a daemon called *Supervisor* which listens for work and manages *worker processes*. Each *worker process* executes a certain subset of a topology. The topology is therefore usually spread across multiple machines. This overview can also be found a little more in-depth at the [Storm Project's homepage](https://storm.apache.org/releases/current/Tutorial.html).

In this project the most important settings for the storm "cluster" are the settings for the connections to zookeeper and the nimbus seeds. Zookeeper is required for Storm to run which is why Storm will access the Zookeeper instance running on the *input node* that is also being used by Kafka. The nimbus seeds are obviously singular in this case and only running on the very same machine, as the rest of the Storm components:
```yaml
storm.zookeeper.servers:
  - "10.10.33.22"
storm.zookeper.port: "2181"
nimbus.seeds: 
  - "10.10.33.33"
```

Storm also gets a list of ports that it can use for its workers. One port will allow Storm to spawn one worker on its machine.
```yaml
supervisor.slots.ports:
  - 6700
  - 6701
  - 6702
  - 6703
```


With those settings the Storm components can be started. Variants and explanations for those settings can be found [here](https://storm.apache.org/releases/1.0.3/Setting-up-a-Storm-cluster.html).

Since Storm is a system that follow the "fail fast" premise, those need to be started as supervised daemons. In this project they are simply being started by Ubuntu's Upstart Init, which will also watch them and restart them if they fail (any exit, that is not an "Upstart stop" is viewed as fail). The configuration for those jobs can be found in */etc/init* and contain the following:
```conf
# start storm nimbus and restart it if failed
description     "start and keepalive storm nimbus"

start on startup
stop on shutdown

exec /opt/apache-storm-1.0.3/bin/storm nimbus
respawn
respawn limit 10 5
```

To start any of the processes manually one can simply use:
```bash
$ bin/storm nimbus
$ bin/storm supervisor
$ bin/storm ui
```

### Topologies ###
Topologies to be submitted to the Storm cluster can be written in Java, Python and a few languages. The programs create a new Topology by setting up a system of Spouts and Bolts. A Spout is a data source for the Topology and a Bolt is some form of processing step on the data that came in. The spout can for example connect to a Kafka stream and read from those topics, while the Bolt can perform computations on the data sets similar to what the MapReduce functions do. By arranging and connecting the Spouts and Bolts in a specific way, the "path" to the output data is determined. Topologies will be compiled, packed and submited to the Nimbus for execution as jar files.

In Java a *TopologyBuilder* is used and provided with Bolts and Spouts:
```java
TopologyBuilder builder = new TopologyBuilder();

topology.setSpout("pvKafkaSpout",new KafkaSpout());
topology.setBolt("pvSplitBolt",new SplitBolt()).shuffleGrouping("pvKafkaSpout");
topology.setBolt("pvCountBolt",new CountBolt()).shuffleGrouping("pvSplitBolt");

cluster.submitTopology("pageviewsTopology", conf, topology.createTopology());  
```

Before submitting a Topology to the configured Nimbus the number of workers to be assigned can be specified.

The Topology classes usually extend some base classes. The very same goes for the Bolts and Spouts. 

The Spout in this project extends *BaseRichSpout*. It outputs its data to a *SpoutOutputCollector*. The *open()* function is used for preparations (in this case a connection to the Kafka stream) and called when a task for this component is initialized within a worker on the cluster. It provides information about the environment to the Spout. For the usage of the Kafka stream, the server address and the name of the topics *("output")* have to be provided. The offset in the queue that indicates which messages have already been received by this client will be managed automatically.
```java
  props.put("bootstrap.servers", "10.10.33.22:9092");
  props.put("enable.auto.commit", "true");

  _consumer = new KafkaConsumer<String, String>(props);
  _consumer.subscribe(Arrays.asList("output"));
```

The *nextTuple()* method is called when Storm is requesting the Spout to emit tuples to the output collector. What is important in this method (to this project) are the requests to the Kafka Stream. Reading single messages from the stream is overly complex and makes little sense. Therefore the Spout will hold a buffer of messages and emit single lines to the Collector per function call. As soon as this buffer is empty, a poll on the Kafka topic is executed. 
```java
if (_records.isEmpty()) { 
	poll(); 
}

submit = _records.remove();

_collector.emit(new Values(submit));
```

The Bolt has similarly a preparing function *prepare()* and a regularly automatically called method *execute()*. The pageviews Topology uses a first Bolt that performs a format on the input strings (basically a string-split) to extract the urls from the input lines. The second Bolt counts the incoming urls and output the results to the dashboard. For further information on the updates of the dashboard, see the Chapter *Output* inside the section *Dashboard*. The data from the stream processing is currently not being persisted anywhere else.

The output data for the collectors has to be individually declared within each class - e.g.: 
```java
@Override
public void declareOutputFields(OutputFieldsDeclarer declarer) {
  declarer.declare(new Fields("url", "count"));
}
```



# **OUTPUT** #
The data output node only contains an instance of Cassandra. Both sides - stream and batch processing - write their data to this collection, where it can be read from.

## Cassandra ##
Cassandra is a reliable distributed database system. In this project it runs on a single node as well. Cassandra requires Java (JDK 8) and Python (curently 2.7) to be installed before going to work. The steps for a basic setup can be found here: [Cassandra Setup](https://cassandra.apache.org/doc/latest/getting_started/installing.html#installation-from-binary-tarball-files)

It's advised against running the application as root user, which will probably lead to errors. Therefore the user *cassandra* is created to start the service. For this service to run after every boot a cron job is set up. One *cassandra* directory is created inside */var/lib/* and */var/log* each. *cassandra* is assigned as owner of the created directories and also the applications home directory (*/opt* in this case).

Cassandra needs to be configured to be accessible from the other nodes in the conf/cassandra.yaml file:
```yaml
listen_address: 10.10.33.44
[...]
seed.provider:
  [...]
    - seeds: "10.10.33.44"
rpc_address: 10.10.33.44
start_native_transport: true
```

Cassandra is being written to from both the batch processing node and the stream processing node. In order to avoid unnecessary memory consume they both share the access to the same cassandra instance but with different keyspaces and therefore also different tables. 

Cassandra can be manually edited (among other ways) by using the cqlsh tool provided by the cassandra installation. The language matches other typical database query languages.
```cql
$ bin/cqlsh 10.10.33.44
> CREATE KEYSPACE IF NOT EXISTS pageviewkeyspace WITH REPLICATION = { 'class' : 'NetworkTopologyStrategy', 'datacenter1' : 3 };
> CREATE TABLE IF NOT EXISTS pageviewkeyspace.pageviewtable (time int, url text, calls int, PRIMARY KEY(time, url));
> select * from pageviewkeyspace.pageviewtable;
```


The keyspaces, tables, rows, columns etc. can be queried, edited and deleted as commonly known from other database software. To insert entries into a database (using the structures given above) with an optional "USING &lt;Option&gt;" appended:
```cql
$ bin/cqlsh 10.10.33.44
> INSERT INTO pageviewkeyspace.pageviewtable (time, url, calls) VALUES(12, 'http://bdelab.hska.de/pageviews', 2000); 
```
The full documentation of the latest version of CQL can be found in [the CQL reference](https://cassandra.apache.org/doc/latest/cql/index.html).

You can check on the cassandra process with the usual system tools and additionally use the nodetool for various commands:
```bash
$ bin/nodetool status
```

The structure of this Cassandra database will be set up as follows: Within the one keyspace *pageviewkeyspace* there are multiple tables. Per calendar day that data is written to it, one table will be created with the name *t${DATE}* (with the *date* in the format *yyyymmdd* e.g. *t20170328*). Within that table there are multiple columns, namely *time, url, calls*. *time* is an integer between 0 and 23 indicating the hour of the day. *url* is a string of the url that has been called. *calls* is an integer indicating the number of calls that have happened on the respective *url*. *time* and *url* form the Primary Key together, where *time* is the partition key and *url* is a clustering column (see the CQL documentation link above). If a new set of data is written to the table containing the same *time* and *url* values as one of the existing entries, the existing entry will be updated to match the new entry. Therefore no duplication will occur.

## Reader ##
The reader is again a Java application like the generator. It can be run via some IDE like IntelliJ or Eclipse, but can also be easily packaged via Maven and run on the command line. It uses the Datastax API to connect to and read from the Cassandra Database. It reads the outputs on the tables that contain the outputs of the batch processing respective to the given input parameters.

As mentioned before the application can be run from the command line. When working from inside the project's home directory the following commands will start it:
```bash
$ mvn package
$ java -jar target/dbreader-*-jar-with-dependencies.jar ${DATE} ${STARTTIME} ${ENDTIME}
```
The date has to be provided as string in the format *yyyymmdd* while start- and end-time have to be provided as full hours in the format *HH*. To give an example, the parameters could look like this: *20170328 10 16* which will request a list of the pageviews registered at the *28th of March 2017* within the timeframe between *10:00* and *16:59*.

Both the Reader and the Hadoop Node access Cassandra via the Datastax API for which a dependency is set in the maven project:
```xml
<dependency>
  <groupId>com.datastax.cassandra</groupId>
  <artifactId>cassandra-driver-core</artifactId>
  <version>3.1.4</version>
</dependency>
```

This driver delivers a very straight forward level of abstraction. It obviously needs to be provided with the essential information for the connection:
```java 
private final String keyspace = "pageviewkeyspace";
private final String node = "10.10.33.44";
```

After that the essence of the reading process are a few simple and self-explaining functions that perform most of the work for the user:
```java
private Cluster cluster = Cluster.builder().addContactPoint(node).build();;
private Session session = cluster.connect();

session.execute(query);

cluster.close();
```
The documentation for all available functions can be found in [the Datastax Java Driver reference ](http://docs.datastax.com/en/developer/java-driver/3.1/).

The query can be any query in correct CQL (Cassandra Query Language) like:
```cql
INSERT INTO exampleKeyspace.exampleTable (rowOneText, rowTwoText, rowThreeInt) VALUES('someValueString', 'someOtherValueString', 1001);
```

## Dashboard ##
To display the output of the stream processing in a somewhat direct and timely manner, a dashboard based on [dashing.io](http://dashing.io) is used. The installation process is explained in the *Quickstart* section.

The dashboard is updated via HTTP-POSTs sent from the Topology running on Storm. A manual update to the dashboard can be sent via:
```bash
$ curl -d '{ "auth_token": "pageviewskey", "items":[ {"label":"testentry2","value":"5"}] }' \http://localhost:3030/widgets/pageviews
```

The Storm topology uses apaches HTTP components for this:
```xml
<dependency>
  <groupId>org.apache.httpcomponents</groupId>
  <artifactId>httpclient</artifactId>
  <version>4.5.3</version>
</dependency>
```

```java
_httpClient = HttpClients.createDefault();
_widgetPost = new HttpPost("http://10.0.2.2:3030/widgets/pageviews");

_widgetPost.setEntity(new StringEntity(postString));
_httpClient.execute(_widgetPost);	
```
The *postString* is a JSON-formated dataload that corresponds to the data in the curl-POST from the example given above. The address *10.0.2.2* given here is the default gateway that is set for any virtual machine and therefore the address that leads from the guest-machine to the host-machine (where the dashboard is running).

The dashboard should be always up to date, since the topology will update it whenever it changes the count to any of the gathered urls.
