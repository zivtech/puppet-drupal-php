class drupal_php::params (
  $server = 'apache'
) {

  $memory_limit = '128M'
  $max_execution_time = 30
  $cache_shared_memory = '256M'


  case $::operatingsystem {
    'RedHat', 'CentOS', 'Fedora', 'Scientific', 'Amazon', 'OracleLinux', 'SLC': {
      $apache_service_name = 'httpd'
      $system_package_manager = 'yum'
    }
    'Debian', 'Ubuntu': {
      $apache_service_name = 'apache2'
      $system_package_manager = 'yum'
    }
    default: {
      fail("\"${module_name}\" provides no package default value for \"${::operatingsystem}\"")
    }
  }
  case $server {
  	'apache': {
  		$service_name = $apache_service_name
  	}
  	default: {
  		fail("Server ${server} is not yet implemented.")
  	}

  }
}
