class roles::database(
  $db_name = "",
  $owner = "",
  $password = "",
){

  # package { ['mysql-server', 'libmysqlclient-dev']:
    # ensure => absent,
  # } ->

  # service { 'mysql':
    # enable => true,
    # ensure => running,
  # }

  anchor { 'roles::database::begin': } ->

  package { ['libpq-dev']:
    ensure => present,
  } ->

  class { 'postgresql':  } ->

  class {'postgresql::server': } ->

  postgresql::db { $db_name:
      owner    => $owner,
      password => $password,
  } ->

  anchor { 'roles::database::end': }
}
