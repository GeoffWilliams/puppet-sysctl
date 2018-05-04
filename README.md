[![Build Status](https://travis-ci.org/GeoffWilliams/puppet-sysctl.svg?branch=master)](https://travis-ci.org/GeoffWilliams/puppet-sysctl)
# sysctl

#### Table of Contents

1. [Description](#description)
1. [Features](#features)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

Manage sysctl kernel tuning with Puppet.

This is a native type and provider that scans the contents of `/etc/sysctl.d` (and thus `/etc/sysctl.conf`
due) to the symlink `99-sysctl.conf`.

The module has its own naming convention for files in `/etc/sysctl.d`:

*   Prefix files managed by puppet with `80-puppet-` and then name of
    setting used as filename, eg `net.ipv4.conf.all.accept_source_route`
    will be saved as `/etc/sysctl.d/80-puppet-net.ipv4.conf.all.accept_source_route.conf`
*   One setting per file, in regular `sysctl` format, eg:
    ```
    net.ipv4.conf.all.accept_source_route=0
    ```
*   Files obeying the above convention are `ensure=>present`
*   All other files in the directory will be scanned for entries and any found
    will be `ensure=>absent` since puppet isn't managing them yet
    they are being explicitly set

## Features

* Scans `/etc/sysctl.d/*.conf` for rules
* Runs `sysctl -w` when a rule is added
* Flushes IPv4 and IPv6 rules when a rule matching `/ipv4/` or `/ipv6/` is updated (optional)
* Rebuild the initrd when any rules updated (optional)
* Supports resource purging for unmanaged rules
* Files created by puppet prefixed `80-puppet-` for identification


## Puppet resource implementation
It's possible to enumerate the list of current settings using
`puppet resource sysctl` which will give output like this:

```puppet
sysctl { 'net.ipv4.conf.all.accept_source_route':
  ensure      => 'present',
  defined_in  => '/etc/sysctl.d/80-puppet-net.ipv4.conf.all.accept_source_route.conf',
  value       => '0',
  value_saved => '0',
}
```

In this case:
*   `net.ipv4.conf.all.accept_source_route` is the setting being managed
*   There is some form of non-default setting in place (`ensure=>present`)
*   The settting is defined in `/etc/sysctl.d/80-puppet-net.ipv4.conf.all.accept_source_route.conf`
    because this file starts `80-puppet-` the module _owns_ the setting
*   The value from running `sysctl net.ipv4.conf.all.accept_source_route` is `0`
*   The value saved in the file at `defined_in` is also `0`

```puppet
sysctl { 'net.ipv4.igmp_qrv':
  ensure      => 'present',
  defined_in  => '/etc/sysctl.d/megacorp_settings.conf',
  value       => '2',
  value_saved => '2',
}
```

The module also detects changes made in files created by the user. These
will have names that don't match the 80-puppet- naming convention. Where
the module is commanded to take ownership of such settings, the existing
file will be renamed rather then deleted, eg:

```puppet
sysctl { "net.ipv4.igmp_qrv=2": }
```

Would result in setting being saved to `80-puppet-net.ipv4.igmp_qrv.conf`
while `megacorp_settings.conf` would be moved to `megacorp_settings.conf.nouse`.

## File precedence
According to `man sysctl`, Several patterns of files are processed with the last
definition _winning_:

```
/run/sysctl.d/*.conf
/etc/sysctl.d/*.conf
/usr/local/lib/sysctl.d/*.conf
/usr/lib/sysctl.d/*.conf
/lib/sysctl.d/*.conf
/etc/sysctl.conf
```

Despite the symlink `/etc/sysctl.d/99-sysctl.conf` existing, `/etc/sysctl.conf`
is still processed separately and in accordance with the above list.

Finally, the file at `/etc/sysctl.conf` is also handled by the module - to a
degree. My understanding is that`/etc/sy`

It's possible for `value` to differ from `value_saved` and this would
indicate that `sysctl -w` was run at some point after the sysctl rules
 were processed.

`net.netfilter.nf_conntrack_max` which is managed in a user created file
`/etc/sysctl.d/myrules.conf`. If we decide to take ownership of this rule
(`ensure=>present`) then the file defining the old setting will be renamed
`.conf` to `.conf.nouse`. This disables the file without deleting it which
is useful since user defined files can hold more then one setting.



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

* Functionally equivalent to long form
* Title must match `key=value`

### Resource purging

```puppet
resources { "sysctl":
  purge => true,
}

sysctl { "net.ipv4.conf.all.accept_source_route":
  value => 0,
}
```

Puppet will purge all unmanaged settings from `/etc/sysctl.d`:
* Existing puppet managed files will be removed
* Existing non-puppet managed files will be renamed
* Only the sysctl settings in the catalog will continue to exist
* You must _reboot_ to restore default settings

### Stop managing a setting

```puppet
sysctl { "net.ipv4.conf.all.accept_source_route":
  ensure => absent,
}

```

### Don't flush IPv4 on rule change (per resource)


### Don't flush IPv6 on rule change (per resource)
### Don't rebuild initrd on rule change (per resource)
### Use an alternate command to rebuild initrd


## Reference
[generated documentation](https://rawgit.com/GeoffWilliams/puppet-sysctl/master/doc/index.html).

Reference documentation is generated directly from source code using [puppet-strings](https://github.com/puppetlabs/puppet-strings).  You may regenerate the documentation by running:

```shell
bundle exec puppet strings
```

## Limitations
* Not supported by Puppet, Inc.

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
