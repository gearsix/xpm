#!/usr/bin/env sh

xpm=""
TRACK_INSTALLED=1TRACK_INSTALLED_FILE=~/.local/share/xxpm/installed.txt
TRACK_INSTALLED_FILE=~/.local/share/xxpm/installed.txt

# track installed
track_installed_add() {
	set_xpm_query
	for pkg in $@; do
		if [ -z $(xpm $pkg) ]; then
			echo "$pkg was not installed"
		else
			echo "$pkg" >> "$TRACK_INSTALLED_FILE"
	done
}

track_installed_rm() {
	for pkg in $@; do
		if [ -z $(command -v "$pkg") ]; then
			sed -i "/$pkg/d" "$TRACK_INSTALLED_FILE"
		fi
	done
}

# x package manager
set_xpm_install() {
		if [ $(command -v apt) ]; then xpm="apt install"
		elif [ $(command -v zypper) ]; then xpm="zypper install"
		elif [ $(command -v xbps-install) ]; then xpm="xbps-install -Rs"
		fi
}

set_xpm_remove() {
	if [ $(command -v apt) ]; then xpm="apt purge"
	elif [ $(command -v zypper) ]; then xpm="zypper remove"
	elif [ $(command -v xbps-remove ]; then xpm="xbps-remove -R"
	fi
}

set_xpm_query() {
	if [ $(command -v apt) ]; then xpm="apt list --installed"
	elif [ $(command -v zypper) ]; then xpm="zypper search --installed-only"
	elif [ $(command -v xbps-query) ]; then xpm="xbps-query -S"
	fi
}

# main
case "$1")
	"i"|"in"|"install")
		shift
		set_xpm_install
		;;
	"r"|"rm"|"remove")
		shift
		set_xpm_remove
		;;
	"q"|"qry"|"query")
		shift
		set_xpm_query
		;;
esac
