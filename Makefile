BIN_DEST=build/bin
LIB_DEST=build/lib

MKDIR=mkdir -p

build:
	@${MKDIR} ${BIN_DEST}
	@${MKDIR} ${LIB_DEST}
	@cp src/pm ${BIN_DEST}
	@cp src/projman -r ${LIB_DEST}

clean:
	rm -rf build/