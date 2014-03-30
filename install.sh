#!/bin/bash -e
# vim:ts=2 sw=2 et smarttab

function usage() {
  echo "Build/Install all or selected package"
  echo
  echo "Usage: ${0##*/} [-a] [-l] [-p PackageName] [-b PackageName]"
  echo "  -l              - List matching packages but not process"
  echo "  -s Name         - Syntax check of the PKGBUILD script for the package Name"
  echo "  -i              - Install packages specified with -p or -a options"
  echo "  -a              - Process all packages"
  echo "  -p Name[,Name]  - Process selected package(s)"
  echo "  -b Name         - Process packages beginning with Name"
  echo "  -D              - Download only (no build/install)"
  echo "  -R              - Remove the package(s)"
  echo "  -c [Name]       - Clear build directory for the given package"
  echo "  -C [Name]       - Clear the package-*.xz installation file"
  echo "  -t ToolChain    - Specify toolchain (gcc | clang | intel)"
  echo "  --confirm       - No autoconfirm ([Y/n] prompting)"
  echo "  --debug         - Debug mode"
  exit 1
}

function remove_pkg() {
  [ ! -f build/$1/$1*.xz ] && \
    echo "No pre-built package build/$1/$1*.xz found!" && \
    return
  echo "Deleting build/$1/$1*.xz"
  rm -f build/$1/$1*.xz 
}

function remove_build() {
  echo "Removing build/$1"
  rm -fr "build/$1"
}

#==============================================================================
# Defaults
#==============================================================================
LISTONLY=0
INSTALL=0
REMOVE=0
PACKAGE=0
TOOLCHAIN="gcc"
CONFIRM="--noconfirm"
DOWNLOAD_ONLY=0
DELETE_PKG=0
DELETE_BUILD=0

export CC=gcc
export CXX=g++
export F77=gfortran
export CFLAGS="-O3 $FLAGS_LOCAL_GCC"
export CXXFLAGS="$OPT_CFLAGS"
export FFLAGS="-O3 $FLAGS_LOCAL_GCC"

#==============================================================================
# Parameter checking loop
#==============================================================================
(( $# )) || usage

while [ -n "$1" ]; do
  case $1 in
    -i) INSTALL=1;;
    -D) DOWNLOAD_ONLY=1;;
    -R) REMOVE=1;;
    -l) LISTONLY=1;;
    -a) PACKAGE=1; ALL_PKGS=1;;
    -b) shift; PACKAGE=1; BEGIN_PKG="$1";;
    -p) shift; PACKAGE=1; IFS=, read -ra p <<< "$1"; PKGS+=("${p[@]}"); unset p;;
    -c) DELETE_BUILD=1
        [ "${2:0:1}" = '-' ] && break
        shift
        remove_build $1
        exit 0;;
    -C) DELETE_PKG=1
        [ "${2:0:1}" = '-' ] && break
        shift
        remove_pkg $1 || exit 1
        exit 0;;
    -s) shift
        ! which namcap >&/dev/null && echo "namcap package not installed!" && exit 1
        namcap -i pkg/$1.PKGBUILD
        exit 0;;
    -t) shift
        TOOLCHAIN=$1
        case $TOOLCHAIN in
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
    --confirm)  CONFIRM="";;
    --debug)    DEBUG=1;;
     *) echo "ERROR: unsupported option: $1"
        usage;;
  esac
  shift
done

if (( INSTALL && ! PACKAGE )); then
  echo "No packages specified!"
  usage
elif (( (REMOVE | DELETE_PKG | DELETE_BUILD) && (INSTALL || DOWNLOAD_ONLY) )); then
  echo "Conflicting flags: (-R | -c | -C) and (-i | -D)"
  usage
elif (( ALL_PKGS || (LISTONLY && ! PACKAGE) )); then
  FILTER='s/#.*$//; /^\s*$/d; p'
elif [ -n "$BEGIN_PKG" ]; then 
  FILTER="s/#.*$//; /^\s*$/d; \!${BEGIN_PKG}!,\$p"
elif (( PACKAGE )); then
  FILTER='s/#.*$//; /^\s*$/d;'
  for i in ${PKGS[@]}; do FILTER+=" \!$i\( \|$\)!p;"; done
fi

if (( DEBUG )); then
  echo "Manifest filter: '$FILTER'"
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
  echo "No matching packages found in Manifest!"
  exit 1
fi

if (( LISTONLY )); then
  printf "%-30s %-15s %-25s %s\n" PackageAlias EnvDirName ArchPkgName InstalledVersion
  printf "%-30s %-15s %-25s %s\n" ============ ========== =========== ================
fi

sed -n "$FILTER" Manifest | \
  while read -r -a array; do
    dirname=""
    repos=""

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

    if [ ! -f "$buildscript" -a "${repos}" != "aur" ]; then
      echo "Package '$buildscript' not found (stale Manifest entry '$s'?)"
      exit 1
    fi

    if [ -f "$buildscript" ]; then
      PKGNAME=$(source $buildscript && echo $pkgname)
    else
      PKGNAME=$mqtname
    fi

    if (( REMOVE )); then
      sudo pacman -R $PKGNAME ${CONFIRM}
      continue
    elif (( DELETE_PKG )); then
      remove_pkg $PKGNAME
      continue
    elif (( DELETE_BUILD )); then
      remove_build $PKGNAME
      continue
    elif (( LISTONLY )); then
      printf "%-30s %-15s %-25s %s %s\n" "$s" "$dirname" "$PKGNAME" \
        $(pacman -Q $PKGNAME 2>/dev/null | cut -d\  -f2)
      continue
    fi

    echo -en "\e[0;32;40m===> Processing package: $mqtname\n\e[0m"

    if [ "${repos}" = "aur" ]; then
      pacaur -Syaq ${CONFIRM} --noedit ${mqtname} 
      continue
    fi

    mkdir -p build/$mqtname
    pushd build/$mqtname > /dev/null 2>&1

    if [ ! -f PKGBUILD ]; then
      ln -s ../../$buildscript PKGBUILD
    fi
    if [ -f ../../$buildscript.install -a ! -f $mqtname.install ]; then
      ln -s ../../$buildscript.install $mqtname.install
    elif [ ! -f $mqtname.install ]; then
      ../../util/gen-post-install.sh $s $dirname $mqtname.install
    fi

    PKG="$(find -maxdepth 1 -name '*.xz' -printf '%f')"

    rm -f $name*.log.*  # Remove stale versioned log files

    if [ -n "$PKG" ] ; then
      echo "Skiping build (found build/$mqtname/$PKG)"
    elif (( DOWNLOAD_ONLY )); then
      makepkg -L -s -o
    else
      makepkg -L -s ${CONFIRM}
      PKG="$(find -maxdepth 1 -name '*.xz' -printf '%f')"
      [ -z "$PKG" ] && exit 1
    fi

    if (( INSTALL )); then
      echo -en "\e[0;32;40m===> Installing $PKG\n\e[0m"
      makepkg -i -L ${CONFIRM}
    fi

    popd > /dev/null 2>&1

  done
