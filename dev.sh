#!/bin/bash

PACKAGE_URL=('http://download.savannah.gnu.org/releases/acl/acl-2.2.53.tar.gz' 'http://download.savannah.gnu.org/releases/attr/attr-2.4.48.tar.gz' 'http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.xz' 'http://ftp.gnu.org/gnu/automake/automake-1.16.1.tar.xz' 'http://ftp.gnu.org/gnu/bash/bash-5.0.tar.gz' 'http://ftp.gnu.org/gnu/bc/bc-1.07.1.tar.gz' 'http://ftp.gnu.org/gnu/binutils/binutils-2.32.tar.xz' 'http://ftp.gnu.org/gnu/bison/bison-3.3.2.tar.xz' 'http://anduin.linuxfromscratch.org/LFS/bzip2-1.0.6.tar.gz' 'https://github.com/libcheck/check/releases/download/0.12.0/check-0.12.0.tar.gz' 'http://ftp.gnu.org/gnu/coreutils/coreutils-8.30.tar.xz' 'https://dbus.freedesktop.org/releases/dbus/dbus-1.12.12.tar.gz' 'http://ftp.gnu.org/gnu/dejagnu/dejagnu-1.6.2.tar.gz' 'http://ftp.gnu.org/gnu/diffutils/diffutils-3.7.tar.xz' 'https://downloads.sourceforge.net/project/e2fsprogs/e2fsprogs/v1.44.5/e2fsprogs-1.44.5.tar.gz' 'https://sourceware.org/ftp/elfutils/0.176/elfutils-0.176.tar.bz2' 'https://prdownloads.sourceforge.net/expat/expat-2.2.6.tar.bz2' 'https://prdownloads.sourceforge.net/expect/expect5.45.4.tar.gz' 'ftp://ftp.astron.com/pub/file/file-5.36.tar.gz' 'http://ftp.gnu.org/gnu/findutils/findutils-4.6.0.tar.gz' 'https://github.com/westes/flex/releases/download/v2.6.4/flex-2.6.4.tar.gz' 'http://ftp.gnu.org/gnu/gawk/gawk-4.2.1.tar.xz' 'http://ftp.gnu.org/gnu/gcc/gcc-8.2.0/gcc-8.2.0.tar.xz' 'http://ftp.gnu.org/gnu/gdbm/gdbm-1.18.1.tar.gz' 'http://ftp.gnu.org/gnu/gettext/gettext-0.19.8.1.tar.xz' 'http://ftp.gnu.org/gnu/glibc/glibc-2.29.tar.xz' 'http://ftp.gnu.org/gnu/gmp/gmp-6.1.2.tar.xz' 'http://ftp.gnu.org/gnu/gperf/gperf-3.1.tar.gz' 'http://ftp.gnu.org/gnu/grep/grep-3.3.tar.xz' 'http://ftp.gnu.org/gnu/groff/groff-1.22.4.tar.gz' 'https://ftp.gnu.org/gnu/grub/grub-2.02.tar.xz' 'http://ftp.gnu.org/gnu/gzip/gzip-1.10.tar.xz' 'http://anduin.linuxfromscratch.org/LFS/iana-etc-2.30.tar.bz2' 'http://ftp.gnu.org/gnu/inetutils/inetutils-1.9.4.tar.xz' 'https://launchpad.net/intltool/trunk/0.51.0/+download/intltool-0.51.0.tar.gz' 'https://www.kernel.org/pub/linux/utils/net/iproute2/iproute2-4.20.0.tar.xz' 'https://www.kernel.org/pub/linux/utils/kbd/kbd-2.0.4.tar.xz' 'https://www.kernel.org/pub/linux/utils/kernel/kmod/kmod-26.tar.xz' 'http://www.greenwoodsoftware.com/less/less-530.tar.gz' 'https://www.kernel.org/pub/linux/libs/security/linux-privs/libcap2/libcap-2.26.tar.xz' 'ftp://sourceware.org/pub/libffi/libffi-3.2.1.tar.gz' 'http://download.savannah.gnu.org/releases/libpipeline/libpipeline-1.5.1.tar.gz' 'http://ftp.gnu.org/gnu/libtool/libtool-2.4.6.tar.xz' 'https://www.kernel.org/pub/linux/kernel/v4.x/linux-4.20.12.tar.xz' 'http://ftp.gnu.org/gnu/m4/m4-1.4.18.tar.xz' 'http://ftp.gnu.org/gnu/make/make-4.2.1.tar.bz2' 'http://download.savannah.gnu.org/releases/man-db/man-db-2.8.5.tar.xz' 'https://www.kernel.org/pub/linux/docs/man-pages/man-pages-4.16.tar.xz' 'https://github.com/mesonbuild/meson/releases/download/0.49.2/meson-0.49.2.tar.gz' 'https://ftp.gnu.org/gnu/mpc/mpc-1.1.0.tar.gz' 'http://www.mpfr.org/mpfr-4.0.2/mpfr-4.0.2.tar.xz' 'https://github.com/ninja-build/ninja/archive/v1.9.0/ninja-1.9.0.tar.gz' 'http://ftp.gnu.org/gnu/ncurses/ncurses-6.1.tar.gz' 'https://openssl.org/source/openssl-1.1.1a.tar.gz' 'http://ftp.gnu.org/gnu/patch/patch-2.7.6.tar.xz' 'https://www.cpan.org/src/5.0/perl-5.28.1.tar.xz' 'https://pkg-config.freedesktop.org/releases/pkg-config-0.29.2.tar.gz' 'https://sourceforge.net/projects/procps-ng/files/Production/procps-ng-3.3.15.tar.xz' 'https://sourceforge.net/projects/psmisc/files/psmisc/psmisc-23.2.tar.xz' 'https://docs.python.org/ftp/python/doc/3.7.2/python-3.7.2-docs-html.tar.bz2' 'https://www.python.org/ftp/python/3.7.2/Python-3.7.2.tar.xz' 'http://ftp.gnu.org/gnu/readline/readline-8.0.tar.gz' 'http://ftp.gnu.org/gnu/sed/sed-4.7.tar.xz' 'https://github.com/shadow-maint/shadow/releases/download/4.6/shadow-4.6.tar.xz' 'https://github.com/systemd/systemd/archive/v240/systemd-240.tar.gz' 'http://anduin.linuxfromscratch.org/LFS/systemd-man-pages-240.tar.xz' 'http://ftp.gnu.org/gnu/tar/tar-1.31.tar.xz' 'https://downloads.sourceforge.net/tcl/tcl8.6.9-src.tar.gz' 'http://ftp.gnu.org/gnu/texinfo/texinfo-6.5.tar.xz' 'https://www.iana.org/time-zones/repository/releases/tzdata2018i.tar.gz' 'https://www.kernel.org/pub/linux/utils/util-linux/v2.33/util-linux-2.33.1.tar.xz' 'ftp://ftp.vim.org/pub/vim/unix/vim-8.1.tar.bz2' 'https://cpan.metacpan.org/authors/id/T/TO/TODDR/XML-Parser-2.44.tar.gz' 'https://tukaani.org/xz/xz-5.2.4.tar.xz' 'https://zlib.net/zlib-1.2.11.tar.xz')

for url in ${PACKAGE_URL[@]}
do
    wget -q --show-progress "$url"
    ret=$?
    if [ $ret -ne 0 ]
    then
            while [ $ret -ne 0 ]
            do
                    wget -q --show-progress "$url"
                    ret=$?
            done
    fi
done