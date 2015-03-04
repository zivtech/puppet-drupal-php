class drupal_php::params (
  $server = 'apache',
  $server_port = 80
) {

  $memory_limit = '128M'
  $max_execution_time = 30
  $max_post_size = '8M'
  $upload_max_filesize = '200M'
  $error_log_file = 'error.log'
  $error_log_directory = '/var/log/php'
  $manage_log_file = true
  $display_errors  = 'Off'
  $log_errors = 'On'
  $timezone = 'GMT'
  $server_manage_service = true
  $server_service_enable = true
  $server_service_ensure = 'running'


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
        }
        'Debian', 'Ubuntu': {
          $apache_service_name = 'apache2'
          $server_user = 'www-data'
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
