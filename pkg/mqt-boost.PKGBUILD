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
pkgver=1.55.0
_boostver=${pkgver//./_}
pkgrel=4
url="http://www.boost.org"
arch=('x86_64')
license=('custom')
options=(buildflags makeflags)
makedepends=('icu>=52.1' 'python' 'python2' 'bzip2' 'zlib')
source=("http://downloads.sourceforge.net/${pkgbase}/${pkgbase}_${_boostver}.tar.gz"
        '001-log_fix_dump_avx2.patch::https://projects.archlinux.org/svntogit/packages.git/plain/trunk/001-log_fix_dump_avx2.patch?h=packages/boost'
        '002-circular_buffer.patch::https://github.com/boostorg/circular_buffer/commit/f5303c70d813b993097ab1c376ac0612b2613b4f.patch'
        'boost-process.zip::https://github.com/saleyn/boost-process/archive/master.zip')
sha1sums=('61ed0e57d3c7c8985805bb0682de3f4c65f4b6e5'
          'a4a47cc5716df87d544ae7684aaf402287132d50'
          '61c614e9feaf4b6e12019e7ae137c77321fc65d1'
          '3cbc47339dafb9055f75227987bb74f78c1d957c')

install=mqt-${pkgbase}.install

prepare() {
    echo "Preparing ${pkgname} build"
    export _stagedir="${srcdir}/stagedir"
    cd ${pkgbase}_${_boostver}

    patch -p0 -i ../001-log_fix_dump_avx2.patch
    sed -i '{s!^\([-+]\{3\}\) ./include/!\1 !; s!^\([-+]\{3\}\) ./test/!\1 libs/circular_buffer/test/!p}' \
        ../002-circular_buffer.patch
    patch -p0 -i ../002-circular_buffer.patch

    # Add an extra python version. This does not replace anything and python 2.x need to be the default.
    echo "using python : 3.3 : /usr/bin/python3 : /usr/include/python3.3m : /usr/lib ;" \
        >> ./tools/build/v2/user-config.jam

    # Add boost/process
    echo "Adding boost/process"
    rm -fr boost/process libs/process
    mv -vf ../boost-process-master/boost/* boost/
    mv -vf ../boost-process-master/libs/*  libs/
}

build() {
    local JOBS="$(sed -e 's/.*\(-j *[0-9]\+\).*/\1/' <<< ${MAKEFLAGS})"
    JOBS=${JOBS:- -j$(nproc)}

    rm -f ../${pkgbase}*.log.*

    cd ${pkgbase}_${_boostver}

    rm -f project-config.jam.*

    if [ ! -f project-config.jam ]; then
        echo "===> Bootstrapping ${pkgbase}_${_boostver}/project-config.jam"
        ./bootstrap.sh \
            --with-toolset=${TOOLSET} \
            --with-icu \
            --with-python=/usr/bin/python2 \
            --prefix="${_stagedir}" || return 1
    fi

    _bindir="bin.linuxx86"
    # Using this trick to check for x86_64 value or else namcap lint check complains
    [ "${CARCH%*86_64}" = x ] && _bindir="bin.linuxx86_64"

    install -dm755 "${_stagedir}"/{bin,include,lib}
    install tools/build/v2/engine/${_bindir}/b2 "${_stagedir}"/bin/b2

    # default "minimal" install: "release link=shared,static
    # runtime-link=shared threading=single,multi"
    # --layout=tagged will add the "-mt" suffix for multithreaded libraries
    # and installs includes in /usr/include/boost.
    # --layout=system no longer adds the -mt suffix for multi-threaded libs.
    # install to ${_stagedir} in preparation for split packaging
    "${_stagedir}"/bin/b2 \
      --build-dir=/tmp/boost \
      --layout=system \
      --prefix="${_stagedir}" \
      ${JOBS} \
      variant=release \
      optimization=speed \
      debug-symbols=off \
      threading=multi \
      runtime-link=shared \
      link=shared \
      toolset=${TOOLSET} \
      python=2.7 \
      cflags="${CFLAGS} -Wno-unused-local-typedefs -march=native" \
      cxxflags="${CPPFLAGS} ${CFLAGS} -Wno-unused-local-typedefs -march=native" \
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
    install -dm755 "${pkgdir}"/"${INSTALL_DIR}"/${TOOLSET}
    install -dm755 "${pkgdir}"/"${INSTALL_DIR}"/${TOOLSET}/{bin,lib}
    cp -a "${_stagedir}"/include "${pkgdir}"/"${INSTALL_DIR}"
    for d in bin lib; do
        cp -a "${_stagedir}/$d" "${pkgdir}/${INSTALL_DIR}/${TOOLSET}"
    done

    #find "${_stagedir}"/lib -name \*.a -exec mv {} "${pkgdir}"/${DIR}/${TOOLSET}/lib \;

    install -Dm644 "${srcdir}/"${pkgbase}_${_boostver}/LICENSE_1_0.txt \
        "${pkgdir}"/"${INSTALL_DIR}/share/licenses/boost/LICENSE_1_0.txt"

    cd "${pkgdir}"/"${DST_DIR}"
    ln -s ${pkgver} current
}
