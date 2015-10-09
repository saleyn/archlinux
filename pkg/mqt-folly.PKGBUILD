# vim:ts=2:sw=2:et
# Maintainer: Joel Teichroeb <joel@teichroeb.net>
# Contributor: Jonas Heinrich <onny@project-insanity.org>
# Contributor: Serge Aleynikov <saleyn@gmail.com>

# If TOOLCHAIN env var is set, then the package name
# will contain "-${toolchain}" suffix in lower case
# otherwise, it'll end with "-gcc"
TOOLSET=$(tr '[:upper:]' '[:lower:]' <<< ${TOOLCHAIN:-gcc})

pkgbase=folly
pkgname=mqt-${pkgbase}
pkgver=57.0.2075
pkgrel=1
pkgdesc='Folly is an open-source C++ library developed and used at Facebook'
arch=x86_64
url='https://github.com/facebook/folly'
license=(Apache)
depends=(google-glog
         google-gflags
         double-conversion
         mqt-boost
        )
GTEST=gtest-1.6.0
makedepends=(git mqt-boost google-gflags double-conversion python2)
options=(staticlibs buildflags makeflags)
source=(
#  folly::git+https://github.com/saleyn/folly.git#branch=atomic-hashmap
  git+https://github.com/facebook/folly.git
  http://googletest.googlecode.com/files/${GTEST}.zip
#https://github.com/saleyn/folly/compare/atomic-hashmap.patch
)
# that sucks that the project downloads gtests sources, it should use system libraries
# https://github.com/facebook/folly/issues/48
md5sums=('SKIP'
         '4577b49f2973c90bf9ba69aa8166b786'
#         'SKIP'
         )

install=mqt-${pkgbase}.install

pkgver() {
  cd ${pkgbase}
  printf "%s.%s" "$(sed 's/:/./g' folly/VERSION)" "$(git rev-list --count HEAD)"
}

prepare() {
  cd ${srcdir}/folly
  #patch -p1 < ../atomic-hashmap.patch

  cd folly
  find -name '*.py' -exec sed -i 's|^#!/usr/bin/env python$|#!/usr/bin/env python2|' {} \;
  sed -i '/AM_INIT_AUTOMAKE/s/nostdinc\])/subdir-objects &/' configure.ac

  cd test
  ln -s "$srcdir"/$GTEST
}

build() {
  local JOBS="$(sed -e 's/.*\(-j *[0-9]\+\).*/\1/' <<< ${MAKEFLAGS})"
  JOBS=${JOBS:- -j$(nproc)}

  echo "==== Building ${pkgbase} (pwd: ${PWD}) ===="

  rm -f ../${pkgbase}*.log.*

  cd "$srcdir"/folly/folly

  grep -q "^CPPFLAGS += -I$GTEST/include -I\.\.$" test/Makefile.am ||
    sed -i "s/^CPPFLAGS += -I$GTEST\/include$/& -I../" test/Makefile.am

  autoreconf -vif

  CPPFLAGS="$CPPFLAGS -DFBSTRING_CONSERVATIVE"
  CPPFLAGS+=" -I/usr/include/double-conversion -Wno-deprecated -g -O3"

  # building shared library fails at it requires libiberty.so, gcc package provides only static library
  ./configure \
    --enable-silent-rules \
    --enable-shared \
    --with-libiberty=no \
    --prefix=/opt/pkg/${pkgbase}/${pkgver} \
    --exec-prefix=/opt/pkg/${pkgbase}/${pkgver}/${TOOLSET} \
    --with-boost=/opt/env/prod/Boost/Current \
    --with-boost-libdir=/opt/env/prod/Boost/Current/${TOOLSET}/lib
  make $JOBS
}

package() {
  cd "${srcdir}"/folly/folly

  echo "==== Packaging folly ==="

  make DESTDIR="${pkgdir}" install

  cd "${pkgdir}"/opt/pkg/${pkgbase}
  ln -vs ${pkgver} current

  # remove gtest libraries installed by the package
  rm -f "$pkgdir"/opt/pkg/${pkgbase}/${pkgver}/${TOOLSET}/lib/{libgtest,libgtestmain}.a
}
