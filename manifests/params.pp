# Ensure php::params is instantiated or we get warnings.
class drupal_php::params (
  $default_vhost_docroot_owner = 'root',
  $default_vhost_docroot_group = 'root',
  $default_vhost_content = "<html><body><h1>It works!</h1>
<p>This is the default web page for this server.</p>
<p>The web server software is running but no content has been added, yet.</p>
</body></html>",
  $server = 'apache',
  $server_port = 80
) inherits php::params {

  $memory_limit = '128M'
  $max_execution_time = 30
  $post_max_size = '8M'
  $upload_max_filesize = '200M'
  $error_log_directory = '/var/log/php'
  $error_log_file = 'error.log'
  $error_log = "${error_log_directory}/${error_log_file}"
  $manage_log_file = true
  $display_errors  = 'Off'
  $log_errors = 'On'
  $timezone = 'GMT'
  $server_manage_service = true
  $server_service_enable = true
  $server_service_ensure = 'running'

  if $::php_version == '' or versioncmp($::php_version, '5.4') >= 0 {
    $opcache = 'opcache'
  }
  else {
    $opcache = 'apc'
  }

  case $::operatingsystem {
    'RedHat', 'CentOS', 'Fedora', 'Scientific', 'Amazon', 'OracleLinux', 'SLC': {
      $system_package_manager = 'yum'
    }
    'Debian', 'Ubuntu': {
      $system_package_manager = 'apt'
    }
    default: {
      fail("\"${module_name}\" provides no package default value for \"${::operatingsystem}\"")
    }
  }

  case $server {
  	'apache': {
  		$service_name = $apache_service_name
      case $::operatingsystem {
        'RedHat', 'CentOS', 'Fedora', 'Scientific', 'Amazon', 'OracleLinux', 'SLC': {
          $apache_service_name = 'httpd'
          $server_user = 'apache'
          $default_vhost_docroot = '/var/www/html/default'
        }
        'Debian', 'Ubuntu': {
          $apache_service_name = 'apache2'
          $server_user = 'www-data'
          $default_vhost_docroot = '/var/www/default'
        }
        default: {
          fail("\"${module_name}\" provides no package default value for \"${::operatingsystem}\"")
        }
      }
  	}
  	default: {
  		fail("Server ${server} is not yet implemented.")
  	}

  }
}
