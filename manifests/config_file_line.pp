define drupal_php::config_file_line(
 $value,
 $option,
 $path,
) {

  # If a value is passed as undefined then
  # it should be removed from the config file.
  if ($value == undef) {
    $ensure = 'absent'
  }
  else {
    $ensure = 'present'
  }

  file_line { "${name}":
    ensure            => $ensure,
    path              => $path,
    line              => "${option} ${value}",
    # Match the option if it is indented
    # but not if it's commented out.
    # This is so we don't replace multiple
    # lines with the same setting.
    match             => "^[^#]*${option}*",
    match_for_absence => true,
  }
}