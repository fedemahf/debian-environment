#!/bin/bash

## previously...

## install optional packages
# apt install sudo wget git curl rxvt-unicode zsh neofetch -y
## create new user
# adduser <name>
## make it superuser
# usermod -aG sudo <name>
## update shell
# chsh -s /usr/bin/zsh <name>
## switch to the new user
# su - <name>

# install dependencies
sudo apt install python3-pip python3-cffi python3-xcffib python3-cairocffi libpangocairo-1.0-0 xorg xserver-xorg -y

# install qtile
sudo pip install qtile psutil

# enable kill startx with ctrl alt backspace
sudo dpkg-reconfigure keyboard-configuration

# configure startx to start qtile
echo "exec qtile start > ~/.qtile.log" > ~/.xsession

# configure startx to start on login
echo "if [[ -z \$DISPLAY ]] && [[ \$(tty) = /dev/tty1 ]]; then exec startx; fi" > ~/.zprofile
