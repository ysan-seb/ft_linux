#!/bin/bash

# debian-9.8.0-amd64-netinst.iso

# Etapes 1

ln -sf /bin/bash /bin/sh
apt -y install binutils bison gawk gcc g++ make patch texinfo

# Crée la partition

(
    echo "n"
    echo "p"
    echo "1"
    echo
    echo +20G

) | fdisk /dev/sdb

mkfs -v -t ext4 /dev/sdb
export LFS=/mnt/lfs
mkdir -pv $LFS
mount -v -t ext4 /dev/sdb $LFS

# Paquets et correctifs
