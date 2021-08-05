##
# worldedit
#
# @file
# @version 0.1

SRC = *.nim
SRCDIR = src
BIN = worldedit

release:
	nimble build '--cc:clang -d:release'

debug:
	nimble build '--cc:clang'

small:
	nimble build '--cc:gcc -d:danger -d:strip --opt:size -d:release --passC:-flto --passL:-flto'

clean:
	rm -f ./${BIN}

run:
	./${BIN}

docs:
	nim doc ${SRCDIR}/${SRC}

pretty:
	nimpretty ${SRCDIR}/${SRC}

test:
	nimble test

# end
