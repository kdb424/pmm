import algorithm
import os
import osproc
import sequtils
import strformat
import strutils
import typetraits


proc brewBundleDump(): string  {.raises: [].} =
  try:
    const cmd = fmt"brew bundle dump -q --force --file=/tmp/pmm"
    discard execProcess(cmd)
    return "/tmp/pmm"
  except: return ""

proc brewBundleList(world: string): seq[string] {.raises: [].} =
  try:
    let cmd = fmt"brew bundle list -q --file={world}"
    return split(execProcess(cmd))
  except: return @[""]

proc generatePackageList*(listCommand: string, worldFile: string): seq[string] {.raises: [].} =
  # Generates a newline seperated list of packages, and returns it
  # as a sorted seq[string]
  try:
    if "brew" in listCommand:
      return brewBundleList(brewBundleDump())
    else: return split(execProcess(listCommand))
  except: return @[""]

proc clean*(input: seq[string]): seq[string] {.raises: [].} =
  return filter(input, proc(x: string): bool = not x.isEmptyOrWhitespace).deduplicate

proc readWorldFile*(input: string, listCommand: string): seq[string] {.raises: [ValueError].} =
  try:
    # Checks for a brewfile, and creates a world file proper if it is one
    var packageFile: seq[string]
    if "brew" in listCommand:
      return input.brewBundleList
    else:
      packageFile = read_file(input).split

    var packageList: seq[string]

    for i in packageFile:
      if i.startsWith("@"): # is a set name
        try:
          let setList = readWorldFile(
            joinpath(input.parentDir, i.strip(chars = {'@'})), listCommand
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


proc removeOrphans*(command: string, worldFile: string) {.raises: [].} =
  var cmd: string
  if "brew" in command: cmd = command & " --file=" & worldFile
  else: cmd = command

  try:
    let pid = startProcess(cmd, options = {poEchoCmd, poInteractive,
            poParentStreams, poUsePath, poEvalCommand})
    pid.waitForExit.echo
    pid.close
  except:
    "Failed to remove orphans".echo


proc installRemove*(command: string, packages: seq[string]) {.raises: [].} =
  # Installs or removes a list of packages
  try:
    if packages.clean.len >= 1:
      let fullCommand = command & " " & packages.join(sep = " ")
      let pid = startProcess(fullCommand, options = {poEchoCmd, poInteractive,
          poParentStreams, poUsePath, poEvalCommand})
      discard pid.waitForExit
      pid.close
  except:
    "Failed to install or remove packages".echo

proc listDiff*(added: seq[string], removed: seq[string]) {.raises: [].} =
  echo ("Added: " & added.join(sep = " "))
  echo ("Removed: " & removed.join(sep = " "))

proc createWorldFile*(worldFile: string, listCommand: string) {.raises: [IOError].} =
  # Mac
  if "brew" in listCommand:
    const prefix = "brew bundle dump --force --file="
    if worldFile.fileExists:
      write(stdout, "Worldfile exists. Overwrite? (y/N) ")
      if readLine(stdin).toLowerAscii != "y": return

    try:
      let pid = startProcess(prefix & worldFile, options = {poEchoCmd,
          poInteractive, poParentStreams, poUsePath, poEvalCommand})
      discard pid.waitForExit
      pid.close
    except: "Unable to create a world file".echo

  else: # Linux
    let world = generatePackageList(listCommand, worldfile)
    # Create directory if it does not exist. No error if exists
    try:
      createDir(parentDir(worldFile))
      if worldFile.fileExists:
        write(stdout, "Worldfile exists. Overwrite? (y/N) ")
        if readLine(stdin).toLowerAscii != "y": return

      writeFile(worldFile, world.join(sep = "\n"))
    except: "Unable to create a world file".echo

proc sync*(installCommand: string, removeCommand: string, added: seq[string],
    removed: seq[string], worldFile: string) {.raises: [].} =
  if "brew" in installCommand:
    # sync with brew
    try:
      let installCmd = fmt"brew bundle --force install -q --file={worldFile}"
      discard execProcess(installCmd)
      let removeCmd = fmt"brew bundle --force cleanup -q --file={worldFile}"
      discard execProcess(removeCmd)
    except: "Unable to sync a world file".echo
  else:
    installRemove(installCommand, added)
    installRemove(removeCommand, removed)

proc install*(installCommand: string, pkglist: string, worldFile: string) {.raises: [].} =
  let packages = @[pkglist]
  # Installs package, and adds it to worldfile
  installRemove(installCommand, packages)
  try:
    var worldNoRecurse = worldFile.read_file.split
    let newWorld = (worldNoRecurse & installCommand.split).clean.join(sep = "\n")
    writeFile(worldFile, newWorld)
  except IOError: "Unable to install".echo

proc remove*(removeCommand: string, packages: string, worldFile: string) {.raises: [ValueError].} =
  try:
    var worldNoRecurse = worldFile.read_file.split
    let toDelete = find(worldNoRecurse, packages)
    if toDelete != -1:
      delete(worldNoRecurse, toDelete)
      let newWorld = worldNoRecurse.clean.join(sep = "\n")
      writeFile(worldFile, newWorld)
      installRemove(removeCommand, @[packages])
    else: fmt"Could not find {packages} in worldfile.".echo
  except IOError: "Unable to remove".echo

proc bash*(installCommand: string, removeCommand: string, added: seq[string],
    removed: seq[string]) {.raises: [].} =
  let ic = installCommand & " " & added.join(sep = " ")
  let rc = removeCommand & " " & removed.join(sep = " ")
  try:
    if removed.len > 0: stdout.write rc
    if added.len > 0 and removed.len > 0: stdout.write " && "
    if added.len > 0: stdout.write ic
    stdout.flushFile
  except IOError: "Unable to output to bash".echo
