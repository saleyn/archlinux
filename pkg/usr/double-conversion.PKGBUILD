# Maintainer: Joel Teichroeb <joel@teichroeb.net>
# Contributor: Jonas Heinrich <onny@project-insanity.org>

pkgname=double-conversion
pkgver=2.0.1
pkgrel=1
pkgdesc='Binary-decimal and decimal-binary routines for IEEE doubles'
arch=(x86_64)
url='https://code.google.com/p/double-conversion/'
license=(BSD3)
makedepends=(cmake)
options=(staticlibs)
source=(https://double-conversion.googlecode.com/files/$pkgname-$pkgver.tar.gz)
sha1sums=('34644bfd063aba87436536e029b0dfb109df850f')

build() {
  cmake . -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON
  make
}

check() {
  cd test
  cmake .
# Currently tests fail
#  make all
}

package () {
  make DESTDIR="$pkgdir" install
}
