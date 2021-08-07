% worldedit(1)

# Name
worldedit - Emulating Gentoo's world files and sets for other package managers.

# Synopsis
worldedit [options]

# DESCRIPTION
Recreates Gentoo's world files for other distros. It hooks the native package manager
to set which packages are explicitly installed, and leaves the dependency resolving up
to the package manager. Any package manager that can create a list of packages installed
by package name, newline separated, and keep track of packages explicitly installed, as
opposed to dependencies should be compatible with this application.

# OPTIONS
**-h**, **--help**
: Show the help screen.

**-v**, **--version**
: Show version.

**--worldfile**=file
: Set the worldfile

**--init**
: Initializes a worldfile if it does not exist

**--list-command**
: List all packages command

**--install-command**
: Package install command

**--remove-command**
: Package remove command

**--orphans-command**
: Orphans uninstall command

**--sync**
: Add/remove packages to match the worldfile

**--diff**
: Lists the packages that are added/removed

**--install**=<package>
: Installs a package and appends to the worldfile

**--remove**=<package>
: Removes a package and deletes the entry in the worldfile

**--bash**
: Outputs commands that can be piped into bash

**--orphans**
: Removes things marked as orphans from your system

# EXIT STATUS
**0**
: Success

**1**
: Failure

# BUGS
https://github.com/kdb424/worldedit/issues

# COPYRIGHT
MIT License Copyright (c) 2021 Kyle Brown

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is furnished
to do so, subject to the following conditions:

The above copyright notice and this permission notice (including the next
paragraph) shall be included in all copies or substantial portions of the
Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
