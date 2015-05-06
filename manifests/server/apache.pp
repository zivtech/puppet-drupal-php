class drupal_php::server::apache (
    $manage_server_listen = true,
    $server_port = $drupal_php::params::server_port,
    $mpm_module = 'prefork',
    $server_default_vhost = true,
    $server_manage_service = $drupal_php::params::server_manage_service,
    $server_service_enable = $drupal_php::params::server_service_enable,
    $server_service_ensure = $drupal_php::params::server_service_ensure,
    $ssl = false,
    $ssl_port = 443,
    $purge_configs = true,
    $apache_mods = [
      'actions',
      'auth_basic',
      'authn_file',
      'authz_groupfile',
      'authz_user',
      'deflate',
      'dir',
      'env',
      'expires',
      'headers',
      'mime',
      'negotiation',
      'reqtimeout',
      'rewrite',
      'setenvif',
      'status',
      'suexec',
      'xsendfile',
    ]
  ) {

  class { '::apache':
    default_mods   => [],
    mpm_module     => $mpm_module,
    default_vhost  => false,
    service_manage => $server_manage_service,
    service_enable => $service_enable,
    service_ensure => $server_service_ensure,
    purge_configs  => $purge_configs,
  }

  if ($server_manage_service) {
    # The puppet service resource name is always httpd in puppet with puppetlabs-apache.
    Php::Extension <| |> -> Php::Config <| |> ~> Service['httpd']
  }

  # TODO: I think we might need these
  # apache::mod { 'alias': }
  # apache::mod { 'authz_default': }
  # apache::mod { 'authz_host': }
  # apache::mod { 'request_arrived': }

  ensure_resource('apache::mod', $apache_mods)

  $vhost_ensure = $server_default_vhost ? {
    true  => 'present',
    false => 'absent',
  }
  ::apache::vhost { '000-default':
    ensure          => $vhost_ensure,
    port            => $server_port,
    docroot         => $::apache::docroot,
    scriptalias     => $::apache::scriptalias,
    serveradmin     => $::apache::serveradmin,
    access_log_file => $::apache::access_log_file,
    priority        => '15',
    ip              => $::apache::ip,
    logroot_mode    => $::apache::logroot_mode,
  }

  if ($manage_server_listen) {
    # This appears by default, if the port is not 80 we should remove it.
    if ($server_port != 80) {
      concat::fragment { "Listen 80":
        ensure  => absent,
        target  => $::apache::ports_file,
        content => template('apache/listen.erb'),
      }
    }
    apache::listen { $server_port: }
    apache::namevirtualhost { "*:${server_port}": }
    if ($ssl) {
      apache::listen { $ssl_port: }
      apache::namevirtualhost { "*:${ssl_port}": }
      apache::mod { 'ssl': }
    }
  }
  else {
    apache::namevirtualhost { '*': }
  }

  include php::apache
}
