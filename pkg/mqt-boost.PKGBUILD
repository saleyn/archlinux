# $Id$
# Maintainer: Stéphane Gaudreault <stephane@archlinux.org>
# Maintainer: Ionut Biru <ibiru@archlinux.org>
# Contributor: kevin <kevin@archlinux.org>
# Contributor: Giovanni Scafora <giovanni@archlinux.org>
# Contributor: Kritoke <kritoke@gamebox.net>
# Contributor: Luca Roccia <little_rock@users.sourceforge.net>
# Contributor: Serge Aleynikov <saleyn@gmail.com>

# If TOOLCHAIN env var is set, then the package name
# will contain "-${toolchain}" suffix in lower case
# otherwise, it'll end with "-gcc"
TOOLSET=$(tr '[:upper:]' '[:lower:]' <<< ${TOOLCHAIN:-gcc})

pkgbase=boost
pkgname=mqt-${pkgbase}
pkgver=1.65.1
_boostver=${pkgver//./_}
pkgrel=4
url="http://www.boost.org"
arch=('x86_64')
license=('custom')
options=(buildflags makeflags)
makedepends=('icu>=53.1' 'python' 'python2' 'bzip2' 'zlib')
source=("http://downloads.sourceforge.net/${pkgbase}/${pkgbase}_${_boostver}.tar.gz")
sha1sums=('SKIP')

install=mqt-${pkgbase}.install

apply_patch() {
    msg "Applying patch (strip $1) $2"
    patch -p$1 -i $2
}

prepare() {
    echo "Preparing ${pkgname} build"
    export _stagedir="${srcdir}/stagedir"
    cd ${pkgbase}_${_boostver}

    #apply_patch 2 ../message-queue.patch
    #apply_patch 2 ../node-allocator.patch
}

build() {
    local JOBS="$(sed -e 's/.*\(-j *[0-9]\+\).*/\1/' <<< ${MAKEFLAGS})"
    JOBS=${JOBS:- -j$(nproc)}

    rm -f ../${pkgbase}*.log.*

    cd ${pkgbase}_${_boostver}

    rm -f project-config.jam.*

    if [ ! -f project-config.jam ]; then
        msg "===> Bootstrapping ${pkgbase}_${_boostver}/project-config.jam"
        ./bootstrap.sh \
            --with-toolset=${TOOLSET} \
            --with-icu \
            --with-python=/usr/bin/python2 \
            --prefix="${_stagedir}" || return 1
    fi

    echo "using python : 3.6 : /usr/bin/python3 : /usr/include/python3.6m : /usr/lib ;" \
      >> project-config.jam

    _bindir="bin.linuxx86"
    # Using this trick to check for x86_64 value or else namcap lint check complains
    [ "${CARCH%*86_64}" = x ] && _bindir="bin.linuxx86_64"

    install -dm755 "${_stagedir}"/{bin,include,lib}
    install tools/build/src/engine/${_bindir}/b2 "${_stagedir}"/bin/b2

    # default "minimal" install: "release link=shared,static
    # runtime-link=shared threading=single,multi"
    # --layout=tagged will add the "-mt" suffix for multithreaded libraries
    # and installs includes in /usr/include/boost.
    # --layout=system no longer adds the -mt suffix for multi-threaded libs.
    # install to ${_stagedir} in preparation for split packaging
    "${_stagedir}"/bin/b2 \
      --build-dir=/tmp/boost \
      --layout=system \
      --without-mpi \
      --prefix="${_stagedir}" \
      ${JOBS} \
      variant=release \
      optimization=speed \
      debug-symbols=on \
      threading=multi \
      runtime-link=shared \
      link=shared \
      toolset=${TOOLSET} \
      python=2.7 \
      cflags="${CFLAGS} -g -Wno-unused-local-typedefs -march=native" \
      cxxflags="${CPPFLAGS} ${CFLAGS} -g -Wno-unused-local-typedefs -march=native" \
      linkflags="${LDFLAGS}" \
      install

    # Note: for debugging add "-d2" switch to the command above
}

package() {
    pkgdesc="Free peer-reviewed portable C++ source libraries - Development"
    depends=('bzip2' 'zlib' 'icu')
    optdepends=('python: for python bindings'
                'python2: for python2 bindings'
                'boost-build: to use boost jam for building your project.')

    DST_DIR=opt/pkg/${pkgbase}
    INSTALL_DIR="${DST_DIR}"/${pkgver}

    install -dm755 "${pkgdir}"/"${INSTALL_DIR}"/include
    install -dm755 "${pkgdir}"/"${INSTALL_DIR}"/{bin,lib}
    cp -a "${_stagedir}"/include "${pkgdir}"/"${INSTALL_DIR}"
    for d in bin lib; do
        cp -a "${_stagedir}/$d" "${pkgdir}/${INSTALL_DIR}"
    done

    #find "${_stagedir}"/lib -name \*.a -exec mv {} "${pkgdir}"/${DIR}/${TOOLSET}/lib \;

    install -Dm644 "${srcdir}/"${pkgbase}_${_boostver}/LICENSE_1_0.txt \
        "${pkgdir}"/"${INSTALL_DIR}/share/licenses/boost/LICENSE_1_0.txt"

    cd "${pkgdir}"/"${DST_DIR}"
    ln -s ${pkgver} current
}
