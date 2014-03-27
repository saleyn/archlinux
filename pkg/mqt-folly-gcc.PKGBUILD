# vim:ts=2:sw=2:et
# Maintainer: Joel Teichroeb <joel@teichroeb.net>
# Contributor: Jonas Heinrich <onny@project-insanity.org>
# Contributor: Serge Aleynikov <saleyn@gmail.com>

toolset=${TOOLCHAIN:-gcc}
TOOLSET=$(tr '[:lower:]' '[:upper:]' <<< ${toolset})
pkgbase=folly
pkgname=mqt-folly-${toolset}
pkgver=657.d9c79af
pkgrel=1
pkgdesc='Folly is an open-source C++ library developed and used at Facebook'
arch=(x86_64)
url='https://github.com/facebook/folly'
license=(Apache)
depends=(google-glog
         google-gflags
         double-conversion
        )
optdepends=(double-conversion)
GTEST=gtest-1.6.0
makedepends=(git mqt-boost-${toolset} python2)
options=(staticlibs)
source=(
  git+https://github.com/facebook/folly.git
  git+https://code.google.com/p/double-conversion
  http://gflags.googlecode.com/files/gflags-2.0.tar.gz
  http://googletest.googlecode.com/files/${GTEST}.zip
)
# that sucks that the project downloads gtests sources, it should use system libraries
# https://github.com/facebook/folly/issues/48
md5sums=('SKIP'
         'SKIP'
         'e02268c1e90876c809ec0ffa095da864'
         '4577b49f2973c90bf9ba69aa8166b786')

pkgver() {
  cd folly
  v=$(git describe --abbrev=0 2>/dev/null | sed 's/[^0-9\.]//g')
  if [ -n "$v" ]; then
    printf "%s" $v
  else
    printf "%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
  fi
}

prepare() {
  cd folly/folly
  find -name '*.py' -exec sed -i 's|^#!/usr/bin/env python$|#!/usr/bin/env python2|' {} \;

  cd test
  ln -s "$srcdir"/$GTEST
}

build() {
  local DCONV=0
  local JOBS="$(sed -e 's/.*\(-j *[0-9]\+\).*/\1/' <<< ${MAKEFLAGS})"
  JOBS=${JOBS:- -j$(nproc)}

  echo "==== Building gflags ===="
  cd "${srcdir}/gflags-2.0"
    ./configure \
      --prefix=/opt/pkg/${pkgbase}/${pkgver} \
      --exec-prefix=/opt/pkg/${pkgbase}/${pkgver}/${TOOLSET}
  make $JOBS

  echo "==== Building double-conversion ==="
  if [ ! -f /usr/include/double-conversion ]; then
    CPPFLAGS="$CPPFLAGS -I/usr/include/double-conversion"
  else
    CPPFLAGS="$CPPFLAGS -I${srcdir}/double-conversion/src"
    LDFLAGS="$LDFLAGS -L${srcdir}/double-conversion"
    DCONV=1
    if [ ! -f "$srcdir"/double-conversion/libdouble_conversion.a ]; then
      cp -f "$srcdir"/folly/SConstruct.double-conversion "$srcdir"/double-conversion
      cd "$srcdir"/double-conversion
      scons -f SConstruct.double-conversion
    fi
  fi

  echo "==== Building folly ==="
  cd "$srcdir"/folly/folly

  if [ $DCONV -eq 1 ]; then
    grep -q '\[double-conversion\]' configure.ac && \
      sed -i 's/\[double-conversion\]/\[double_conversion_pic\]/' configure.ac

    grep -q "AC_SUBST(AM_CPPFLAGS, '-Wno-deprecated" configure.ac ||
      sed -i "s/AC_SUBST(AM_CPPFLAGS, '/&-Wno-deprecated /p" configure.ac

    grep -q "^CPPFLAGS += -I$GTEST/include -I\.\.$" test/Makefile.am ||
      sed -i "s/^CPPFLAGS += -I$GTEST\/include$/& -I../" test/Makefile.am
  fi

  autoreconf --install

  # building shared library fails at it requires libiberty.so, gcc package provides only static library
  ./configure \
    --prefix=/opt/pkg/${pkgbase}/${pkgver} \
    --exec-prefix=/opt/pkg/${pkgbase}/${pkgver}/${TOOLSET} \
    --with-boost=/opt/env/Boost/Current \
    --with-boost-libdir=/opt/env/Boost/Current/${TOOLSET}/lib \
    --disable-shared
  make $JOBS
}

package() {
  cd "${srcdir}"/gflags-2.0
  make DESTDIR="${pkgdir}" install

  cd "${srcdir}"/folly/folly
  make DESTDIR="${pkgdir}" install

  # remove gtest libraries installed by the package
  rm "$pkgdir"/opt/pkg/${pkgbase}/${pkgver}/${TOOLSET}/lib/{libgtest,libgtestmain}.a
}
