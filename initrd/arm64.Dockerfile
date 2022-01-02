FROM gcc:11.2 AS builder
ARG BBVersion="busybox-1.34.1"
COPY .config .config
COPY buildinitrd.sh buildinitrd.sh
COPY initrd initrd
RUN dpkg --add-architecture arm64 && \
    apt update && \
    apt install -y wget tar cpio && \
    apt install --install-recommends -y gcc-10-aarch64-linux-gnu && \
    ln -s /usr/bin/aarch64-linux-gnu-gcc-10 /usr/bin/aarch64-linux-gnu-gcc && \
    mkdir -p initrd && \
    wget https://www.busybox.net/downloads/$BBVersion.tar.bz2 --progress=bar -nc && \
    tar -xf $BBVersion.tar.bz2  && \
    cp .config $BBVersion/.config  && \
    cd $BBVersion && \
    make -j$(expr $(nproc) - 2) CROSS_COMPILE=/usr/bin/aarch64-linux-gnu- && \
    cd ../

RUN for dir in dev etc/init.d lib64 mnt opt proc run sbin sys tmp usr/bin usr/sbin var;do mkdir -p /initrd/$dir; done

RUN ln -s /usr/bin initrd/bin && \
    cp $BBVersion/busybox initrd/usr/bin/busybox && \
    cd initrd && \
    find . -print0 | cpio --null --create --verbose --format=newc | gzip --best > ../initrd.gz

FROM scratch
COPY --from=builder /initrd.gz /initrd.gz