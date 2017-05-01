# Puppet Drupal PHP

The goal of this module is to create a simple and easy to use class for configuring
php, specifically with Drupal in mind.  It wraps the most complete and popular
[php module](https://forge.puppetlabs.com/mayflower/php) on the forge and adds a ton of
convenience settings that can be set from hiera.

This module is thoroughly tested on Ubuntu 16.04 and should be useable
right out of the box.  It currently supports running php in apache with php-fpm and manages
apache as well using [puppetlabs-apache](https://forge.puppetlabs.com/puppetlabs/apache).
The module has been architected with the intention of adding nginx support, we're
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

### Advanced Usage

```` puppet
class { 'drupal_php':
  memory_limit_server    => '128M',
  max_execution_time_cli => 60,
  post_max_size          => '8M',
}
````

More advanced configuration can be accomplished using hierra.

### What drupal_php affects

* Installs php, php-fpm, many extensions, and apache
* Modifies some apache configurations (installing modules, optionally changing listen ports)
* Installs a default fpm pool that listens at 127.0.0.1:9001
* An apache vhost can be easily added using the [apache php vhost resource provided by the php module](https://github.com/voxpupuli/puppet-php/blob/master/manifests/apache_vhost.pp).