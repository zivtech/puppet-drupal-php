# Puppet Drupal PHP

The goal of this module is to create a simple and easy to use class for configuring
php, specifically with Drupal in mind.  It wraps the most complete and popular
[php module](https://forge.puppetlabs.com/nodes/php) on the forge and adds a ton of
convenience settings that can be set from hierra.

This module is thoroughly tested on Ubuntu 10.04, 12.04, and 14.04 and should be useable
right out of the box.  It currently supports running php in apache with mod_php and manages
apache as well using [puppetlabs-apache](https://forge.puppetlabs.com/puppetlabs/apache).
The module has been architected with the intention of adding fpm and nginx support, we're
just not there yet.  PR's are welcome.


## Setup

### Installation

```` bash
puppet module install zivtech-drupal_php
````

### Simple setup

```` puppet
include drupal_php
````

### Advanced Useage

```` puppet
class { 'drupal_php':
  # Defaults to opcache.
  opcache 			 => 'apc',
  memory_limit 		 => '128M',
  max_execution_time => 60,
}
````

More advanced configuration can be accomplished using hierra.

### What drupal_php affects

* Installs php, many extensions, and apache
* Modifies some apache configurations (installing modules, optionally changing listen ports)
