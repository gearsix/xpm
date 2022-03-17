# xpm

**x package manager**

A sh script to provide a generic interface to whatever package manager your system uses.

The goal of this project is to avoid the requirement for doing the mental check required when interfacing with your systems package manager, useful if you hop between systems frequently.


## configure

It also tracks installed/uninstalled packages (only what you've requested for install, not including its dependencies) in `~/.local/share/xpm/installed.txt`.

Tracking installed packages can be disabled by setting *XPM_NOTRACK* to 1, either in your environment.


## install

`install ./xpm.sh [INSTALL DIR]/xpm`

**INSTALL DIR** can be any directory in your *$PATH*, common locations are:

- */usr/local/bin* (requires sudo)
- *~/.local/bin*


## notes

- Add hooking (á la githooks)


## authors

- gearsix
