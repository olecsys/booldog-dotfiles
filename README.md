[Arch Wiki](https://wiki.archlinux.org/index.php/bspwm)
# booldog-dotfiles
Configuration files for GNU/Linux

`Manjaro` requirements:
```
sudo pacman-mirrors --fasttrack && sudo pacman -Syyu

pacman -S ttf-material-icons
pacman -S ttf-font-awesome
pacman -S ibus
pacman -S gnome-keyring
pacman -S scrot

pamac build bento4
pamac install inkscape

pamac update -a
pamac install gvfs-mtp
pamac remove perl


pamac install palemoon-bin
```

## How to check Flash Plugin
```shell
pamac build flashplugin
pamac install palemoon-bin

pamac search -a waterfox
pamac build waterfox-classic-bin
```

## How to find out a window name string
```shell
xprop | grep WM_CLASS
```

### Keyboard
`super + shift + q` - cleanly quit bspwm
`super + shift + Escape` - make sxhkd reload its configuration files

### How to force work `Visual Studio Code` hot key `CTRL+SHIFT+E`
[Visual Studio Code GitHub issue](https://github.com/microsoft/vscode/issues/48480)
* install `ibus`: `sudo pacman -S ibus`
* start `ibus-setup` in terminal: `ibus-setup`
* go to `Emoji` tab and press `...`
* press `delete` button to delete the shortcut and press `OK`
* try in terminal: `GTK_IM_MODULE=ibus code`

How to check font existence:
```bash
fc-list | awk -F: '/Termsynu/ {print $2;}' | sort -u
```

### How to find package
```bash
pacman -Q | grep noto
```