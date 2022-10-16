# pmm - Package manager manager

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT
)[![Linux](https://svgshare.com/i/Zhy.svg)](https://svgshare.com/i/Zhy.svg
)[![macOS](https://svgshare.com/i/ZjP.svg)](https://svgshare.com/i/ZjP.svg
)[![GitHub tag](https://img.shields.io/github/tag/kdb424/pmm.svg)](https://GitHub.com/kdb424/pmm/tags/
)<a href="https://ko-fi.com/kdb424"><img src="https://i.imgur.com/9T0bvqO.png" alt="kofibadge" align="right"/></a>

Emulating Gentoo's world files and [sets](https://wiki.gentoo.org/wiki//etc/portage/sets) for other package managers.

## Requirements

- The Nim ([Official website](https://nim-lang.org/)) programming language (Min version 1.4.0)
- Nimble ([Github](https://github.com/nim-lang/nimble)), the Nim's package manager

Hint: Install Nim with Choosenim ([Github](https://github.com/dom96/choosenim))

## Installation

### Arch Linux (AUR)

```bash
pacman -S --needed git base-devel
git clone https://aur.archlinux.org/pmm-git.git
cd pmm
makepkg -si
```

### Mac
```bash
brew tap kdb424/kdb424
brew install --HEAD kdb424/kdb424/pmm
```

### Directly with Nimble (with url)

```bash
# Install directly with Nimble (with url)
nimble install https://github.com/kdb424/pmm
```

### Manually with Nimble

```bash
# Clone repo
git clone https://github.com/kdb424/pmm

# go to folder
cd pmm

# Install (with Nimble)
nimble install -y
```

## Usage
```bash
Pmm.

Usage:
  pmm [options]

Options:
  -h, --help                         Show this screen.
  -v, --version                      Show version.
  --worldfile file                   Set the worldfile
  --init                             Initializes a worldfile if it does not exist
  --listCommand=<command>            List all packages command
  --installCommand=<command>         Package install command
  --removeCommand=<command>          Package remove command
  --orphansCommand=<command>         Orphans uninstall command
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
~/worldfile
```

### Overriding the worldfile location
```bash
export PMM_WORLD="~/.config/pmm/world"
```

### Example
```bash
╭─kdb424@planex ~/.config/pmm
╰─$ ls
amy    bluetooth  gui         laptop  openrc    planex  sway      wireless
artix  dev        guisupport  misc    pipewire  pulse   terminal  zfs

╭─kdb424@planex ~/.config/pmm
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
╭─kdb424@planex ~/.config/pmm
╰─$ cat pulse
pulseaudio
pulseaudio-alsa
pulseeffects-legacy
```

## Suggestion
The example configuration doesn't actually remove packages, but mark them
as orphans. Make sure to clean your system occasionally with
```bash
pmm --orphans
```

## Linux Distros

### Alpine
This is not recommended for Alpine. They have a way to manage a worldfile
already, and this tool's functions would conflict with it.
[Alpine world file](https://docs.alpinelinux.org/user-handbook/0.1a/Working/apk.html#_world) 

### Arch (and Arch-like distros)
Default commands are below. It will try to detect if `yay` is installed. Pmm will
fall back to `sudo pacman` if `yay` is not detected.
```bash
export PMM_INSTALL_COMMAND="sudo pacman -S --asexplicit"
export PMM_REMOVE_COMMAND="sudo pacman -D --asdeps"
export PMM_LIST_COMMAND="sudo pacman -Qqe"
export PMM_ORPHANS_COMMAND="pacman -Qtdq | sudo pacman -Rns -"
```

### Debian/Ubuntu/Apt
Default commands are below. This relies on apt-mark to get a list of packages, as well as
marking them as orphans or dependencies of other programs.
```bash
export PMM_INSTALL_COMMAND="sudo apt install"
export PMM_REMOVE_COMMAND="sudo apt-mark auto"
export PMM_LIST_COMMAND="sudo apt-mark showmanual | sort -u"
export PMM_ORPHANS_COMMAND="sudo apt autoremove"
```

### Fedora
Default commands are below. This relies on rpm to get a list of packages, and dnf to
mark them as orphans or dependencies of other programs.
```bash
export PMM_INSTALL_COMMAND="sudo dnf install"
export PMM_REMOVE_COMMAND="sudo dnf mark remove"
export PMM_LIST_COMMAND="rpm -qa | sort | sed -e 's/\([^.]*\).*/\1/' -e 's/\(.*\)-.*/\1/'"
export PMM_ORPHANS_COMMAND="sudo dnf autoremove"
```

### Gentoo
This package is not needed on Gentoo. Portage provides all of these functions
and is what inspired this project. The world file is located at 
`/var/lib/portage/world`, and you can read about 
[sets here](https://wiki.gentoo.org/wiki//etc/portage/sets).

### Void
Default commands are below.
```bash
export PMM_INSTALL_COMMAND="sudo xbps-install"
export PMM_REMOVE_COMMAND="sudo xbps-pkgdb -m auto"
export PMM_LIST_COMMAND="xbps-query -m | xargs -n1 xbps-uhelper getpkgname"
export PMM_ORPHANS_COMMAND="sudo xpbs-remove -o"
```

## Mac

### Brew
Brew uses it's own format for worldfiles. We support 
[Brewfiles](https://thoughtbot.com/blog/brewfile-a-gemfile-but-for-homebrew) directly. 
Default commands are below.
```bash
export PMM_INSTALL_COMMAND="brew install"
export PMM_REMOVE_COMMAND="brew remove"
export PMM_LIST_COMMAND="brew list"
export PMM_ORPHANS_COMMAND="brew bundle --force cleanup $PMM_WORLDFILE"
```
