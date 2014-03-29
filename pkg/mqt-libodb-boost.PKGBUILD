# vim:ts=2:sw=2:et
# Contributor: Serge Aleynikov <saleyn@gmail.com>

# If TOOLCHAIN env var is set, then the package name
# will contain "-${toolchain}" suffix in lower case
# otherwise, it'll end with "-gcc"
_toolset=$(tr '[:upper:]' '[:lower:]' <<< ${TOOLCHAIN:-gcc})
TOOLSET=$(tr  '[:lower:]' '[:upper:]' <<< ${_toolset})

_pkgsfx=-${_toolset}
pkgbase=libodb-boost
pkgname=mqt-${pkgbase}${_pkgsfx}
pkgver=2.3.0
pkgrel=1
pkgdesc='The ODB boost profile library'
arch=('x86_64')
url='http://www.codesynthesis.com/products/odb'
options=('!libtool' buildflags makeflags)
license=('GPL')
depends=(mqt-boost${_pkgsfx} 'libodb')
makedepends=(git mqt-boost${_pkgsfx} 'libodb')
source=("http://www.codesynthesis.com/download/odb/2.3/${pkgbase}-${pkgver}.tar.bz2")
md5sums=('2db307ced79231d78b75b1c80f4fd8f0')

install=mqt-${pkgbase}.install

build() {
  local JOBS="$(sed -e 's/.*\(-j *[0-9]\+\).*/\1/' <<< ${MAKEFLAGS})"
  JOBS=${JOBS:- -j$(nproc)}

  echo "==== Building ${pkgname} ==="

  rm -f "${pkgbase}*.log.*"

  cd "${srcdir}/${pkgbase}-${pkgver}"

  ./configure \
    --enable-silent-rules \
    --enable-optimize \
    --libdir=/usr/lib/odb \
    --with-pkgconfigdir=/usr/lib/pkgconfig \
    --with-libodb=/usr/lib \
    --with-boost=/opt/env/prod/Boost/Current \
    --with-boost-libdir=/opt/env/prod/Boost/Current/${TOOLSET}/lib

    #--prefix=/opt/pkg/${pkgbase}/${pkgver} \
    #--exec-prefix=/opt/pkg/${pkgbase}/${pkgver}/${TOOLSET} \

  make $JOBS
}

package() {
  cd "${srcdir}"/${pkgbase}-${pkgver}

  echo "==== Packaging ${pkgname} ==="

  make DESTDIR="${pkgdir}" install

  install -Dm644 LICENSE "${pkgdir}"/usr/share/licenses/${pkgname}/LICENSE
  #cd "${pkgdir}"/opt/pkg/${pkgbase}
  #ln -vs ${pkgver} current
}
