import commands
import detect
import docopt
import envconfig
import os
import sequtils
import strutils
import typetraits

let doc = """
pmm - Emulating Gentoo's world files and sets for other package managers.

Usage:
  pmm [options]

Options:
  -h, --help                         Show this screen.
  -v, --version                      Show version.
  --worldfile file                   Sets the worldfile
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
"""
type
  Pmm = object
    install, installCommand, listCommand, orphansCommand, remove, removeCommand, world: string
    bash, diff, init, orphans, sync: bool


when isMainModule:
  var config = getEnvConfig(Pmm)

  let args = docopt(doc, version = "Pmm 0.4.1")
  if args["--worldfile"]: config.world = $args["--worldfile"]
  if args["--list-command"]: config.listCommand = $args["--list-command"]
  if args["--install-command"]: config.installCommand = $args["--install-command"]
  if args["--remove-command"]: config.removeCommand = $args["--remove-command"]
  if args["--orphans-command"]: config.orphansCommand = $args["--orphans-command"]
  if args["--sync"]: config.sync = parseBool($args["--sync"])
  if args["--diff"]: config.diff = parseBool($args["--diff"])
  if args["--init"]: config.init = parseBool($args["--init"])
  if args["--install"]: config.install = $args["--install"]
  if args["--remove"]: config.remove = $args["--remove"]
  if args["--bash"]: config.bash = parseBool($args["--bash"])
  if args["--orphans"]: config.orphans = parseBool($args["--orphans"])

  if config.world.isEmptyOrWhitespace:
    config.world = "~/worldfile"
  else:
    config.world = config.world.expandTilde

  if config.listCommand.isEmptyOrWhitespace:
    config.listCommand = detect.listCommand()
  if config.installCommand.isEmptyOrWhitespace:
    config.installCommand = detect.installCommand()
  if config.removeCommand.isEmptyOrWhitespace:
    config.removeCommand = detect.removeCommand()
  if config.orphansCommand.isEmptyOrWhitespace:
    config.orphansCommand = detect.orphansCommand()

  if config.init:
    createWorldFile(config.world, config.listCommand)
  else:
    var world = readWorldFile(config.world, config.listCommand)
    var package_list = generatePackageList(config.listCommand, config.world)
    let added = world.filterIt(it notin package_list).clean
    let removed = package_list.filterIt(it notin world).clean

    if config.sync:
      sync(config.installCommand, config.removeCommand, added, removed, config.world)
    elif config.diff:
      listDiff(added, removed)
    elif not config.install.isEmptyOrWhitespace:
      install(config.installCommand, config.install, config.world)
    elif not config.remove.isEmptyOrWhitespace:
      remove(config.removeCommand, config.remove, config.world)
    elif config.bash:
      bash(config.installCommand, config.removeCommand, added, removed)
    elif config.orphans:
      removeOrphans(config.orphansCommand, config.world)
