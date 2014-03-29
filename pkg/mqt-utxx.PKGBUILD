# vim:ts=2:sw=2:et
# Contributor: Serge Aleynikov <saleyn@gmail.com>

# If TOOLCHAIN env var is set, then the package name
# will contain "-${toolchain}" suffix in lower case
# otherwise, it'll end with "-gcc"
_toolset=$(tr '[:upper:]' '[:lower:]' <<< ${TOOLCHAIN:-gcc})
TOOLSET=$(tr  '[:lower:]' '[:upper:]' <<< ${_toolset})

_pkgsfx=-${_toolset}
pkgbase=utxx
pkgname=mqt-${pkgbase}${_pkgsfx}
pkgver=1.1
pkgrel=1
pkgdesc='utxx is a collection of C++ utility components'
arch=('x86_64')
url='https://github.com/saleyn/utxx'
license=('LGPL')
depends=(mqt-boost${_pkgsfx} mqt-thrift${_pkgsfx})
makedepends=(git mqt-boost${_pkgsfx} mqt-thrift${_pkgsfx} python2)
options=(buildflags makeflags)
source=(git+https://github.com/saleyn/utxx.git)
md5sums=('SKIP')

install=mqt-${pkgbase}.install

pkgver() {
  cd utxx
  v=$(git describe --tags --abbrev=0 2>/dev/null | sed 's/[^0-9\.]//g')
  if [ -n "$v" ]; then
    printf "%s" $v
  else
    printf "%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
  fi
}

build() {
  local JOBS="$(sed -e 's/.*\(-j *[0-9]\+\).*/\1/' <<< ${MAKEFLAGS})"
  JOBS=${JOBS:- -j$(nproc)}

  echo "==== Building ${pkgname} ==="

  rm -f "${pkgbase}*.log.*"

  cd "$srcdir"/${pkgbase}

  ./bootstrap

  ./configure \
    --enable-silent-rules \
    --enable-optimize \
    --prefix=/opt/pkg/${pkgbase}/${pkgver} \
    --exec-prefix=/opt/pkg/${pkgbase}/${pkgver}/${TOOLSET} \
    --with-boost=/opt/env/prod/Boost/Current \
    --with-boost-libdir=/opt/env/prod/Boost/Current/${TOOLSET}/lib \
    --with-thrift=/opt/env/prod/Thrift/Current \
    --with-thrift-libdir=/opt/env/prod/Thrift/Current/${TOOLSET}/lib
  make $JOBS
}

package() {
  cd "${srcdir}"/${pkgbase}

  echo "==== Packaging ${pkgname} ==="

  make DESTDIR="${pkgdir}" install

  cd "${pkgdir}"/opt/pkg/${pkgbase}
  ln -vs ${pkgver} current
}
