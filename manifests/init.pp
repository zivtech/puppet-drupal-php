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
  $server = $drupal_php::params::server,
  $opcache = 'opcache',
  # $upload_max_filesize = '200M',
  # $max_post_size = '8M',
  $apacheport = '80',
  $cached_shared_memory = $drupal_php_params::params::shared_memory,
  $max_execution_time = $drupal_php::params::max_execution_time,
  $memory_limit = $drupal_php::params::memory_limit
) inherits drupal_php::params {

  # The puppet service resource name is always httpd in puppet with puppetlabs-apache.
  Php::Extension <| |> -> Php::Config <| |> ~> Service['httpd']

  # Use require to install apache before any module to ensure the service can be notified.
  require "drupal_php::server::$server"

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
      include php::extension::apc

      php::config { 'apc_shared_memory':
        file  => "${php::params::config_root_ini}/apc.ini",
        config => [
          "set .anon/apc.shm_size ${cached_shared_memory}",
        ],
      }
      php::config { 'apc_settings':
        file  => "${php::params::config_root_ini}/apc.ini",
        config => [
          'set .anon/apc.enabled 1',
          'set .anon/apc.shm_segments 1',
          'set .anon/apc.optimization 0',
          'set .anon/apc.num_files_hint 512',
          'set .anon/apc.user_entries_hint 1024',
          'set .anon/apc.ttl 0',
          'set .anon/apc.user_ttl 0',
          'set .anon/apc.gc_ttl 600',
          'set .anon/apc.cache_by_default 1',
          'set .anon/apc.filters "apc\.php$"',
          'set .anon/apc.slam_defense 0',
          'set .anon/apc.use_request_time 1',
          'set .anon/apc.mmap_file_mask /dev/zero',
          'set .anon/apc.file_update_protection 2',
          'set .anon/apc.enable_cli 0',
          'set .anon/apc.max_file_size 2M',
          'set .anon/apc.stat 1',
          'set .anon/apc.write_lock 1',
          'set .anon/apc.report_autofilter 0',
          'set .anon/apc.include_once_override 0',
          'set .anon/apc.rfc1867 0',
          'set .anon/apc.rfc1867_prefix "upload_"',
          'set .anon/apc.rfc1867_name "APC_UPLOAD_PROGRESS"',
          'set .anon/apc.rfc1867_freq 0',
          'set .anon/apc.localcache 1',
          'set .anon/apc.localcache.size 512',
          'set .anon/apc.coredump_unmap 0',
          'set .anon/apc.stat_ctime 0',
        ],
      }

    }
    'opcache': {
      include php::extension::opcache
    }
  }

  php::config { 'memory_limit':
    file  => "${php::params::config_root_ini}/general_settings.ini",
    section  => 'PHP',
    setting  => 'memory_limit',
    value    => $memory_limit,
  }

  php::config { 'max_execution_time':
    file  => "${php::params::config_root_ini}/general_settings.ini",
    section  => 'PHP',
    setting  => 'max_execution_time',
    value    => $max_execution_time,
  }

}
