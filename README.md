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
- Two layout modes (`compact` and `classic`). The default is `compact`. To use the classic view, set `set -g fcnf_layout classic` in your `config.fish`.
- Displays useful package metadata: size, version, packager, and build date.
- Terminal hyperlinking support to easily navigate to the official Arch Linux package website.