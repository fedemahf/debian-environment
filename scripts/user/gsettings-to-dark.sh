#!/bin/bash

if ! [ -x "$(command -v gsettings)" ]; then
	echo "libglib2.0-dev is not installed" >&2
	exit 1
fi

gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
exit 0
