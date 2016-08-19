### v3.2.1
 - Changes conditional to use PHP version rather than Ubuntu version
 to allow for other Linux distros.

### v3.2.0
 - Fix issue with installing php-redis. PECL updated the version of
 php-redis and it no longer supports the php language version that
 ships with ubuntu 14.04. Since earlier versions of ubuntu do not have
 apt packages for php-redis, we drop support for php-redis on versions
 prior to 14.04

### v3.1.0
 - Adjust handling of apache modules and default vhosts name.

### v3.0.2

 - Fix an issue in which provisioning might fail if a port number was interpreted as an integer.

### v3.0.1

 - Fixes an error in which a variable was defined multiple times.
 - Adjusts formatting and string usage to be better in line with community standards.
