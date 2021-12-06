# BPFCI

This repository contains script to build a number of different kernel images and a generic initrd. Together the generated bzImages and initrd can be used for unit testing in a VM using QEMU direct linux boot. Main purpose of this repository is to hold build scripts and pre-compiled kernel images to be used by the testing framework of [gobpfld](https://github.com/dylandreimerink/gobpfld).

## .config creation process

This is the process for getting a working(but bloated) kernel image compiled which meets our requirements.

1. make defconfig ARCH={arch}
2. Copy .config to config/{cpu+arch}/.defconfig
    The idea behind this is that we can diff the .config and .defconfig to see what we changed.
3. Modify .config (see settings chapter)
4. Run `make oldconfig` and set any missing values
5. Remove the section above `General setup` which is local env specific
6. Copy .config to config/{cpu+arch}/.config

## settings

This is a list of important settings which should be corrected if they are not already set in the generated default config.

```properties
# Add custom kernel version suffix
CONFIG_LOCALVERSION="bpfci"

# Explicitly enable all BPF flags
CONFIG_BPF=y
CONFIG_HAVE_EBPF_JIT=y
CONFIG_ARCH_WANT_DEFAULT_BPF_JIT=y
CONFIG_BPF_SYSCALL=y
CONFIG_BPF_JIT=y
CONFIG_BPF_JIT_ALWAYS_ON=y
CONFIG_BPF_JIT_DEFAULT_ON=y
CONFIG_USERMODE_DRIVER=y
CONFIG_BPF_PRELOAD=y
CONFIG_BPF_PRELOAD_UMD=y
CONFIG_BPF_LSM=y
CONFIG_CGROUP_BPF=y
CONFIG_IPV6_SEG6_BPF=y
CONFIG_NET_CLS_BPF=y
CONFIG_NET_ACT_BPF=y
CONFIG_BPF_STREAM_PARSER=y
CONFIG_LWTUNNEL_BPF=y
CONFIG_BPF_LIRC_MODE2=y
CONFIG_BPF_EVENTS=y

# Enable ethernet and compile E1000 support (used when emulating a NIC in qemu)
CONFIG_ETHERNET=y
CONFIG_NET_VENDOR_INTEL=y
CONFIG_E100=y
CONFIG_E1000=y
CONFIG_E1000E=y
CONFIG_E1000E_HWTS=y
```