# fish-pkg-suggest-arch

A smart `command-not-found` handler for Fish shell on Arch Linux that suggests and allows interactive installation of missing packages.

⚠️ **Requirements:**
- Arch Linux
- `pacman`
- `pkgfile`
- `expac`

## Installation

Using [Fisher](https://github.com/jorgebucaran/fisher) (recommended):

```fish
fisher install SEU_USUARIO/fish-pkg-suggest-arch
```
*(Substitua `SEU_USUARIO` pelo seu usuário do GitHub assim que este repositório estiver público)*

### Setup `pkgfile`
If you haven't already initialized `pkgfile` on your system, run:
```bash
sudo pacman -S pkgfile expac
sudo pkgfile -u
```

## Features
- Interactive prompt `[S/n]` to install missing packages directly from official repositories.
- Two layout modes (`compact` and `classic`). The default is `compact`. To use the classic view, set `set -g fcnf_layout classic` in your `config.fish`.
- Displays useful package metadata: size, version, packager, and build date.
- Terminal hyperlinking support to easily navigate to the official Arch Linux package website.