# fish-pkg-suggest-arch

A `command_not_found` handler for [Fish shell](https://fishshell.com) on Arch Linux. When a command is not found, it queries `pkgfile` to identify the package that provides it and offers an interactive prompt to install it immediately.

<!-- demo.gif -->
<img width="792" height="445" alt="Recording 2026-04-28 at 05 37 52" src="https://github.com/user-attachments/assets/4fd10fe2-dd56-41f4-8b71-c625d1d47ded" />



## Requirements

- Arch Linux
- [`pkgfile`](https://archlinux.org/packages/extra/x86_64/pkgfile/)
- [`expac`](https://archlinux.org/packages/extra/x86_64/expac/)

## Installation

**Via Fisher:**

```fish
fisher install huandney/fish-pkg-suggest-arch
```

**Via AUR** (pulls dependencies automatically):

```bash
makepkg -si
```

### Setting up pkgfile

The plugin requires the `pkgfile` file database to be initialized. Choose one option:

- **Manual** — run once, update on demand:
  ```bash
  sudo pkgfile -u
  ```

- **Systemd timer** (recommended) — automatic daily updates:
  ```bash
  sudo systemctl enable --now pkgfile-update.timer
  ```

- **Pacman hook** (advanced) — updates after every pacman transaction. Adds a few seconds of latency per install; only worthwhile if daily updates are not fresh enough. See the [pkgfile wiki](https://wiki.archlinux.org/title/Pkgfile) for hook setup.

If the cache is not initialized, the plugin will tell you on the first failed command.

## Features

- Interactive `[Y/n]` prompt to install the missing package without leaving the shell.
- Three display modes: `compact`, `classic`, and `minimal`. Default is `compact`.
- Package metadata: version, installed and download size, description, packager, build date.
- Clickable terminal hyperlinks to the official Arch package page (`core`, `extra`, `multilib`).
- Automatic language detection: displays in Portuguese or English based on the system locale.

## Configuration

Set a layout persistently with a universal variable:

```fish
set -U fcnf_layout compact   # default — dense, icons and colors
set -U fcnf_layout classic   # one line per field, more information
set -U fcnf_layout minimal   # pure pacman style, no icons
```

Tab-completion is available for `fcnf_layout` values.

To preview all three layouts with a real package:

```fish
fcnf-preview
```

## License

MIT
