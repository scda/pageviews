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
    /*unless => "ls /tmp | grep storm.tar.gz",*/
  }
  file {
    "/tmp/storm.tar.gz":
    source => "puppet:///modules/storm/apache-storm-1.0.3.tar.gz",
    before => Exec["download_storm"]
  }
  exec { "download_storm" :
    command => "echo 0",
    path => $path,
    unless => "ls /tmp | grep storm.tar.gz",
    require => Exec["insecuressh_finish"]
  }
  ## END local test

  /*
  exec { "download_python" :
    command => "wget -O /tmp/python.tar.gz https://www.python.org/ftp/python/2.6.6/Python-2.6.6.tgz",
    path => $path,
    unless => "ls ${home_dir} | grep apache-storm-${storm_version}",
    require => Exec["insecuressh_finish"]
  }  TODO: output dir anpassen bei "unless" 
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
    require => Exec["download_storm"]
  }
  
  file {
    "/tmp/Python-${python_version}/install_python.sh":
    source => "puppet:///modules/storm/install_python.sh",
    require => Exec["unpack_python"]
  }
  
  exec { "build_python" :
    command => "/tmp/Python-${python_version}/install_python.sh",
    cwd => "/tmp/Python-${python_version}",
    path => $path,
    require => File["/tmp/Python-${python_version}/install_python.sh"]
  }
  
  
  
  exec { "unpack_storm" :
    command => "tar -zxf /tmp/storm.tar.gz -C ${home_dir}/",
    path => $path,
    require => Exec["download_storm"]
  }
}
