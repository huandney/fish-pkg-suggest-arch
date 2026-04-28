# fish-pkg-suggest-arch

A smart `command-not-found` handler for Fish shell on Arch Linux that suggests and allows interactive installation of missing packages.

⚠️ **Requirements:**
- Arch Linux
- `pacman`
- `pkgfile`
- `expac`

## Installation

Using [Fisher](https://github.com/jorgebucaran/fisher):

```fish
fisher install huandney/fish-pkg-suggest-arch
```

Or via AUR (recommended on Arch — pulls dependencies automatically):

```bash
# clone the repo and run makepkg, or use your AUR helper
makepkg -si
```

### Setup `pkgfile`
The plugin needs the `pkgfile` cache initialized to suggest packages. Pick **one**:

- **Manual** — initialize once, update when you want:
  ```bash
  sudo pkgfile -u
  ```
- **Automatic (recommended)** — daily background updates via the timer shipped by `pkgfile`:
  ```bash
  sudo systemctl enable --now pkgfile-update.timer
  ```
- **Pacman hook (advanced)** — refresh after every install/upgrade. Adds 5-30s of synchronous latency to each `pacman` transaction; only worth it if you need fresher data than daily. Create `/etc/pacman.d/hooks/pkgfile-update.hook` yourself if you want this.

If the cache isn't initialized, the plugin will tell you on the first failed command — no silent failures.

## Features
- Interactive prompt `[S/n]` to install missing packages directly from official repositories.
- Three layout modes (`compact`, `classic`, `minimal`). Default is `compact`.
- Useful package metadata: version, install + download size, description (in classic), packager, build date.
- Terminal hyperlinks to the official Arch Linux package page (for `core`, `extra`, `multilib`).

## Configuration

Pick a layout with a fish universal variable:

```fish
set -U fcnf_layout compact   # default — denso, ícones e cores
set -U fcnf_layout classic   # uma linha por campo, mais informação
set -U fcnf_layout minimal   # estilo pacman puro, sem ícones
```

Tab-completion is provided for `fcnf_layout` values.

To preview all three layouts side by side with a real package, run:

```fish
fcnf-preview
```