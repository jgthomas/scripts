all: clean
	makepkg

clean:
	rm -rf src/
	rm -rf pkg/
	rm *pkg.tar.xz
