
all: clean
	export PKGDEST=$(CURDIR) && makepkg
	unset PKGDEST

clean:
	rm -rf src/
	rm -rf pkg/
	rm -rf *.pkg.tar.xz
