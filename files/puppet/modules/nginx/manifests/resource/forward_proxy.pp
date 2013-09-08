# define: nginx::resource::forward_proxy
#
# This definition create a forward proxy entry in a separate config file. This was inspired by http://ef.gy/using-nginx-as-a-proxy-server
#
# Parameters:
# [*listen*]     - Listen directive to be put directly in the conf file (must be compatible with nginx "listen" directive)
# [*conf_file*]  - Path to the configuration file (optional)
# [*access_log*] - Path to the access log for the proxy (optional)
# [*error_log*]  - Path to the error log for the proxy (optional)
# [*resolver*]   - DNS to be used from the proxy (optional)
#
# Actions:
#
# Require:
#
# Sample usage:
#
# Basic usage (only one parameter)
# nginx:resource::forward_proxy {'internal':
#    $listen => '10.10.1.1:8888'
# }
#
# Full example with custom file paths and opendns resolver
# nginx:resource::forward_proxy { 'my_proxy':
#    $listen     => '10.10.1.1:8888',
#    $conf_file  => "/etc/nginx/conf.d/${name}.conf",
#    $access_log => "/var/log/nginx/${name}.access.log",
#    $error_log  => "/var/log/nginx/${name}.error.log",
#    $resolver   => '208.67.222.222'
# }


define nginx::resource::forward_proxy (
	$listen,
	$conf_file  = "/etc/nginx/conf.d/${name}-proxy.conf",
	$access_log = "/var/log/nginx/${name}-proxy.access.log",
	$error_log  = "/var/log/nginx/${name}-proxy.error.log",
	$resolver   = '8.8.8.8',
) {
  File {
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }
  file { $conf_file:
    ensure   => 'file',
    content  => template('nginx/conf.d/forward_proxy.erb'),
    notify   => Class['nginx::service'],
  }
}

