#!/bin/bash
set -e

ProgName=$(basename $0)
subcommand=$1
version=$2

sub_help(){
    echo "Usage: $ProgName <subcommand> <initrd-version>"
    echo "Subcommands:"
    echo "    all       compiles and saves the initrd"
    echo "    build     copies initrd config file, install dependencies and builds the initrd"
    echo "    save      saves the bzImage of the generated initrd in the dist folder"
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
    [ -z $version ] && die "error: <initrd-version> is a required argument"

    # Any cpu initrd version for which we have a config directory is supported
    if [[ -e initrd/$version.Dockerfile ]]; then
        echo "=== initrd version supported ==="
    else
        echo "Unsupported CPU initrd version, pick one from:"
        for dir in $(cd initrd && ls *.Dockerfile)
        do
            echo "- $(basename $dir .Dockerfile)"
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
    docker build initrd -f initrd/$version.Dockerfile -t initrd-$version:latest
}

save(){
    mkdir -p dist
    id=$(docker create --rm initrd-$version:latest placeholder)
    docker cp $id:/initrd.gz dist/$version-initrd.gz
    docker rm $id
    sha256sum dist/$version-initrd.gz | awk '{ print $1 }' > dist/$version-initrd.gz.sha256
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