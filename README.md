# xpm

**x package manager**

A sh script to provide a generic interface to whatever package manager your system uses.

The goal of this project is to avoid the requirement for doing the mental check required when interfacing with your systems package manager, useful if you hop between systems frequently.


## install

`install ./xpm.sh [INSTALL DIR]/xpm`

**INSTALL DIR** can be any directory in your *$PATH*, common locations are:

- */usr/local/bin* (requires sudo)
- *~/.local/bin*


## configure

**tracking**

xpm keeps track of installed/uninstalled packages (only what you've requested for install, not including its dependencies) in `~/.local/share/xpm/installed.txt`.

This behaviour can be disabled by setting *XPM_NOTRACK* to 1, either in your environment.

**hooks**

xpm supports 'hooks' (inspired by git-hooks). A 'hook' is a script that gets executed *after* running the specified command.

All you need to do is add the script file to execute in `~/.config/xpm/hooks` and make sure it's executable.

This is useful if you install package outside of the package manager that require a seperate command to execute, or if you want to add additional behaviour to the default xpm commands.


## authors

- gearsix
