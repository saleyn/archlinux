# vim:ts=2:sw=2:et
# Maintainer: Joel Teichroeb <joel@teichroeb.net>
# Contributor: Jonas Heinrich <onny@project-insanity.org>
# Contributor: Serge Aleynikov <saleyn@gmail.com>

# If TOOLCHAIN env var is set, then the package name
# will contain "-${toolchain}" suffix in lower case
# otherwise, it'll end with "-gcc"
TOOLSET=$(tr '[:upper:]' '[:lower:]' <<< ${TOOLCHAIN:-gcc})

pkgbase=erl-libs
pkgname=${pkgbase}
pkgver=1.1
pkgrel=1
pkgdesc='Collection of open-source Erlang libraries'
arch=('x86_64')
license=(Apache)

if [ -d /opt/sw/${pkgbase} ]; then
  BASE="opt/sw"
else
  BASE="opt/pkg"
fi

INSTALL_DIR="${BASE}/${pkgbase}/${pkgver}"
LINK_DIR="opt/pkg/erl-links"

#makedepends=(git rebar saxon-he)
makedepends=(git erl-sw)
source=(
  #emysql::git+https://github.com/Eonblast/Emysql.git
  #escribe::git+https://github.com/saleyn/erl_scribe.git
  #git+https://github.com/erlware/rebar_vsn_plugin.git
  #git+https://github.com/saleyn/secdb.git
  #thrift.zip::https://github.com/saleyn/thrift/archive/uds.zip
  bcrypt::git+https://github.com/saleyn/erlang-bcrypt.git
  git+https://github.com/ninenines/ranch.git
  emmap::git+https://github.com/saleyn/emmap.git ## #branch=atomic
  git+https://github.com/DeadZen/goldrush.git#tag=0.1.6
  git+https://github.com/davisp/jiffy.git
    cowlib::git+https://github.com/ninenines/cowlib.git#branch=master
  #git+https://github.com/maxlapshin/io_libc.git
  #git+https://github.com/mochi/mochiweb.git
  git+https://github.com/erlang/pmod_transform
  git+https://github.com/erlware/erlcron.git
  git+https://github.com/esl/parse_trans.git
  git+https://github.com/extend/sheriff.git
  git+https://github.com/manopapad/proper.git
  git+https://github.com/saleyn/erlsom.git
  git+https://github.com/saleyn/gen_timed_server.git
  git+https://github.com/saleyn/getopt.git#branch=format_error
  git+https://github.com/saleyn/proto.git
  git+https://github.com/saleyn/util.git
  git+https://github.com/saleyn/etran.git
  git+https://github.com/soranoba/bbmustache.git
  git+https://github.com/ninenines/cowboy.git
  sqlite::git+https://github.com/saleyn/erlang-sqlite3.git
  git+https://github.com/saleyn/erlcfg.git
  git+https://github.com/saleyn/erlexec.git
  #git+https://github.com/saleyn/erlfix.git
  git+https://github.com/uwiger/edown.git
  git+https://github.com/uwiger/gproc.git
  git+https://github.com/sile/jsone.git
  mysql::git+https://github.com/mysql-otp/mysql-otp.git
  #git+https://github.com/gen-smtp/gen_smtp.git
  git+https://github.com/saleyn/gen_smtp.git#branch=norm-err
  git+https://github.com/processone/iconv.git
  git+https://github.com/benoitc/cbt.git    #tag=1.2.2
  git+https://github.com/refuge/cowdb.git
  git+https://github.com/yuce/pot.git
)

#noextract=(thrift.zip)

md5sums=( $(for i in `seq 1 ${#source[@]}`; do echo 'SKIP'; done) )

install=${pkgbase}.install

prepare() {
  cd $srcdir
  #rm -fr erl ethrift
  #bsdtar -xf thrift.zip --strip-components=2 thrift-uds/lib/erl
  #mv erl ethrift

  rm util/src/decompiler.erl

  # Install links to deps by reading {deps, [...]} entry in rebar.config
  # for each project
  for f in $(find . -maxdepth 1 -type d -not -name '.' \
                                        -not -name src \
                                        -not -name pkg \
                                        -not -name 'rebar*' \
                                        -printf "%f\n"); do
    cd $srcdir/$f
    if [ -f rebar.config ]; then
      DEPS=( $(erl -eval 'case file:consult("rebar.config") of
                            {ok, L} ->
                              case proplists:get_value(deps, L, []) of
                                [] -> "";
                                V -> [io:format("~p\n", [element(1,I)]) || I <- V]
                              end;
                            _ ->
                              io:format(standard_error, "No rebar.config found\n", [])
                          end, halt(0).' -noinput -noshell) )
      if [ ${#DEPS[@]} -gt 0 ]; then
        echo "Link dependencies of '$f': ${DEPS[@]}"

        mkdir -p deps
        cd deps

        for p in ${DEPS[@]}; do ln -fs ../../$p; done
      fi
    fi
  done

  cd $srcdir
}

function do_process() {
  local d="$1"
  cd "${srcdir}/$d"
  echo "Building $d"
  case $d in
    bbmustache|\
    erlcron|\
    io_libc|\
    jsone|\
    gproc|\
    rebar_vsn_plugin|\
    proper|\
    cbt|\
    etran|\
    cowdb)
                      rebar compile;;
    iconv)            wget -q -P src https://raw.githubusercontent.com/processone/p1_utils/master/src/p1_nif_utils.erl
                      rebar compile;;

    emmap)            rebar3 compile;;

    gen_smtp)         rebar3 upgrade ranch
                      rebar3 compile;;
    *)                echo "Making $d ($PWD})"
                      make $JOBS;;
  esac
}

build() {
  local JOBS="$(sed -e 's/.*\(-j *[0-9]\+\).*/\1/' <<< ${MAKEFLAGS})"
  JOBS=${JOBS:- -j$(nproc)}

  rm -f ../${pkgbase}*.log.*

  [ -z "$(whereis -b rebar  | awk '{print $2}')" ] && echo "Rebar not found in path!"  && exit 1
  [ -z "$(whereis -b rebar3 | awk '{print $2}')" ] && echo "Rebar3 not found in path!" && exit 1

  echo "DIR: ${srcdir}"

  for d in $(find ${srcdir} -maxdepth 1 -type d -name 'rebar*'); do
    cd "$d"
    echo "Building ${d##*/}"
    ./bootstrap
  done

  export srcdir
  export -f do_process

  if [ -z "$SKIP_BUILD" ]; then
    find ${srcdir} -maxdepth 1 -type d -not -name src -not -name pkg -not -name 'rebar*' -printf "%f\n" | \
      parallel --max-args 1 ${JOBS} do_process {}
  fi
}

inst_dir() {
  local base="${INSTALL_DIR}/$1"
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

warn_build_references() {
  : # Don't consider build references to $src_dir to be a problem
  return 0
}

package() {

  echo "==== Packaging ${pkgbase} ==="

  cd "${srcdir}"

  # Install rebar
  [ "$OS" = "Windows_NT" ] && BIN_DIR="${pkgdir}/c/bin" || BIN_DIR="${pkgdir}/opt/bin"

  mkdir -p "$BIN_DIR"

  for d in $(ls -dtr */); do
    d=${d%/}
    cd "${srcdir}/${d}"
    d=${d##*/}
    DIR=$(inst_dir $d)

    ! mkdir -p $DIR && echo "Cannot create dir '$DIR' (pwd=$PWD)" && exit 1
    INC=""
    [ -d "bin"     ] && INC+=" $(find bin     -maxdepth 1 -type f)"
    [ -d "ebin"    ] && INC+=" $(find ebin    -maxdepth 1 -type f \( -name '*.app' -o -name '*.beam' \))"
    [ -d "src"     ] && INC+=" $(find src     -maxdepth 1 -type f)"
    [ -d "include" ] && INC+=" $(find include -maxdepth 1 -type f -name '*.hrl')"
    [ -d "test"    ] && INC+=" $(find test    -maxdepth 1 -type f -name '*.erl')"
    [ -d "priv"    ] && INC+=" $(find priv    -maxdepth 2 -type f)"
    if [ -d "_build"  ]; then
        path=$(rebar3 path)
        files=$(find _build${path##*/_build} -maxdepth 1 -type f \( -name '*.app' -o -name '*.beam' \))
        INC+=" ${files}"
    fi

    for i in $INC; do
      j=$i
      # Strip "_build/.../ebin/*.{app,beam}" to "ebin/*{app,beam}"
      [[ $i == _build/* ]] && [[ "$i" =~ ([^/]+/+[^/]+)/*$ ]] && j=${BASH_REMATCH[1]}
      [ -x "$i" ] && M=755 || M=644
      ! install -m $M -D $i ${pkgdir}/$DIR/${j} && echo "Failed to install '$i' to '${pkgdir}/$DIR/${j}'" && exit 1
    done

    LINK="${d%%-*}"
    mkdir -pv "${pkgdir}/${LINK_DIR}"
    cd "${pkgdir}/${LINK_DIR}"
    ln -fs "/${DIR}" "${LINK}"
    #if [ -d "deps" ]; then
    #  cd deps
    #  for i in */ebin/*.{app,beam} */src/*.erl; do install -v -m 644 -D $i $DIR/deps/$i; done
    #fi
  done
  
  #cd "${srcdir}"/erlexec
  #DIR=$(inst_dir erlexec)
  #for i in priv/*/*; do install -m 755 -D $i $DIR/$i; done

  #cd "${srcdir}"/mochiweb
  #DIR=$(inst_dir mochiweb)
  #for i in examples/*/*; do install -m 644 -D $i $DIR/$i; done

  echo "Pkg:     ${pkgdir}"
  echo "Install: /${INSTALL_DIR}"
  cd "${pkgdir}/${INSTALL_DIR%/*}"
  ln -vfs ${pkgver} current
}
