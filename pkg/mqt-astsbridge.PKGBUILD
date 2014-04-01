# vim:ts=2:sw=2:et
# Maintainer: Serge Aleynikov <saleyn@gmail.com>

# If TOOLCHAIN env var is set, then the package name
# will contain "-${toolchain}" suffix in lower case
# otherwise, it'll end with "-gcc"
TOOLSET=$(tr '[:upper:]' '[:lower:]' <<< ${TOOLCHAIN:-gcc})

pkgbase=astsbridge
pkgname=mqt-${pkgbase}
pkgver=4.2.3.1135
pkgrel=1
pkgdesc='MOEX Astsbridge'
arch=('x86_64')
url='http://ftp.moex.com/pub'
source=("http://ftp.moex.com/pub/ClientsAPI/ASTS/${pkgbase}-${pkgver}.zip")
md5sums=('4bdb26d3fffa4dc4955fdf3282385c6c')

install=mqt-${pkgbase}.install

prepare() {
  msg "Preparing ${pkgname} build"
  (cd "${srcdir}/embedded/linux64" && tar zxf libmtesrl-linux-*)
}

package() {
  #cd "${srcdir}"
  echo "==== Packaging ${pkgname} ==="

  rm -f ../${pkgbase}*.log.*

  install -D -d -v -m755 "${pkgdir}/opt/pkg/${pkgbase}/${pkgver}/doc"
  install -D -d -v -m755 "${pkgdir}/opt/pkg/${pkgbase}/${pkgver}/include"
  install -D -d -v -m755 "${pkgdir}/opt/pkg/${pkgbase}/${pkgver}/${TOOLSET}/lib"

  find doc -iname '*.pdf' -print0 | while read -d $'\0' -r file; do
    dest=${file##*/}
    dest=${dest// /-}
    dest=${dest//---/-}
    install -D -m644 "$file" "${pkgdir}/opt/pkg/${pkgbase}/${pkgver}/doc/$dest"
  done

  install -D -v -m644 -t "${pkgdir}/opt/pkg/${pkgbase}/${pkgver}/include" embedded/linux64/*.h 
  install -D -v -m644 -t "${pkgdir}/opt/pkg/${pkgbase}/${pkgver}/${TOOLSET}/lib" embedded/linux64/*.so
  install -D -v -m644 "demo/MSVC/MteSrlTest.ini" "${pkgdir}/opt/pkg/${pkgbase}/${pkgver}/${TOOLSET}/lib"

  cd "${pkgdir}/opt/pkg/${pkgbase}"
  ln -vs ${pkgver} current
}
