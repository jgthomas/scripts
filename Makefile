all: clean
	makepkg --config /etc/makepkg-custom.conf

clean:
	rm -rf src/
	rm -rf pkg/
	rm -rf *pkg.tar.xz
