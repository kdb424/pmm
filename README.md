# worldedit
Emulating Gentoo's world files and sets for other package managers.
[Gentoo sets](https://wiki.gentoo.org/wiki//etc/portage/sets)

## Requirements

- The Nim ([Official website](https://nim-lang.org/)) programming language (Min version 1.4.0)
- Nimble ([Github](https://github.com/nim-lang/nimble)), the Nim's package manager

Hint: Install Nim with Choosenim ([Github](https://github.com/dom96/choosenim))

## Installation
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
  -h, --help                   Show this screen.
  -v, --version                Show version.
  --worldfile file             Worldfile to use
  --init                       Initializes a worldfile if none are provided
  --list-command=<command>     List all packages command
  --install-command=<command>  Package install command
  --remove-command=<command>   Package remove command
  --sync                       Add/remove packages to match the worldfile
  --diff                       Lists the packages that are added/removed
  --install=<package>          Installs a package and appends to the worldfile
  --remove=<package>           Removes a package and deletes the entry in the worldfile
  --bash                       Outputs commands that can be piped into bash
```

## Configuration
There are no config files. All configuration is done through environment variables, or manually by flags.

```bash
export WORLDEDIT_INSTALL_COMMAND="yay -S --noconfirm"
export WORLDEDIT_REMOVE_COMMAND="sudo pacman -D --asdeps"
export WORLDEDIT_LIST_COMMAND="yay -Qqe"
export WORLDEDIT_WORLD="~/.config/worldedit/$(hostname)"
```

## Worldfile
A worldfile is a list if installed packages, that are newline seperated.
Lines starting with @ are used to refer to a set file. Sets can contain
more packages, as well as other sets. Comments are allowed only at the
beginning of the line, and are defined with # at the start of the line.
Spaces in package names or sets are not supported.

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