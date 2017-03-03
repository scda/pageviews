class flume {
	$home_dir = "/opt"
	$flume_version = "1.7.0"

	## BEGIN local test
  file {
    "/tmp/flume.tar.gz":
    source => "puppet:///modules/flume/apache-flume-${flume_version}-bin.tar.gz",
    before => Exec["download_flume"]
  }
  exec { "download_flume" :
    command => "echo 0",
    path => $path,
    unless => "ls /tmp | grep flume.tar.gz",
    require => Exec["removeknownhosts"]
  }
  ## END local test

  /*
  exec { "download_flume" :
	  command => "wget -O /tmp/flume.tar.gz http://mirrors.cicku.me/apache/flume/1.7.0/apache-flume-1.7.0-bin.tar.gz",
    path => $path,
    unless => "ls ${home_dir} | grep apache-flume-${flume_version}-bin.tar.gz",
    require => Exec["keycopy"]
  }
  */

	exec { "unpack_flume" :
    command => "tar -zxf /tmp/flume.tar.gz -C ${home_dir}/",
    path => $path,
    creates => "${home_dir}/apache-flume-${flume_version}-bin",
    require => Exec["download_flume"]
  }

	file {
		"${home_dir}/apache-flume-${flume_version}-bin/conf/flume-kafka-source-hdfs-sink.conf":
    source => "puppet:///modules/flume/flume-kafka-source-hdfs-sink.conf",
    require => Exec["unpack_flume"],
		before => Exec["start-flume"]
  }

	file {
    "${home_dir}/logs":
    ensure => directory,
    before => Exec["start-flume"]
  }

	file {
    "${home_dir}/logs/flume.log":
    ensure => present,
    before => Exec["start-flume"],
		require => File["${home_dir}/logs"]
  }

	exec {"start-flume" :
		command => "${home_dir}/apache-flume-${flume_version}-bin/bin/flume-ng agent --conf ${home_dir}/apache-flume-${flume_version}-bin/conf -conf-file ${home_dir}/apache-flume-${flume_version}-bin/conf/flume-kafka-source-hdfs-sink.conf --name agent1 &",
		require => [ Exec["unpack_flume"], Exec["start_hdpdaemons"] ],
		timeout => 30
	}

	cron { "cron-flume" :
    command => "${home_dir}/apache-flume-${flume_version}-bin/bin/flume-ng agent --conf ${home_dir}/apache-flume-${flume_version}-bin/conf -conf-file ${home_dir}/apache-flume-${flume_version}-bin/conf/flume-kafka-source-hdfs-sink.conf --name agent1 &",
    user => "root",
    special => "reboot",
    ensure => present,
    require => Exec["unpack_flume"] 
	}

}
