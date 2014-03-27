#!/bin/bash -e
# vim:ts=2 sw=2 et

function usage() {
  echo "Build/Install all or selected package"
  echo
  echo "Usage: ${0##*/} [-a] [-l] [-p PackageName] [-b PackageName]"
  echo "    -l          - List matching packages but not process"
  echo "    -i          - Install packages after build (default: build only)"
  echo "    -a          - Process all packages"
  echo "    -p Name     - Process selected package"
  echo "    -b Name     - Process packages beginning with Name"
  exit 1
}

LISTONLY=0
INSTALL=0

if [ $# -eq 0 ]; then
  usage
fi

while getopts "halib:p:c:" o; do
  case $o in
    i) INSTALL=1;;
    l) LISTONLY=1
       [ -z "$FILTER" ] && FILTER='/^#/d; p';;
    a) FILTER='/^#/d; p';;
    b) FILTER="/^#/d; /$OPTARG/,\$p";;
    p) FILTER="/^#/d; /$OPTARG/p";;
    c) echo "Removing build/$OPTARG"
       rm -fr build/$OPTARG
       exit 0;;
    *) usage;;
  esac
done

if ! grep -q '^COMPRESSXZ=(7z' /etc/makepkg.conf ; then
  echo -en "\e[1;33;40mWarning: add 'COMPRESS=(7z a dummy -txz -si -so)'" \
           " to /etc/makepkg.conf and install p7zip package\n\e[0m"
fi

if grep -q '^BUILDENV=.* !ccache' /etc/makepkg.conf ; then
  echo -en "\e[1;33;40mWarning: install ccache for speed.\n" \
           "  See: https://wiki.archlinux.org/index.php/Makepkg 'Improving compile times'\n" \
           "  and  https://wiki.archlinux.org/index.php/Ccache\n\e[0m"
fi

[ ! -f Manifest ] && echo "Manifest file not found!" && exit 1
[ ! -d "build"  ] && mkdir build

sed -n "$FILTER" Manifest | \
  while read -r s; do
    mqtname=${s#usr/}
    mqtname=${mqtname%.PKGBUILD}
    name=${mqtname#mqt-}

    if [ ! -f "pkg/$s" ]; then
      echo "Package 'pkg/$s' not found (stale Manifest entry '$s'?)"
      exit 1
    fi

    if [ $LISTONLY -eq 1 ]; then
      echo $mqtname
      continue
    fi

    echo -en "\e[0;32;40m===> Processing package: $mqtname\n\e[0m"

    mkdir -p build/$mqtname
    pushd build/$mqtname > /dev/null 2>&1

    if [ ! -f PKGBUILD ]; then
      ln -s ../../pkg/$s PKGBUILD
      [ -f ../../pkg/$s.install -a ! -f $mqtname.install ] && \
        ln -s ../../pkg/$s.install $mqtname.install
    fi

    PKG="$(ls *.xz 2>/dev/null)"

    if [ -z "$PKG" ] ; then
      makepkg -L
      PKG="$(ls *.xz 2>/dev/null)"
    else
      echo "Skiping build (found $PKG)"
    fi

    if [ $INSTALL -eq 1 ]; then
      echo "Installing $PKG"
      echo 'Y' | makepkg -i -L
    fi

    popd > /dev/null 2>&1

  done
