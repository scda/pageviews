class hadoop {
  $hadoop_home = "/opt/hadoop"
  $hadoop_version = "2.7.3"

  package { "openjdk-7-jre-headless" :
	  ensure => present,
	  require => Exec["apt-get update"]
	}

  ## BEGIN local test
  file {
    "/tmp/hadoop.tar.gz":
    source => "puppet:///modules/hadoop/hadoop-2.7.3.tar.gz",
    before => Exec["download_hadoop"]
  }
  exec { "download_hadoop" :
    command => "echo 0",
    path => $path,
    unless => "ls /tmp | grep hadoop.tar.gz",
    require => Exec["removeknownhosts"]
  }
  ## END local test

  /*
  exec { "download_hadoop" :
  command => "wget -O /tmp/hadoop.tar.gz http://mirrors.cicku.me/apache/hadoop/common/hadoop-${hadoop_version}/hadoop-${hadoop_version}.tar.gz",
    path => $path,
    unless => "ls /opt | grep hadoop-${hadoop_version}",
    require => Exec["keycopy"]
  }
  */

  exec { "unpack_hadoop" :
    command => "tar -zxf /tmp/hadoop.tar.gz -C /opt",
    path => $path,
    creates => "${hadoop_home}-${hadoop_version}",
    require => Exec["download_hadoop"]
  }

  file {
    "${hadoop_home}-${hadoop_version}/etc/hadoop/hadoop-env.sh":
    source => "puppet:///modules/hadoop/hadoop-env.sh",
    mode => 644,
    owner => root,
    group => root,
    require => Exec["unpack_hadoop"],
    before => Exec["hdfs_format"]
  }

  file {
    "${hadoop_home}-${hadoop_version}/etc/hadoop/core-site.xml":
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

  exec { "hdfs_format" :
    command => "${hadoop_home}-${hadoop_version}/bin/hdfs namenode -format",
    path => $path,
    timeout => 30,
    require => Exec["unpack_hadoop"],
    before => Exec["start_daemons"]
  }

  exec { "start_hdpdaemons" :
    command => "${hadoop_home}-${hadoop_version}/sbin/start-dfs.sh",
    path => $path,
    require => Exec["unpack_hadoop"]
  }

  exec { "dfs_directories_1" :
    command => "${hadoop_home}-${hadoop_version}/bin/hdfs dfs -mkdir /user",
    path => $path,
    require => Exec["start_hdpdaemons"],
  }

  exec { "dfs_directories_2" :
    command => "${hadoop_home}-${hadoop_version}/bin/hdfs dfs -mkdir /user/root",
    path => $path,
    require => Exec["dfs_directories_1"]
  }

  cron { "cron-dfs-daemons" :
    command => "${hadoop_home}-${hadoop_version}/sbin/start-dfs.sh",
    user => "root",
    special => "reboot",
    ensure => present,
    require => Exec["unpack_hadoop"]
	}

  exec {"set_hadoop_home" :
    command => "echo 'HADOOP_HOME=${hadoop_home}-${hadoop_version}' >> /etc/environment",
    path => $path,
    user => "root"
  }
}
