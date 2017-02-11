include hadoop

exec { "apt-get update" :
  command => "/usr/bin/apt-get update";
}

package { "openjdk-7-jre-headless" :
  ensure => present,
  require => Exec["apt-get update"]
}

## open machine to *any* SSH access (for hadoop localhost loop access etc.) ##
exec { "keygen" :
  command => "ssh-keygen -t rsa -P '' -f /root/.ssh/id_rsa",
  path => $path,
  unless => "ls /root/.ssh | grep id_rsa"
}

exec { "keycopy" :
  command => "cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys",
  path => $path,
  require => Exec["keygen"]
}

file {
  "/root/.ssh/authorized_keys" :
  mode => 600,
  require => Exec["keycopy"]
}
