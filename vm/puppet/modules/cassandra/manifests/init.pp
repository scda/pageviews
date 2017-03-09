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
		require => Exec["insecuressh_finish"]
	}
	## END local test

	/*
	exec { "download_cassandra" :
	command => "wget -O /tmp/cassandra.tar.gz http://mirror.netcologne.de/apache.org/cassandra/${cassandra_version}/apache-cassandra-${cassandra_version}-bin.tar.gz",
		path => $path,
		unless => "ls ${home_dir} | grep apache-cassandra-${cassandra_version}",
		require => Exec["insecuressh_finish"]
	}
	*/

	exec { "unpack_cassandra" :
		command => "tar -zxf /tmp/cassandra.tar.gz -C ${home_dir}",
		path => $path,
		creates => "${home_dir}/apache-cassandra-${cassandra_version}",
		require => File["/tmp/cassandra.tar.gz"]
	}

	user { "cass-user" :
		name => "cassandra",
		ensure => present,
		require => Exec["unpack_cassandra"]
	}
	
	file { "${home_dir}/apache-cassandra-${cassandra_version}/conf/cassandra.yaml" :
		source => "puppet:///modules/cassandra/cassandra.yaml",
		owner => "cassandra",
		before => Exec["start_cassandra"]
	}

	file { "chown-home" :
		path => "${home_dir}/apache-cassandra-${cassandra_version}",
		owner => "cassandra",
		ensure => directory,
		recurse => true,
		require => User["cass-user"],
		before => Exec["start_cassandra"]
	}

	file { "var-lib" :
		path => "/var/lib/cassandra",
		ensure => directory,
		owner => "cassandra",
		require => User["cass-user"],
		before => Exec["start_cassandra"]
	}

	file { "var-log" :
		path => "/var/log/cassandra",
		ensure => directory,
		owner => "cassandra",
		require => User["cass-user"],
		before => Exec["start_cassandra"]
	}

	exec { "start_cassandra" :
		command => "${home_dir}/apache-cassandra-${cassandra_version}/bin/cassandra",
		require => Exec["unpack_cassandra"],
		user => "cassandra"
	}

	cron { "cron-cassandra" :
		command => "${home_dir}/apache-cassandra-${cassandra_version}/bin/cassandra",
		user => "cassandra",
		special => "reboot",
		ensure => present,
		require => Exec["unpack_cassandra"]
	}
}
