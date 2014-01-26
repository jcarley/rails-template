class roles::infrastructure(
  $allow_ports = []
){
  # include ufw

  # notice($allow_ports)

  # $allow_ports.foreach { |$port|
    # ufw::allow { "allow-$port-from-all":
      # port => $port
    # }
  # }

  # ufw::allow { "allow-ssh-from-all":
    # port    => 22,
  # }

  # ufw::allow { "allow-http-from-all":
    # port => 80,
  # }

  # ufw::allow { "allow-8080-from-all":
    # port => 8080,
  # }

  # ufw::allow { "allow-3000-from-all":
    # port => 3000,
  # }

  package { "ufw":
    ensure => present,
  } ->

  service { "ufw":
    ensure  => stopped,
    enable  => false,
  }

}
