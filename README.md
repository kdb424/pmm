# worldedit
Emulating Gentoo's world files and sets for other package managers.
[Gentoo sets](https://wiki.gentoo.org/wiki//etc/portage/sets)

## Requirements

- The Nim ([Official website](https://nim-lang.org/)) programming language (Min version 1.4.0)
- Nimble ([Github](https://github.com/nim-lang/nimble)), the Nim's package manager

Hint: Install Nim with Choosenim ([Github](https://github.com/dom96/choosenim))

## Installation
Arch Linux (AUR)

```bash
pacman -S --needed git base-devel
git clone https://aur.archlinux.org/worldedit-git.git
cd worldedit
makepkg -si
```

or

Directly with Nimble (with url)

```bash
# Install directly with Nimble (with url)
nimble install https://github.com/kdb424/worldedit
```

or

Manually with Nimble

```bash
# Clone repo
git clone https://github.com/kdb424/worldedit

# go to folder
cd worldedit

# Install (with Nimble)
nimble install -y
```

## Usage
```bash
Worldedit.

Usage:
  worldedit [options]

Options:
  -h, --help                         Show this screen.
  -v, --version                      Show version.
  --worldfile file                   Set the worldfile
  --init                             Initializes a worldfile if it does not exist
  --list-command=<command>           List all packages command
  --install-command=<command>        Package install command
  --remove-command=<command>         Package remove command
  --orphans-command=<command>        Orphans uninstall command
  --sync                             Add/remove packages to match the worldfile
  --diff                             Lists the packages that are added/removed
  --install=<package>                Installs a package and appends to the worldfile
  --remove=<package>                 Removes a package and deletes the entry in the worldfile
  --bash                             Outputs commands that can be piped into bash
  --orphans                          Removes things marked as orphans from your system
```

## Configuration
There are no configuration files. All configuration is done through environment
variables, or manually by flags. All required commands will be auto detected if
environment variables aren't set. See #Distros below for examples


## Worldfile
A worldfile is a list of installed packages, that are newline separated.
Lines starting with @ are used to refer to a set file. Sets can contain
more packages, as well as other sets. Comments are allowed only at the
beginning of the line, and are defined with # at the start of the line.
Spaces in package names or sets are not supported. An example of a world
file in use can be seen below.

### Default worldfile location
```
/etc/worldedit/worldfile
```

### Overriding the worldfile location
```bash
export WORLDEDIT_WORLD="~/.config/worldedit/world"
```

### Example
```bash
╭─kdb424@planex ~/.config/worldedit
╰─$ ls
amy    bluetooth  gui         laptop  openrc    planex  sway      wireless
artix  dev        guisupport  misc    pipewire  pulse   terminal  zfs

╭─kdb424@planex ~/.config/worldedit
╰─$ cat planex
# Sets
@artix
@dev
@sway
@gui
@terminal
@pulse
@bluetooth
@misc
@zfs
# Packages
amd-ucode
amdgpu-fancontrol-git
asus-wmi-sensors-dkms-git
efibootmgr
piper
radeontop
refind
╭─kdb424@planex ~/.config/worldedit
╰─$ cat pulse
pulseaudio
pulseaudio-alsa
pulseeffects-legacy
```

## Suggestion
The example configuration doesn't actually remove packages, but mark them
as orphans. Make sure to clean your system occasionally with
```bash
worldedit --orphans
```

## Linux Distros

### Alpine
This is not recommended for Alpine. They have a way to manage a worldfile
already, and this tool's functions would conflict with it.
[Alpine world file](https://docs.alpinelinux.org/user-handbook/0.1a/Working/apk.html#_world) 

### Arch (and Arch-like distros)
Default commands are below. It will try to detect if `yay` is installed. Worldedit will
fall back to `sudo pacman` if `yay` is not detected.
```bash
export WORLDEDIT_INSTALL_COMMAND="sudo pacman -S --asexplicit"
export WORLDEDIT_REMOVE_COMMAND="sudo pacman -D --asdeps"
export WORLDEDIT_LIST_COMMAND="sudo pacman -Qqe"
export WORLDEDIT_ORPHANS_COMMAND="pacman -Qtdq | sudo pacman -Rns -"
```

### Debian/Ubuntu/Apt
Default commands are below. This relies on apt-mark to get a list of packages, as well as
marking them as orphans or dependencies of other programs.
```bash
export WORLDEDIT_INSTALL_COMMAND="sudo apt install"
export WORLDEDIT_REMOVE_COMMAND="sudo apt-mark auto"
export WORLDEDIT_LIST_COMMAND="sudo apt-mark showmanual | sort -u"
export WORLDEDIT_ORPHANS_COMMAND="sudo apt autoremove"
```

### Gentoo
This package is not needed on Gentoo. Portage provides all of these functions
and is what inspired this project. The world file is located at 
`/var/lib/portage/world`, and you can read about 
[sets here](https://wiki.gentoo.org/wiki//etc/portage/sets).

### Void
UNTESTED: FEEDBACK IS REQUESTED. ONLY FOR TESTING.
Default commands are below.
```bash
export WORLDEDIT_INSTALL_COMMAND="sudo xbps-install"
export WORLDEDIT_REMOVE_COMMAND="sudo xbps-pkgdb -m auto"
export WORLDEDIT_LIST_COMMAND="sudo xbps-query -m | sed 's/-[0-9].*//g"
export WORLDEDIT_ORPHANS_COMMAND="sudo xpbs-remove -o"
```
