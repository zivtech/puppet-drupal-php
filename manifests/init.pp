# == Class: drupal_php
#
# Full description of class drupal_php here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { 'drupal_php':
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2015 Your name here, unless otherwise noted.
#
class drupal_php (
  $server                     = $drupal_php::params::server,
  $opcache                    = 'opcache',
  $upload_max_filesize        = $drupal_php::params::upload_max_filesize,
  $timezone                   = $drupal_php::params::timezone,
  $max_post_size              = $drupal_php::params::max_post_size,
  $max_execution_time         = $drupal_php::params::max_execution_time,
  $memory_limit               = $drupal_php::params::memory_limit,
  $display_errors             = $drupal_php::params::display_errors,
  $log_errors                 = $drupal_php::params::log_errors,
  $error_log_file             = $drupal_php::params::error_log_file,
  $error_log_directory        = $drupal_php::params::error_log_directory,
  $manage_log_file            = $drupal_php::params::manage_log_file,
  $server_user                = $drupal_php::params::server_user,
  $server_group               = $drupal_php::params::server_group,
  $server_manage_service      = $drupal_php::params::server_manage_service,
  $server_service_enable      = $drupal_php::params::server_service_enable,
  $server_service_ensure       = $drupal_php::params::server_service_ensure
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
    'apc': {
      include drupal_php::extension::apc
    }
    'opcache': {
      include php::extension::opcache
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

  php::config { 'php-max-post-size':
    file  => "${php::params::config_root_ini}/general_settings.ini",
    section  => 'PHP',
    setting  => 'max_post_size',
    value    => $max_post_size,
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
  
  php::config { 'php-log-file':
    file  => "${php::params::config_root_ini}/general_settings.ini",
    section  => 'PHP',
    setting  => 'log_file',
    value    => "${error_log_directory}/${error_log_file}",
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
  
  # Unfotunately, old ubuntu packages use deprecated comments.
  exec { 'clean deprecated comments in /etc/php5/conf.d':
    command => "find ${php::params::config_root_ini}/* -type f -exec sed -i 's/#/;/g' {} \\;",
    path => "/usr/bin:/usr/sbin:/bin",
    onlyif => "grep -qr '#' /etc/php5/conf.d"
  }

}
