class kafka {
	$home_dir = "/opt"
  $scala_version_major = "2.11"
	$scala_version_minor = "8"
	$kafka_version = "0.9.0.1"
	
  exec { "download_scala" :
	  command => "wget -O /tmp/scala.tar.gz http://downloads.lightbend.com/scala/${scala_version_major}.${scala_version_minor}/scala-${scala_version_major}.${scala_version_minor}.tgz",
    path => $path,
    unless => "ls ${home_dir} | grep scala-${scala_version_major}.${scala_version_minor}",
    require => Exec["insecuressh_finish"]
  }
	exec { "download_kafka" :
	  command => "wget -O /tmp/kafka.tar.gz http://ftp-stud.hs-esslingen.de/pub/Mirrors/ftp.apache.org/dist/kafka/${kafka_version}/kafka_${scala_version_major}-${kafka_version}.tgz",
    path => $path,
    unless => "ls ${home_dir} | grep kafka_${scala_version_major}-${kafka_version}",
    require => Exec["insecuressh_finish"]
  }
  

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

	file {
		"/root/startupscript.sh":
		source => "puppet:///modules/kafka/startupscript.sh",
		mode => 744,
		owner => root,
		group => root
	}

	exec { "startupscript_zookeeper" :
    command => "echo '${home_dir}/kafka_${scala_version_major}-${kafka_version}/bin/zookeeper-server-start.sh ${home_dir}/kafka_${scala_version_major}-${kafka_version}/config/zookeeper.properties &' >> /root/startupscript.sh",
    user => "root",
    path => $path,
    require => File["/root/startupscript.sh"],
    before => Exec["startupscript_kafka"]
  }
	exec { "startupscript_kafka" :
    command => "echo '${home_dir}/kafka_${scala_version_major}-${kafka_version}/bin/kafka-server-start.sh ${home_dir}/kafka_${scala_version_major}-${kafka_version}/config/server.properties &' >> /root/startupscript.sh",
    user => "root",
    path => $path,
    require => [ File["/root/startupscript.sh"], Exec["unpack_kafka"] ]
  }

	cron { "cron-startupscript-kfk" :
		command => "/root/startupscript.sh",
		user => "root",
		special => "reboot",
		ensure => present,
		require => [ Exec["unpack_kafka"], Exec["startupscript_kafka"] ]
	}

}
