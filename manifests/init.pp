class drupal_php (
  $composer                    = $drupal_php::params::composer,
  $default_vhost_content       = $drupal_php::params::default_vhost_content,
  $default_vhost_docroot       = $drupal_php::params::default_vhost_docroot,
  $default_vhost_docroot_group = $drupal_php::params::default_vhost_docroot_group,
  $default_vhost_docroot_owner = $drupal_php::params::default_vhost_docroot_owner,
  $dev                         = $drupal_php::params::dev,
  $display_errors              = $drupal_php::params::display_errors,
  $display_startup_errors      = $drupal_php::params::display_startup_errors,
  $error_log                   = $drupal_php::params::error_log,
  $error_log_directory         = $drupal_php::params::error_log_directory,
  $error_log_file              = $drupal_php::params::error_log_file,
  $error_reporting             = $drupal_php::params::error_reporting,
  $expose_php                  = $drupal_php::params::expose_php,
  $fpm                         = $drupal_php::params::fpm,
  $log_errors                  = $drupal_php::params::log_errors,
  $manage_fpm_pool             = $drupal_php::params::manage_fpm_pool,
  $manage_log_file             = $drupal_php::params::manage_log_file,
  $manage_repos                = $drupal_php::params::manage_repos,
  $max_execution_time_cli      = $drupal_php::params::max_execution_time_cli,
  $max_execution_time_server   = $drupal_php::params::max_execution_time_server,
  $memory_limit_server         = $drupal_php::params::memory_limit_server,
  $memory_limit_cli            = $drupal_php::params::memory_limit_cli,
  $opcache                     = $drupal_php::params::opcache,
  $pear                        = $drupal_php::params::pear,
  $phpunit                     = $drupal_php::params::phpunit,
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

  # @todo: Add uploadprogress once we figure out how to get it working.
  class { '::php':
    manage_repos => $manage_repos,
    extensions => {
      bcmath => {},
      bz2 => {},
      dba => {},
      gd => {},
      imagick => {
        package_prefix => 'php-'
      },
      ldap => {},
      mbstring => {},
      memcached => {
        package_prefix => 'php-'
      },
      mysql => {
        so_name => 'pdo_mysql',
      },
      opcache => {
        zend => true,
      },
      curl  => {},
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
      'PHP/display_startup_errors' => $display_startup_errors,
      'PHP/error_log' => $error_log,
      'PHP/error_reporting' => $error_reporting,
      'PHP/memory_limit' => $memory_limit_server,
      'PHP/max_execution_time' => $max_execution_time_server,
    },
    cli_settings => {
      'PHP/memory_limit' => $memory_limit_cli,
      'PHP/max_execution_time' => $max_execution_time_cli,
    }
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

  if ($manage_fpm_pool) {
    include drupal_php::fpm
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
