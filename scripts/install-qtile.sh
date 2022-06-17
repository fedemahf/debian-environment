#!/bin/bash
set -e

GITHUB_REPO_URL="https://raw.githubusercontent.com/fedemahf/debian-environment/master"

# Check if the user is root
if [ "$EUID" -ne 0 ]; then
  echo "You need to run this script as root." >&2
  exit 1
fi

# Get the user name
echo "Qtile needs to be installed for each user."
read -p "Please provide the user name: " USER_NAME

# Check if provided user exists
if [[ ! id -u "$USER_NAME" >/dev/null 2>&1 ]]; then
  read -p "The user ('$USER_NAME') doesn't exists. Do you want to create it? (y/n)"
  case "$REPLY" in
    y|Y)
      echo "Creating user '$USER_NAME'..."
      adduser $USER_NAME

      echo "Installing zsh..."
      apt install zsh -y

      echo "Updating default shell of $USER_NAME to /usr/bin/zsh"
      chsh -s /usr/bin/zsh $USER_NAME
    ;;
    *)
      echo "User not created. Aborting program..."
      exit 1
    ;;
  esac
fi

# Check if provided user is in sudoers file
if ! [[ id -nG "$USER_NAME" | grep -qw "sudo" ]]; then
  read -p "The user ('$USER_NAME') is not in the sudoers group. Do you want to add it to sudoers? (y/n)"
  case "$REPLY" in
    y|Y)
      echo "Adding '$USER_NAME' to sudoers group..."
      usermod -aG sudo $USER_NAME
    ;;
    *)
      echo "The user '$USER_NAME' will not be added to sudoers group."
    ;;
  esac
fi

USER_HOMEDIR="/home/$USER_NAME"

# install useful packages
apt install sudo wget git curl rxvt-unicode zsh neofetch -y

# install qtile dependencies
apt install python3-pip python3-cffi python3-xcffib python3-cairocffi libpangocairo-1.0-0 xorg xserver-xorg -y

# install qtile
pip install qtile psutil

# configure startx to start qtile
echo "exec qtile start > ~/.qtile.log" > $USER_HOMEDIR/.xsession
chown $USER_NAME:$USER_NAME $USER_HOMEDIR/.xsession

# configure startx to start on login
echo "if [[ -z \$DISPLAY ]] && [[ \$(tty) = /dev/tty1 ]]; then exec startx; fi" > $USER_HOMEDIR/.zprofile
chown $USER_NAME:$USER_NAME $USER_HOMEDIR/.zprofile

# upload qtile config file
mkdir -p $USER_HOMEDIR/.config/qtile
rm -rf $USER_HOMEDIR/.config/qtile/config.py
wget -O $USER_HOMEDIR/.config/qtile/config.py $GITHUB_REPO_URL/dotfiles/config.py
chown $USER_NAME:$USER_NAME $USER_HOMEDIR/config.py

rm -rf $USER_HOMEDIR/.Xresources
wget -O $USER_HOMEDIR/.Xresources $GITHUB_REPO_URL/dotfiles/.Xresources
chown $USER_NAME:$USER_NAME $USER_HOMEDIR/.Xresources

echo ""
echo "Run `dpkg-reconfigure keyboard-configuration` and enable the"
echo "Control+Alt+Backspace combination to terminate X server."
echo ""
echo "Qtile installation done."
echo ""

exit 0
