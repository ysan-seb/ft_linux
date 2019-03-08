# #!/bin/bash

# # vbox
# # debian.vdi 8Go  Stockage de taille dynamique
# # lfsDisk    20Go Stockage de taille fixe
# # debian-9.8.0-amd64-netinst.iso

# # Etapes 1: Prerequis
# ln -sf /bin/bash /bin/sh
# apt -y install binutils bison gawk gcc g++ make patch texinfo

# # Etapes 2: Creation de la partition
# (
#     echo "n"
#     echo "p"
#     echo "1"
#     echo
#     echo +20G

# ) | fdisk /dev/sdb
# mkfs -v -t ext4 /dev/sdb
# export LFS=/mnt/lfs
# mkdir -pv $LFS
# mount -v -t ext4 /dev/sdb $LFS

# # Etapes 3: Paquets et correctifs
# mkdir -v $LFS/sources
# chmod -v a+wt $LFS/sources
# wget http://www.linuxfromscratch.org/lfs/downloads/8.4/wget-list
# wget http://www.linuxfromscratch.org/lfs/downloads/8.4/md5sums
# wget --input-file=wget-list --continue --directory-prefix=$LFS/sources
# pushd $LFS/sources
# md5sum -c md5sums
# popd

# Etapes 4: Dernieres preparations
# mkdir -v $LFS/tools
# ln -sv $LFS/tools /
# groupadd lfs
# useradd -s /bin/bash -g lfs -m -k /dev/null lfs
# passwd lfs
# chown -v lfs $LFS/tools
# chown -v lfs $LFS/sources
# su - lfs
cat > ~/.bash_profile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF
cat > ~/.bashrc << "EOF"
set +h
umask 022
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/tools/bin:/bin:/usr/bin
export LFS LC_ALL LFS_TGT PATH
EOF
source ~/.bash_profile
export MAKEFLAGS='-j 2'

# Etapes 5: Construire un systeme temporaire