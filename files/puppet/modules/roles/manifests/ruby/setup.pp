class roles::ruby::setup(
  $run_as_user,
  $update = false,
) {

  $user_home = "/home/${run_as_user}"

  file { "${user_home}/.bashenv":
    ensure => 'present',
    owner  => $run_as_user,
    group  => $run_as_user,
  } ->

  exec { 'source bashenv':
    command => "sed -i '4i source ${user_home}/.bashenv' .bashrc",
    cwd     => $user_home,
    unless  => "grep 'source ${user_home}/.bashenv' .bashrc 2>/dev/null",
  } ->

  rbenv::install { $run_as_user:
    group   => $run_as_user,
    home    => $user_home,
    rc      => ".bashenv",
  } ->

  file { "${user_home}/.gemrc":
    content => "
:verbose: true
:update_sources: true
:backtrace: false
:bulk_threshold: 1000
:benchmark: false
gem: --no-ri --no-rdoc",
    owner => $run_as_user,
    group => $run_as_user,
  } ->

  rbenv::plugin { "rbenv-gem-rehash":
    user   => $run_as_user,
    source => "git://github.com/sstephenson/rbenv-gem-rehash.git"
  } ->

  rbenv::plugin { "rbenv-bootstrap":
    user   => $run_as_user,
    source => "git://github.com/fesplugas/rbenv-bootstrap.git"
  } ->

  rbenv::plugin { "rbenv-update":
    user   => $run_as_user,
    source => "git://github.com/rkh/rbenv-update.git"
  } ->

  rbenv::plugin { "rbenv-whatis":
    user   => $run_as_user,
    source => "git://github.com/rkh/rbenv-whatis.git"
  } ->

  rbenv::plugin { "rbenv-vars":
    user   => $run_as_user,
    source => "git://github.com/sstephenson/rbenv-vars.git"
  } ->

  rbenv::plugin { "rbenv-default-gems":
    user   => $run_as_user,
    source => "git://github.com/sstephenson/rbenv-default-gems.git"
  } ->

  rbenv::plugin { "rbenv-binstubs":
    user   => $run_as_user,
    source => "git://github.com/ianheggie/rbenv-binstubs.git"
  }

}
