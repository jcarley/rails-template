class roles::www::webapp(
  $run_as_user,
  $ruby_home_path = "/home/${run_as_user}/.rbenv/shims",
  $application_name,
  $virtual_host,
  $base_app_home,
  $server_name = ['localhost'],
  $rails_env = 'development',
  $vhost_template = 'nginx/vhost.erb'
) {

  $upstream_port = 9292
  $application_home = "$base_app_home/$application_name"

  puma::app { "install_app $application_home":
    run_as_user    => $run_as_user,
    app_path       => $application_home,
    port           => $upstream_port,
    ruby_home_path => $ruby_home_path,
  }

  nginx::resource::upstream { "${application_name}_rack_app":
    ensure  => present,
    members => [
      "127.0.0.1:${upstream_port}",
    ],
  }

  nginx::resource::vhost { $virtual_host:
    ensure      => present,
    www_root    => $base_app_home,
    server_name => $server_name,
    try_files   => ['$uri/index.html', '$uri', "@${application_name}_endpoint"],
    index_files => undef,
  }

  $rack_app_config = {
    ''                 => 'proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; proxy_set_header X-Forwarded-Proto $http_x_forwarded_proto; proxy_set_header Host $http_host',
    'proxy_redirect'   => 'off',
  }

  nginx::resource::location { "${application_name}_upstream":
    ensure               => present,
    location             => "@${application_name}_endpoint",
    proxy                => "http://${application_name}_rack_app",
    location_cfg_prepend => $rack_app_config,
    vhost                => $virtual_host,
  }

  # The following lines are saying the same thing
  # <% unless ['development', 'test'].include?(rails_env) %>
  # unless member(['development', 'test'], $rails_env) {

    # $assets_config = {
      # 'gzip_static' => 'on',
    # }

    # nginx::resource::location { 'assets':
      # ensure               => present,
      # location             => '^~ /assets/',
      # www_root             => "${submission_app_home}/public",
      # location_cfg_prepend => $assets_config,
      # vhost                => 'www.espdev.com',
    # }

    # nginx::resource::location { 'javascripts':
      # ensure               => present,
      # location             => '^~ /javascripts/',
      # www_root             => "${submission_app_home}/public",
      # index_files          => undef,
      # location_cfg_prepend => $assets_config,
      # vhost                => 'www.espdev.com',
    # }

    # nginx::resource::location { 'stylesheets':
      # ensure               => present,
      # location             => '^~ /stylesheets/',
      # www_root             => "${submission_app_home}/public",
      # location_cfg_prepend => $assets_config,
      # vhost                => 'www.espdev.com',
    # }
  # }

}
