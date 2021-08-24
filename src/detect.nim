import osproc

proc detectCommand(command: string): bool =
  let pid = startProcess(command, options = {poUsePath, poEvalCommand})
  discard pid.waitForExit
  if pid.peekExitCode == 0:
    pid.close
    return true
  else:
    pid.close
    return false

proc listCommand*(): string =
  if detectCommand("which yay"):
    return "yay -Qqe"
  elif detectCommand("which pacman"):
    return "pacman -Qqe"
  elif detectCommand("which apt-mark"):
    return "apt-mark showmanual | sort -u"
  elif detectCommand("which xbps-query"):
    return "xbps-query -m | sed 's/-[0-9].*//g'"
  elif detectCommand("which rpm"):
    return """rpm -qa | sort | sed -e 's/\([^.]*\).*/\1/' -e 's/\(.*\)-.*/\1/'"""
  elif detectCommand("which brew"):
    return "brew"
  else:
    "Could not find a list command".echo
    quit(QuitFailure)

proc installCommand*(): string =
  if detectCommand("which yay"):
    return "yay -S --asexplicit"
  elif detectCommand("which pacman"):
    return "sudo pacman -S --asexplicit"
  elif detectCommand("which brew"):
    return "brew install"
  elif detectCommand("which xbps-install"):
    return "sudo xbps-install"
  elif detectCommand("which dnf"):
    return "sudo dnf install"
  elif detectCommand("which apt"):
    return "sudo apt install"
  else:
    "Could not find an install command".echo
    quit(QuitFailure)

proc removeCommand*(): string =
  if detectCommand("which yay"):
    return "yay -D --asdeps"
  elif detectCommand("which pacman"):
    return "sudo pacman -D --asdeps"
  elif detectCommand("which apt-mark"):
    return "sudo apt-mark auto"
  elif detectCommand("which dnf"):
    return "sudo dnf mark remove"
  elif detectCommand("which brew"):
    return "brew remove"
  else:
    "Could not find a remove command".echo
    quit(QuitFailure)

proc orphansCommand*(): string =
  if detectCommand("which yay"):
    return "yay -Qtdq | yay -Rns -"
  elif detectCommand("which pacman"):
    return "pacman -Qtdq | sudo pacman -Rns -"
  elif detectCommand("which brew"):
    return "brew bundle --force cleanup"
  elif detectCommand("which xbps-remove"):
    return "sudo xbps-remove -o"
  elif detectCommand("which dnf"):
    return "sudo dnf autoremove"
  elif detectCommand("which apt"):
    return "sudo apt autoremove"
  else:
    "Could not find an orphans command".echo
    quit(QuitFailure)
