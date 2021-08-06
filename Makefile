##
# worldedit
#
# @file
# @version 0.1

SRC = *.nim
SRCDIR = src
BIN = worldedit
PREFIX := /usr/local
DESTDIR :=

.PHONY: default
default: release

.PHONY: release
release:
	nimble build '--cc:clang -d:release'

.PHONY: debug
debug:
	nimble build '--cc:clang'

.PHONY: small
small:
	nimble build '--cc:gcc -d:danger -d:strip --opt:size -d:release --passC:-flto --passL:-flto'

.PHONY: clean
clean:
	rm -f ./${BIN}

.PHONY: run
run:
	./${BIN}

.PHONY: docs
docs:
	nim doc ${SRCDIR}/${SRC}

.PHONY: pretty
pretty:
	nimpretty ${SRCDIR}/${SRC}

.PHONY: test
test:
	nimble test

.PHONY: install
install:
	install -Dm755 ${BIN} $(DESTDIR)$(PREFIX)/bin/${BIN}

# end
