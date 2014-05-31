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
depends=('openssl' 'pcre' 'libxml2' 'qdbm')
optdepends=('tokyocabinet' 'libvirt' 'postgresql-libs' 'libmariadbclient')
#install=${pkgname}.install
source=("${pkgname}-${pkgver}.tar.gz::http://cfengine.com/source-code/download?file=${pkgname}-${pkgver}.tar.gz"
        'https://raw.githubusercontent.com/zizzfizzix/pkgbuilds/master/cfengine/cf-execd.service'
        'https://raw.githubusercontent.com/zizzfizzix/pkgbuilds/master/cfengine/cf-monitord.service'
        'https://raw.githubusercontent.com/zizzfizzix/pkgbuilds/master/cfengine/cf-serverd.service')
md5sums=('8171347ef4d365a1f621ebbc1d5b33b8'
         'dba17dc5133b8fa86de11577120d46c5'
         'a2f9db31408f288cb934397ffb474db3'
         'ff28f7de9b81b4673082a2640a318896')

build() {
  local JOBS="$(sed -e 's/.*\(-j *[0-9]\+\).*/\1/' <<< ${MAKEFLAGS})"
  JOBS=${JOBS:- -j$(nproc)}

	cd ${srcdir}/${pkgname}-${pkgver}

  ./configure \
    --enable-silent-rules \
    --prefix=/usr \
    --with-workdir=/var/lib/${pkgname} \
    --with-openssl \
    --with-pcre \
    --with-libacl=check \
    --with-libxml2 \
    --without-libvirt \
    --with-qdbm \
    --without-mysql \
    --without-tokyocabinet \
    --without-postgresql

  make $JOBS
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

