#!/bin/bash -ex
# vim:ts=2 sw=2 et

function usage() {
  echo "Build/Install all or selected package"
  echo
  echo "Usage: ${0##*/} [-a] [-l] [-p PackageName] [-b PackageName]"
  echo "    -l          - List matching packages but not process"
  echo "    -i          - Install packages specified with -p or -a options"
  echo "    -a          - Process all packages"
  echo "    -p Name     - Process selected package"
  echo "    -b Name     - Process packages beginning with Name"
  echo "    -c Name     - Clear build directory for the given package"
  echo "    -C Name     - Clear the package-*.xz installation file"
  exit 1
}

LISTONLY=0
INSTALL=0
PACKAGE=0

while getopts "halib:p:c:C:" o; do
  case $o in
    i) INSTALL=1;;
    l) LISTONLY=1
       [ -z "$FILTER" ] && FILTER='/^#/d; p';;
    a) PACKAGE=1
       FILTER='/^#/d; p';;
    b) PACKAGE=1
       FILTER="/^#/d; /$OPTARG/,\$p";;
    p) PACKAGE=1
       FILTER="/^#/d; /$OPTARG/p";;
    c) echo "Removing build/$OPTARG"
       rm -fr build/$OPTARG
       exit 0;;
    C) [ ! -f "build/$OPTARG/$OPTARG*.xz" ] && \
          "No pre-built package $OPTARG found!" && \
          exit 1
       echo "Deleting build/$OPTARG/$OPTARG*.xz"
       rm -f build/$OPTARG/$OPTARG*.xz || exit 1
       exit 0;;
    *) usage;;
  esac
done

if [ $# -eq 0 ] || [ $INSTALL -eq 1 -a -z "$FILTER" ]; then 
  usage
fi

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
    buildscript="pkg/$s.PKGBUILD"

    if [ ! -f "$buildscript" ]; then
      echo "Package '$buildscript' not found (stale Manifest entry '$s'?)"
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
      ln -s ../../$buildscript PKGBUILD
      [ -f ../../$buildscript.install -a ! -f $mqtname.install ] && \
        ln -s ../../$buildscript.install $mqtname.install
    fi

    PKG="$(find -maxdepth 1 -name '*.xz' -printf '%f')"

    if [ -z "$PKG" ] ; then
      makepkg -L
      PKG="$(ls *.xz 2>/dev/null)"
    else
      echo "Skiping build (found build/$mqtname/$PKG)"
    fi

    if [ -z "$PKG" ]; then
      exit 1
    fi

    if [ $INSTALL -eq 1 ]; then
      echo "Installing $PKG"
      echo 'Y' | makepkg -i -L
    fi

    popd > /dev/null 2>&1

  done
