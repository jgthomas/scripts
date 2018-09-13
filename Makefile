all: clean
	makepkg

clean:
	rm -rf src/
	rm -rf pkg/
	rm -rf *pkg.tar.xz
