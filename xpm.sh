#!/usr/bin/env sh

pm=""

HOOKS_DIR=~/.config/xpm/hooks
if [ "$(uname)" = "Darwin" ]; then HOOKS_DIR=~/Library/Application Support/xpm/hooks; fi

# misc
usage() {
	echo "usage: xpm COMMAND [PKG ...]"
	echo ""
	echo "xpm - x package manager, an interface to the system package manager."
	echo ""
	echo "COMMAND"
	echo "install, in,  i    install all [PKG]"
	echo "remove,  re,  r    uninstall all [PKG] (and dependencies)"
	echo "search,  se,  s    search the repositories for [PKG]"
	echo "query,   qry, q    query [PKG] for information"
	echo "list,    ls,  l    list installed files for [PKG]"
	echo "update,  up,  u    update all packages on the system"
	echo ""
	echo "See the README.md file for more details"
}

# hooks
exec_hooks() {
	if [ "$1" = "" ]; then return; fi
	
	if [ ! -d "$HOOKS_DIR" ]; then mkdir -p $HOOKS_DIR; fi

	for f in "$HOOKS_DIR"/*; do
		if [ "$(basename "$f")" = "$1" ]; then
			echo "executing $f"
			exec "$f"
		fi
	done
}

# identify the package manager
identify_pm() {
	if [ "$(command -v apt)" ] && [ "$(command -v apt-get)" ]; then
		pm="apt"
	elif [ "$(command -v zypper)" ]; then
		pm="zypper"
	elif [ "$(command -v xbps-install)" ]; then
		pm="xbps"
	elif [ "$(command -v brew)" ]; then
		pm="homebrew"
	else
		unknown_pm
	fi
}

unknown_pm() {
	echo "unknown package manager!"
	echo "  The package manager for your system could not be recognised."
	echo "  If you're using a stanadard package manager, report it to the dev so he can add support."
	exit
}

# xpm commands
xpm_install() {
	case $pm in
		"apt") sudo apt install "$@" ;;
		"zypper") sudo zypper install "$@" ;;
		"xbps") sudo xbps-install "$@" ;;
		"homebrew") brew install "$@" ;;
		*) unknown_pm ;;
	esac
}

xpm_remove() {
	case $pm in
		"apt") sudo apt purge "$@" ;;
		"zypper") sudo zypper remove -u "$@" ;;
		"xbps") sudo xbps-remove -R "$@" ;;
		"homebrew") brew uninstall "$@" ;;
		*) unknown_pm ;;
	esac
}

xpm_search() {
	case $pm in
		"apt") apt search "$@" ;;
		"zypper") zypper search "$@" ;;
		"xbps") xbps-query -Rs "$@" ;;
		"homebrew") brew search "$@" ;;
		*) unknown_pm ;;
	esac
}

xpm_query() {
	case $pm in
		"apt") apt show "$@" ;;
		"zypper") zypper info "$@" ;;
		"xbps") xbps-query -RS "$@" ;;
		"homebrew") brew info "$@" ;;
		*) unknown_pm ;;
	esac
}

xpm_list() {
	case $pm in
		"apt") apt list --installed "$@" ;;
		"zypper") zypper search --installed-only "$@" ;;
		"xbps") xbps-query -S "$@" ;;
		"homebrew") brew list "$@" ;;
		*) unknown_pm ;;
	esac
}

xpm_update() {
	case $pm in
		"apt") sudo apt update && sudo apt upgrade ;;
		"zypper") sudo zypper refresh && sudo zypper update ;;
		"xbps") sudo xbps-install -Suv ;;
		"homebrew") brew update && brew upgrade ;;
		*) unknown_pm ;;
	esac
}

# main
identify_pm

cmd="$1";

if [ "$cmd" != "" ]; then shift; fi

case "$cmd" in	
	"i"|"in"|"install")
		xpm_install "$@"
		exec_hooks install
		;;
	"r"|"rm"|"remove")
		xpm_remove "$@"
		exec_hooks remove
		;;
	"s"|"se"|"search")
		xpm_search "$@"
		exec_hooks search
		;;
	"q"|"qry"|"query")
		xpm_query "$@"
		exec_hooks query
		;;
	"l"|"ls"|"list")
		xpm_list "$@"
		exec_hooks list
		;;
	"u"|"up"|"update")
		xpm_update
		exec_hooks update
		;;
	*)
		usage
		exit
esac
