node default {
  include apt
  include stdlib
  include roles::infrastructure

  $run_as_user    = "vagrant"
  $ruby_version   = "2.0.0-p353"
  $home_dir       = "/home/${run_as_user}"
  $ruby_home_path = "/home/${run_as_user}/.rbenv/shims"
  $base_app_home  = "/home/${run_as_user}/apps"

  $application_name  = 'carleyfamily'
  $virtual_host      = "${application_name}"

  $database_name     = "${application_name}_development"
  $database_username = "${application_name}"
  $database_password = 'letmein123'
  $database_config   = 'https://gist.github.com/jcarley/6703972/raw/a272325f88bf91696d649289b5db1438e86b8286/database.yml'

  $rails_env = "development"

  file { "${home_dir}/.bash_aliases":
    ensure => present,
  } ->

  line { 'create aliases':
    file    => "${home_dir}/.bash_aliases",
    line    => 'alias be="bundle exec"',
    ensure  => present,
  }

  package { ['git', 'curl', 'vim', 'nfs-common']:
    ensure => installed,
  }

  wget::fetch { 'copy databse yaml':
    source      => $database_config,
    destination => "${base_app_home}/${application_name}/config/database.yml",
  }

  class { 'roles::setup': } ->

  class { 'java': } ->

  class { 'roles::database':
    db_name  => $database_name,
    owner    => $database_username,
    password => $database_password,
  } ->

  class { 'roles::www::webserver':
    run_as_user  => $run_as_user,
    ruby_version => $ruby_version,
    rails_env    => $rails_env,
  } ->

  class { 'roles::www::webapp':
    run_as_user      => $run_as_user,
    ruby_home_path   => $ruby_home_path,
    application_name => $application_name,
    virtual_host     => $virtual_host,
    base_app_home    => $base_app_home,
  } ->

 roles::ruby::rake { "application setup":
  run_as_user    => $run_as_user,
  ruby_home_path => $ruby_home_path,
  app_home       => "${base_app_home}/${application_name}",
 }

}
