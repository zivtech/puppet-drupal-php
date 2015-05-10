class drupal_php::extension::xhprof (
  $output_directory = '/tmp/xhprof'
) {

  package { 'xhprof-0.9.4':
    provider => 'pecl',
  }

  php::config { 'xhprof_enable':
    file  => "${php::params::config_root_ini}/xhprof.ini",
    config => [
      'set ".anon/extension" "xhprof.so"'
    ],
  }

  php::config { 'xhprof_':
    file    => "${php::params::config_root_ini}/xhprof.ini",
    section => 'xhprof',
    setting => 'xhprof.output_dir',
    value   => $output_directory,
  }

  if ($::php_version == '' or versioncmp($::php_version, '5.4') >= 0) {
    file { "/etc/php5/apache2/conf.d/xhprof.ini":
      target => "${php::params::config_root_ini}/xhprof.ini",
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }
    file { "/etc/php5/cli/conf.d/xhprof.ini":
      target => "${php::params::config_root_ini}/xhprof.ini",
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }
  }

}
