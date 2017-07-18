define drupal_php::config_file_line(
 $value,
 $option,
 $path,
) {

  # If a value is passed as undefined then
  # it should be removed from the config file.
  if ($value == undef) {
    $ensure = 'absent'
    $match  = "^${option}*"
  }
  else {
    $ensure = 'present'
    $match = "^${option}"
  }

  file_line { "${name}":
    ensure            => $ensure,
    path              => $path,
    line              => "${option} ${value}",
    match             => $match,
    match_for_absence => true,
  }
}