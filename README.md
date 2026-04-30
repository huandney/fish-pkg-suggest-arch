# fish-pkg-suggest-arch

A `command_not_found` handler for [Fish shell](https://fishshell.com) on Arch Linux. When a command is missing, it queries `pkgfile` to identify the package that provides it and prompts you to install it on the spot — for a single command or for an entire pipeline of missing commands at once.

## Modes

### Single mode — one missing command

Standard reactive flow: the shell fails, the plugin prints the package details and asks. Zero overhead on a normal command.

<!-- single-demo.gif -->
![Single mode](https://github.com/user-attachments/assets/1d5a9df5-35d1-4c02-b03e-9cd57f1f26bb)

### Batch mode — pipeline with two or more missing commands

A `fish_preexec` hook runs *before* the line executes, splits on `|`, `&&`, `||`, `;`, `&`, identifies which positions are real commands the system can't resolve, and presents a single unified prompt. Pick all, a subset, or cancel — no need to retype the line afterwards.

<!-- batch-demo.gif -->
![Single mode](https://github.com/user-attachments/assets/73fec785-abf5-48f6-9898-7a6e93266bd1)


Both modes also work behind `sudo` (e.g. `sudo missing-cmd` or `sudo cmdA; cmdB`). Language auto-detects from the system locale (Portuguese / English).

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

### Initialize the pkgfile database

The plugin needs `pkgfile`'s file database. Pick one:

- **Manual**: `sudo pkgfile -u` (run once, refresh on demand).
- **Systemd timer (recommended)**: `sudo systemctl enable --now pkgfile-update.timer`.
- **Pacman hook (advanced)**: refreshes after every pacman transaction. Adds latency per install. See the [pkgfile wiki](https://wiki.archlinux.org/title/Pkgfile).

If the cache is missing, the plugin tells you on the first failed command.

## Configuration

All options are universal variables. Changes take effect immediately, no reload needed.

All options are universal variables, so they persist across sessions. Each block below lists the available values — copy the line you want.

```fish
# Master kill-switch (default: enabled)
set -U fcnf_enabled false   # plugin out of the way: native pkgfile suggestion + fish default
set -U fcnf_enabled true    # re-enable
set -e fcnf_enabled         # remove the variable (= default = enabled)

# Layout (default: compact). Run `fcnf-preview` to compare all three.
set -U fcnf_layout compact
set -U fcnf_layout classic
set -U fcnf_layout minimal

# Skip pacman's own "Continuar? [S/n]" prompt (default: off)
set -U fcnf_pacman_noconfirm true
set -U fcnf_pacman_noconfirm false

# Batch mode for pipelines (default: enabled)
set -U fcnf_batch_mode false   # 1 missing = single prompt; 2+ missing = silent, native fish errors only
set -U fcnf_batch_mode true

# Sudo wrapper (default: enabled). See section below for the decision flow.
set -U fcnf_sudo_wrapper false   # erase shadow sudo + ignore sudo in batch flow
set -U fcnf_sudo_wrapper true
```

### Master kill-switch (`fcnf_enabled`)

Useful for debugging a script or isolating interference without uninstalling.

```fish
set -U fcnf_enabled false   # plugin out of the way
set -U fcnf_enabled true    # re-enable
set -e fcnf_enabled         # same as true (default)
```

When `false`: `fish_command_not_found` mirrors the standard `pkgfile` suggestion (then falls back to fish's default), the preexec hook short-circuits, and the shadow `sudo` function is erased from memory. This flag takes precedence over `fcnf_sudo_wrapper`.

### Batch mode (`fcnf_batch_mode`)

When `false`:

- A line with **one** missing command still triggers the regular single-mode prompt.
- A line with **two or more** missing commands is silenced entirely — no batch summary, no per-command prompts. You see only fish's native `command not found` errors. This avoids a "machine-gun" of prompts when you only wanted single mode.

Caveat: the post-batch sudo-password suppression (which prevents a stray password prompt when you cancel a `sudo cmdA; cmdB` line) only runs when batch is on. `sudo missing-cmd` alone still works normally via the sudo wrapper.

### Sudo wrapper (`fcnf_sudo_wrapper`)

By default, the plugin mounts a shadow `sudo` function that intercepts `sudo missing-cmd` and offers `[I]nstall / [R]un after / [C]ancel`. It also prevents a stray password prompt when the batch flow has just handled a missing command behind `sudo`.

The wrapper is **dynamically mounted** at runtime by `conf.d/fcnf.fish`. The autoload file is named `__fcnf_sudo.fish`, so the name `sudo` is never claimed at the file level — it only exists in memory while enabled.

| `fcnf_sudo_wrapper` | Effect |
|---|---|
| unset (default) or `true` | Shadow `sudo` function is defined; batch flow descends into `sudo` prefixes. |
| `false` | Shadow function is erased; batch flow ignores `sudo`. The `sudo` name is fully released — other plugins that wrap `sudo` work normally. |

Decision flow when the wrapper is on (top-down, fail-fast):

| Guard | Behavior |
|---|---|
| Non-interactive context (subshell, command substitution, script) | Forwards to `command sudo`. |
| Command was already handled by the batch flow this turn | Returns silently. |
| No inner command, command already exists, no pkgfile cache, or no package match | Forwards to `command sudo`. |
| TTY interactive prompt | Shows `[I]nstall / [R]un after / [C]ancel`. |

**Compatibility with other `sudo`-wrapping plugins.** Fish allows only one function definition per name. If you use another plugin that wraps `sudo`, set `fcnf_sudo_wrapper false` — our function is removed from memory and the other plugin takes over cleanly.

## Development

Symlink the project into your fish config to iterate without `makepkg`:

```fish
./dev-link.fish              # creates symlinks in ~/.config/fish
./dev-link.fish --unlink     # removes them
```

After running it, `exec fish` reloads the shell. For functions already loaded in the current session (e.g. `sudo`), `functions --erase <name>` first.

## License

MIT
