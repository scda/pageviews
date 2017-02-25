include insecuressh
include hadoop
include flume

exec { "apt-get update" :
  command => "/usr/bin/apt-get update";
}
