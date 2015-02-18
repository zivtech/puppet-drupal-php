class drupal_php::server::apache {
  # class { 'apache':
  #   default_mods   => false,
  #   mpm_module     => 'prefork',
  #   service_enable => false,
  #   # Do not purge configs because it will remove any vhosts we put in palce.
  #   purge_configs => false,
  # }
  # include ::apache

  # Alias to prevent a conflict with this module.
  # class { 'apache':
  #   alias          => 'apache2',
  #   default_mods  => false,
  #   mpm_module    => false,
  #   purge_configs => false,
  # }
  class { '::apache':
    default_mods => [],
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

  apache::listen { '8080': }

  include php::apache
}
