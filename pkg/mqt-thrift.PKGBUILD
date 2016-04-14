# Contributor: Byron Clark <byron@theclarkfamily.name>
# Maintainer: Serge Aleynikov
# based on thrift-git PKGBUILD

# If TOOLCHAIN env var is set, then the package name
# will contain "-${toolchain}" suffix in lower case
# otherwise, it'll end with "-gcc"
TOOLSET=$(tr '[:upper:]' '[:lower:]' <<< ${TOOLCHAIN:-gcc})

pkgbase=thrift
pkgname=mqt-${pkgbase}
pkgver=0.9.1
pkgrel=1
pkgdesc="Scalable cross-language services framework for IPC/RPC"
arch=(x86_64)
url="http://thrift.apache.org/"
license=(Apache2.0)
#makedepends=(boost java-environment apache-ant apache-ant-maven-tasks python2 php perl perl-bit-vector perl-class-accessor glib2)
makedepends=(mqt-boost python2 glib2)
optdepends=('python2: to use Python bindings'
            'erlang: to use Erlang bindings'
            'perl: to use Perl bindings'
            'perl-bit-vector: to use Perl bindings')
options=(!emptydirs staticlibs buildflags makeflags)
source=("thrift::git+https://github.com/saleyn/thrift.git#branch=uds"
       )
md5sums=('SKIP'
        )

install=mqt-${pkgbase}.install

ENV_DIR=/opt/env/prod
INSTALL_DIR=/opt/pkg
THRIFT_DIR="${INSTALL_DIR}"/${pkgbase}/${pkgver}

build() {

  echo "==== Building ${pkgbase} ===="

  rm -f ../${pkgbase}*.log.*

  cd $srcdir/$pkgbase

  BOOST_INSTALL_DIR=/opt/pkg/boost/current
  BOOST_LIB_DIR=${BOOST_INSTALL_DIR}/lib
  OPTIMIZE=${OPTIMIZE:-3}
  THREADS=$(nproc)

  ./bootstrap.sh

  ./configure CXXFLAGS=" -g -O${OPTIMIZE} -Wno-deprecated-declarations" \
              PYTHON=/usr/bin/python2 \
              LDFLAGS="-L${BOOST_LIB_DIR} -Wl,-rpath,${BOOST_LIB_DIR}" \
            --with-boost=${BOOST_INSTALL_DIR} --prefix=${THRIFT_DIR} \
            --exec-prefix=${THRIFT_DIR}/${TOOLSET} --without-qt4 \
            --without-php --without-c_glib --without-haskell --without-go \
            --without-d --without-erlang --without-perl \
            --with-cpp=yes

  make -j$THREADS

  echo "==== Building FB303 ===="
  echo "Pkg    dir: ${pkgdir}"
  echo "Thrift dir: ${THRIFT_DIR}"

  cd contrib/fb303

  aclocal -I ./aclocal
  automake -a
  autoconf
  PYTHON=/usr/bin/python2 \
  ./configure CXXFLAGS="-g -O${OPTIMIZE:-3}" --with-boost=${BOOST_INSTALL_DIR} \
      --with-thriftpath="../../../compiler/cpp" --prefix=${THRIFT_DIR} \
      --exec-prefix=${THRIFT_DIR}/${TOOLSET}
  make -j$THREADS

  echo "==== Build Completed ===="
}

package() {
  cd $srcdir/$pkgbase

  make DESTDIR=$pkgdir install

  rm -f ${pkgdir}/${INSTALL_DIR}/${pkgbase}/current/bin \
        ${pkgdir}/${INSTALL_DIR}/${pkgbase}/current

  echo "==============================================="
  echo Pwd..........: "$PWD"
  echo pkgdir.......: "$pkgdir"
  echo ThriftDir....: "${pkgdir}"${THRIFT_DIR}
  echo InstallDir...: "${pkgdir}"${INSTALL_DIR}
  echo "==============================================="

  cd $srcdir/$pkgbase/contrib/fb303

  make DESTDIR=$pkgdir install

  cd "${pkgdir}"/${INSTALL_DIR}/${pkgbase}
  ln -s ${pkgver} current

  cd ${pkgver}
  [ -L bin ] || ln -s ${TOOLSET}/bin bin

}

# vim:set ts=2 sw=2 et:
