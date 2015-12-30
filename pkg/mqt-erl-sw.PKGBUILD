# vim:ts=2:sw=2:et
# Maintainer: Joel Teichroeb <joel@teichroeb.net>
# Contributor: Jonas Heinrich <onny@project-insanity.org>
# Contributor: Serge Aleynikov <saleyn@gmail.com>

# If TOOLCHAIN env var is set, then the package name
# will contain "-${toolchain}" suffix in lower case
# otherwise, it'll end with "-gcc"
TOOLSET=$(tr '[:upper:]' '[:lower:]' <<< ${TOOLCHAIN:-gcc})

pkgbase=erl-sw
pkgname=mqt-${pkgbase}
pkgver=1.1
pkgrel=1
pkgdesc='Collection of open-source Erlang libraries'
arch=x86_64
license=(Apache)
GTEST=gtest-1.6.0
makedepends=(git rebar)
source=(
  git+https://github.com/rebar/rebar.git
  git+https://github.com/rebar/rebar3.git
  git+https://github.com/archaelus/edump.git
)

noextract=(thrift.zip)

md5sums=( $(for i in `seq 1 ${#source[@]}`; do echo 'SKIP'; done) )

install=mqt-${pkgbase}.install

build() {
  local JOBS="$(sed -e 's/.*\(-j *[0-9]\+\).*/\1/' <<< ${MAKEFLAGS})"
  JOBS=${JOBS:- -j$(nproc)}

  rm -f ../${pkgbase}*.log.*

  for d in rebar rebar3 $(find ${srcdir} -maxdepth 1 -type d -not -name src -not -name pkg ! -name rebar ! -name rebar3 -printf "%f\n")
  do
    echo "Making $d (${srcdir}/$d)"
    case $d in
      rebar)            cd ${srcdir}/$d && ./bootstrap;;
      rebar3)           cd ${srcdir}/$d && ./bootstrap;;
      edump)            cd ${srcdir}/$d && ../rebar3/rebar3 escriptize;;
      *)                cd ${srcdir}/$d
                        make $JOBS;;
    esac
  done
}

inst_dir() {
  local base="${pkgdir}/opt/sw/${pkgbase}/${pkgver}/$1"
  echo "${PWD}" 1>&2
  local ver=$(sed -n 's/.*{vsn,[[:space:]]*"[^0-9\.]*\([^"-+]\+\)\([-+][^"]\+\)\{0,1\}"}.*$/\1/p' ebin/$1.app 2>/dev/null || true)
  if [ -n "$ver" ]; then
    printf "${base}-${ver}"
  else
    ver=$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^[^0-9\.]*//')
    if [ -n "$ver" ]; then
      printf "${base}-${ver}"
    else
      printf "${base}-0.1.%s" $(git rev-list --count HEAD) #$(git rev-parse --short HEAD)
    fi
  fi
}

package() {

  echo "==== Packaging ${pkgbase} ==="
  BASE="${pkgdir}/opt/sw/${pkgbase}/${pkgver}"

  cd "${srcdir}"

  REBAR3="${srcdir}/rebar3/rebar3"

  for d in $(ls -dtr */)
  do
    d=${d%/}
    cd "${srcdir}/${d}"
    d=${d##*/}
    DIR=$(inst_dir $d)
    mkdir -vp $DIR
    INC=""
    for f in $(find -maxdepth 4 -executable -type f -not -iwholename '*.git*' -not -iwholename '*bootstrap' -not -name '*.*'); do
      INC+=" $f"
    done
    [ -d "ebin"    ] && INC+=" $(find ebin    -maxdepth 1 -type f \( -name '*.app' -o -name '*.beam' \))"
    [ -d "src"     ] && INC+=" $(find src     -maxdepth 1 -type f)"
    [ -d "include" ] && INC+=" $(find include -maxdepth 1 -type f -name '*.hrl')"
    [ -d "test"    ] && INC+=" $(find test    -maxdepth 1 -type f -name '*.erl')"
    [ -d "priv"    ] && INC+=" $(find priv    -maxdepth 2 -type f)"
    if [ -d "_build"  ]; then
        [ ! -f "${REBAR3}" ] && echo "rebar3 not found" && exit 1
        path=$(${REBAR3} path)
        files=$(find _build${path##*/_build} -maxdepth 1 -type f \( -name '*.app' -o -name '*.beam' \))
        INC+=" ${files}"
    fi
    for i in $INC; do
      j=$i
      # Strip "_build/.../ebin/*.{app,beam}" to "ebin/*{app,beam}"
      [[ $i == _build/* ]] && [[ "$i" =~ ([^/]+/+[^/]+)/*$ ]] && j=${BASH_REMATCH[1]}
      install -m $(if [ -x "$i" ]; then echo 755; else echo 644; fi) -D $i $DIR/${j};
    done
    #if [ -d "deps" ]; then
    #  cd deps
    #  for i in */ebin/*.{app,beam} */src/*.erl; do install -v -m 644 -D $i $DIR/deps/$i; done
    #fi
  done
  
  mkdir -p "${pkgdir}"/opt/bin

  cd "${srcdir}/edump"
  DIR=$(inst_dir edump)
  cd ${DIR} && ln -vs _build/default/bin/edump

  cd "${pkgdir}"/opt/sw/${pkgbase}
  ln -vs ${pkgver} current
}
