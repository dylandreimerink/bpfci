#!/bin/bash
set -e

BBVersion="busybox-1.34.1"

mkdir -p initrd
wget https://www.busybox.net/downloads/$BBVersion.tar.bz2 --progress=bar -nc || true
tar -xf $BBVersion.tar.bz2
cp .config $BBVersion/.config
cd $BBVersion
make -j$(expr $(nproc) - 2) || true
cd ../
dirs=(dev etc/init.d lib64 mnt opt proc run sbin sys tmp usr/bin usr/sbin var)
for dir in ${dirs[@]}
do
    mkdir -p initrd/$dir
done
ln -s usr/bin initrd/bin
cp initrd/init build/initrd/init
cp $BBVersion/busybox initrd/usr/bin
cd initrd
find . -print0 | cpio --null --create --verbose --format=newc | gzip --best > ../initrd.gz
cd ../
sha256sum initrd.gz | awk '{ print $1 }' > initrd.gz.sha256