# vim:ts=2:sw=2:et
# Contributor: Serge Aleynikov <saleyn@gmail.com>

# If TOOLCHAIN env var is set, then the package name
# will contain "-${toolchain}" suffix in lower case
# otherwise, it'll end with "-gcc"
TOOLSET=$(tr '[:upper:]' '[:lower:]' <<< ${TOOLCHAIN:-gcc})

pkgbase=eixx
pkgname=mqt-${pkgbase}
pkgver=1.1.72
pkgrel=1
pkgdesc='Erlang C++ interface library'
arch=('x86_64')
url='https://github.com/saleyn/eixx'
license=('LGPL')
depends=(mqt-boost mqt-thrift)
optdepends=(erlang mqt-erlang)
makedepends=(git mqt-boost mqt-thrift python2)
options=(buildflags makeflags)
source=(git+https://github.com/saleyn/eixx.git)
md5sums=('SKIP')

install=mqt-${pkgbase}.install

pkgver() {
  cd ${pkgbase}
  printf "%s.%s" \
    "$(git describe --tags --abbrev=0 | sed 's/[^0-9]*//')" \
    "$(git rev-list --count HEAD)"
}

build() {
  local JOBS="$(sed -e 's/.*\(-j *[0-9]\+\).*/\1/' <<< ${MAKEFLAGS})"
  JOBS=${JOBS:- -j$(nproc)}

  echo "==== Building ${pkgname} ==="

  rm -f ../${pkgbase}*.log.*

  cd "$srcdir"/${pkgbase}

  ./bootstrap

  ./configure \
    --enable-silent-rules \
    --enable-optimize \
    --prefix=/opt/pkg/${pkgbase}/${pkgver} \
    --exec-prefix=/opt/pkg/${pkgbase}/${pkgver}/${TOOLSET} \
    --with-boost=/opt/env/prod/Boost/Current \
    --with-boost-libdir=/opt/env/prod/Boost/Current/${TOOLSET}/lib
  make $JOBS
}

package() {
  cd "${srcdir}"/${pkgbase}

  echo "==== Packaging ${pkgname} ==="

  make DESTDIR="${pkgdir}" install

  cd "${pkgdir}"/opt/pkg/${pkgbase}
  ln -vs ${pkgver} current
}
