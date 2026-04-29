# Maintainer: huandney <huandney@gmail.com>

_pkgname=fish-pkg-suggest-arch
pkgname=${_pkgname}-git
pkgver=r20.f72e3c9 # Will be auto-updated by pkgver()
pkgrel=1
pkgdesc="A smart command-not-found handler for Fish shell on Arch Linux"
arch=('any')
url="https://github.com/huandney/fish-pkg-suggest-arch"
license=('MIT')
depends=('fish' 'pkgfile' 'expac' 'pacman')
makedepends=('git')
provides=("${_pkgname}")
conflicts=("${_pkgname}")
source=("git+file://${PWD}#branch=feature/sudo-wrapper-optin")
sha256sums=('SKIP')

pkgver() {
  cd "$srcdir/${_pkgname}"
  printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
}

package() {
  cd "$srcdir/${_pkgname}"

  install -Dm644 functions/fish_command_not_found.fish \
    "$pkgdir/usr/share/fish/vendor_functions.d/fish_command_not_found.fish"
  install -Dm644 functions/__fcnf_i18n.fish \
    "$pkgdir/usr/share/fish/vendor_functions.d/__fcnf_i18n.fish"
  install -Dm644 functions/__fcnf_print.fish \
    "$pkgdir/usr/share/fish/vendor_functions.d/__fcnf_print.fish"
  install -Dm644 functions/__fcnf_print_batch_item.fish \
    "$pkgdir/usr/share/fish/vendor_functions.d/__fcnf_print_batch_item.fish"
  install -Dm644 functions/__fcnf_prompt.fish \
    "$pkgdir/usr/share/fish/vendor_functions.d/__fcnf_prompt.fish"
  install -Dm644 functions/__fcnf_install.fish \
    "$pkgdir/usr/share/fish/vendor_functions.d/__fcnf_install.fish"
  install -Dm644 functions/sudo.fish \
    "$pkgdir/usr/share/fish/vendor_functions.d/sudo.fish"
  install -Dm644 functions/fcnf-preview.fish \
    "$pkgdir/usr/share/fish/vendor_functions.d/fcnf-preview.fish"
  install -Dm644 completions/fcnf.fish \
    "$pkgdir/usr/share/fish/vendor_completions.d/fcnf.fish"
  install -Dm644 conf.d/fcnf.fish \
    "$pkgdir/usr/share/fish/vendor_conf.d/fcnf.fish"
}
