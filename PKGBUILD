# Maintainer: Seu Nome <seu.email@exemplo.com>

_pkgname=fish-pkg-suggest-arch
pkgname=${_pkgname}-git
pkgver=r1.29f8aff # Will be auto-updated by pkgver()
pkgrel=1
pkgdesc="A smart command-not-found handler for Fish shell on Arch Linux"
arch=('any')
url="https://github.com/huandney/fish-pkg-suggest-arch"
license=('MIT')
depends=('fish' 'pkgfile' 'expac' 'pacman')
makedepends=('git')
provides=("${_pkgname}")
conflicts=("${_pkgname}")
source=("git+${url}.git")
sha256sums=('SKIP')

pkgver() {
  cd "$srcdir/${_pkgname}"
  printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
}

package() {
  cd "$srcdir/${_pkgname}"
  
  # Instala a função no diretório global de vendors do Fish
  install -Dm644 functions/fish_command_not_found.fish \
    "$pkgdir/usr/share/fish/vendor_functions.d/fish_command_not_found.fish"
}
