class insecuressh {

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

	file {
		"/root/.ssh/authorized_keys" :
		mode => 600,
		require => Exec["keycopy"],
		before => Exec["disablestricthost"]
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
	
	exec {"insecuressh_finish" :
		command => "echo 0",
		path => $path,
		require => Exec["removeknownhosts"]
	}

}
