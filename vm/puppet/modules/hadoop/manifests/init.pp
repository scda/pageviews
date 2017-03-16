class hadoop {
  $hadoop_home = "/opt/hadoop"
  $hadoop_version = "2.7.3"

  package { "openjdk-7-jdk":
	  ensure => present,
	  require => Exec["apt-get update"]
	}
  
  package { "maven":
    ensure => present,
    require => Exec["apt-get update"]
  }
  
  exec { "package_finish" :
    command => "echo 0",
    path => $path,
    require => [ Package["openjdk-7-jdk"], Package["maven"] ]
  }

  ## BEGIN local test
  file { "/tmp/hadoop.tar.gz":
    source => "puppet:///modules/hadoop/hadoop-2.7.3.tar.gz",
    before => Exec["download_hadoop"]
  }
  exec { "download_hadoop":
    command => "echo 0",
    path => $path,
    unless => "ls /tmp | grep hadoop.tar.gz",
    require => Exec["insecuressh_finish"]
  }
  ## END local test

  /*
  exec { "download_hadoop" :
  command => "wget -O /tmp/hadoop.tar.gz http://mirrors.cicku.me/apache/hadoop/common/hadoop-${hadoop_version}/hadoop-${hadoop_version}.tar.gz",
    path => $path,
    unless => "ls /opt | grep hadoop-${hadoop_version}",
    require => Exec["insecuressh_finish"]
  }
  */

  exec { "unpack_hadoop":
    command => "tar -zxf /tmp/hadoop.tar.gz -C /opt",
    path => $path,
    creates => "${hadoop_home}-${hadoop_version}",
    require => Exec["download_hadoop"]
  }

  file { "${hadoop_home}-${hadoop_version}/etc/hadoop/hadoop-env.sh":
    source => "puppet:///modules/hadoop/hadoop-env.sh",
    mode => 644,
    owner => root,
    group => root,
    require => Exec["unpack_hadoop"],
    before => Exec["hdfs_format"]
  }

  file { "${hadoop_home}-${hadoop_version}/etc/hadoop/core-site.xml":
    source => "puppet:///modules/hadoop/core-site.xml",
    mode => 644,
    owner => root,
    group => root,
    require => Exec["unpack_hadoop"],
    before => Exec["hdfs_format"]
  }

  file {
    "${hadoop_home}-${hadoop_version}/etc/hadoop/hdfs-site.xml":
    source => "puppet:///modules/hadoop/hdfs-site.xml",
    mode => 644,
    owner => root,
    group => root,
    require => Exec["unpack_hadoop"],
    before => Exec["hdfs_format"]
  }

  file {
    "${hadoop_home}-${hadoop_version}/etc/hadoop/mapred-site.xml":
    source => "puppet:///modules/hadoop/mapred-site.xml",
    mode => 644,
    owner => root,
    group => root,
    require => Exec["unpack_hadoop"],
    before => Exec["hdfs_format"]
  }

  file {
    "/etc/environment":
    source => "puppet:///modules/hadoop/environment",
    mode => 644,
    owner => root,
    group => root,
    before => Exec["hdfs_format"]
  }

  exec { "hdfs_format" :
    command => "${hadoop_home}-${hadoop_version}/bin/hdfs namenode -format",
    path => $path,
    timeout => 30,
    require => Exec["unpack_hadoop"],
    before => Exec["start_hdpdaemons"]
  }

  exec { "start_hdpdaemons" :
    command => "${hadoop_home}-${hadoop_version}/sbin/start-dfs.sh",
    path => $path,
    require => Exec["unpack_hadoop"],
    before => Exec["startupscript_flume"]
  }

  /*exec { "dfs_directories_1" :
    command => "${hadoop_home}-${hadoop_version}/bin/hdfs dfs -mkdir /user",
    path => $path,
    require => Exec["start_hdpdaemons"],
  }

  exec { "dfs_directories_2" :
    command => "${hadoop_home}-${hadoop_version}/bin/hdfs dfs -mkdir /user/root",
    path => $path,
    require => Exec["dfs_directories_1"]
  }*/

  file {
    "/root/startupscript.sh":
    source => "puppet:///modules/hadoop/startupscript.sh",
    mode => 744,
    owner => root,
    group => root
  }

  exec { "startupscript_hdpdaemons" :
    command => "echo '${hadoop_home}-${hadoop_version}/sbin/start-dfs.sh' >> /root/startupscript.sh",
    user => "root",
    path => $path,
    require => File["/root/startupscript.sh"],
    before => Exec["startupscript_flume"]
  }

  cron { "cron-startupscript-hdp" :
    command => "/root/startupscript.sh",
    user => "root",
    special => "reboot",
    ensure => present,
    require => [ Exec["unpack_hadoop"], Exec["startupscript_hdpdaemons"] ]
	}
  
  file { "${hadoop_home}-${hadoop_version}/jobs/":
    ensure => directory,
    owner => root,
    group => root,
    require => Exec["unpack_hadoop"]
  }

  file { "${hadoop_home}-${hadoop_version}/jobs/PageViews.java":
    source => "puppet:///modules/hadoop/PageViews.java",
    mode => 744,
    owner => root,
    group => root,
    ensure => present,
    require => File["${hadoop_home}-${hadoop_version}/jobs/"],
    before => Exec["compile_job"]
  }

  exec { "compile_job" :
    cwd => "${hadoop_home}-${hadoop_version}/jobs",
    command => "${hadoop_home}-${hadoop_version}/bin/hadoop com.sun.tools.javac.Main PageViews.java",
    environment => [ "JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64",  "HADOOP_CLASSPATH=/usr/lib/jvm/java-7-openjdk-amd64/lib/tools.jar",
    "HADOOP_HOME=/opt/hadoop-2.7.3" ],
    path => $path,
    user => "root",
    require => [ File["${hadoop_home}-${hadoop_version}/PageViews.java"], File["${hadoop_home}-${hadoop_version}/etc/hadoop/hadoop-env.sh"], Exec["start_hdpdaemons"] ]
  }

  exec { "pack_job" :
    cwd => "${hadoop_home}-${hadoop_version}/jobs",
    command => "jar cf pageviewsJob.jar PageViews*.class",
    path => $path,
    user => "root",
    require => Exec["compile_job"]
  }
  
  file { "/tmp/dbwriter.tar.gz":
    source => "puppet:///modules/hadoop/dbwriter.tar.gz",
    ensure => present
  }
  
  exec { "unpack_dbwriter": 
    command => "tar -zxf /tmp/dbwriter.tar.gz -C /opt",
    path => $path,
    require => File["/tmp/dbwriter.tar.gz"]
  }
  
  exec { "package_dbwriter":
    cwd => "/opt/dbwriter",
    command => "mvn package",
    path => $path,
    require => Exec["unpack_dbwriter"]
  }
  
  exec { "rename_dbwriter"
    command => "/opt/dbwriter/target/pv-db-writer-jar-with-dependencies pv-db-writer-full.jar",
    path => $path,
    require => "package_dbwriter"
    before => Cron["cron-hdp-batch"]
  }

  file {
    "${hadoop_home}-${hadoop_version}/run-batch.sh":
    source => "puppet:///modules/hadoop/run-batch.sh",
    ensure => present,
    mode => 744,
    owner => root,
    group => root,
    require => Exec["unpack_hadoop"]
  }

  cron { "cron-hdp-batch" :
    command => "${hadoop_home}-${hadoop_version}/run-batch.sh",
    user => "root",
    minute => "*/5",
    ensure => present,
    require => File["${hadoop_home}-${hadoop_version}/run-batch.sh"]
	}
  
}
