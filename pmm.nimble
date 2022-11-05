# Package

version       = "0.5.1"
author        = "Kyle Brown"
description   = "Gentoo's world file, but everywhere."
license       = "MIT"
srcDir        = "src"
bin           = @["pmm"]


# Dependencies

requires "nim >= 1.6.8"
requires "docopt >= 0.7.0"
requires "envconfig >= 1.1.0"

task buildRelease, "Builds the release version":
  exec "nimble -d:release build"
