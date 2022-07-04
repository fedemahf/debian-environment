#!/bin/bash
set -e

# GITHUB_REPO_URL="https://raw.githubusercontent.com/fedemahf/debian-environment/master"

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
    echo "You gave your permission. The packages will be installed now."
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
echo ""
echo "Qtile needs to be installed for each user."
read -p "Please provide the user name: " USER_NAME
echo ""

# Check if provided user exists
if ! ( id -u "$USER_NAME" >/dev/null 2>&1 ); then
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
if ! ( id -nG "$USER_NAME" | grep -qw "sudo" ); then
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

USER_DIR_HOME="/home/$USER_NAME"
USER_DIR_QTILE_CONFIG="$USER_DIR_HOME/.config/qtile"
USER_DIR_SCRIPTS="${USER_DIR_HOME}/scripts"

# https://stackoverflow.com/a/246128
REPO_DIR_SCRIPTS_INSTALL=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
REPO_DIR_ROOT="${REPO_DIR_SCRIPTS_INSTALL}/../.."
REPO_DIR_SCRIPTS_USER="${REPO_DIR_ROOT}/scripts/user"
REPO_DIR_DOTFILES="${REPO_DIR_ROOT}/dotfiles"
REPO_DIR_QTILE="${REPO_DIR_ROOT}/qtile"

update_file_owner() {
  chown -R $USER_NAME:$USER_NAME "$1"
}

# install qtile
pip install qtile psutil

# create logs folder
mkdir -p "$USER_DIR_HOME/logs"

echo "Copying qtile files..."
mkdir -p "$USER_DIR_QTILE_CONFIG"
for file in $REPO_DIR_QTILE/*; do
  filename="${file##*/}"
  rm -f "${USER_DIR_QTILE_CONFIG}/${filename}"
  cp "${REPO_DIR_QTILE}/${filename}" "${USER_DIR_QTILE_CONFIG}/"
  update_file_owner "${USER_DIR_QTILE_CONFIG}/${filename}"
done

echo "Copying dotfiles..."
for file in $REPO_DIR_DOTFILES/*; do
  filename="${file##*/}"
  rm -f "${USER_DIR_HOME}/.${filename}"
  cp "${REPO_DIR_DOTFILES}/${filename}" "${USER_DIR_HOME}/.${filename}"
  update_file_owner "${USER_DIR_HOME}/.${filename}"
done

echo "Copying scripts..."
mkdir -p "${USER_DIR_SCRIPTS}"
for file in $REPO_DIR_SCRIPTS_USER/*; do
  filename="${file##*/}"
  rm -rf "${USER_DIR_SCRIPTS}/${filename}"
  cp -r "${REPO_DIR_SCRIPTS_USER}/${filename}" "${USER_DIR_SCRIPTS}/"
  update_file_owner "${USER_DIR_SCRIPTS}/${filename}"
done

# send exit message
echo ""
echo "Run \`dpkg-reconfigure keyboard-configuration\` and enable the"
echo "Control+Alt+Backspace combination to terminate X server."
echo ""
echo "Qtile installation done."
echo ""

exit 0
