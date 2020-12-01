# gip

Actually I needed a tool which backups some relevant system files (e.g. /usr/src/linux/.config and /usr/portage/make.conf) with the help of git.

## Installation

Install with
```shell
sudo make install
```

Create user-related config file
```shell
make def_config
```
__Important:__ You should have a look at the config file after it is created!

Uninstall with
```shell
sudo make uninstall
```

## Get started

Run backup with
```shell
gip full
```
