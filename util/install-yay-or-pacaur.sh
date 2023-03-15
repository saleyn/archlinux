#!/bin/bash -e

#ASROOT=" --asroot"

if [ "$1" != "-r" -a $EUID -eq 0 ]; then
    echo "Script must be run by non-root user!"
    exit 1
fi

for f in go p7zip perl; do
  if ! pacman -Q $f &>/dev/null; then
    sudo pacman --noconfirm -S $f
  fi
done

export PATH=$PATH:/usr/bin/core_perl

mkdir -p /tmp/build
cd $_

if uname -r | grep -q Microsoft; then
  FILE=fakeroot_1.31.orig.tar.gz
  wget -q http://ftp.debian.org/debian/pool/main/f/fakeroot/$FILE.orig.tar.gz
  tar zxf $FILE
  pushd ${FILE//_/-}
  ./bootstrap
  configure --prefix=/opt/sw/fakeroot --libdir=/opt/sw/fakeroot/libs --disable-static --with-ipc=tcp
  make
  sudo make install
  export PATH=/opt/sw/fakeroot/bin:$PATH
  popd
else
  sudo pacman -S fakechroot
fi

if [ "$1" = "-pacaur" -o "$1" = "--pacaur" ] && ! pacman -Q pacaur &>/dev/null; then
  #wget -O PKGBUILD https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=cower
  #wget -O PKGBUILD https://raw.githubusercontent.com/saleyn/archlinux/master/util/cower.PKGBUILD
  wget -q https://aur.archlinux.org/cgit/aur.git/snapshot/auracle-git.tar.gz
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
  sudo pacman -S meson gtest patch
  mkdir -p pacaur
  pushd $_
  wget -O PKGBUILD https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=pacaur
  makepkg -si --noconfirm
  popd
elif ! pacman -Q yay &>/dev/null; then
  # Install yay
  git clone https://aur.archlinux.org/yay.git
  pushd yay
  makepkg -si --noconfirm
  popd
fi
cd /tmp
rm -fr /tmp/build
