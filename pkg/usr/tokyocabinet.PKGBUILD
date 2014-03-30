# Maintainer: Mark Foxwell <fastfret79@archlinux.org.uk>
# Contributor: Nicolas Martyanoff <khaelin@gmail.com> 
# Contributor: Rick Chen <stuffcorpse@archlinux.us>

pkgname=tokyocabinet
pkgver=1.4.48
pkgrel=1
pkgdesc="a modern implementation of DBM"
arch=('x86_64')
url="http://fallabs.com/tokyocabinet/"
license=('LGPL')
makedepends=('gcc>=3.1' 'make' 'pkgconfig')
depends=('zlib' 'bzip2')
source=("http://fallabs.com/tokyocabinet/${pkgname}-${pkgver}.tar.gz")
md5sums=('fd03df6965f8f56dd5b8518ca43b4f5e')

build() {
  local JOBS="$(sed -e 's/.*\(-j *[0-9]\+\).*/\1/' <<< ${MAKEFLAGS})"
  JOBS=${JOBS:- -j$(nproc)}

  cd "$srcdir/$pkgname-$pkgver"
  ./configure \
    --enable-silent-rules \
    --prefix=/usr --enable-off64 --enable-fastest
  make $JOBS
}

# uncomment check routine if needed (can take ~5mins to run check)
check() {
 cd "$srcdir/$pkgname-$pkgver"
 make -k check
}

package() {
  cd "$srcdir/$pkgname-$pkgver"
  make DESTDIR="$pkgdir/" install
}

# vim:set ts=2 sw=2 et:
