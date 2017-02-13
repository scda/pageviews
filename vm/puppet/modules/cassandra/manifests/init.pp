class cassandra {
	$home_dir = "/opt"
	$cassandra_version = "3.10"

	exec { "jdk8-ppa" :
		command => 'add-apt-repository ppa:openjdk-r/ppa',
		path => $path,
		before => Exec["update"]
	}

	exec { "update" :
		command => "/usr/bin/apt-get update";
	}

	package { "python2.7" :
	  ensure => present,
	  require => Exec["update"]
	}

	package { "openjdk-8-jre-headless" :
		ensure => present,
		require => [ Exec["update"], Exec["jdk8-ppa"] ]
	}



	## BEGIN local test
	file {
		"/tmp/cassandra.tar.gz":
		source => "puppet:///modules/cassandra/apache-cassandra-3.10-bin.tar.gz",
		before => Exec["download_cassandra"]
	}
	exec { "download_cassandra" :
		command => "echo 0",
		path => $path,
		unless => "ls /tmp | grep cassandra.tar.gz",
		require => Exec["removeknownhosts"]
	}
	## END local test

	/*
	exec { "download_cassandra" :
	command => "wget -O /tmp/cassandra.tar.gz http://mirror.netcologne.de/apache.org/cassandra/${cassandra_version}/apache-cassandra-${cassandra_version}-bin.tar.gz",
		path => $path,
		unless => "ls ${home_dir} | grep cassandra-${cassandra_version}",
		require => Exec["keycopy"]
	}
	*/

	exec { "unpack_cassandra" :
		command => "tar -zxf /tmp/cassandra.tar.gz -C ${home_dir}",
		path => $path,
		creates => "${home_dir}/cassandra-${cassandra_version}",
		require => Exec["download_cassandra"]
	}
}
