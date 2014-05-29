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
)
# that sucks that the project downloads gtests sources, it should use system libraries
# https://github.com/facebook/folly/issues/48
md5sums=(
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
  mkdir -p "lager/deps"
  cd lager/deps
  ln -s ../../goldrush
}

build() {
  local JOBS="$(sed -e 's/.*\(-j *[0-9]\+\).*/\1/' <<< ${MAKEFLAGS})"
  JOBS=${JOBS:- -j$(nproc)}

  rm -f ../${pkgbase}*.log.*

  cd "$srcdir"/emysql  && make $JOBS
  cd "$srcdir"/erlexec && make $JOBS
  cd "$srcdir"/util    && make $JOBS
  cd "$srcdir"/gen_timed_server && make $JOBS
  cd "$srcdir"/gproc   && make $JOBS
  cd "$srcdir"/lager   && make $JOBS
}

package() {

  echo "==== Packaging emysql ==="
  BASE="${pkgdir}/opt/pkg/${pkgbase}/${pkgver}"

  cd "${srcdir}"/emysql
  DIR="${BASE}/emysql-$(awk -F= '/^VERSION/{print $2; exit}' Makefile)"
  mkdir -p $DIR
  for i in ebin/*.{app,beam} include/*.hrl src/*.erl; do install -m 644 -D $i $DIR/$i; done
  
  cd "${srcdir}"/erlexec
  DIR="${BASE}/erlexec-$(git describe --always --tags --abbrev=0 | sed 's/^v//')"
  mkdir -p $DIR
  for i in ebin/*.{app,beam} include/*.hrl priv/*/* src/*.erl; do install -m 644 -D $i $DIR/$i; done

  cd "${srcdir}"/util
  DIR="${BASE}/util-1.0"
  mkdir -p $DIR
  for i in ebin/*.{app,beam} include/*.hrl src/*.erl; do install -m 644 -D $i $DIR/$i; done

  cd "${srcdir}"/gen_timed_server
  DIR="${BASE}/gen_timed_server-1.0"
  mkdir -p $DIR
  for i in ebin/*.{app,beam} src/*.erl; do install -m 644 -D $i $DIR/$i; done

  cd "${srcdir}"/util
  DIR="${BASE}/gproc-1.0"
  mkdir -p $DIR
  for i in ebin/*.{app,beam} include/*.hrl src/*.erl; do install -m 644 -D $i $DIR/$i; done

  cd "${srcdir}"/lager
  DIR="${BASE}/lager-1.0"
  mkdir -p $DIR
  for i in  ebin/*.{app,beam} include/*.hrl src/*.erl test/*.erl \
            deps/goldrush/ebin/*.{app,beam} deps/goldrush/src/*.erl; do
    install -m 644 -D $i $DIR/$i
  done

  cd "${pkgdir}"/opt/pkg/${pkgbase}
  ln -vs ${pkgver} current
}
