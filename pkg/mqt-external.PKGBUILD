# vim:ts=2:sw=2:et
# Maintainer: Joel Teichroeb <joel@teichroeb.net>
# Contributor: Jonas Heinrich <onny@project-insanity.org>
# Contributor: Serge Aleynikov <saleyn@gmail.com>

# If TOOLCHAIN env var is set, then the package name
# will contain "-${toolchain}" suffix in lower case
# otherwise, it'll end with "-gcc"
TOOLSET=$(tr '[:upper:]' '[:lower:]' <<< ${TOOLCHAIN:-gcc})

pkgbase=external
pkgname=mqt-${pkgbase}
pkgver=1.0
pkgrel=1
pkgdesc='Maquette external libraries'
arch=x86_64
url='https://github.com/saleyn/archlinux'
license=('BSD3')
depends=()
makedepends=(
  msgpack
  libodb
  libcutl
  libodb-mysql
  mqt-boost
  mqt-thrift
  mqt-folly
  mqt-utxx        
  mqt-eixx        
  mqt-armadillo
  mqt-libodb-boost
  mqt-zeromq      
)
source=()

install=mqt-${pkgbase}.install

build() {
  return
}

package() {
  return
}
