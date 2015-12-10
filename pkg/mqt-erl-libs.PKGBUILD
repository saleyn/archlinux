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
makedepends=(git rebar saxon-he)
source=(
  git+https://github.com/erlang/pmod_transform
  git+https://github.com/saleyn/erlsom.git
  git+https://github.com/saleyn/erlcfg.git
  bcrypt::git+https://github.com/saleyn/erlang-bcrypt.git
  git+https://github.com/saleyn/proto.git
  emmap::git+https://github.com/saleyn/emmap.git#branch=atomic
  #git+https://github.com/saleyn/secdb.git
  git+https://github.com/erlware/rebar_vsn_plugin.git
  git+https://github.com/erlware/erlcron.git
  git+https://github.com/saleyn/erlfix.git
  git+https://github.com/uwiger/edown.git
  git+https://github.com/esl/parse_trans.git
  git+https://github.com/extend/sheriff.git
  mysql::git+https://github.com/mysql-otp/mysql-otp
  #emysql::git+https://github.com/Eonblast/Emysql.git
  cowlib::git+https://github.com/ninenines/cowlib.git#branch=master
  git+https://github.com/ninenines/ranch.git
  git+https://github.com/ninenines/cowboy.git
  git+https://github.com/saleyn/erlexec
  git+https://github.com/saleyn/util
  git+https://github.com/saleyn/gen_timed_server
  git+https://github.com/uwiger/gproc.git
  git+https://github.com/basho/lager.git
  git+https://github.com/DeadZen/goldrush.git#tag=0.1.6
  git+https://github.com/mochi/mochiweb.git
  git+https://github.com/davisp/jiffy.git
  git+https://github.com/maxlapshin/io_libc.git
  git+https://github.com/manopapad/proper.git
  git+https://github.com/saleyn/getopt.git#branch=format_error
  git+https://github.com/massemanet/eper.git
  thrift.zip::https://github.com/saleyn/thrift/archive/uds.zip
  escribe::git+https://github.com/saleyn/erl_scribe.git
)

noextract=(thrift.zip)

md5sums=( $(for i in `seq 1 ${#source[@]}`; do echo 'SKIP'; done) )

install=mqt-${pkgbase}.install

prepare() {
  cd $srcdir
  rm -fr erl ethrift
  bsdtar -xf thrift.zip --strip-components=2 thrift-uds/lib/erl
  mv erl ethrift

  rm util/src/decompiler.erl
  cd $srcdir
  mkdir -p "lager/deps"
  cd $srcdir/lager/deps
  ln -fs ../../goldrush

  cd $srcdir
  mkdir -p jiffy/deps
  cd $srcdir/jiffy/deps
  ln -fs ../../proper

  cd $srcdir
  mkdir -p parse_trans/deps
  cd $srcdir/parse_trans/deps
  ln -fs ../../edown

  cd $srcdir
  mkdir -p sheriff/deps
  cd $srcdir/sheriff/deps
  ln -fs ../../parse_trans
  ln -fs ../../edown

  cd $srcdir
  mkdir -p erlcron/deps
  cd $srcdir/erlcron/deps
  ln -fs ../../rebar_vsn_plugin

  cd $srcdir
  mkdir -p emmap/deps
  cd $srcdir/emmap/deps
  ln -fs ../../edown

  cd $srcdir
  mkdir -p erlcfg/deps
  cd $srcdir/erlcfg/deps
  ln -fs ../../pmod_transform

  cd $srcdir
  mkdir -p cowboy/deps
  cd $srcdir/cowboy/deps
  ln -fs ../../cowlib
  ln -fs ../../ranch
}

build() {
  local JOBS="$(sed -e 's/.*\(-j *[0-9]\+\).*/\1/' <<< ${MAKEFLAGS})"
  JOBS=${JOBS:- -j$(nproc)}

  rm -f ../${pkgbase}*.log.*

  for d in $(find ${srcdir} -maxdepth 1 -type d -not -name src -not -name pkg -printf "%f\n")
  do
    case $d in
      proper)           cd ${srcdir}/$d && make fast;;
      rebar_vsn_plugin) cd ${srcdir}/$d && make compile;;
      stockdb)          cd ${srcdir}/$d && make app;;
      erlcron)          cd ${srcdir}/$d && make compile;;
      ethrift)          cd ${srcdir}/$d && rebar compile;;
      io_libc)          cd ${srcdir}/$d && rebar compile;;
      emmap)            cd ${srcdir}/$d && rebar compile;;
      *)                cd ${srcdir}/$d
                        echo "Making $d ($PWD})"
                        make $JOBS;;
    esac
  done
}

inst_dir() {
  local base="${pkgdir}/opt/pkg/${pkgbase}/${pkgver}/$1"
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
  BASE="${pkgdir}/opt/pkg/${pkgbase}/${pkgver}"

  cd "${srcdir}"

  for d in $(ls -dtr */)
  do
    d=${d%/}
    cd "${srcdir}/${d}"
    d=${d##*/}
    DIR=$(inst_dir $d)
    mkdir -vp $DIR
    INC=""
    [ -d "bin"     ] && INC+=" $(find bin     -maxdepth 1 -type f)"
    [ -d "ebin"    ] && INC+=" $(find ebin    -maxdepth 1 -type f \( -name '*.app' -o -name '*.beam' \))"
    [ -d "_build"  ] && INC+=" $(find $(find _build -type f \( -name ${d}.app \) -printf '%h') \
                                      -maxdepth 1 -type f \( -name '*.app' -o -name '*.beam' \))"
    [ -d "src"     ] && INC+=" $(find src     -maxdepth 1 -type f)"
    [ -d "include" ] && INC+=" $(find include -maxdepth 1 -type f -name '*.hrl')"
    [ -d "test"    ] && INC+=" $(find test    -maxdepth 1 -type f -name '*.erl')"
    [ -d "priv"    ] && INC+=" $(find priv    -maxdepth 2 -type f)"
    for i in $INC; do
      j=$i
      [[ $i == _build/* ]] && j="ebin/${i##*/}"
      install -m $(if [ -x "$i" ]; then echo 755; else echo 644; fi) -D $i $DIR/${j};
    done
    #if [ -d "deps" ]; then
    #  cd deps
    #  for i in */ebin/*.{app,beam} */src/*.erl; do install -v -m 644 -D $i $DIR/deps/$i; done
    #fi
  done
  
  cd "${srcdir}"/erlexec
  DIR=$(inst_dir erlexec)
  for i in priv/*/*; do install -m 755 -D $i $DIR/$i; done

  cd "${srcdir}"/mochiweb
  DIR=$(inst_dir mochiweb)
  for i in examples/*/*; do install -m 644 -D $i $DIR/$i; done

  cd "${srcdir}"/eper
  DIR=$(inst_dir eper)
  install -m 755 -d "$DIR/bin"
  install -m 755 -d "${pkgdir}/opt/bin"
  for f in priv/bin/*; do cd $DIR/bin && ln -vs ../$f; done
  
  cd "${pkgdir}"/opt/pkg/${pkgbase}
  ln -vs ${pkgver} current
}
