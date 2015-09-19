class drupal_php::extension::opcache (
  $memory_consumption = 256,
  $max_accelerated_files = 65407,
  $revalidate_freq = 60,
  $fast_shutdown = 0,
  $validate_timestamps = 1,
  $enable_cli = 0,
  $interned_strings_buffer = 24
) {

  include php::extension::opcache

  php::config { 'opcache_settings':
    file  => "${php::params::config_root_ini}/opcache_settings.ini",
    config => [
      "set .anon/opcache.memory_consumption ${memory_consumption}",
      "set .anon/opcache.max_accelerated_files ${max_accelerated_files}",
      "set .anon/opcache.revalidate_freq ${revalidate_freq}",
      "set .anon/opcache.fast_shutdown ${fast_shutdown}",
      "set .anon/opcache.validate_timestamps ${validate_timestamps}",
      "set .anon/opcache.enable_cli ${enable_cli}",
      "set .anon/opcache.interned_strings_buffer ${interned_strings_buffer}",
    ],
    notify => Service['httpd'],
  }

  if $::php_version == '' or versioncmp($::php_version, '5.4') >= 0 {
    file { '/etc/php5/apache2/conf.d/20-opcache_settings.ini':
      target  => "${php::params::config_root_ini}/opcache_settings.ini",
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      notify  => Service['httpd'],
      require => Php::Config['opcache_settings'],

    }

    file { '/etc/php5/cli/conf.d/20-opcache_settings.ini':
      target  => "${php::params::config_root_ini}/opcache_settings.ini",
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      notify  => Service['httpd'],
      require => Php::Config['opcache_settings'],
    }
  }


}
