FROM gcc:11.2 AS builder
ARG version=4.14.260
COPY .config .config
RUN apt update && \
    apt install -y wget tar && \
    apt install -y \
        flex \
        bison \
        libelf-dev \
        bc \
    && \
    wget https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-$version.tar.xz && \
    tar -xf linux-$version.tar.xz && \
    rm linux-$version.tar.xz && \
    cp .config linux-$version/.config && \
    cd linux-$version && \
    make -j$(expr $(nproc) - 2) && \
    cp arch/x86/boot/bzImage /bzImage && \
    cd / && \
    rm -Rf linux-$version

FROM scratch
COPY --from=builder /bzImage /bzImage