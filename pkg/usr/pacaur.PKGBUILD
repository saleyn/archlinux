pkgname='pacaur'
pkgver=4.8.6
pkgrel=1
pkgdesc='An AUR helper that minimizes user interaction'
arch=('any')
url="https://github.com/E5ten/${pkgname}"
license=('ISC')
depends=('expac' 'sudo' 'git' 'jq' 'make')
makedepends=('perl' 'git')
backup=("etc/xdg/${pkgname}/config")
source=("git+${url}#tag=${pkgver}")
sha256sums=('SKIP')

build() {
  [ ! -d auracle-git ] && git clone https://aur.archlinux.org/auracle-git.git || true
  cd auracle-git
  git pull origin master
  makepkg -si --noconfirm --noprogressbar
}

package() {
  make -C "${srcdir}/${pkgname}" DESTDIR="${pkgdir}" PREFIX='/usr' install
}
