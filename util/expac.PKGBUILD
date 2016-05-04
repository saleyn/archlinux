# $Id: PKGBUILD 87501 2013-04-02 00:06:04Z dreisner $
# Maintainer: Dave Reisner <d@falconindy.com>

pkgname=expac
pkgver=6
pkgrel=1
pkgdesc="pacman database extraction utility"
arch=('i686' 'x86_64')
url="http://github.com/falconindy/expac"
license=('GPL')
depends=('pacman')
makedepends=('perl')
source=("http://code.falconindy.com/archive/$pkgname/$pkgname-$pkgver.tar.gz")
#validpgpkeys=('487EACC08557AD082088DABA1EB2638FF56C0C53')  # Dave Reisner
md5sums=('06b6175221176d0cd9076eaf93166832')

prepare() {
  cd "$pkgname-$pkgver"

  sed '/\*\//q' expac.c >LICENSE
}

build() {
  cd "$pkgname-$pkgver"

  make
}

package() {
  cd "$pkgname-$pkgver"

  make PREFIX=/usr DESTDIR="$pkgdir" install

  install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}

# vim: ft=sh syn=sh
