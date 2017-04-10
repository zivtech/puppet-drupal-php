class drupal_php::fpm (
  $listen                 = $drupal_php::params::fpm_pool_listen,
  $pm_start_servers       = $drupal_php::params::fpm_pm_start_servers,
  $pm_min_spare_servers   = $drupal_php::params::fpm_pm_min_spare_servers,
  $pm_max_spare_servers   = $drupal_php::params::fpm_pm_max_spare_servers,
  $pm_max_children        = $drupal_php::params::fpm_pm_max_children,
  $pm_max_requests        = $drupal_php::params::fpm_pm_max_requests,
) inherits drupal_php::params {

  ::php::fpm::pool {'drupal_php':
    listen               => $listen,
    catch_workers_output => 'yes',
    pm_start_servers     => $pm_start_servers,
    pm_min_spare_servers => $pm_min_spare_servers,
    pm_max_spare_servers => $pm_max_spare_servers,
    pm_max_children      => $pm_max_children,
    pm_max_requests      => $pm_max_requests,
    php_flag             => {
      'session.auto_start'            => 'off',
      'mbstring.encoding_translation' => 'off',
    },
    php_value            => {
      'mbstring.http_input'  => 'pass',
      'mbstring.http_output' => 'pass',
    }
  }
}
