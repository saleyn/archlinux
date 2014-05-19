# vim:ts=2:sw=2:et
# Contributor: Serge Aleynikov <saleyn@gmail.com>

# If TOOLCHAIN env var is set, then the package name
# will contain "-${toolchain}" suffix in lower case
# otherwise, it'll end with "-gcc"
TOOLSET=$(tr '[:upper:]' '[:lower:]' <<< ${TOOLCHAIN:-gcc})

pkgbase=odb
pkgname=${pkgbase}
pkgver=2.3.0
pkgrel=2
pkgdesc='The ODB Compiler'
arch=('x86_64')
url='http://www.codesynthesis.com/download/odb'
options=('!libtool' buildflags makeflags)
license=('GPL')
depends=('mqt-boost' 'libodb')
makedepends=('git' 'mqt-boost' 'libodb')
source=("${url}/2.3/${pkgbase}-${pkgver}.tar.gz")
sha1sums=(`curl -sL ${url}/2.3/${pkgbase}-${pkgver}.tar.gz.sha1 | awk '{print $1}'`)

build() {
  local JOBS="$(sed -e 's/.*\(-j *[0-9]\+\).*/\1/' <<< ${MAKEFLAGS})"
  JOBS=${JOBS:- -j$(nproc)}

  echo "==== Building ${pkgname} ==="

  rm -f ../${pkgbase}*.log.*

  cd "${srcdir}/${pkgbase}-${pkgver}"

  ./configure \
    --enable-silent-rules \
    --enable-optimize \
    --prefix=/usr \
    --libexecdir=/usr/lib \
    --with-boost=/opt/env/prod/Boost/Current/include \
    --with-boost-libdir=/opt/env/prod/Boost/Current/${TOOLSET}/lib

    #--prefix=/opt/pkg/${pkgbase}/${pkgver} \
    #--exec-prefix=/opt/pkg/${pkgbase}/${pkgver}/${TOOLSET} \

  make $JOBS
}

package() {
  cd "${srcdir}"/${pkgbase}-${pkgver}

  echo "==== Packaging ${pkgname} ==="

  make DESTDIR="${pkgdir}" install

  #install -Dm644 LICENSE "${pkgdir}"/usr/share/licenses/${pkgname}/LICENSE
  #cd "${pkgdir}"/opt/pkg/${pkgbase}
  #ln -vs ${pkgver} current
}
