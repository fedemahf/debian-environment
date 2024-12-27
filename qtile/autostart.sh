#!/bin/bash

echo "Executing ~/.config/qtile/autostart.sh ..."

# NetworkManager applet
if [ -x "$(command -v nm-applet)" ]; then
	nm-applet &
fi

# Check for xautolock & slock
if [ -x /usr/bin/xautolock ] && [ -x /usr/bin/slock ]; then
	# Enable slock after 15 minutes idle
	/usr/bin/xautolock -time 15 -locker slock &
fi
