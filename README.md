# booldog-dotfiles
Configuration files for GNU/Linux

`Manjaro` requirements:
```
pacman -S ttf-material-icons
pacman -S ttf-font-awesome
```

How to check font existence:
```bash
fc-list | awk -F: '/Termsynu/ {print $2;}' | sort -u
```

### How to find package
```bash
pacman -Q | grep noto
```
