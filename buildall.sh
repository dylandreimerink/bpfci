#!/bin/bash

# This bash script will all kernel versions and architectures
for version in $(ls config)
do
    ./buildkernel.sh all amd64-5.15.5
done