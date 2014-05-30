# vim:ts=2:sw=2:et
# Maintainer: Joel Teichroeb <joel@teichroeb.net>
# Contributor: Jonas Heinrich <onny@project-insanity.org>
# Contributor: Serge Aleynikov <saleyn@gmail.com>

# If TOOLCHAIN env var is set, then the package name
# will contain "-${toolchain}" suffix in lower case
# otherwise, it'll end with "-gcc"
TOOLSET=$(tr '[:upper:]' '[:lower:]' <<< ${TOOLCHAIN:-gcc})

pkgbase=erl-libs
pkgname=mqt-${pkgbase}
pkgver=1.1
pkgrel=1
pkgdesc='Collection of open-source Erlang libraries'
arch=x86_64
license=(Apache)
GTEST=gtest-1.6.0
makedepends=(git rebar)
source=(
  emysql::git+https://github.com/Eonblast/Emysql.git
  git+https://github.com/saleyn/erlexec
  git+https://github.com/saleyn/util
  git+https://github.com/saleyn/gen_timed_server
  git+https://github.com/uwiger/gproc.git
  git+https://github.com/basho/lager.git
  git+https://github.com/DeadZen/goldrush.git
  git+https://github.com/mochi/mochiweb.git
  git+https://github.com/davisp/jiffy.git
  git+https://github.com/manopapad/proper.git
  git+https://github.com/saleyn/getopt.git#branch=format_error
)

md5sums=(
  'SKIP'
  'SKIP'
  'SKIP'
  'SKIP'
  'SKIP'
  'SKIP'
  'SKIP'
  'SKIP'
  'SKIP'
  'SKIP'
  'SKIP'
)

install=mqt-${pkgbase}.install

prepare() {
  rm util/src/decompiler.erl
  cd $srcdir
  mkdir -p "lager/deps"
  cd $srcdir/lager/deps
  ln -s ../../goldrush

  cd $srcdir
  mkdir -p jiffy/deps
  cd $srcdir/jiffy/deps
  ln -s ../../proper
}

build() {
  local JOBS="$(sed -e 's/.*\(-j *[0-9]\+\).*/\1/' <<< ${MAKEFLAGS})"
  JOBS=${JOBS:- -j$(nproc)}

  rm -f ../${pkgbase}*.log.*

  for d in $(find ${srcdir} -type d -maxdepth 1 -not -name src -not -name pkg -printf "%f\n")
  do
    case $d in
      proper)   cd ${srcdir}/$d && make fast;;
      *)        cd ${srcdir}/$d && make $JOBS;;
    esac
  done
}

inst_dir() {
  echo "${pkgdir}/opt/pkg/${pkgbase}/${pkgver}/$d-$(git describe --always --tags --abbrev=0 | sed 's/^v//')"
}

package() {

  echo "==== Packaging emysql ==="
  BASE="${pkgdir}/opt/pkg/${pkgbase}/${pkgver}"

  for d in $(find ${srcdir} -type d -maxdepth 1 -not -name src -not -name pkg -printf "%f\n")
  do
    cd "${srcdir}"/$d
    DIR=$(inst_dir)
    mkdir -p $DIR
    INC="ebin/*.app ebin/*.beam src/*.erl"
    [ -d "include" ] && INC+=" $(find include -type f -name '*.hrl' -maxdepth 1)"
    [ -d "test"    ] && INC+=" $(find test    -type f -name '*.erl' -maxdepth 1)"
    [ -d "priv"    ] && INC+=" $(find priv    -type f -maxdepth 1)"
    for i in $INC; do  install -m 644 -D $i $DIR/$i; done
  done
  
  cd "${srcdir}"/erlexec
  DIR=$(inst_dir)
  for i in priv/*/*; do install -m 644 -D $i $DIR/$i; done

  cd "${srcdir}"/lager
  DIR=$(inst_dir)
  for i in deps/goldrush/ebin/*.{app,beam} deps/goldrush/src/*.erl; do
    install -m 644 -D $i $DIR/$i
  done

  cd "${srcdir}"/mochiweb
  DIR=$(inst_dir)
  for i in examples/*/*; do install -m 644 -D $i $DIR/$i; done

  cd "${pkgdir}"/opt/pkg/${pkgbase}
  ln -vs ${pkgver} current
}
