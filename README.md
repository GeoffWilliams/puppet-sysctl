[![Build Status](https://travis-ci.org/GeoffWilliams/puppet-sysctl.svg?branch=master)](https://travis-ci.org/GeoffWilliams/puppet-sysctl)
# sysctl

#### Table of Contents

1. [Description](#description)
1. [Features](#features)
1. [Puppet resource implementation](#puppet-resource-implementation)
1. [sysctl precedence](#sysctl-precedence)
1. [Value handling](#value-handling)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

Manage sysctl kernel tuning with Puppet.

This is a native type and provider that scans for known `sysctl` settings in all directories the command scans 
(see sysctl precedence).

The module has its own naming convention for files in `/etc/sysctl.d`:

*   Prefix files managed by puppet with `80-puppet-` and then name of setting used as filename, eg 
    `net.ipv4.conf.all.accept_source_route` will be saved as 
    `/etc/sysctl.d/80-puppet-net.ipv4.conf.all.accept_source_route.conf`
*   One setting per file, in regular `sysctl` format, eg:
    ```
    net.ipv4.conf.all.accept_source_route=0
    ```    

## Features

* Scans system directories for for rules (see sysctl precedence)
* Runs `sysctl -w` when a rule is added
* Flushes IPv4 and IPv6 rules when a rule matching `/ipv4/` or `/ipv6/` is updated (can be disabled)
* Rebuild the initrd when any rules updated (can be disabled)
* Supports resource purging for unmanaged rules
* Files created by puppet prefixed `80-puppet-` for identification


## Puppet resource implementation
It's possible to enumerate the list of current settings using `puppet resource sysctl` which will give output like this:

```puppet
sysctl { 'net.ipv4.conf.all.accept_source_route':
  ensure      => 'present',
  defined_in  => ['/etc/sysctl.d/80-puppet-net.ipv4.conf.all.accept_source_route.conf'],
  value       => '0',
  value_saved => '0',
}
```

In this case:
*   `net.ipv4.conf.all.accept_source_route` is the setting being managed
*   There is some form of non-default setting in place (`ensure=>present`)
*   The setting is defined in `/etc/sysctl.d/80-puppet-net.ipv4.conf.all.accept_source_route.conf` and because this file
    starts `80-puppet-` the module _owns_ the setting
*   `defined_in` lists _all_ `.conf` file defining the setting (see sysctl precedence)
*   `value` represents the active value on the system, obtained from  running `sysctl net.ipv4.conf.all.accept_source_route`
*   `valued_saved` represents the current _winning_ value saved in `.conf` files (see sysctl precedence)

```puppet
sysctl { 'net.ipv4.igmp_qrv':
  ensure      => 'present',
  defined_in  => ['/etc/sysctl.d/megacorp_settings.conf'],
  value       => '2',
  value_saved => '2',
}
```

The module also manages changes made in files created by the user which  will have names that don't match the `80-puppet-`
naming convention. When the module is commanded to take ownership of such settings, the existing file will be renamed 
rather then deleted, eg:

```puppet
sysctl { "net.ipv4.igmp_qrv=2": }
```

Would result in setting being saved to `80-puppet-net.ipv4.igmp_qrv.conf` while `megacorp_settings.conf` would be moved
to `megacorp_settings.conf.nouse`.

## sysctl precedence
According to `man sysctl`, Several patterns of files are processed with the last definition _winning_:

```
/run/sysctl.d/*.conf
/etc/sysctl.d/*.conf
/usr/local/lib/sysctl.d/*.conf
/usr/lib/sysctl.d/*.conf
/lib/sysctl.d/*.conf
/etc/sysctl.conf
```

Despite the symlink `/etc/sysctl.d/99-sysctl.conf` existing, `/etc/sysctl.conf` is still processed separately and in 
accordance with the above list.

The module keeps track of settings that occur in any of the above files in the `defined_in` property. If asked to manage
a setting that is already defined and not managed by the module Puppet will disable all existing `.conf` files 
containing the offending definition by appending `.nouse` to the filename and will then create a new file obeying the 
`80-puppet-` naming convention if `ensure=>present`.

## Value handling
It's possible for `value` to differ from `value_saved` and this would indicate that `sysctl -w` was run at some point 
after the sysctl rules were processed.

Puppet detects when `value != value_saved` and will sync the resource on detection.


## Usage

### Simple (long form)

```puppet
sysctl { "net.ipv4.conf.all.accept_source_route":
  ensure => present,
  value  => 0,
}
```

* Runs `sysctl -w net.ipv4.conf.all.accept_source_route=0`
* Writes the setting to `/etc/net.ipv4.conf.all.accept_source_route.conf` for activation on boot
* Flushes the IPv4 rules
* Rebuilds initrd

### Simple (short form)

```puppet
sysctl { "net.ipv4.conf.all.accept_source_route=0":
  ensure => present,
}
```

* Functionally equivalent to long form but handly shortened syntax using only `title`
* `title` must match `key=value`

### Resource purging

```puppet
resources { "sysctl":
  purge => true,
}

sysctl { "net.ipv4.conf.all.accept_source_route":
  value => 0,
}
```

Puppet will purge all unmanaged settings from all scanned file patterns (see sysctl precedence):
* Only valid settings can be purged (visible in `sysctl -a`)
* Existing puppet managed files will be removed
* Existing non-puppet managed files will be renamed
* Only the sysctl settings in the catalog will continue to exist
* You must _reboot_ to restore default settings
* Only sysctl rules managed by puppet will exist if this technique is used

### Stop managing a setting

```puppet
sysctl { "net.ipv4.conf.all.accept_source_route":
  ensure => absent,
}

```
* Removes the `.conf` file from `/etc/sysctl.d`
* initrd will be rebuilt
* You must _reboot_ to restore default settings

### Don't flush IPv4 on rule change (per resource)
```puppet
sysctl { "net.ipv4.conf.all.accept_source_route=1":
  autoflush_ipv4 => false,
}
```
* To avoid flushing the IPv4 rules for _this_ resource, set `autoflush_ipv4` false

### Don't flush IPv6 on rule change (per resource)
```puppet
sysctl { "net.ipv6.conf.default.disable_ipv6=1":
  autoflush_ipv6 => false,
}
```
* To avoid flushing the IPv6 rules for _this_ resource, set `autoflush_ipv6` false

### Don't rebuild initrd on rule change (per resource)
```puppet
sysctl { "net.ipv6.conf.default.disable_ipv6=1":
  rebuild_initrd => false,
}
```
* To avoid rebuilding initrd with `dracut` for _this_ resource, set `rebuild_initrd` false 

### Use an alternate command to rebuild initrd
```puppet
sysctl { "net.ipv6.conf.default.disable_ipv6=1":
  rebuild_initrd_cmd => "/bin/echo custom > /tmp/testcase/initrd_cmd",
}
```
* Run any command you like to rebuild the initrd for _this_ resource. This should allow multi-OS support


## Reference
[generated documentation](https://rawgit.com/GeoffWilliams/puppet-sysctl/master/doc/index.html).

Reference documentation is generated directly from source code using [puppet-strings](https://github.com/puppetlabs/puppet-strings).  You may regenerate the documentation by running:

```shell
bundle exec puppet strings
```

## Limitations
*   Tested on RHEL/CentOS 7 so far. You might be able to support other systems by passing the appropriate command to 
    rebuild initrd on your platform

## Development

PRs accepted :)

## Testing
This module supports testing using [PDQTest](https://github.com/declarativesystems/pdqtest).


Test can be executed with:

```
bundle install
make
```

See `.travis.yml` for a working CI example
