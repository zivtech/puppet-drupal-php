class drupal_php::server::apache (
    $manage_server_listen = true,
    $server_port = $drupal_php::params::server_port,
    $mpm_module = 'prefork',
    $server_default_vhost = true,
    $server_manage_service = $drupal_php::params::server_manage_service,
    $server_service_enable = $drupal_php::params::server_service_enable,
    $server_service_ensure = $drupal_php::params::server_service_ensure,
    $ssl = false,
    $ssl_port = 443
  ) {

  class { '::apache':
    default_mods   => [],
    mpm_module     => $mpm_module,
    default_vhost  => false,
    service_manage => $server_manage_service,
    service_enable => $service_enable,
    service_ensure => $server_service_ensure,
  }

  if ($server_manage_service) {
    # The puppet service resource name is always httpd in puppet with puppetlabs-apache.
    Php::Extension <| |> -> Php::Config <| |> ~> Service['httpd']
  }

  apache::mod{ 'actions': }
  # apache::mod { 'alias': }
  apache::mod { 'auth_basic': }
  apache::mod { 'authn_file': }
  apache::mod { 'authz_default': }
  apache::mod { 'authz_groupfile': }
  # apache::mod { 'authz_host': }
  apache::mod { 'authz_user': }
  apache::mod { 'deflate': }
  apache::mod { 'dir': }
  apache::mod { 'env': }
  apache::mod { 'expires': }
  apache::mod { 'headers': }
  apache::mod { 'mime': }
  apache::mod { 'negotiation': }
  apache::mod { 'reqtimeout': }
  # apache::mod { 'request_arrived': }
  apache::mod { 'rewrite': }
  apache::mod { 'setenvif': }
  apache::mod { 'ssl': }
  apache::mod { 'status': }
  apache::mod { 'suexec': }
  apache::mod { 'xsendfile': }

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
    }
  }
  else {
    apache::namevirtualhost { '*': }
  }

  include php::apache
}
