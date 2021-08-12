import algorithm
import detect
import docopt
import envconfig
import os
import osproc
import sequtils
import strformat
import strutils
import typetraits

let doc = """
worldedit - Emulating Gentoo's world files and sets for other package managers.

Usage:
  worldedit [options]

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
  Worldedit = object
    install, installCommand, listCommand, orphansCommand, remove, removeCommand, world: string
    bash, diff, init, orphans, sync: bool

proc clean(input: seq[string]): seq[string] =
  return filter(input, proc(x: string): bool = not x.isEmptyOrWhitespace).deduplicate

proc readWorldFile(input: string): seq[string] =
  # Recursively reads in worldfiles, and sets
  try:
    let packageFile = read_file(input).split
    var packageList: seq[string]

    for i in packageFile:
      if i.startsWith("@"): # is a set name
        try:
          let setList = readWorldFile(
            joinpath(input.parentDir, i.strip(chars = {'@'}))
          )
          packageList = concat(packageList, setList)
        except:
          fmt"Could not read {i} file.".echo
          quit(QuitFailure)

      elif i.startsWith("#"): # is a comment
        discard
      elif not i.isEmptyOrWhitespace: # is a package name
        packageList.insert(i)

    # filter out empty/whitespace, then dedupe on return
    packageList = packageList.clean
    return packageList.sorted
  except:
    fmt"Could not read {input} file.".echo
    quit(QuitFailure)


proc generatePackageList(listCommand: string): seq[string] =
  # Generates a newline seperated list of packages, and returns it
  # as a sorted seq[string]
  return split(execProcess(listCommand))

proc removeOrphans(command: string) =
  # Installs or removes a list of packages
  let pid = startProcess(command, options = {poEchoCmd, poInteractive,
        poParentStreams, poUsePath, poEvalCommand})
  pid.waitForExit.echo
  pid.close

proc installRemove(command: string, packages: seq[string]) =
  # Installs or removes a list of packages
  if packages.clean.len >= 1:
    let fullCommand = command & " " & packages.join(sep = " ")
    let pid = startProcess(fullCommand, options = {poEchoCmd, poInteractive,
        poParentStreams, poUsePath, poEvalCommand})
    discard pid.waitForExit
    pid.close

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

  let args = docopt(doc, version = "Worldedit 0.3.3")
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
    config.world = "/etc/worldedit/worldfile"
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
    fmt"Creating world file {config.world}".echo
    createWorldFile(config.world, config.listCommand)
  else:
    var world = readWorldFile(config.world)

    let package_list = generatePackageList(config.listCommand)
    let removed = package_list.filterIt(it notin world).clean
    let added = world.filterIt(it notin package_list).clean

    if config.sync:
      installRemove(config.removeCommand, removed)
      installRemove(config.installCommand, added)
    elif config.diff:
      listDiff(added, removed)
    elif not config.install.isEmptyOrWhitespace:
      # Installs package, and adds it to worldfile
      installRemove(config.installCommand, @[config.install])
      var worldNoRecurse = config.world.read_file.split
      let newWorld = (worldNoRecurse & config.install.split).clean.join(sep = "\n")
      writeFile(config.world, newWorld)
    elif not config.remove.isEmptyOrWhitespace:
      var worldNoRecurse = config.world.read_file.split
      let toDelete = find(worldNoRecurse, config.remove)
      if toDelete != -1:
        delete(worldNoRecurse, toDelete)
        let newWorld = worldNoRecurse.clean.join(sep = "\n")
        writeFile(config.world, newWorld)
        installRemove(config.removeCommand, @[config.remove])
      else:
        fmt"Could not find {config.remove} in worldfile.".echo
    elif config.bash:
      let ic = config.installCommand & " " & added.join(sep = " ")
      let rc = config.removeCommand & " " & removed.join(sep = " ")
      if removed.len > 0: stdout.write rc
      if added.len > 0 and removed.len > 0: stdout.write " && "
      if added.len > 0: stdout.write ic
      stdout.flushFile
    elif config.orphans:
      removeOrphans(config.orphansCommand)
