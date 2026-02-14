PREFIX ?= /usr/local

build:
	swift build -c release --arch arm64 --arch x86_64

install: build
	install -d $(PREFIX)/bin
	install .build/apple/Products/Release/pbrich $(PREFIX)/bin

uninstall:
	rm -f $(PREFIX)/bin/pbrich

clean:
	swift package clean

.PHONY: build install uninstall clean
