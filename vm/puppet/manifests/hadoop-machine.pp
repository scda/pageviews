include hadoop

exec { "apt-get update" :
  command => "/usr/bin/apt-get update";
}

package { "openjdk-7-jre-headless" :
  ensure => present,
  require => Exec["apt-get update"]
}

## setup passwordless ssh access 
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
exec { "disablestricthost" :
  command => "sed -ie 's/#   StrictHostKeyChecking ask/    StrictHostKeyChecking no/g' /etc/ssh/ssh_config",
  path => $path,
  require => Exec["keycopy"]
}
exec { "removeknownhosts" :
  command => "echo UserKnownHostsFile /dev/null >> /etc/ssh/ssh_config",
  path => $path,
  require => Exec["disablestricthost"]
}
file {
  "/root/.ssh/authorized_keys" :
  mode => 600,
  require => Exec["removeknownhosts"]
}
