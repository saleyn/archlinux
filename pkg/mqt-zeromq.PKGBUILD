# vim:ts=2:sw=2:et
# Contributor: Serge Aleynikov <saleyn@gmail.com>

# If TOOLCHAIN env var is set, then the package name
# will contain "-${toolchain}" suffix in lower case
# otherwise, it'll end with "-gcc"
_toolset=$(tr '[:upper:]' '[:lower:]' <<< ${TOOLCHAIN:-gcc})
TOOLSET=$(tr  '[:lower:]' '[:upper:]' <<< ${_toolset})

_pkgsfx=-${_toolset}
pkgbase=zeromq
pkgname=mqt-${pkgbase}${_pkgsfx}
pkgver=4.0.4
pkgrel=1
pkgdesc='0MQ libzmq core library -- development trunk'
arch=('x86_64')
depends=('gcc-libs' 'libsodium' 'util-linux')
makedepends=('asciidoc' 'gcc' 'git' 'libtool' 'python2' 'xmlto')
url="https://github.com/zeromq/libzmq"
license=('LGPL3')
source=(${pkgbase}::git+https://github.com/zeromq/libzmq
        https://raw.github.com/zeromq/cppzmq/master/zmq.hpp)
md5sums=('SKIP'
         'SKIP')
options=('staticlibs')

install=mqt-${pkgbase}.install

pkgver() {
  cd ${pkgbase}
  printf "%s" $(git describe --tags --abbrev=0 2>/dev/null | sed 's/[^0-9\.]//g')
}

build() {
  local JOBS="$(sed -e 's/.*\(-j *[0-9]\+\).*/\1/' <<< ${MAKEFLAGS})"
  JOBS=${JOBS:- -j$(nproc)}

  echo "==== Building ${pkgname} ==="

  rm -f "${pkgbase}*.log.*"

  cd "$srcdir"/${pkgbase}

  ./autogen.sh

  ./configure \
    --enable-silent-rules \
    --prefix=/opt/pkg/${pkgbase}/${pkgver} \
    --exec-prefix=/opt/pkg/${pkgbase}/${pkgver}/${TOOLSET} \
    --sysconfdir=/etc \
    --with-pgm
  sed -i 's/python$/&2/' foreign/openpgm/build-staging/openpgm/pgm/{Makefile,version_generator.py}
  make $JOBS
}

package() {
  cd "${srcdir}"/${pkgbase}

  echo "==== Packaging ${pkgname} ==="
  for f in COPYING COPYING.LESSER; do
    install -D -m644 $f $pkgdir/opt/pkg/${pkgbase}/${pkgver}/share/licenses/zeromq/$f
  done

  make DESTDIR="${pkgdir}" install

  install -Dm 644 $srcdir/zmq.hpp $pkgdir/opt/pkg/${pkgbase}/${pkgver}/include/zmq.hpp

  # Cleanup
  find "$pkgdir" -type d -name .git -exec rm -r '{}' \;
  find "$pkgdir" -type f -name .gitignore -exec rm -r '{}' \;

  cd "${pkgdir}"/opt/pkg/${pkgbase}
  ln -vs ${pkgver} current
}
