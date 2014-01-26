define roles::ruby::rake(
  $run_as_user,
  $ruby_home_path = "/home/${run_as_user}/.rbenv/shims",
  $app_home
) {

  exec { "bootstrap ${app_home}":
    command => "${ruby_home_path}/rake bootstrap:install",
    onlyif  => "${ruby_home_path}/rake -T | /bin/grep 'bootstrap:install'",
    cwd     => $app_home,
    path    => [$path, "${path}:/bin:/usr/bin", "${ruby_home_path}/bin"],
    timeout => 0,
  }

}
