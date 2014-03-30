# vim:ts=2:sw=2:et
# Maintainer: Serge Aleynikov <saleyn@gmail.com>

# If TOOLCHAIN env var is set, then the package name
# will contain "-${toolchain}" suffix in lower case
# otherwise, it'll end with "-gcc"
TOOLSET=$(tr '[:upper:]' '[:lower:]' <<< ${TOOLCHAIN:-gcc})

pkgbase=cgate
pkgname=mqt-${pkgbase}
pkgver=1.3.8
pkgrel=1
pkgdesc='FORTS Plaza2 CGATE'
arch=('x86_64')
url='http://ftp.moex.com/pub'
source=("http://ftp.moex.com/pub/FORTS/Plaza2/${pkgbase}-${pkgver}.x86_64.tar.gz")
md5sums=('6deb3ab7d31cb7943bb141c5932e6f52')

install=mqt-${pkgbase}.install

package() {
  cd "${srcdir}/${pkgbase}-${pkgver}"

  echo "==== Packaging ${pkgname} ==="

  install -D -d -v -m755 "${pkgdir}/opt/pkg/${pkgbase}/${pkgver}/bin"
  install -D -d -v -m755 "${pkgdir}/opt/pkg/${pkgbase}/${pkgver}/include"
  install -D -d -v -m755 "${pkgdir}/opt/pkg/${pkgbase}/${pkgver}/${TOOLSET}/lib"

  install -D -v -m644 -t "${pkgdir}/opt/pkg/${pkgbase}/${pkgver}/bin" bin/*
  install -D -v -m644 -t "${pkgdir}/opt/pkg/${pkgbase}/${pkgver}/include" include/*.h 
  install -D -v -m644 -t "${pkgdir}/opt/pkg/${pkgbase}/${pkgver}/${TOOLSET}/lib" lib/{cgate,lib}* 

  cd "${pkgdir}/opt/pkg/${pkgbase}"
  ln -vs ${pkgver} current
}
