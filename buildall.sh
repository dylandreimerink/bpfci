#!/bin/bash

# This bash script will all kernel versions and architectures
for version in $(ls config/linux)
do
    ./buildkernel.sh all $version
done