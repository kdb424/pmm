##
# worldedit
#
# @file
# @version 0.3

SRC = *.nim
SRCDIR = src
BIN = worldedit
MAN = worldedit.1
PREFIX := /usr/local
DESTDIR :=

.PHONY: default
default: release

.PHONY: all
all: pretty release man docs

.PHONY: release
release:
	nimble build '--cc:clang -d:release --opt:size -d:strip' -y

.PHONY: static
static:
	nimble build '--cc:clang -d:release --passL:-static --opt:size -d:strip' -y

.PHONY: debug
debug:
	nimble build '--cc:clang'

.PHONY: clean
clean:
	rm -f ./${BIN}

.PHONY: run
run:
	./${BIN}

.PHONY: docs
docs:
	nimble doc ${SRCDIR}/${SRC}

.PHONY: pretty
pretty:
	nimpretty ${SRCDIR}/${SRC}

.PHONY: test
test:
	nimble test

.PHONY: install
install:
	install -Dm 755 ${MAN} $(DESTDIR)$(PREFIX)/man/${MAN}
	install -Dm 755 ${BIN} $(DESTDIR)$(PREFIX)/bin/${BIN}

.PHONY: man
man:
	pandoc worldedit.1.md -s -t man | gzip > worldedit.1

.PHONY: testman
testman: man
	cat worldedit.1 | man -l -

# end
