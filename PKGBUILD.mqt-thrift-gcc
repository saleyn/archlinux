# Contributor: Byron Clark <byron@theclarkfamily.name>
# Contributor: Serge Aleynikov
# based on thrift-git PKGBUILD
toolset=gcc
TOOLSET=$(echo ${toolset} | tr '[:lower:]' '[:upper:]')
pkgbase=thrift
pkgname=mqt-thrift-${toolset}
pkgver=0.9.1
pkgrel=1
pkgdesc="Scalable cross-language services framework for IPC/RPC"
arch=(x86_64)
url="http://thrift.apache.org/"
license=(Apache2.0)
#depends=(boost-libs)
#makedepends=(boost java-environment apache-ant apache-ant-maven-tasks python2 php perl perl-bit-vector perl-class-accessor glib2)
makedepends=(mqt-boost-gcc python2 glib2)
optdepends=('python2: to use Python bindings'
            'erlang: to use Erlang bindings'
            'perl: to use Perl bindings'
            'perl-bit-vector: to use Perl bindings')
options=(!emptydirs !makeflags)
source=("https://github.com/saleyn/thrift/archive/mqt-${pkgver}.zip")
md5sums=('ae63293822e368f69c981cd6ecf48d2f')

BASE_DIR=/opt/pkg

build() {

  cd $srcdir/$pkgbase-mqt-$pkgver

  THRIFT_DIR=${BASE_DIR}/thrift
  PREFIX=${THRIFT_DIR}/${pkgver}
  BOOST_BASE_DIR=${BASE_DIR}/boost/current
  BOOST_LIB_DIR=${BOOST_BASE_DIR}/${TOOLSET}/lib
  OPTIMIZE=${OPTIMIZE:-3}
  THREADS=$(awk '/MHz/{s++} END {print s-1}' /proc/cpuinfo)

  ./bootstrap.sh

  PYTHON=/usr/bin/python2 ./configure CXXFLAGS=" -g -O${OPTIMIZE}" \
            LDFLAGS="-L${BOOST_LIB_DIR} -Wl,-rpath,${BOOST_LIB_DIR}" \
            --with-boost=${BASE_DIR}/boost/current --prefix=${PREFIX} \
            --exec-prefix=${PREFIX}/${TOOLSET} --without-qt4 \
            --without-php --without-c_glib --without-haskell --without-go \
            --without-d --without-erlang --without-perl \
            --with-cpp=yes

  make -j$THREADS

  cd contrib/fb303

  aclocal -I ./aclocal
  automake -a
  autoconf
  PYTHON=/usr/bin/python2 ./configure CXXFLAGS="-g -O${OPTIMIZE:-3}" --with-boost=${BOOST_BASE_DIR} \
      --with-thriftpath=${PREFIX} --prefix=${PREFIX} \
      --exec-prefix=${PREFIX}/${TOOLSET}
  make -j$THREADS
}

package() {
  cd $srcdir/$pkgbase-mqt-$pkgver

  make DESTDIR=$pkgdir install

  INSTALL_DIR=${pkgdir}${BASE_DIR}
  THRIFT_DIR=${INSTALL_DIR}/thrift
  PREFIX=${pkgdir}/${pkgver}
  rm -f ${THRIFT_DIR}/current/bin ${THRIFT_DIR}/current

  cd ${THRIFT_DIR}
  ln -s ${pkgver} current

  cd ${pkgver}
  ln -s ${TOOLSET}/bin bin

  cd $srcdir/$pkgname-mqt-$pkgver/contrib/fb303

  make DESTDIR=$pkgdir install
}

# vim:set ts=2 sw=2 et:
