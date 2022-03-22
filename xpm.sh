#!/usr/bin/env sh

xpm=""
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
}

installed_add() {
	if [ $XPM_NOTRACK ]; then return; fi
	
	if [ ! -d $(dirname $INSTALLED) ]; then
		mkdir -p $(dirname $INSTALLED)
	fi

	for pkg in $@; do
		if [ "$(grep $pkg $INSTALLED)" = "" ]; then
			echo $pkg >> "$INSTALLED"
		fi
	done
}

installed_rm() {
	if [ $XPM_NOTRACK ]; then return; fi

	for pkg in $@; do
		if [ "$(grep $pkg $INSTALLED)" != "" ]; then
			sed -i "/$pkg/d" "$INSTALLED"
		fi
	done
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
		sudo apt remove $@ && sudo apt autoremove -y
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
		;;
	"r"|"rm"|"remove")
		shift
		xpm_remove $@ && installed_rm $@
		;;
	"s"|"se"|"search")
		shift
		xpm_search $@
		;;
	"q"|"qry"|"query")
		shift
		xpm_query $@
		;;
	"u"|"up"|"update")
		shift
		xpm_update
		;;
	*)
		usage
		exit
esac
