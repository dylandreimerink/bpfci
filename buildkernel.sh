#!/bin/bash
set -e

ProgName=$(basename $0)
subcommand=$1
kernelVersion=$2

sub_help(){
    echo "Usage: $ProgName <subcommand> <kernel-version>"
    echo "Subcommands:"
    echo "    all       cleans, downloads, compiles and saves the kernel"
    echo "    clean     remove the build directory"
    echo "    download  downloads and unpacks the kernel"
    echo "    build     copies kernel config file, install dependencies and builds the kernel"
    echo "    save      saves the bzImage of the generated kernel in the dist folder"
    echo ""
    echo "For help with each subcommand run:"
    echo "$ProgName <subcommand> -h|--help"
    echo ""
}

# Public "all" command
sub_all(){
    check
    clean
    download
    build
    save
}

# Public "clean" command
sub_clean(){
    check
    clean
}

# Public "download" command
sub_download(){
    check
    download
}

# Public "download" command
sub_build() {
    check
    build
}

# Public "build" command
sub_save() {
    check
    save
}

die () {
    echo >&2 "$@"
    sub_help
    exit 1
}

# Check args and environment
check(){
    # Input checking
    [ -z $kernelVersion ] && die "error: <kernel-version> is a required argument"

    # Any cpu arch/kernel version for which we have a config directory is supported
    if [[ -d config/linux/$kernelVersion ]]; then
        echo "=== Kernel version supported ==="
    else
        echo "Unsupported CPU arch/kernel version combo, pick one from:"
        for dir in $(ls config/linux)
        do
            echo "- $dir"
        done
        exit 1
    fi

    # Check tools
    assertCommand wget
    assertCommand tar
    assertCommand make
}

assertCommand() {
    if ! command -v $1 &> /dev/null
    then
        echo "missing '$1', please install it"
        exit 1
    fi
}

clean(){
    rm -f build/$kernelVersion.tar.xz
    rm -Rf build/${kernelVersion}
}

download(){   
    echo "=== downloading kernel tarball ==="

    # Download kernel tarball, only if we don't have the file already
    wget $(cat config/linux/$kernelVersion/url) --progress=bar -nc -O build/$kernelVersion.tar.xz || true

    echo "=== extracting tarball ==="
    tar -xf build/$kernelVersion.tar.xz -C build
    mv build/linux-$(cat config/linux/$kernelVersion/version) build/$kernelVersion
}

build(){
    cp config/linux/$kernelVersion/.config build/$kernelVersion/.config
    cd build/$kernelVersion/

    # Build with all available cores, minus 2 for other tasks
    make -j$(expr $(nproc) - 2) || true

    cd ../../
}

save(){
    mkdir -p dist
    cp build/$kernelVersion/arch/x86/boot/bzImage dist/$kernelVersion-bzImage
    sha256sum dist/$kernelVersion-bzImage | awk '{ print $1 }' > dist/$kernelVersion-bzImage.sha256
}

case $subcommand in
    "" | "-h" | "--help")
        sub_help
        ;;
    *)
        shift
        sub_${subcommand} $@
        if [ $? = 127 ]; then
            echo "Error: '$subcommand' is not a known subcommand." >&2
            echo "       Run '$ProgName --help' for a list of known subcommands." >&2
            exit 1
        fi
        ;;
esac