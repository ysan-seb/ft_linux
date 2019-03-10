#!/bin/bash

# debian-9.8.0-amd64-netinst.iso
# Username : lfs
# Password : lfs
# /dev/sda  8Go
# /dev/sdb  15Go

# Host System Requirements

ln -sf /bin/bash /bin/sh
apt -y install binutils bison gawk gcc g++ make patch texinfo

# Creating a New Partition
(
    echo "n"
    echo "p"
    echo "1"
    echo
    echo +100M

    echo "n"
    echo "p"
    echo "2"
    echo
    echo +2G

    echo "n"
    echo "p"
    echo "3"
    echo
    echo

    echo "w"
) | fdisk /dev/sdb

# Creating a File System on the Partition

mkfs -v -t ext4 /dev/sdb1
mkswap /dev/sdb2
mkfs -v -t ext4 /dev/sdb3

# Setting The $LFS Variable

export LFS=/mnt/lfs

# Mounting the New Partition

mkdir -pv $LFS
mount -v -t ext4 /dev/sdb3 $LFS
/sbin/swapon -v /dev/sdb2
mkdir -pv $LFS/boot
mount -v -t ext4 /dev/sdb1 $LFS/boot

# Packages and Patches

mkdir -v $LFS/sources
chmod -v a+wt $LFS/sources
wget http://www.linuxfromscratch.org/lfs/downloads/8.4/wget-list
wget http://www.linuxfromscratch.org/lfs/downloads/8.4/md5sums --directory-prefix=$LFS/sources
wget --input-file=wget-list --continue --directory-prefix=$LFS/sources
cd $LFS/sources
pushd $LFS/sources
md5sum -c md5sums
popd

# Creating the $LFS/tools Directory

mkdir -v $LFS/tools
ln -sv $LFS/tools /

# Adding the LFS User

useradd -s /bin/bash -g lfs -m -k /dev/null lfs
chown -v lfs $LFS/tools
chown -v lfs $LFS/sources

cat > /home/lfs << "END_OF_SCRIPT"
#!/bin/bash

# Setting Up the Environment

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

# About SBUs

export MAKEFLAGS="-j 2"

# Installation of Cross Binutils

tar xvf binutils-2.32.tar.xz
cd binutils-2.32/
mkdir -v build
cd build
../configure --prefix=/tools            \
             --with-sysroot=$LFS        \
             --with-lib-path=/tools/lib \
             --target=$LFS_TGT          \
             --disable-nls              \
             --disable-werror
case $(uname -m) in
  x86_64) mkdir -v /tools/lib && ln -sv lib /tools/lib64 ;;
esac
make
if [ $? -ne 0 ]
then
    exit
fi
make install
if [ $? -ne 0 ]
then
    exit
fi
cd $LFS/sources
rm -rf binutils-2.32/

# GCC-8.2.0 - Pass 1

tar xvf gcc-8.2.0.tar.xz
cd gcc-8.2.0/
tar -xf ../mpfr-4.0.2.tar.xz
mv -v mpfr-4.0.2 mpfr
tar -xf ../gmp-6.1.2.tar.xz
mv -v gmp-6.1.2 gmp
tar -xf ../mpc-1.1.0.tar.gz
mv -v mpc-1.1.0 mpc
for file in gcc/config/{linux,i386/linux{,64}}.h
do
  cp -uv $file{,.orig}
  sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
      -e 's@/usr@/tools@g' $file.orig > $file
  echo '
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
#define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
  touch $file.orig
done
case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
 ;;
esac
mkdir -v build
cd       build
../configure                                       \
    --target=$LFS_TGT                              \
    --prefix=/tools                                \
    --with-glibc-version=2.11                      \
    --with-sysroot=$LFS                            \
    --with-newlib                                  \
    --without-headers                              \
    --with-local-prefix=/tools                     \
    --with-native-system-header-dir=/tools/include \
    --disable-nls                                  \
    --disable-shared                               \
    --disable-multilib                             \
    --disable-decimal-float                        \
    --disable-threads                              \
    --disable-libatomic                            \
    --disable-libgomp                              \
    --disable-libmpx                               \
    --disable-libquadmath                          \
    --disable-libssp                               \
    --disable-libvtv                               \
    --disable-libstdcxx                            \
    --enable-languages=c,c++
make
if [ $? -ne 0 ]
then
    exit
fi
make install
if [ $? -ne 0 ]
then
    exit
fi
cd $LFS/sources
rm -rf gcc-8.2.0/

# Linux-4.20.12 API Headers

tar xvf linux-4.20.12.tar.xz
cd linux-4.20.12/
make mrproper
if [ $? -ne 0 ]
then
    exit
fi
make INSTALL_HDR_PATH=dest headers_install
if [ $? -ne 0 ]
then
    exit
fi
cp -rv dest/include/* /tools/include
cd $LFS/sources
rm -rf linux-4.20.12/

# Glibc-2.29

unset MAKEFLAGS
tar xvf glibc-2.29.tar.xz
cd glibc-2.29/
mkdir -v build
cd       build
../configure                             \
      --prefix=/tools                    \
      --host=$LFS_TGT                    \
      --build=$(../scripts/config.guess) \
      --enable-kernel=3.2                \
      --with-headers=/tools/include
make
if [ $? -ne 0 ]
then
    exit
fi
make install
if [ $? -ne 0 ]
then
    exit
fi
echo 'int main(){}' > dummy.c
$LFS_TGT-gcc dummy.c
readelf -l a.out | grep ': /tools'
if [ $? -ne 0 ]
then
    exit
fi
rm -v dummy.c a.out
cd $LFS/sources
rm -rf glibc-2.29/
export MAKEFLAGS="-j 2"

# Libstdc++ from GCC-8.2.0

tar xvf gcc-8.2.0.tar.xz
cd gcc-8.2.0/
mkdir -v build
cd build
../libstdc++-v3/configure           \
    --host=$LFS_TGT                 \
    --prefix=/tools                 \
    --disable-multilib              \
    --disable-nls                   \
    --disable-libstdcxx-threads     \
    --disable-libstdcxx-pch         \
    --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/8.2.0
make
if [ $? -ne 0 ]
then
    exit
fi
make install
if [ $? -ne 0 ]
then
    exit
fi
cd $LFS/sources
rm -rf gcc-8.2.0/

# Binutils-2.32 - Pass 2

tar xvf binutils-2.32.tar.xz
cd binutils-2.32/
mkdir -v build
cd       build
CC=$LFS_TGT-gcc                \
AR=$LFS_TGT-ar                 \
RANLIB=$LFS_TGT-ranlib         \
../configure                   \
    --prefix=/tools            \
    --disable-nls              \
    --disable-werror           \
    --with-lib-path=/tools/lib \
    --with-sysroot
make
if [ $? -ne 0 ]
then
    exit
fi
make install
if [ $? -ne 0 ]
then
    exit
fi
make -C ld clean
if [ $? -ne 0 ]
then
    exit
fi
make -C ld LIB_PATH=/usr/lib:/lib
if [ $? -ne 0 ]
then
    exit
fi
cp -v ld/ld-new /tools/bin
cd $LFS/sources
rm -rf binutils-2.32/

# GCC-8.2.0 - Pass 2

tar xvf gcc-8.2.0.tar.xz
cd gcc-8.2.0/
cat gcc/limitx.h gcc/glimits.h gcc/limity.h >  `dirname \
  $($LFS_TGT-gcc -print-libgcc-file-name)`/include-fixed/limits.h
for file in gcc/config/{linux,i386/linux{,64}}.h
do
  cp -uv $file{,.orig}
  sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
      -e 's@/usr@/tools@g' $file.orig > $file
  echo '
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
#define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
  touch $file.orig
done
case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
  ;;
esac
tar -xf ../mpfr-4.0.2.tar.xz
mv -v mpfr-4.0.2 mpfr
tar -xf ../gmp-6.1.2.tar.xz
mv -v gmp-6.1.2 gmp
tar -xf ../mpc-1.1.0.tar.gz
mv -v mpc-1.1.0 mpc
mkdir -v build
cd       build
CC=$LFS_TGT-gcc                                    \
CXX=$LFS_TGT-g++                                   \
AR=$LFS_TGT-ar                                     \
RANLIB=$LFS_TGT-ranlib                             \
../configure                                       \
    --prefix=/tools                                \
    --with-local-prefix=/tools                     \
    --with-native-system-header-dir=/tools/include \
    --enable-languages=c,c++                       \
    --disable-libstdcxx-pch                        \
    --disable-multilib                             \
    --disable-bootstrap                            \
    --disable-libgomp
make
if [ $? -ne 0 ]
then
    exit
fi
make install
if [ $? -ne 0 ]
then
    exit
fi
ln -sv gcc /tools/bin/cc
echo 'int main(){}' > dummy.c
cc dummy.c
readelf -l a.out | grep ': /tools'
if [ $? -ne 0 ]
then
    exit
fi
rm -v dummy.c a.out
cd $LFS/sources
rm -rf gcc-8.2.0/

# Tcl-8.6.9
tar xvf tcl8.6.9-src.tar.gz
cd tcl8.6.9/
cd unix
./configure --prefix=/tools
make
if [ $? -ne 0 ]
then
    exit
fi
make install
if [ $? -ne 0 ]
then
    exit
fi
chmod -v u+w /tools/lib/libtcl8.6.so
make install-private-headers
if [ $? -ne 0 ]
then
    exit
fi
ln -sv tclsh8.6 /tools/bin/tclsh
cd $LFS/sources
rm -rf tcl8.6.9/

# Expect-5.45.4

tar xvf expect5.45.4.tar.gz
cd expect5.45.4
cp -v configure{,.orig}
sed 's:/usr/local/bin:/bin:' configure.orig > configure
./configure --prefix=/tools       \
            --with-tcl=/tools/lib \
            --with-tclinclude=/tools/include
make
if [ $? -ne 0 ]
then
    exit
fi
make SCRIPTS="" install
if [ $? -ne 0 ]
then
    exit
fi
cd $LFS/sources
rm -rf expect5.45.4

# DejaGNU-1.6.2

tar xvf dejagnu-1.6.2.tar.gz
cd dejagnu-1.6.2/
./configure --prefix=/tools
make install
if [ $? -ne 0 ]
then
    exit
fi
cd $LFS/sources
rm -rf dejagnu-1.6.2/

# M4-1.4.18

tar xvf m4-1.4.18.tar.xz
cd m4-1.4.18/
sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' lib/*.c
echo "#define _IO_IN_BACKUP 0x100" >> lib/stdio-impl.h
./configure --prefix=/tools
make
if [ $? -ne 0 ]
then
    exit
fi
make install
if [ $? -ne 0 ]
then
    exit
fi
cd $LFS/sources
rm -rf m4-1.4.18/

# Ncurses-6.1

tar xvf ncurses-6.1.tar.gz
cd ncurses-6.1/
sed -i s/mawk// configure
./configure --prefix=/tools \
            --with-shared   \
            --without-debug \
            --without-ada   \
            --enable-widec  \
            --enable-overwrite
make
if [ $? -ne 0 ]
then
    exit
fi
make install
if [ $? -ne 0 ]
then
    exit
fi
ln -s libncursesw.so /tools/lib/libncurses.so
cd $LFS/sources
rm -rf ncurses-6.1/

# Bash-5.0

tar xvf bash-5.0.tar.gz
cd bash-5.0/
./configure --prefix=/tools --without-bash-malloc
make
make install
if [ $? -ne 0 ]
then
    exit
fi
make install
make install
if [ $? -ne 0 ]
then
    exit
fi
ln -sv bash /tools/bin/sh
cd $LFS/sources
rm -rf bash-5.0/

# Bison-3.3.2

tar xvf bison-3.3.2.tar.xz 
cd bison-3.3.2/
./configure --prefix=/tools
make
if [ $? -ne 0 ]
then
    exit
fi
make install
if [ $? -ne 0 ]
then
    exit
fi
cd $LFS/sources
rm -rf bison-3.3.2/

# Bzip2-1.0.6

tar xvf bzip2-1.0.6.tar.gz
cd bzip2-1.0.6/
make
if [ $? -ne 0 ]
then
    exit
fi
make PREFIX=/tools install
if [ $? -ne 0 ]
then
    exit
fi
cd $LFS/sources
rm -rf bzip2-1.0.6/

# Coreutils-8.30

tar xvf coreutils-8.30.tar.xz
cd coreutils-8.30/
./configure --prefix=/tools --enable-install-program=hostname
make
if [ $? -ne 0 ]
then
    exit
fi
make install
if [ $? -ne 0 ]
then
    exit
fi
cd $LFS/sources
rm -rf coreutils-8.30/

# Diffutils-3.7

tar xvf diffutils-3.7.tar.xz
cd diffutils-3.7/
./configure --prefix=/tools
make
if [ $? -ne 0 ]
then
    exit
fi
make install
if [ $? -ne 0 ]
then
    exit
fi
cd $LFS/sources
rm -rf diffutils-3.7/

# File-5.36

tar xvf file-5.36.tar.gz
cd file-5.36/
./configure --prefix=/tools
make
if [ $? -ne 0 ]
then
    exit
fi
make install
if [ $? -ne 0 ]
then
    exit
fi
cd $LFS/sources
rm -rf file-5.36/

# Findutils-4.6.0

tar xvf findutils-4.6.0.tar.gz
cd findutils-4.6.0/
sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' gl/lib/*.c
sed -i '/unistd/a #include <sys/sysmacros.h>' gl/lib/mountlist.c
echo "#define _IO_IN_BACKUP 0x100" >> gl/lib/stdio-impl.h
./configure --prefix=/tools
make
if [ $? -ne 0 ]
then
    exit
fi
make install
if [ $? -ne 0 ]
then
    exit
fi
cd $LFS/sources
rm -rf findutils-4.6.0/

# Gawk-4.2.1

tar xvf gawk-4.2.1.tar.xz
cd gawk-4.2.1/
./configure --prefix=/tools
make
if [ $? -ne 0 ]
then
    exit
fi
make install
if [ $? -ne 0 ]
then
    exit
fi
cd $LFS/sources
rm -rf gawk-4.2.1/

# Gettext-0.19.8.1

tar xvf gettext-0.19.8.1.tar.xz
cd gettext-0.19.8.1/
cd gettext-tools
EMACS="no" ./configure --prefix=/tools --disable-shared
make -C gnulib-lib
if [ $? -ne 0 ]
then
    exit
fi
make -C intl pluralx.c
if [ $? -ne 0 ]
then
    exit
fi
make -C src msgfmt
if [ $? -ne 0 ]
then
    exit
fi
make -C src msgmerge
if [ $? -ne 0 ]
then
    exit
fi
make -C src xgettext
if [ $? -ne 0 ]
then
    exit
fi
cp -v src/{msgfmt,msgmerge,xgettext} /tools/bin
cd $LFS/sources
rm -rf gettext-0.19.8.1/

# Grep-3.3

tar xvf grep-3.3.tar.xz
cd grep-3.3/
./configure --prefix=/tools
make
if [ $? -ne 0 ]
then
    exit
fi
make install
if [ $? -ne 0 ]
then
    exit
fi
cd $LFS/sources
rm -rf grep-3.3/

# Gzip-1.10

tar xvf gzip-1.10.tar.xz
cd gzip-1.10/
./configure --prefix=/tools
make
if [ $? -ne 0 ]
then
    exit
fi
make install
if [ $? -ne 0 ]
then
    exit
fi
cd $LFS/sources
rm -rf gzip-1.10/

# Make-4.2.1

tar xvf make-4.2.1.tar.bz2
cd make-4.2.1/
sed -i '211,217 d; 219,229 d; 232 d' glob/glob.c
./configure --prefix=/tools --without-guile
make
if [ $? -ne 0 ]
then
    exit
fi
make install
if [ $? -ne 0 ]
then
    exit
fi
cd $LFS/sources
rm -rf make-4.2.1/

# Patch-2.7.6

tar xvf patch-2.7.6.tar.xz
cd patch-2.7.6/
./configure --prefix=/tools
make
if [ $? -ne 0 ]
then
    exit
fi
make install
if [ $? -ne 0 ]
then
    exit
fi
cd $LFS/sources
rm -rf patch-2.7.6/

# Perl-5.28.1

tar xvf perl-5.28.1.tar.xz
cd perl-5.28.1/
sh Configure -des -Dprefix=/tools -Dlibs=-lm -Uloclibpth -Ulocincpth
make
if [ $? -ne 0 ]
then
    exit
fi
cp -v perl cpan/podlators/scripts/pod2man /tools/bin
mkdir -pv /tools/lib/perl5/5.28.1
cp -Rv lib/* /tools/lib/perl5/5.28.1
cd $LFS/sources
rm -rf perl-5.28.1/

# Python-3.7.2

tar xvf Python-3.7.2.tar.xz 
cd Python-3.7.2/
sed -i '/def add_multiarch_paths/a \        return' setup.py
./configure --prefix=/tools --without-ensurepip
make
if [ $? -ne 0 ]
then
    exit
fi
make install
if [ $? -ne 0 ]
then
    exit
fi
cd $LFS/sources
rm -rf Python-3.7.2/

# Sed-4.7

tar xvf sed-4.7.tar.xz
cd sed-4.7/
./configure --prefix=/tools
make
if [ $? -ne 0 ]
then
    exit
fi
make install
if [ $? -ne 0 ]
then
    exit
fi
cd $LFS/sources
rm -rf sed-4.7/

# Tar-1.31

tar xvf tar-1.31.tar.xz
cd tar-1.31/
./configure --prefix=/tools
make
if [ $? -ne 0 ]
then
    exit
fi
make install
if [ $? -ne 0 ]
then
    exit
fi
cd $LFS/sources
rm -rf tar-1.31/

# Texinfo-6.5

tar xvf texinfo-6.5.tar.xz
cd texinfo-6.5/
./configure --prefix=/tools
make
if [ $? -ne 0 ]
then
    exit
fi
make install
if [ $? -ne 0 ]
then
    exit
fi
cd $LFS/sources
rm -rf texinfo-6.5/

# Util-linux-2.33.1

tar xvf util-linux-2.33.1.tar.xz
cd util-linux-2.33.1/
./configure --prefix=/tools                \
            --without-python               \
            --disable-makeinstall-chown    \
            --without-systemdsystemunitdir \
            --without-ncurses              \
            PKG_CONFIG=""
make
if [ $? -ne 0 ]
then
    exit
fi
make install
if [ $? -ne 0 ]
then
    exit
fi
cd $LFS/sources
rm -rf util-linux-2.33.1/

# Xz-5.2.4

tar xvf xz-5.2.4.tar.xz
cd xz-5.2.4/
./configure --prefix=/tools
make
if [ $? -ne 0 ]
then
    exit
fi
make install
if [ $? -ne 0 ]
then
    exit
fi
cd $LFS/sources
rm -rf xz-5.2.4/
END_OF_SCRIPT

su - lfs