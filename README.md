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

By default, the plugin installs a shadow `sudo` function that intercepts `sudo missing-cmd` and offers an `[I]nstall / [R]un after / [C]ancel` prompt — the same flow as a bare missing command, but for privileged invocations. It also guarantees that when the batch flow handles a missing command behind `sudo` (e.g. `sudo cmdA; cmdB`), fish does not later run the original `sudo cmdA` and trigger a stray password prompt before failing.

The wrapper is **dynamically mounted** by `conf.d/fcnf.fish` based on `fcnf_sudo_wrapper`. The autoload file is named `__fcnf_sudo.fish`, so the name `sudo` is never claimed at the file level — it only exists in memory while the feature is enabled.

| `fcnf_sudo_wrapper` | Effect |
|---|---|
| unset (default) or `true` | The shadow `sudo` function is defined; batch flow descends into `sudo` prefixes. |
| `false` | The shadow function is erased from memory; batch flow ignores `sudo` prefixes entirely. The `sudo` name is fully released — other plugins that wrap `sudo` work normally, and the system `sudo` binary runs without any indirection. |

Toggle at runtime — change takes effect immediately, no reload needed:

```fish
set -U fcnf_sudo_wrapper false   # full kill-switch: native sudo, no interception anywhere
set -U fcnf_sudo_wrapper true    # re-enable
set -e fcnf_sudo_wrapper         # same as true (default)
```

When the wrapper is on, the order of decisions inside the function is (top-down, fail-fast):

| Guard | Behavior |
|---|---|
| Non-interactive shell (subshell, command substitution, script) | Forwards to `command sudo` immediately. |
| Command was already handled by the batch flow this turn | Returns silently. Suppresses the stray password prompt. |
| No inner command, or it already exists, or no pkgfile cache, or no package match | Forwards to `command sudo`. |
| TTY interactive prompt | Shows `[I]nstall / [R]un after / [C]ancel`. |

**Compatibility with other `sudo`-wrapping plugins.** Fish allows only one function definition per name, and load order decides which wins. If you use another plugin that wraps `sudo` (password caching, sudoedit helpers, etc.), set `fcnf_sudo_wrapper false` — our function is removed from memory and the other plugin's wrapper takes over cleanly.

## Development

To work on the plugin without going through `makepkg` on every change, symlink the project files into your fish config:

```fish
./dev-link.fish              # creates symlinks in ~/.config/fish
./dev-link.fish --unlink     # removes them
```

After running it, `exec fish` reloads the shell with your live edits. For functions already loaded in the current session (e.g. `sudo`), use `functions --erase <name>` first.

## License

MIT
