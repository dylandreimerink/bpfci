#!/bin/bash
set -e

ProgName=$(basename $0)
subcommand=$1
kernelVersion=$2

sub_help(){
    echo "Usage: $ProgName <subcommand> <kernel-version>"
    echo "Subcommands:"
    echo "    all       compiles and saves the kernel"
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
    build
    save
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
    if [[ -d linux/$kernelVersion ]]; then
        echo "=== Kernel version supported ==="
    else
        echo "Unsupported CPU arch/kernel version combo, pick one from:"
        for dir in $(ls linux)
        do
            echo "- $dir"
        done
        exit 1
    fi

    # Check tools
    assertCommand docker
}

assertCommand() {
    if ! command -v $1 &> /dev/null
    then
        echo "missing '$1', please install it"
        exit 1
    fi
}

build(){
    docker build linux/$kernelVersion -f linux/$kernelVersion/Dockerfile -t linux-$kernelVersion:latest
}

save(){
    mkdir -p dist
    id=$(docker create --rm linux-$kernelVersion:latest placeholder)
    docker cp $id:/bzImage dist/$kernelVersion-bzImage
    docker rm $id
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