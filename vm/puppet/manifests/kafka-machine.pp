include insecuressh
include kafka

exec { "apt-get update" :
  command => "/usr/bin/apt-get update";
}

package { "openjdk-7-jre-headless" :
  ensure => present,
  require => Exec["apt-get update"]
}

/*
package { "scala" :
  ensure => present,
  require => Exec["apt-get update"]
}
*/
