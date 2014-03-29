#!/bin/bash -e
# vim:ts=2 sw=2 et smarttab

function usage() {
  echo "Build/Install all or selected package"
  echo
  echo "Usage: ${0##*/} [-a] [-l] [-p PackageName] [-b PackageName]"
  echo "    -l            - List matching packages but not process"
  echo "    -s Name       - Syntax check of the PKGBUILD script for the package Name"
  echo "    -i            - Install packages specified with -p or -a options"
  echo "    -a            - Process all packages"
  echo "    -p Name       - Process selected package"
  echo "    -b Name       - Process packages beginning with Name"
  echo "    -c Name       - Clear build directory for the given package"
  echo "    -C Name       - Clear the package-*.xz installation file"
  echo "    -t ToolChain  - Specify toolchain (gcc | clang | intel)"
  echo "    -y            - Autoconfirm (no [Y/n] prompting)"
  exit 1
}

#==============================================================================
# Defaults
#==============================================================================
LISTONLY=0
INSTALL=0
PACKAGE=0
TOOLCHAIN="gcc"

export CC=gcc
export CXX=g++
export F77=gfortran
export CFLAGS="-O3 $FLAGS_LOCAL_GCC"
export CXXFLAGS="$OPT_CFLAGS"
export FFLAGS="-O3 $FLAGS_LOCAL_GCC"

#==============================================================================
# Parameter checking loop
#==============================================================================
while getopts "halib:p:c:C:s:t:y" o; do
  case $o in
    i) INSTALL=1;;
    l) LISTONLY=1
       [ -z "$FILTER" ] && FILTER='/^#/d; p';;
    a) PACKAGE=1
       FILTER='/^#/d; p';;
    b) PACKAGE=1
       FILTER="/^#/d; \!$OPTARG!,\$p";;
    p) PACKAGE=1
       FILTER="/^#/d; \!${OPTARG}\( \|$\)!p";;
    c) echo "Removing build/$OPTARG"
       rm -fr build/$OPTARG
       exit 0;;
    C) [ ! -f build/$OPTARG/$OPTARG*.xz ] && \
          echo "No pre-built package build/$OPTARG/$OPTARG*.xz found!" && \
          exit 1
       echo "Deleting build/$OPTARG/$OPTARG*.xz"
       rm -f build/$OPTARG/$OPTARG*.xz || exit 1
       exit 0;;
    s) ! which namcap >&/dev/null && echo "namcap package not installed!" && exit 1
       namcap -i pkg/${OPTARG}.PKGBUILD
       exit 0;;
    t) TOOLCHAIN=$OPTARG
       case $OPTARG in
         gcc)
            ;;
         clang)
            export CC=clang
            export CXX=clang++
            export F77=gfortran
            export CFLAGS="-Ofast $FLAGS_LOCAL_CLANG"
            export CXXFLAGS="$OPT_CFLAGS"
            export FFLAGS="-O3 $FLAGS_LOCAL_GCC"
            ;;
         intel) 
            export CC=gcc
            export CXX=g++
            export F77=gfortran
            export CFLAGS="-O3 $FLAGS_LOCAL_INTEL"
            export CXXFLAGS="$OPT_CFLAGS"
            export FFLAGS="-O3 $FLAGS_LOCAL_INTEL"
            ;;
         *) echo "Invalid toolchain! Supported values: gcc, clang, intel"
            exit 1;;
       esac;;
    y) NOCONFIRM=1;;
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

TOOLSET_SFX="-${TOOLCHAIN:-gcc}"

#==============================================================================
# Manifest processing
#==============================================================================
[ ! -f Manifest ] && echo "Manifest file not found!" && exit 1
[ ! -d "build"  ] && mkdir build

if [ -z "$(sed -n "$FILTER" Manifest)" ]; then
  echo "No matching packages found!"
  exit 1
fi

if [ $LISTONLY -eq 1 ]; then
  printf "%-40s %-15s %-25s %s\n" PackageName EnvDirName InstalledPkg Revision
  printf "%-40s %-15s %-25s %s\n" =========== ========== ============ ========
fi

sed -n "$FILTER" Manifest | \
  while read -r -a array; do
    s=${array[0]}
    repos=${s%%/*}
    mqtname=${s#*/}               # Remove prefix before '/'
    mqtname=${mqtname%.PKGBUILD}
    name=${mqtname#mqt-*}
    buildscript="pkg/$s.PKGBUILD"

    [ "$repos" = "$s" ] && repos=""
    [ -z "$repos"     ] && dirname=${array[1]:-${name^}} # Directory name under
                                                         #   /opt/env/prod
                                                         # defaults to ${name}
                                                         # with first letter capitalized 
    [ -z "$s" ] && continue

    if [ -z "$repos" ]; then
      PKGNAME="${mqtname}${TOOLSET_SFX}"
    else
      PKGNAME=$mqtname
    fi

    if [ ! -f "$buildscript" -a "${repos}" != "aur" ]; then
      echo "Package '$buildscript' not found (stale Manifest entry '$s'?)"
      exit 1
    fi

    if [ $LISTONLY -eq 1 ]; then
      printf "%-40s %-15s %-25s %s\n" "$s" "$dirname" $(pacman -Q $PKGNAME 2>/dev/null)
      continue
    fi

    echo -en "\e[0;32;40m===> Processing package: $mqtname\n\e[0m"

    if [ "${repos}" = "aur" ]; then
      pacaur -Syaq ${NOCONFIRM:+--noconfirm} --noedit ${mqtname} 
      continue
    fi

    mkdir -p build/$mqtname
    pushd build/$mqtname > /dev/null 2>&1

    if [ ! -f PKGBUILD ]; then
      ln -s ../../$buildscript PKGBUILD
      if [ -f ../../$buildscript.install -a ! -f $mqtname.install ]; then
        ln -s ../../$buildscript.install $mqtname.install
      elif [ ! -f $mqtname.install ]; then
        ../../util/gen-post-install.sh $s $dirname $mqtname.install
      fi
    fi

    PKG="$(find -maxdepth 1 -name '*.xz' -printf '%f')"

    rm -f $name*.log.*  # Remove stale versioned log files

    if [ -z "$PKG" ] ; then
      makepkg -L -s ${NOCONFIRM:+--noconfirm}
      PKG="$(find -maxdepth 1 -name '*.xz' -printf '%f')"
    else
      echo "Skiping build (found build/$mqtname/$PKG)"
    fi

    if [ -z "$PKG" ]; then
      exit 1
    fi

    if [ $INSTALL -eq 1 ]; then
      echo -en "\e[0;32;40m===> Installing $PKG\n\e[0m"
      makepkg -i -L ${NOCONFIRM:+--noconfirm}
    fi

    popd > /dev/null 2>&1

  done
