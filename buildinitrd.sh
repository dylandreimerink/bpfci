#!/bin/bash
set -e

BBVersion="busybox-1.34.1"

echo "=== cleaning build/initrd ==="
rm -Rf build/initrd
mkdir -p build/initrd

echo "=== downloading busybox tarball ==="
wget https://www.busybox.net/downloads/$BBVersion.tar.bz2 --progress=bar -nc -O build/$BBVersion.tar.bz2 || true

echo "=== extracting tarball ==="
rm -Rf build/$BBVersion
tar -xf build/$BBVersion.tar.bz2 -C build

echo "=== compiling busybox ==="
cp config/busybox/.config build/$BBVersion/.config
cd build/$BBVersion
make -j$(expr $(nproc) - 2) || true
cd ../../

echo "=== making directories ==="
dirs=(dev etc/init.d lib64 mnt opt proc run sbin sys tmp usr/bin usr/sbin var)
for dir in ${dirs[@]}
do
    mkdir -p build/initrd/$dir
done

echo "=== making symlinks ==="
ln -s usr/bin build/initrd/bin

echo "=== copying files ==="
cp initrd/etc/init.d/rcS build/initrd/etc/init.d/rcS
cp initrd/init build/initrd/init

echo "=== copying busybox ==="
cp build/$BBVersion/busybox build/initrd/usr/bin

echo "=== archiving initrd ==="
cd build/initrd
find . -print0 | cpio --null --create --verbose --format=newc | gzip --best > ../../dist/initrd.gz
cd ../..