class drupal_php::server::apache (
    $manage_server_listen = true,
    $server_port = $drupal_php::params::server_port,
    $mpm_module = 'prefork',
    $server_default_vhost = true
  ) {


  class { '::apache':
    default_mods   => [],
    mpm_module     => $mpm_module,
    default_vhost => false,
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
  apache::mod { 'fastcgi': }
  apache::mod { 'fcgid': }
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
  }

  include php::apache
}