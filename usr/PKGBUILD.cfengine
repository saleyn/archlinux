# Maintainer: Kuba Serafinowski <zizzfizzix AT gmail DOT com>
# https://github.com/zizzfizzix/pkgbuilds
#
# Contributor: Phillip Smith <fukawi2@NO-SPAM.gmail.com>
# Contributor: Christian Berendt <christian@thorlin.de>

pkgname=cfengine
pkgver=3.6.0b1
pkgrel=1
pkgdesc='Automated suite of programs for configuring and maintaining Unix-like computers.'
url='http://www.cfengine.org'
license=('GPL3')
options=('!libtool')
arch=('x86_64')
depends=('openssl' 'pcre' 'libxml2' 'tokyocabinet')
optdepends=('tokyocabinet' 'libvirt' 'postgresql-libs' 'libmariadbclient')
#install=${pkgname}.install
source=("${pkgname}-${pkgver}.tar.gz::http://cfengine.com/source-code/download?file=${pkgname}-${pkgver}.tar.gz"
        'https://raw.githubusercontent.com/zizzfizzix/pkgbuilds/master/cfengine/cf-execd.service'
        'https://raw.githubusercontent.com/zizzfizzix/pkgbuilds/master/cfengine/cf-monitord.service'
        'https://raw.githubusercontent.com/zizzfizzix/pkgbuilds/master/cfengine/cf-serverd.service')
md5sums=('7b73fecf2238c5f8afc9ca8ecb30e02f'
         'b9b73328006416e27bb59968187707b3'
         '3edfcfc72b89109dc7918ee552af76f5'
         'd6978af146da94eed3f58a2bc28a87b3')

build() {
	cd ${srcdir}/${pkgname}-${pkgver}

  ./configure \
    --prefix=/usr \
    --with-workdir=/var/lib/${pkgname} \
    --with-openssl \
    --with-pcre \
    --with-libacl=check \
    --with-libxml2 \
    --without-libvirt \
    --without-qdbm \
    --without-mysql \
    --with-tokyocabinet \
    --without-postgresql

  make
}

package() {
	cd ${srcdir}/${pkgname}-${pkgver}

	make DESTDIR=$pkgdir install

	install -D -m644 ${srcdir}/cf-execd.service \
		${pkgdir}/usr/lib/systemd/system/cf-execd.service
	install -D -m644 ${srcdir}/cf-serverd.service \
		${pkgdir}/usr/lib/systemd/system/cf-serverd.service
	install -D -m644 ${srcdir}/cf-monitord.service \
		${pkgdir}/usr/lib/systemd/system/cf-monitord.service
}

# vim:set ts=2 sw=2 et:

