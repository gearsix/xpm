#!/usr/bin/env sh

xpm=""
HOOKS_DIR=~/.config/xpm/hooks
INSTALLED=~/.local/share/xpm/installed.txt

usage() {
	echo "usage: xpm COMMAND [PKG ...]"
	echo ""
	echo "xpm - x package manager, an interface to the system package manager."
	echo ""
	echo "COMMAND"
	echo "install    install all [PKG]"
	echo "remove     uninstall all [PKG] (and uneeded dependencies)"
	echo "search     search the repositories for [PKG]"
	echo "query      query [PKG] to see if it's installed"
	echo "update     update all packages on the system"
	echo ""
	echo "See the README.md file for more details"
}

exec_hooks() {
	if [ $1 = "" ]; then return; fi
	
	if [ ! -d $HOOKS_DIR ]; then mkdir -p $HOOKS_DIR; fi

	for f in $HOOKS_DIR/*; do
		if [ "$(basename $f)" = "$1" ]; then
			echo "executing $f"
			exec $f
		fi
	done
}

installed_add() {
	if [ $XPM_NOTRACK ]; then return; fi
	
	if [ ! -d $(dirname $INSTALLED) ]; then
		mkdir -p $(dirname $INSTALLED)
	fi

	if [ ! -e $INSTALLED ]; then
		touch $INSTALLED
	fi

	for pkg in $@; do
		if [ "$(grep $pkg $INSTALLED)" = "" ]; then
			echo $pkg >> "$INSTALLED"
		fi
	done
}

installed_rm() {
	if [ $XPM_NOTRACK ]; then return; fi

	if [ -e $INSTALLED ]; then
		for pkg in $@; do
			if [ "$(grep $pkg $INSTALLED)" != "" ]; then
				sed -i "/$pkg/d" "$INSTALLED"
			fi
		done
	fi
}

unknown_pm() {
	echo "unknown package manager"
	exit
}

xpm_install() {
	if [ $(command -v apt) ]; then
		sudo apt install $@
	elif [ $(command -v zypper) ]; then
		sudo zypper install $@
	elif [ $(command -v xbps-install) ]; then
		sudo xbps-install -Rs $@
	else unknown_pm; fi
}

xpm_remove() {
	if [ $(command -v apt) ]; then
		sudo apt purge $@
	elif [ $(command -v zypper) ]; then
		sudo zypper remove -u $@
	elif [ $(command -v xbps-remove) ]; then
		sudo xbps-remove -R $@
	else unknown_pm; fi
}

xpm_search() {
	if [ $(command -v apt) ]; then
		apt search $@
	elif [ $(command -v zypper) ]; then
		zypper search $@
	elif [ $(command -v xbps-query) ]; then
		xbps-query -Rs $@
	else unknown_pm; fi
}

xpm_query() {
	if [ $(command -v apt) ]; then
		apt list --installed $@
	elif [ $(command -v zypper) ]; then
		zypper search --installed-only $@
	elif [ $(command -v xbps-query) ]; then
		xbps-query -S $@
	else unknown_pm; fi
}

xpm_update() {
	if [ $(command -v apt) ]; then
		sudo apt update && sudo apt upgrade
	elif [ $(command -v zypper) ]; then
		sudo zypper refresh && sudo zypper update
	elif [ $(command -v xbps-install) ]; then
		sudo xbps-install -Suv
	else unknown_pm; fi
}

# main
case "$1" in	
	"i"|"in"|"install")
		shift
		xpm_install $@ && installed_add $@
		exec_hooks install
		;;
	"r"|"rm"|"remove")
		shift
		xpm_remove $@ && installed_rm $@
		exec_hooks remove
		;;
	"s"|"se"|"search")
		shift
		xpm_search $@
		exec_hooks search
		;;
	"q"|"qry"|"query")
		shift
		xpm_query $@
		exec_hooks query
		;;
	"u"|"up"|"update")
		shift
		xpm_update
		exec_hooks update
		;;
	*)
		usage
		exit
esac
