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

:: Pacotes a instalar ([T]odos, ex: 1 2 ou 1-3, [C]ancelar):
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

By default, pacman shows its own confirmation prompt (download sizes, dependencies) after the plugin prompts. The interaction looks like this:

```
:: [I]nstalar / [E]xecutar após / [C]ancelar: i

Pacote (1)              Versão nova   Diferença

extra/nyancat           1.5.2-3.1      0,04 MiB

:: Continuar a instalação? [S/n]        ← prompt do pacman
```

To skip the pacman prompt and install immediately after confirming in the plugin:

```fish
set -U fcnf_pacman_noconfirm true
```

### Sudo wrapper

The plugin always defines a shadow `sudo` function. This is necessary so that when the batch flow handles a missing command behind `sudo` (e.g. `sudo cmdA; cmdB`), fish does not later run the original `sudo cmdA` and trigger a stray password prompt before failing. The wrapper has multiple early-exit guards so its impact stays minimal.

Order of decisions inside the function (top-down, fail-fast):

| Guard | Behavior |
|---|---|
| Non-interactive shell (script, CI, hook) | Forwards to `command sudo` immediately. **Native sudo behavior is preserved for any non-human caller.** |
| Command was already handled by the batch flow this turn | Returns silently. Suppresses the stray password prompt. |
| `fcnf_sudo_wrapper` is unset or `false` | Forwards to `command sudo`. **Default off.** |
| No inner command, or it already exists, or no pkgfile cache | Forwards to `command sudo`. |
| TTY interactive prompt | Shows `[I]nstall / [R]un after / [C]ancel`. |

Toggle the interactive prompt at runtime:

```fish
set -U fcnf_sudo_wrapper true    # enable the [I/R/C] prompt for `sudo missing-cmd`
set -U fcnf_sudo_wrapper false   # disable; sudo's native "command not found" is shown
set -e fcnf_sudo_wrapper         # same as false
```

**What the flag does *not* control:**

- The pipeline batch flow (`sudo cmdA; cmdB` with both missing) — runs from `conf.d/` regardless of the flag, because that is the plugin's main value.
- The post-batch suppression that prevents the stray password prompt.

**Compatibility with other `sudo`-wrapping plugins.** This plugin defines a `sudo` function, which shadows any other plugin's `sudo` wrapper in the same fish session — only one definition wins, and load order decides. Even with `fcnf_sudo_wrapper=false`, our function still owns the name and forwards via `command sudo` (the system binary), which deliberately bypasses *every* function wrapper. If you rely on another plugin that wraps `sudo` (password caching, sudoedit helpers, etc.), remove our `sudo.fish` to fully restore the chain — the rest of the plugin keeps working without it. With the dev symlinks, that is `rm ~/.config/fish/functions/sudo.fish`.

## Development

To work on the plugin without going through `makepkg` on every change, symlink the project files into your fish config:

```fish
./dev-link.fish              # creates symlinks in ~/.config/fish
./dev-link.fish --unlink     # removes them
```

After running it, `exec fish` reloads the shell with your live edits. For functions already loaded in the current session (e.g. `sudo`), use `functions --erase <name>` first.

## License

MIT
