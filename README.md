# fish-pkg-suggest-arch

A `command_not_found` handler for [Fish shell](https://fishshell.com) on Arch Linux. When a command is not found, it queries `pkgfile` to identify the package that provides it and offers an interactive prompt to install it immediately.

<!-- demo.gif -->
![Demonstration](https://github.com/user-attachments/assets/4fd10fe2-dd56-41f4-8b71-c625d1d47ded)

## Requirements

- Arch Linux
- [`pkgfile`](https://archlinux.org/packages/extra/x86_64/pkgfile/)
- [`expac`](https://archlinux.org/packages/extra/x86_64/expac/)

## Installation

**Via Fisher:**

```fish
fisher install huandney/fish-pkg-suggest-arch
```

**Via PKGBUILD** (pulls dependencies automatically):

```bash
git clone https://github.com/huandney/fish-pkg-suggest-arch
cd fish-pkg-suggest-arch
makepkg -si
```

### Configuration requirements

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
- **Batch mode for pipelines**: when a single line references multiple missing commands (e.g. `foo | bar | baz`), the plugin detects them all up front and offers a unified prompt — install all, pick a subset, or cancel — instead of forcing one Enter per missing command.
- Three display modes: `compact`, `classic`, and `minimal`. Default is `compact`.
- Package metadata: version, installed and download size, description, packager, build date.
- Clickable terminal hyperlinks to the official Arch package page (`core`, `extra`, `multilib`).
- Automatic language detection: displays in Portuguese or English based on the system locale.

### How batch mode works

Single missing command: standard reactive flow — the shell fails, the plugin shows the package details, prompts to install. Fast, zero overhead on a normal command.

Two or more missing commands in the same line: a `fish_preexec` hook runs *before* the line executes. It splits on `|`, `&&`, `||`, `;`, `&`, identifies which positions are real commands the system can't resolve, and presents a single summary:

<!-- batch-demo.gif -->

```
:: 2 pacotes ausentes para executar esta linha:

    1  nyancat  →  cachyos-extra-v3/nyancat  v1.5.2-3.1    42KB
       └─ Terminal-based nyancat animation
    2  cmatrix  →  cachyos-extra-v3/cmatrix  v2.0-4.1      95KB
       └─ Matrix screen saver

:: Pacotes a instalar (Enter=todos, ex: 1 2 ou 1-3, c=cancelar):
```

After installing, the original pipeline runs automatically — no need to retype.

## Configuration

### Configuring the layout

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

### Configuring pacman confirmation

By default, Pacman will present its own confirmation prompt (showing download sizes and dependencies) after you say "Yes" to the plugin. If you want a fully automatic installation without the second prompt, enable the fast mode:

```fish
set -U fcnf_pacman_noconfirm true
```

## License

MIT
