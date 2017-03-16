class drupal_php (
  $default_vhost_content       = $drupal_php::params::default_vhost_content,
  $default_vhost_docroot       = $drupal_php::params::default_vhost_docroot,
  $default_vhost_docroot_group = $drupal_php::params::default_vhost_docroot_group,
  $default_vhost_docroot_owner = $drupal_php::params::default_vhost_docroot_owner,
  $display_errors              = $drupal_php::params::display_errors,
  $error_log                   = $drupal_php::params::error_log,
  $error_log_directory         = $drupal_php::params::error_log_directory,
  $error_log_file              = $drupal_php::params::error_log_file,
  $expose_php                  = $drupal_php::params::expose_php,
  $log_errors                  = $drupal_php::params::log_errors,
  $manage_log_file             = $drupal_php::params::manage_log_file,
  $manage_repos                = $drupal_php::params::manage_repos,
  $max_execution_time_cli      = $drupal_php::params::max_execution_time_cli,
  $max_execution_time_server   = $drupal_php::params::max_execution_time_server,
  $memory_limit_server         = $drupal_php::params::memory_limit_server,
  $memory_limit_cli            = $drupal_php::params::memory_limit_cli,
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

  class { '::php':
    manage_repos => $manage_repos,
    extensions => {
      bcmath => {},
      bz2 => {},
      dba => {},
      gd => {},
      imagick => {},
      ldap => {},
      mbstring => {},
      mcrypt => {},
      memcached => {},
      mysql => {},
      opcache => {},
      curl  => {},
      uploadprogress => {
        package_prefix => 'php-'
      },
      redis => {
        package_prefix => 'php-'
      },
      soap => {},
      zip => {}
    },
    settings => {
      'PHP/date.timezone' => $timezone,
      'PHP/post_max_size' => $post_max_size,
      'PHP/upload_max_filesize' => $upload_max_filesize,
      'PHP/log_errors' => $log_errors,
      'PHP/display_errors' => $display_errors,
      'PHP/error_log' => $error_log,
    }
  }

  # Add separate settings for cli and fpm.
  ::php::config::setting { 'cli-PHP/memory_limit':
    file  => $::php::cli::inifile,
    key   => 'PHP/memory_limit',
    value => $memory_limit_cli,
  }
  ::php::config::setting { 'cli-PHP/max_execution_time':
    file  => $::php::cli::inifile,
    key   => 'PHP/max_execution_time',
    value => $max_execution_time_cli,
  }
  ::php::config::setting { 'fpm-PHP/memory_limit':
    file  => $::php::fpm::inifile,
    key   => 'PHP/memory_limit',
    value => $memory_limit_server,
  }
  ::php::config::setting { 'fpm-PHP/max_execution_time':
    file  => $::php::fpm::inifile,
    key   => 'PHP/max_execution_time',
    value => $max_execution_time_server,
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

  # TODO: Fix this one
  /*
  php::apache::config { 'php-expose-php':
    section  => 'PHP',
    setting  => 'expose_php',
    value    => $expose_php,
  }
  */



}
