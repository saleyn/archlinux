# vim:ts=2:sw=2:et
# Maintainer: Serge Aleynikov <saleyn@gmail.com>

# If TOOLCHAIN env var is set, then the package name
# will contain "-${toolchain}" suffix in lower case
# otherwise, it'll end with "-gcc"
TOOLSET=$(tr '[:upper:]' '[:lower:]' <<< ${TOOLCHAIN:-gcc})

pkgbase=stringencoders
pkgname=${pkgbase}
pkgver=3.10.3
pkgrel=1
pkgdesc='A collection of high performance c-string transformations'
arch=('x86_64')
url='https://code.google.com/p/stringencoders/'
license=('BSD3')
makedepends=('git' 'mqt-boost' 'cmake')
source=("https://$pkgbase.googlecode.com/files/$pkgbase-v$pkgver.tar.gz")
sha1sums=('47128e536f43d614711129c6774251fd02c794c4')

install=${pkgbase}.install

build() {
  local JOBS="$(sed -e 's/.*\(-j *[0-9]\+\).*/\1/' <<< ${MAKEFLAGS})"
  JOBS=${JOBS:- -j$(nproc)}

  echo "==== Building ${pkgname} ==="

  rm -f ../${pkgbase}*.log.*

  cd "${srcdir}/${pkgbase}-v${pkgver}"

  ./boostrap.sh

  CFLAGS="-O3 -Wno-error=unused-but-set-variable" ./configure \
    --enable-silent-rules \
    --enable-shared
#--prefix=/opt/pkg/${pkgbase}/${pkgver} \
#--exec-prefix=/opt/pkg/${pkgbase}/${pkgver}/${TOOLSET}
  make $JOBS
}

package() {
  cd "${srcdir}/${pkgbase}-v${pkgver}"

  echo "==== Packaging ${pkgname} ==="

  make DESTDIR="${pkgdir}" install

  #cd "${pkgdir}/opt/pkg/${pkgbase}"
  #ln -vs ${pkgver} current

  #cd ${pkgver}
  #mkdir -p ${TOOLSET}
  #mv -v lib ${TOOLSET}/lib
}
