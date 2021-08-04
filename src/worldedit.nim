import docopt
import distros
import envconfig
import os
import osproc
import sequtils
import strutils
import typetraits

let doc = """
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
"""
type
  Worldedit = object
    installCommand, listCommand, removeCommand, world: string
    diff, init, sync: bool

proc readWorldFile(input: string): seq[string] =
  let packageFile = read_file(input).split
  var packageList = @[""]

  for i in packageFile:
    if i.startsWith("@"): # is a set name
      let setList = readWorldFile(
        joinpath(input.parentDir, i.strip(chars = {'@'}))
      )

      packageList = concat(packageList, setList)
    elif i.startsWith("#"): # is a comment
      discard
    elif not i.isEmptyOrWhitespace: # is a package name
      packageList.insert(i)

  # filter out empty/whitespace, then dedupe on return
  packageList = filter(packageList, proc(
      x: string): bool = not x.isEmptyOrWhitespace)
  return deduplicate(packageList)

proc generate_package_list(listCommand: string): seq[string] =
  var package_list = @[""]

  if listCommand.isEmptyOrWhitespace:
    package_list = split(execProcess(listCommand))
  else:
    if detectOS(ArchLinux) or detectOS(Archbang) or detectOS(BlackArch):
      package_list = split(execProcess("pacman -Qqe"))
    elif detectOS(Debian) or detectOS(Ubuntu):
      package_list = split(execProcess("apt-mark showmanual | sort -u"))
    else: # Artix is missing currently. https://github.com/nim-lang/Nim/pull/18629
      package_list = split(execProcess("pacman -Qqe"))


  return package_list

proc installRemove(command: string, packages: seq[string]) =
  let fullCommand = command & " " & packages.join(sep = " ")
  discard execProcess(fullCommand)

proc listDiff(added: seq[string], removed: seq[string]) =
  echo ("Added: " & added.join(sep = " "))
  echo ("Removed: " & removed.join(sep = " "))

proc createWorldFile(worldFile: string, listCommand: string) =
  let world = generatePackageList(listCommand)
  # Create directory if it does not exist. No error if exists
  createDir(parentDir(worldFile))
  if not worldFile.fileExists:
    writeFile(worldFile, world.join(sep = "\n"))
  else:
    write(stdout, "Worldfile exists. Overwrite? (y/N) ")
    if readLine(stdin).toLowerAscii == "y":
      writeFile(worldFile, world.join(sep = "\n"))

when isMainModule:
  var config = getEnvConfig(Worldedit)

  let args = docopt(doc, version = "Renamer 0.1")
  if args["--worldfile"]: config.world = $args["--worldfile"]
  if args["--list-command"]: config.listCommand = $args["--list-command"]
  if args["--install-command"]: config.installCommand = $args["--install-command"]
  if args["--remove-command"]: config.removeCommand = $args["--remove-command"]
  if args["--sync"]: config.sync = parseBool($args["--sync"])
  if args["--diff"]: config.diff = parseBool($args["--diff"])
  if args["--init"]: config.init = parseBool($args["--init"])

  if config.world.isEmptyOrWhitespace:
    config.world = "/etc/worldedit/worldfile"
  else:
    config.world = config.world.expandTilde

  if config.init:
    createWorldFile(config.world, config.listCommand)
  else:
    let world = readWorldFile(config.world)

    let package_list = generate_package_list(config.installCommand)
    let removed = package_list.filterIt(it notin world)
    let added = world.filterIt(it notin package_list)

    if config.sync:
      installRemove(config.installCommand, added)
      installRemove(config.removeCommand, removed)
    elif config.diff:
      listDiff(added, removed)
