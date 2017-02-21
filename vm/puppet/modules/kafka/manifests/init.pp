class kafka {
	$home_dir = "/opt"
  $scala_version_major = "2.11"
	$scala_version_minor = "8"
	$kafka_version = "0.10.1.1"

  ## BEGIN local test
  file {
    "/tmp/scala.tar.gz":
    source => "puppet:///modules/kafka/scala-2.11.8.tgz",
    before => Exec["download_scala"]
  }
  exec { "download_scala" :
    command => "echo 0",
    path => $path,
    unless => "ls /tmp | grep scala.tar.gz",
    require => Exec["removeknownhosts"]
  }
	file {
    "/tmp/kafka.tar.gz":
    source => "puppet:///modules/kafka/kafka_2.11-0.10.1.1.tgz",
    before => Exec["download_kafka"]
  }
  exec { "download_kafka" :
    command => "echo 0",
    path => $path,
    unless => "ls /tmp | grep scala.tar.gz",
    require => Exec["keycopy"]
  }
  ## END local test

  /*
  exec { "download_scala" :
	  command => "wget -O /tmp/scala.tar.gz http://downloads.lightbend.com/scala/${scala_version_major}.${scala_version_minor}/scala-${scala_version_major}.${scala_version_minor}.tgz",
    path => $path,
    unless => "ls ${home_dir} | grep scala-${scala_version_major}.${scala_version_minor}",
    require => Exec["keycopy"]
  }
	exec { "download_kafka" :
	  command => "wget -O /tmp/kafka.tar.gz http://mirror.yannic-bonenberger.com/apache/kafka/${kafka_version}/kafka_${scala_version_major}-${kafka_version}.tgz",
    path => $path,
    unless => "ls ${home_dir} | grep kafka_${scala_version_major}-${kafka_version}",
    require => Exec["keycopy"]
  }
  */

  exec { "unpack_scala" :
    command => "tar -zxf /tmp/scala.tar.gz -C ${home_dir}/",
    path => $path,
    creates => "${home_dir}/scala-${scala_version_major}.${scala_version_minor}",
    require => Exec["download_scala"]
  }

	exec { "unpack_kafka" :
    command => "tar -zxf /tmp/kafka.tar.gz -C ${home_dir}/",
    path => $path,
    creates => "${home_dir}/kafka_${scala_version_major}-${kafka_version}",
    require => Exec["download_kafka"]
  }

	file {
		"${home_dir}/kafka_${scala_version_major}-${kafka_version}/config/server.properties":
		source => "puppet:///modules/kafka/server.properties",
		require => Exec["unpack_kafka"],
		before => Exec["start-kafka"]
	}

	exec { "start-zookeeper" :
		command => "${home_dir}/kafka_${scala_version_major}-${kafka_version}/bin/zookeeper-server-start.sh -daemon ${home_dir}/kafka_${scala_version_major}-${kafka_version}/config/zookeeper.properties",
		user => "root",
		require => Exec["unpack_kafka"],
		before => Exec["start-kafka"]
	}

	exec { "start-kafka" :
		command => "${home_dir}/kafka_${scala_version_major}-${kafka_version}/bin/kafka-server-start.sh -daemon ${home_dir}/kafka_${scala_version_major}-${kafka_version}/config/server.properties",
		user => "root",
		require => Exec["unpack_kafka"]
	}


	cron { "cron-zookeeper" :
		command => "${home_dir}/kafka_${scala_version_major}-${kafka_version}/bin/zookeeper-server-start.sh ${home_dir}/kafka_${scala_version_major}-${kafka_version}/config/zookeeper.properties",
		user => "root",
		special => "reboot",
		ensure => present,
		require => Exec["unpack_kafka"]
	}
	cron { "cron-kafka" :
		command => "${home_dir}/kafka_${scala_version_major}-${kafka_version}/bin/kafka-server-start.sh ${home_dir}/kafka_${scala_version_major}-${kafka_version}/config/server.properties",
		user => "root",
		special => "reboot",
		ensure => present,
		require => Exec["unpack_kafka"]
	}

}
