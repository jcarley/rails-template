class roles::database(
  $db_name = "",
  $owner = "",
  $password = "",
){

  anchor { 'roles::database::begin': } ->

  package { ['libpq-dev']:
    ensure => present,
  } ->

  class { 'postgresql':  } ->

  class {'postgresql::server':
    listen => ['*', ],
    acl    => ['host all all 0.0.0.0/0 md5', 'local all all trust'],
  } ->

  pg_user { $owner:
    ensure     => present,
    password   => $password,
    createdb   => true,
    createrole => true,
    superuser  => true,
  } ->

  pg_user {'jcarley':
    ensure     => present,
    password   => $password,
    createdb   => true,
    createrole => true,
    superuser  => true,
  } ->

  pg_database { $db_name:
    ensure   => present,
    owner    => $owner,
    encoding => 'UTF8',
  }

  anchor { 'roles::database::end': }
}
