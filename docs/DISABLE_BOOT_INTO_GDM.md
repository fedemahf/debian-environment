# Disable boot into Gnome Display Manager

I don't like the login screen from GDM. This line will disable it.

```
systemctl set-default multi-user.target
```

## References

- [GDM](https://wiki.debian.org/GDM) at wiki.debian.org
