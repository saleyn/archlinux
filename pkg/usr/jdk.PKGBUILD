# Maintainer: Det
# Based on jre: https://aur.archlinux.org/packages.php?ID=51908

pkgname=jdk
_major=8
_minor=5
_build=b13
pkgver=${_major}u${_minor}
pkgrel=1
pkgdesc="Java Development Kit"
arch=('x86_64')
url=http://www.oracle.com/technetwork/java/javase/downloads/index.html
license=('custom')
depends=('desktop-file-utils' 'hicolor-icon-theme' 'libx11' 'libxrender' 'libxslt' 'libxtst' 'shared-mime-info' 'xdg-utils')
optdepends=('alsa-lib: sound'
            'ttf-dejavu: fonts')
provides=("java-environment=${_major}" "java-runtime=${_major}" "java-runtime-headless=${_major}" "java-web-start=${_major}")
conflicts=("${provides[@]}" "${provides[@]/${_major}/7}")
backup=('etc/profile.d/jdk.sh')
install=${pkgname}.install
# Workaround for the AUR Web interface Source parser
_arch=x64
_arch2=amd64
if [ "${CARCH}" = 'i686' ]; then
  _arch=i586
  _arch2=i386
fi
source=("http://download.oracle.com/otn-pub/java/jdk/${pkgver}-${_build}/${pkgname}-${pkgver}-linux-${_arch}.tar.gz")
md5sums=(`curl -sL ${url/i*}/javase8-binaries-checksum-2133161.html | sed -nr "s|.*>${source##*/}</td> *<td>(<*[^<]*).*|\1|p"`)
## Alternative mirrors, if your local one is throttled:
#source[0]="http://ftp.wsisiz.edu.pl/pub/pc/pozyteczne%20oprogramowanie/java/${pkgname}-${pkgver}-linux-${_arch}.tar.gz"
#source[0]="http://uni-smr.ac.ru/archive/dev/java/SDKs/sun/j2se/${_major}/jdk-${pkgver}-linux-${_arch}.tar.gz"

DLAGENTS=('http::/usr/bin/curl -LC - -b "oraclelicense=a" -O')

package() {
  msg2 "Creating required dirs"
  cd ${pkgname}1.${_major}.0_0${_minor}
  mkdir -p "${pkgdir}"/{opt/sw/java/,usr/{lib/{mozilla/plugins,systemd/system},share/licenses/jdk},etc/{.java/.systemPrefs,profile.d}}

  msg2 "Removing redundancies"
  rm -r db/bin/*.bat jre/{plugin/,COPYRIGHT,LICENSE,*.txt} man/ja # lib/{desktop,visualvm/platform/docs}

  msg2 "Moving stuff in place"
  mv jre/lib/desktop/* man "${pkgdir}"/usr/share/
  mv COPYRIGHT LICENSE *.txt "${pkgdir}"/usr/share/licenses/jdk/
  mv * "${pkgdir}"/opt/sw/java/

  msg2 "Symlinking plugin"
  ln -s /opt/sw/java/jre/lib/${_arch2}/libnpjp2.so "${pkgdir}"/usr/lib/mozilla/plugins/

  msg2 "Installing additions"
  cd "${srcdir}"

  msg2 "Tweaking javaws .desktop"
  sed -e 's/Exec=javaws/&-launcher %f/' \
      -e '/NoDisplay=true/d' \
      -i "${pkgdir}"/usr/share/applications/sun-javaws.desktop
}
