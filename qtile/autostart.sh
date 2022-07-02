#!/bin/bash

echo "Executing ~/.config/qtile/autostart.sh ..."

# NetworkManager applet
if [ -x "$(command -v nm-applet)" ]; then
	nm-applet &
fi
