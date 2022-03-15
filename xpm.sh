#!/usr/bin/env sh

pm=""

set_cmd_install() {
		if [ $(command -v apt) ]; then pm="apt install"
		elif [ $(command -v zypper) ]; then pm="zypper install"
		elif [ $(command -v xbps-install" ]; then pm="xbps-install"
		fi
}

set_cmd_remove() {
	if [ $(command -v apt) ]; then pm="apt purge"
	elif [ $(command -v zypper) ]; then pm="zypper remove"
	elif [ $(command -v xbps-remove ]; then pm="xbps-remove -R"
	fi
}

case "$1")
	"i"|"in"|"install")
		set_pm_install
		;;
	"r"|"rm"|"remove")
		set_pm_remove
		;;
esac
