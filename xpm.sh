#!/usr/bin/env sh

xpm=""
TRACK_INSTALLED=1
TRACK_INSTALLED_FILE=~/.local/share/xpm/installed.txt

# track installed
track_installed_add() {
	if [ ! -d $(dirname $TRACK_INSTALLED_FILE) ]; then
		mkdir -p $(dirname $TRACK_INSTALLED_FILE)
	fi

	set_xpm_query
	for pkg in $@; do
		if [ -z $($xpm $pkg) ]; then
			echo "$pkg was not installed"
		else
			echo "$pkg" >> "$TRACK_INSTALLED_FILE"
		fi
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
unknown_pm() {
	echo "unknown package manager"
	exit
}

set_xpm_install() {
		if [ $(command -v apt) ]; then xpm="apt install"
		elif [ $(command -v zypper) ]; then xpm="zypper install"
		elif [ $(command -v xbps-install) ]; then xpm="xbps-install -Rs"
		else unknown_pm; fi
}

set_xpm_remove() {
	if [ $(command -v apt) ]; then xpm="apt purge"
	elif [ $(command -v zypper) ]; then xpm="zypper remove"
	elif [ $(command -v xbps-remove) ]; then xpm="xbps-remove -R"
	else unknown_pm; fi
}

set_xpm_search() {
	if [ $(command -v apt) ]; then xpm="apt search"
	elif [ $(command -v zypper) ]; then xpm="zypper search"
	elif [ $(command -v xbps-query) ]; then xpm="xbps-query -Rs"
	else unknown_pm; fi
}

set_xpm_query() {
	if [ $(command -v apt) ]; then xpm="apt list --installed"
	elif [ $(command -v zypper) ]; then xpm="zypper search --installed-only"
	elif [ $(command -v xbps-query) ]; then xpm="xbps-query -S"
	else unknown_pm; fi
}

# main
case "$1" in
	"i"|"in"|"install")
		shift
		set_xpm_install
		$xpm $@
		if [ $? -eq 0 ]; then track_installed_add $@; fi
		;;
	"r"|"rm"|"remove")
		shift
		set_xpm_remove
		$xpm $@
		if [ $? -eq 0 ]; then track_installed_rm $@; fi
		;;
	"s"|"se"|"search")
		shift
		set_xpm_search
		$xpm $@
		;;
	"q"|"qry"|"query")
		shift
		set_xpm_query
		$xpm $@
		;;
esac
