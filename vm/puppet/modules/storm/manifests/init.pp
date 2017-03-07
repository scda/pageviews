class storm {
  $home_dir = "/opt"
  $storm_version= "1.0.3"
  $python_version="2.6.6"
  
  exec { "apt-get update" :
    command => "/usr/bin/apt-get update",
    require => Exec["insecuressh_finish"]
  }
  
  package { "openjdk-7-jdk" :
	  ensure => present,
	  require => Exec["apt-get update"]
	}  
  
  package { "build-essential" :
    ensure => present,
    require => Exec["apt-get update"]
  }
  
  ## BEGIN local test
  file {
    "/tmp/python.tar.gz":
    source => "puppet:///modules/storm/Python-${python_version}.tgz",
    before => Exec["download_python"]
  }
  exec { "download_python" :
    command => "echo 0",
    path => $path,
    unless => "ls /usr/local/bin | grep python"
  }
  file {
    "/tmp/storm.tar.gz":
    source => "puppet:///modules/storm/apache-storm-1.0.3.tar.gz",
    before => Exec["download_storm"]
  }
  exec { "download_storm" :
    command => "echo 0",
    path => $path,
    unless => "ls ${home_dir} | grep apache-storm-${storm_version}",
    require => Exec["insecuressh_finish"]
  }
  ## END local test

  /*
  exec { "download_python" :
    command => "wget -O /tmp/python.tar.gz https://www.python.org/ftp/python/2.6.6/Python-2.6.6.tgz",
    path => $path,
    unless => "ls /usr/local/bin | grep python2.6",
    require => Exec["insecuressh_finish"]
  }
  exec { "download_storm" :
	  command => "wget -O /tmp/storm.tar.gz http://ftp.halifax.rwth-aachen.de/apache/storm/apache-storm-1.0.3/apache-storm-1.0.3.tar.gz",
    path => $path,
    unless => "ls ${home_dir} | grep apache-storm-${storm_version}",
    require => Exec["insecuressh_finish"]
  }
  */
  
  exec { "unpack_python" :
    command => "tar -zxf /tmp/python.tar.gz -C /tmp/",
    path => $path,
    require => Exec["download_python"]
  }
  
  file {
    "/tmp/Python-${python_version}/install_python.sh":
    source => "puppet:///modules/storm/install_python.sh",
    owner => root,
    group => root,
    mode => 744,
    require => Exec["unpack_python"]
  }
  
  exec { "build_python" :
    command => "/tmp/Python-${python_version}/install_python.sh",
    cwd => "/tmp/Python-${python_version}",
    path => $path,
    require => File["/tmp/Python-${python_version}/install_python.sh"],
    unless => "ls /usr/local/bin | grep python2.6"
  }
  
  exec { "unpack_storm" :
    command => "tar -zxf /tmp/storm.tar.gz -C ${home_dir}/",
    path => $path,
    require => Exec["download_storm"]
  }
  
  file {
    "${home_dir}/apache-storm-${storm_version}/conf/storm.yaml":
    source => "puppet:///modules/storm/storm.yaml",
    owner => root,
    group => root,
    mode => 644,
    require => Exec["unpack_storm"]
  }
  /*
  file {
    "${home_dir}/apache-storm-${storm_version}/conf/storm-env.sh":
    source => "puppet:///modules/storm/storm-env.sh",
    owner => root,
    group => root,
    mode => 755,
    require => Exec["unpack_storm"]
  }
  */
  
  file {
    "/etc/init/storm-nimbus.conf":
    source => "puppet:///modules/storm/storm-nimbus.conf",
    owner => root,
    group => root,
    mode => 755,
    require => Exec["unpack_storm"]
  }
  file {
    "/etc/init/storm-supervisor.conf":
    source => "puppet:///modules/storm/storm-supervisor.conf",
    owner => root,
    group => root,
    mode => 755,
    require => Exec["unpack_storm"]
  }
  file {
    "/etc/init/storm-ui.conf":
    source => "puppet:///modules/storm/storm-ui.conf",
    owner => root,
    group => root,
    mode => 755,
    require => Exec["unpack_storm"]
  }
  
  exec { "start-storm-nimbus" :
    command => "start storm-nimbus",
    path => $path,
    require => [ File["/etc/init/storm-nimbus.conf"], File["${home_dir}/apache-storm-${storm_version}/conf/storm-env.sh"], File["${home_dir}/apache-storm-${storm_version}/conf/storm.yaml"] ]
  }
  exec { "start-storm-supervisor" :
    command => "start storm-supervisor",
    path => $path,
    require => [ File["/etc/init/storm-supervisor.conf"], File["${home_dir}/apache-storm-${storm_version}/conf/storm-env.sh"], File["${home_dir}/apache-storm-${storm_version}/conf/storm.yaml"] ]
  }
  exec { "start-storm-ui" :
    command => "start storm-ui",
    path => $path,
    require => [ File["/etc/init/storm-ui.conf"], File["${home_dir}/apache-storm-${storm_version}/conf/storm-env.sh"], File["${home_dir}/apache-storm-${storm_version}/conf/storm.yaml"] ]
  }
  
}
