#!/bin/bash -e

#ASROOT=" --asroot"

if [ "$1" != "-r" -a $EUID -eq 0 ]; then
    echo "Script must be run by non-root user!"
    exit 1
fi

sudo pacman --noconfirm -S perl p7zip
export PATH=$PATH:/usr/bin/core_perl

mkdir -p /tmp/build
cd $_
#wget -O PKGBUILD https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=cower
#wget -O PKGBUILD https://raw.githubusercontent.com/saleyn/archlinux/master/util/cower.PKGBUILD
wget -O PKGBUILD https://aur.archlinux.org/cgit/aur.git/snapshot/auracle-git.tar.gz
tar -xzf auracle-git.tar.gz
pushd auracle-git
makepkg -i -s --noconfirm
popd
#mkdir -p expac
#pushd $_
#wget -O PKGBUILD https://projects.archlinux.org/svntogit/packages.git/plain/trunk/PKGBUILD?h=packages/expac
#wget -O PKGBUILD https://raw.githubusercontent.com/saleyn/archlinux/master/util/expac.PKGBUILD
#makepkg -i --noconfirm
#popd
sudo pacman -S meson fakechroot gtest patch
mkdir -p pacaur
pushd $_
wget -O PKGBUILD https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=pacaur
makepkg -i -s --noconfirm
popd
cd /tmp
rm -fr /tmp/build
