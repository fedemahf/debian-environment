# Dark mode

Install packages.

```bash
apt-get install gnome-tweaks gnome-tweak-tool gnome-themes-extra libglib2.0-bin
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
```

Then set:

```ini
[Settings]
gtk-application-prefer-dark-theme=1
```

In the `settings.ini` file inside the GTK configuration folder (`~/.config/gtk-VERSION`).
