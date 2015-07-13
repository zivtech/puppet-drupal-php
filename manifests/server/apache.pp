class drupal_php::server::apache (
    $manage_server_listen = true,
    $server_port = $drupal_php::params::server_port,
    $mpm_module = 'prefork',
    $server_default_vhost = true,
    $default_vhost_docroot = $::apache::docroot,
    $server_manage_service = $drupal_php::params::server_manage_service,
    $server_service_enable = $drupal_php::params::server_service_enable,
    $server_service_ensure = $drupal_php::params::server_service_ensure,
    $default_vhost_docroot = $drupal_php::params::default_vhost_docroot,
    $default_vhost_docroot_owner = $drupal_php::params::default_vhost_docroot_owner,
    $default_vhost_docroot_group = $drupal_php::params::default_vhost_docroot_group,
    $default_vhost_content = $drupal_php::params::default_vhost_content,
    $ssl = false,
    $ssl_port = 443,
    $purge_configs = true,
    $apache_mods = [
      'actions',
      'auth_basic',
      'authn_file',
      'authz_groupfile',
      'authz_user',
      'autoindex',
      'deflate',
      'dir',
      'env',
      'expires',
      'headers',
      'mime',
      'mime_magic',
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
    default_mods   => $apache_mods,
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

  $vhost_ensure = $server_default_vhost ? {
    true  => 'present',
    false => 'absent',
  }
  ::apache::vhost { '000-default':
    ensure          => $vhost_ensure,
    port            => $server_port,
    docroot         => $default_vhost_docroot,
    docroot_owner   => $default_vhost_docroot_owner,
    docroot_group   => $default_vhost_docroot_group,
    scriptalias     => $::apache::scriptalias,
    serveradmin     => $::apache::serveradmin,
    access_log_file => $::apache::access_log_file,
    priority        => '15',
    ip              => $::apache::ip,
    logroot_mode    => $::apache::logroot_mode,
  }
  if ($vhost_ensure) {
    file { $default_vhost_docroot:
      ensure  => directory,
      path    => $default_vhost_docroot,
      owner   => $default_vhost_docroot_owner,
      group   => $default_vhost_docroot_group,
    }->
    file { "${default_vhost_docroot}/index.html":
      ensure  => file,
      content => $default_vhost_content,
      path    => "${default_vhost_docroot}/index.html",
      owner   => $default_vhost_docroot_owner,
      group   => $default_vhost_docroot_group,
    }
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
      include apache::mod::ssl
    }
  }
  else {
    apache::namevirtualhost { '*': }
  }

  include apache::mod::php
}
