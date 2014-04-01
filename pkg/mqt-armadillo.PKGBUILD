# vim:ts=2:sw=2:et
# Maintainer: Serge Aleynikov <saleyn@gmail.com>

# If TOOLCHAIN env var is set, then the package name
# will contain "-${toolchain}" suffix in lower case
# otherwise, it'll end with "-gcc"
TOOLSET=$(tr '[:upper:]' '[:lower:]' <<< ${TOOLCHAIN:-gcc})

pkgbase=armadillo
pkgname=mqt-${pkgbase}
pkgver=4.100.2
pkgrel=1
pkgdesc='C++ linear algebra library'
arch=('x86_64')
url='http://arma.sourceforge.net'
license=('MPL 2.0')
depends=('lapack' 'blas' 'mqt-boost')
makedepends=('git' 'mqt-boost' 'cmake')
source=("http://downloads.sourceforge.net/sourceforge/arma/$pkgbase-$pkgver.tar.gz")
md5sums=('dd422706778cde656d531b3c3919766e')

install=mqt-${pkgbase}.install

build() {
  local JOBS="$(sed -e 's/.*\(-j *[0-9]\+\).*/\1/' <<< ${MAKEFLAGS})"
  JOBS=${JOBS:- -j$(nproc)}

  echo "==== Building ${pkgname} ==="

  rm -f ../${pkgbase}*.log.*

  cd "${srcdir}/${pkgbase}-${pkgver}"

  rm -f CMakeCache.txt
  cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER="$CC" \
    -DCMAKE_CXX_COMPILER="$CXX" \
    -DCMAKE_INSTALL_PREFIX="/opt/pkg/${pkgbase}/${pkgver}"
      
  make $JOBS
}

package() {
  cd "${srcdir}/${pkgbase}-${pkgver}"

  echo "==== Packaging ${pkgname} ==="

  make DESTDIR="${pkgdir}" install
  install -D -m644 LICENSE.txt \
    "${pkgdir}/opt/pkg/${pkgbase}/${pkgver}/share/licenses/Armadillo/LICENSE"

  cd "${pkgdir}/opt/pkg/${pkgbase}"
  ln -vs ${pkgver} current

  cd ${pkgver}
  mkdir -p ${TOOLSET}
  mv -v lib ${TOOLSET}/lib
}
