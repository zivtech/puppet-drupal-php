class drupal_php::extension::xdebug (
  $idekey = false,
  $max_nesting_level = 500,
  $remote_enable = true,
  $remote_port = 9000,
) {

  # nodes-php wants to install this from the repo but building through pecl
  # gives us a reliable installtion location (despite taking a bit longer)
  class { 'php::extension::xdebug':
    package  => 'xdebug',
    provider => 'pecl',
    settings => [
      "set .anon/zend_extension 'xdebug.so'"
    ],
  }

  if ($::php_version == '' or versioncmp($::php_version, '5.4') >= 0) {
    file { "/etc/php5/apache2/conf.d/xdebug.ini":
      target => "${php::params::config_root_ini}/xdebug.ini",
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }
    file { "/etc/php5/cli/conf.d/xdebug.ini":
      target => "${php::params::config_root_ini}/xdebug.ini",
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }
  }

  # This is necessary for composer installations.
  php::config { 'xdebug_max_nesting_level':
    file    => "${php::params::config_root_ini}/xdebug.ini",
    setting => 'xdebug.max_nesting_level',
    value   => $max_nesting_level,
  }

  if ($idekey) {
    php::config { 'xdebug_idekey':
      file    => "${php::params::config_root_ini}/xdebug.ini",
      setting => 'xdebug.max_nesting_level',
      value   => $idekey,
    }
  }

  php::config { 'xdebug_remote_enable':
    file    => "${php::params::config_root_ini}/xdebug.ini",
    setting => 'xdebug.remote_enable',
    value   => $remote_enable,
  }

  php::config { 'xdebug_remote_port':
    file    => "${php::params::config_root_ini}/xdebug.ini",
    setting => 'xdebug.remote_port',
    value   => $remote_port,
  }

}
