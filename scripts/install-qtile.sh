#!/bin/bash
set -e

GITHUB_REPO_URL="https://raw.githubusercontent.com/fedemahf/debian-environment/master"

# Check if the user is root
if [ "$EUID" -ne 0 ]; then
  echo "You need to run this script as root." >&2
  exit 1
fi

echo ""
echo "Before installing qtile, this program will install several packages."
echo ""
echo "Useful packages: sudo wget git curl rxvt-unicode zsh neofetch"
echo ""
echo "Qtile dependencies: python3-pip python3-cffi python3-xcffib"
echo "python3-cairocffi libpangocairo-1.0-0 xorg xserver-xorg"
echo ""
echo "It also will run an \`apt update\`."
echo ""

read -p "Do you agree? (y/n) "
case "$REPLY" in
  y|Y)
    echo "You give your permission. The packages will be installed now."
  ;;
  *)
    echo "You refused to install the required packages. Aborting program..."
    exit 1
  ;;
esac

# update packages
apt update

# install useful packages & qtile dependencies
apt install -y \
  sudo wget git curl rxvt-unicode zsh neofetch \
  python3-pip python3-cffi python3-xcffib python3-cairocffi libpangocairo-1.0-0 xorg xserver-xorg

# Get the user name
echo "Qtile needs to be installed for each user."
read -p "Please provide the user name: " USER_NAME

# Check if provided user exists
if [[ ! id -u "$USER_NAME" >/dev/null 2>&1 ]]; then
  read -p "The user ('$USER_NAME') doesn't exists. Do you want to create it? (y/n) "
  case "$REPLY" in
    y|Y)
      echo "Creating user '$USER_NAME'..."
      adduser $USER_NAME
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
  read -p "The user ('$USER_NAME') is not in the sudoers group. Do you want to add it to sudoers? (y/n) "
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

USER_HOME_DIR="/home/$USER_NAME"
USER_QTILE_CONFIG_DIR="$USER_HOME_DIR/.config/qtile"

update_file_owner() {
  chown $USER_NAME:$USER_NAME "$1"
}

# install qtile
pip install qtile psutil

# configure startx to start qtile
echo "exec qtile start > ~/.qtile.log" > "$USER_HOME_DIR/.xsession"
update_file_owner "$USER_HOME_DIR/.xsession"

# configure startx to start on login
echo "if [[ -z \$DISPLAY ]] && [[ \$(tty) = /dev/tty1 ]]; then exec startx; fi" > $USER_HOME_DIR/.zprofile
update_file_owner "$USER_HOME_DIR/.zprofile"

# create qtile config folder
mkdir -p "$USER_QTILE_CONFIG_DIR"

# download `config.py`
rm -f "$USER_QTILE_CONFIG_DIR/config.py"
wget -O "$USER_QTILE_CONFIG_DIR/config.py" "$GITHUB_REPO_URL/qtile/config.py"
update_file_owner "$USER_QTILE_CONFIG_DIR/config.py"

# download `crypto_ticker_binance.py` (custom widget)
rm -f "$USER_QTILE_CONFIG_DIR/crypto_ticker_binance.py"
wget -O "$USER_QTILE_CONFIG_DIR/crypto_ticker_binance.py" "$GITHUB_REPO_URL/qtile/crypto_ticker_binance.py"
update_file_owner "$USER_QTILE_CONFIG_DIR/crypto_ticker_binance.py"

# download .Xresources
rm -f "$USER_HOME_DIR/.Xresources"
wget -O "$USER_HOME_DIR/.Xresources" "$GITHUB_REPO_URL/dotfiles/.Xresources"
update_file_owner "$USER_HOME_DIR/.Xresources"

# send exit message
echo ""
echo "Run \`dpkg-reconfigure keyboard-configuration\` and enable the"
echo "Control+Alt+Backspace combination to terminate X server."
echo ""
echo "Qtile installation done."
echo ""

exit 0
