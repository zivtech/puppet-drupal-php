class drupal_php::server::apache (
    $manage_server_listen = true,
    $server_port = $drupal_php::params::server_port,
    $mpm_module = 'prefork',
    $server_default_vhost = true,
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
  ) {

  class { '::apache':
    default_mods   => false,
    mpm_module     => $mpm_module,
    default_vhost  => false,
    service_manage => $server_manage_service,
    service_enable => $server_service_enable,
    service_ensure => $server_service_ensure,
    purge_configs  => $purge_configs,
  }

  # TODO Audit this list. Drupal actually doesn't need most of these.
  class { '::apache::mod::auth_basic': }
  class { '::apache::mod::authn_file': }
  class { '::apache::mod::authz_user': }
  class { '::apache::mod::deflate': }
  class { '::apache::mod::dir': }
  class { '::apache::mod::headers': }
  class { '::apache::mod::mime': }
  class { '::apache::mod::mime_magic': }
  class { '::apache::mod::negotiation': }
  class { '::apache::mod::reqtimeout': }
  class { '::apache::mod::rewrite': }
  class { '::apache::mod::setenvif': }
  class { '::apache::mod::suexec': }
  class { '::apache::mod::xsendfile': }

  # Add other apache mods we want (not defined in puppet apache module).
  apache::mod { 'authz_groupfile': }
  apache::mod { 'env': }
  apache::mod { 'expires': }

  if ($server_manage_service) {
    # The puppet service resource name is always httpd in puppet with puppetlabs-apache.
    Php::Extension <| |> ~> Service['httpd']
    Php::Config <| |> ~> Service['httpd']
  }

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
    priority        => false,
    ip              => $::apache::ip,
    logroot_mode    => $::apache::logroot_mode,
    directories     => [
      {
        path    => $default_vhost_docroot,
        options => ['-Indexes','+FollowSymLinks']
      }
    ],
  }
  if ($server_default_vhost) {
    file { $default_vhost_docroot:
      ensure  => directory,
      path    => $default_vhost_docroot,
      owner   => $default_vhost_docroot_owner,
      group   => $default_vhost_docroot_group,
    }->
    file { "${default_vhost_docroot}/index.html":
      ensure  => 'file',
      content => $default_vhost_content,
      path    => "${default_vhost_docroot}/index.html",
      owner   => $default_vhost_docroot_owner,
      group   => $default_vhost_docroot_group,
    }
  }

  # The apache module does not allow us to overwrite the
  # mpm_event.conf file.  It only allows writing the event.conf
  # file but mpm_event.conf is the one used by apache.
  if ($mpm_module == 'event') {
    $event_conf_file = "${::apache::mod_dir}/mpm_event.conf"
    $event_config = {
      'mpm_event_maxclients' => {
        'value'  => $apache::mod::event::maxclients,
        'option' => "MaxClients",
        'path'   => $event_conf_file,
      },
      'mpm_event_maxrequestworkers' => {
        'value'  => $apache::mod::event::maxrequestworkers,
        'option' => "MaxRequestWorkers",
        'path'   => $event_conf_file,
      },
      'mpm_event_maxrequestsperchild' => {
        'value'  => $apache::mod::event::maxrequestsperchild,
        'option' => "MaxConnectionsPerChild",
        'path'   => $event_conf_file,
      },
      'mpm_event_maxconnectionsperchild' => {
        'value'  => $apache::mod::event::maxconnectionsperchild,
        'option' => "MaxConnectionsPerChild",
        'path'   => $event_conf_file,
      },
      'mpm_event_minsparethreads' => {
        'value'  => $apache::mod::event::minsparethreads,
        'option' => "MinSpareThreads",
        'path'   => $event_conf_file,
      },
      'mpm_event_maxsparethreads' => {
        'value'  => $apache::mod::event::maxsparethreads,
        'option' => "MaxSpareThreads",
        'path'   => $event_conf_file,
      },
      'mpm_event_threadlimit' => {
        'value'  => $apache::mod::event::threadlimit,
        'option' => "ThreadLimit",
        'path'   => $event_conf_file,
      },
      'mpm_event_threadsperchild' => {
        'value'  => $apache::mod::event::threadsperchild,
        'option' => "ThreadsPerChild",
        'path'   => $event_conf_file,
      },
      'mpm_event_startservers' => {
        'value'  => $apache::mod::event::startservers,
        'option' => "StartServers",
        'path'   => $event_conf_file,
      },
      'mpm_event_serverlimit' => {
        'value'  => $apache::mod::event::serverlimit,
        'option' => "ServerLimit",
        'path'   => $event_conf_file,
      },
      'mpm_event_listenbacklog' => {
        'value'  => $apache::mod::event::listenbacklog,
        'option' => "ListenBacklog",
        'path'   => $event_conf_file,
      },
    }
    create_resources('drupal_php::config_file_line', $event_config)
  }

  if ($manage_server_listen) {
    apache::listen { "${server_port}": }
    apache::namevirtualhost { "*:${server_port}": }
    if ($ssl) {
      apache::listen { "$ssl_port": }
      apache::namevirtualhost { "*:${ssl_port}": }
      include apache::mod::ssl
    }
  }
  else {
    apache::namevirtualhost { '*': }
  }

  include apache::mod::proxy
  include apache::mod::proxy_fcgi
}
