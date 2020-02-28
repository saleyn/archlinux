# vim:ts=2:sw=2:et
# Contributor: Serge Aleynikov <saleyn@gmail.com>

# If TOOLCHAIN env var is set, then the package name
# will contain "-${toolchain}" suffix in lower case
# otherwise, it'll end with "-gcc"
TOOLSET=$(tr '[:upper:]' '[:lower:]' <<< ${TOOLCHAIN:-gcc})

pkgbase=utxx
pkgname=mqt-${pkgbase}
pkgver=1.4.1
pkgrel=1
pkgdesc='utxx is a collection of C++ utility components'
arch=('x86_64')
url='https://github.com/saleyn/utxx'
license=('LGPL')
depends=(mqt-boost ninja cmake doxygen python2-lxml)
makedepends=(git mqt-boost python2)
options=(buildflags makeflags)
source=(git+https://github.com/saleyn/utxx.git)
md5sums=('SKIP')

install=mqt-${pkgbase}.install

pkgver() {
  cd ${pkgbase}
  make ver
  #v=$(git describe --tags --abbrev=0 2>/dev/null | sed 's/[^0-9\.]//g')
  #if [ -n "$v" ]; then
  #  printf "%s" $v
  #else
  #  printf "%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
  #fi
}

build() {
  local JOBS="$(sed -e 's/.*\(-j *[0-9]\+\).*/\1/' <<< ${MAKEFLAGS})"
  JOBS=${JOBS:- -j$(nproc)}

  echo "==== Building ${pkgname} ==="

  rm -f ../${pkgbase}*.log.*

  cd "$srcdir"/${pkgbase}

  [ -n "$DEBUG" ] && VERBOSE="VERBOSE=1"

  echo "DIR:BUILD=${srcdir}/${pkgbase}/build"      >  .cmake-args
  echo "DIR:INSTALL=/opt/pkg/${pkgbase}/${pkgver}" >> .cmake-args
  echo "BOOST_ROOT=/opt/pkg/boost/current"         >> .cmake-args
  echo "Boost_USE_STATIC_LIBS=ON"                  >> .cmake-args
  echo "BUILD_SHARED_LIBS=ON"                      >> .cmake-args

  make bootstrap toolchain=gcc build=Debug generator=ninja ${VERBOSE} \
    PKG_ROOT_DIR=/opt/pkg \
    WITH_THRIFT=OFF

  make src/lib${pkgbase}_d.so src/lib${pkgbase}_d.a

  make rebootstrap build=Release ${VERBOSE}

  make 
 }

package() {
  cd "${srcdir}"/${pkgbase}

  echo "==== Packaging ${pkgname} ==="
  echo "Pkgdir: ${pkgdir}"

  make DESTDIR="${pkgdir}" install

  cd "${pkgdir}"/opt/pkg/${pkgbase}
  echo "Dir: ${PWD}"
  ln -vs ${pkgver} current
}
