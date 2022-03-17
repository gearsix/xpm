#!/usr/bin/env sh

xpm=""
INSTALLED=~/.local/share/xpm/installed.txt

# track installed
track_installed_add() {
	if [ ! -d $(dirname $INSTALLED) ]; then
		mkdir -p $(dirname $INSTALLED)
	fi

	for pkg in $@; do
		if [ "$(grep $pkg $INSTALLED)" = "" ]; then
			echo $pkg >> "$INSTALLED"
		else
			echo "grep"
			grep $pkg $INSTALLED
		fi
	done
}

track_installed_rm() {
	for pkg in $@; do
		if [ "$(grep $pkg $INSTALLED)" != "" ]; then
			sed -i "/$pkg/d" "$INSTALLED"
		else
			echo "grep"
			grep $pkg $INSTALLED
		fi
	done
}

# x package manager
unknown_pm() {
	echo "unknown package manager"
	exit
}

xpm_install() {
		if [ $(command -v apt) ]; then xpm="sudo apt install"
		elif [ $(command -v zypper) ]; then xpm="sudo zypper install"
		elif [ $(command -v xbps-install) ]; then xpm="sudo xbps-install -Rs"
		else unknown_pm; fi
}

xpm_remove() {
	if [ $(command -v apt) ]; then xpm="sudo apt remove"
	elif [ $(command -v zypper) ]; then xpm="sudo zypper remove"
	elif [ $(command -v xbps-remove) ]; then xpm="sudo xbps-remove -R"
	else unknown_pm; fi
}

xpm_search() {
	if [ $(command -v apt) ]; then xpm="apt search"
	elif [ $(command -v zypper) ]; then xpm="zypper search"
	elif [ $(command -v xbps-query) ]; then xpm="xbps-query -Rs"
	else unknown_pm; fi
}

xpm_query() {
	if [ $(command -v apt) ]; then xpm="apt list --installed"
	elif [ $(command -v zypper) ]; then xpm="zypper search --installed-only"
	elif [ $(command -v xbps-query) ]; then xpm="xbps-query -S"
	else unknown_pm; fi
}

# main
case "$1" in
	"i"|"in"|"install")
		shift
		xpm_install
		$xpm $@ && track_installed_add $@
		;;
	"r"|"rm"|"remove")
		shift
		xpm_remove
		$xpm $@ && track_installed_rm $@
		;;
	"s"|"se"|"search")
		shift
		xpm_search
		$xpm $@
		;;
	"q"|"qry"|"query")
		shift
		xpm_query
		$xpm $@
		;;
esac
