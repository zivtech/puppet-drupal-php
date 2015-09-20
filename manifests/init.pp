class drupal_php (
  $default_vhost_content       = $drupal_php::params::default_vhost_content,
  $default_vhost_docroot       = $drupal_php::params::default_vhost_docroot,
  $default_vhost_docroot_group = $drupal_php::params::default_vhost_docroot_group,
  $default_vhost_docroot_owner = $drupal_php::params::default_vhost_docroot_owner,
  $display_errors              = $drupal_php::params::display_errors,
  $error_log                   = $drupal_php::params::error_log,
  $error_log_directory         = $drupal_php::params::error_log_directory,
  $error_log_file              = $drupal_php::params::error_log_file,
  $log_errors                  = $drupal_php::params::log_errors,
  $manage_log_file             = $drupal_php::params::manage_log_file,
  $max_execution_time          = $drupal_php::params::max_execution_time,
  $memory_limit                = $drupal_php::params::memory_limit,
  $opcache                     = $drupal_php::params::opcache,
  $post_max_size               = $drupal_php::params::post_max_size,
  $server                      = $drupal_php::params::server,
  $server_group                = $drupal_php::params::server_group,
  $server_manage_service       = $drupal_php::params::server_manage_service,
  $server_service_enable       = $drupal_php::params::server_service_enable,
  $server_service_ensure       = $drupal_php::params::server_service_ensure,
  $server_user                 = $drupal_php::params::server_user,
  $timezone                    = $drupal_php::params::timezone,
  $upload_max_filesize         = $drupal_php::params::upload_max_filesize
) inherits drupal_php::params {


  # Use require to install apache before any module to ensure the service can be notified.
  class { "drupal_php::server::$server":
    server_manage_service => $server_manage_service,
    server_service_enable => $server_service_enable,
    server_service_ensure => $server_service_ensure,
  }

  require wget

  include php

  include php::dev

  include php::cli

  include php::composer

  include php::pear

  include php::extension::curl

  include php::extension::ldap

  # TODO: do we want memcache or memcached
  include php::extension::memcached

  include php::extension::mysql

  # php module wants to use apt as the provider but the package isn't available on ubuntu 12.04.
  class { 'php::extension::redis':
    provider => 'pecl',
    package  => 'redis',
  }->

  php::config { 'redis_conf':
    file  => "${php::params::config_root_ini}/redis.ini",
    config => [
      'set ".anon/extension" "redis.so"'
    ],
  }

  # Modifying the config file is failing.
  class { 'php::extension::uploadprogress':
    package => 'uploadprogress',
  }

  include php::extension::gd

  # Doesn't exist with this version:
  include php::extension::imagick

  case $opcache {
    'none': {
    }
    'apc': {
      include drupal_php::extension::apc
    }
    'opcache': {
      include drupal_php::extension::opcache
    }
    default: {
       warning("drupal_php does not support the sepcified opcache: `${opcache}")
    }
  }

  php::config { 'php-date-timezone':
    file  => "${php::params::config_root_ini}/general_settings.ini",
    section  => 'PHP',
    setting  => 'date.timezone',
    value    => $timezone,
  }

  php::config { 'php-memory-limit':
    file  => "${php::params::config_root_ini}/general_settings.ini",
    section  => 'PHP',
    setting  => 'memory_limit',
    value    => $memory_limit,
  }

  php::config { 'php-max-execution-time':
    file  => "${php::params::config_root_ini}/general_settings.ini",
    section  => 'PHP',
    setting  => 'max_execution_time',
    value    => $max_execution_time,
  }

  php::config { 'php-post-max-size':
    file  => "${php::params::config_root_ini}/general_settings.ini",
    section  => 'PHP',
    setting  => 'post_max_size',
    value    => $post_max_size,
  }

  php::config { 'php-upload-max-filesize':
    file  => "${php::params::config_root_ini}/general_settings.ini",
    section  => 'PHP',
    setting  => 'upload_max_filesize',
    value    => $upload_max_filesize,
  }


  php::config { 'php-log-errors':
    file  => "${php::params::config_root_ini}/general_settings.ini",
    section  => 'PHP',
    setting  => 'log_errors',
    value    => $log_errors,
  }

  php::config { 'php-display-errors':
    file  => "${php::params::config_root_ini}/general_settings.ini",
    section  => 'PHP',
    setting  => 'display_errors',
    value    => $display_errors,
  }

  php::config { 'php-error-log':
    file  => "${php::params::config_root_ini}/general_settings.ini",
    section  => 'PHP',
    setting  => 'error_log',
    value    => $error_log,
  }

  if ($manage_log_file) {
    file { 'php-error-log-directory':
      path   => $error_log_directory,
      ensure => 'directory',
      owner  => $server_user,
      group  => $server_group,
    }
    file { 'php-error-log-file':
      path   => "${error_log_directory}/${error_log_file}",
      ensure => 'file',
      owner  => $server_user,
      group  => $server_group,
    }
  }


  if $::php_version == '' or versioncmp($::php_version, '5.4') >= 0 {
    file { '/etc/php5/apache2/conf.d/20-general_settings.ini':
      target  => "${php::params::config_root_ini}/general_settings.ini",
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      notify  => Service['httpd'],
      require => Php::Config['php-upload-max-filesize'],

    }

    file { '/etc/php5/cli/conf.d/20-general_settings.ini':
      target  => "${php::params::config_root_ini}/general_settings.ini",
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      notify  => Service['httpd'],
      require => Php::Config['php-upload-max-filesize'],
    }
  }

  # Unfotunately, old ubuntu packages use deprecated comments.
  exec { 'clean deprecated comments in /etc/php5/conf.d':
    command => "find ${php::params::config_root_ini}/* -type f -exec sed -i 's/#/;/g' {} \\;",
    path => "/usr/bin:/usr/sbin:/bin",
    onlyif => "grep -qr '#' /etc/php5/conf.d"
  }

}
