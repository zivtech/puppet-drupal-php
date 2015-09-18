class drupal_php::extension::apc (
  $shm_size = 256M,
  $shm_segments = 1,
  $optimization = 0,
  $num_files_hint = 512,
  $user_entries_hint = 1024,
  $ttl = 0,
  $user_ttl = 0,
  $gc_ttl = 600,
  $cache_by_default = 1,
  $slam_defense = 0,
  $use_request_time = 1,
  $mmap_file_mask = '/dev/zero',
  $file_update_protection = 2,
  $enable_cli = 0,
  $max_file_size = '2M',
  $stat = 1,
  $write_lock = 1,
  $report_autofilter = 0,
  $include_once_override = 0,
  $rfc1867 = 0,
  $rfc1867_prefix = "upload_",
  $rfc1867_name = "APC_UPLOAD_PROGRESS",
  $rfc1867_freq = 0,
  $localcache = 1,
  $localcache_size = 512,
  $coredump_unmap = 0,
  $stat_ctime = 0
) inherits drupal_php::params {

  include php::extension::apc

  php::config { 'apc_settings':
    file  => "${php::params::config_root_ini}/apc.ini",
    config => [
      'set ".anon/extension" "apc.so"',
      "set .anon/apc.enabled 1",
      "set .anon/apc.shm_size ${shm_size}",
      "set .anon/apc.shm_segments ${shm_segments}",
      "set .anon/apc.optimization ${optimization}",
      "set .anon/apc.num_files_hint $num_files_hint",
      "set .anon/apc.user_entries_hint $user_entries_hint",
      "set .anon/apc.ttl $ttl",
      "set .anon/apc.user_ttl $user_ttl",
      "set .anon/apc.gc_ttl $gc_ttl",
      "set .anon/apc.cache_by_default $cache_by_default",
      "set .anon/apc.slam_defense $slam_defense",
      "set .anon/apc.use_request_time $use_request_time",
      "set .anon/apc.mmap_file_mask $mmap_file_mask",
      "set .anon/apc.file_update_protection $file_update_protection",
      "set .anon/apc.enable_cli $enable_cli",
      "set .anon/apc.max_file_size $max_file_size",
      "set .anon/apc.stat $stat",
      "set .anon/apc.write_lock $write_lock",
      "set .anon/apc.report_autofilter $report_autofilter",
      "set .anon/apc.include_once_override $include_once_override",
      "set .anon/apc.rfc1867 $rfc1867",
      "set .anon/apc.rfc1867_prefix $rfc1867_prefix",
      "set .anon/apc.rfc1867_name $rfc1867_name",
      "set .anon/apc.rfc1867_freq $rfc1867_freq",
      "set .anon/apc.localcache $localcache",
      "set .anon/apc.localcache.size $localcache_size",
      "set .anon/apc.coredump_unmap $coredump_unmap",
      "set .anon/apc.stat_ctime $stat_ctime",
    ],
  }

  if $::php_version == '' or versioncmp($::php_version, '5.4') >= 0 {
    file { '/etc/php5/apache2/conf.d/20-apc_settings.ini':
      target  => "${php::params::config_root_ini}/apc_settings.ini",
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      notify  => Service['httpd'],
      require => Php::Config['apc_settings'],
    }

    file { '/etc/php5/cli/conf.d/20-apc_settings.ini':
      target  => "${php::params::config_root_ini}/apc_settings.ini",
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      notify  => Service['httpd'],
      require => Php::Config['apc_settings'],
    }
  }
}
