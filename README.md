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


Both modes also work behind `sudo` (e.g. `sudo missing-cmd` or `sudo cmdA; cmdB`) and behind background operators (`cmd1 & cmd2`). When the line contains a single missing command running solo in background (`nyancat &`), the plugin stays silent — interactive prompts can't run from a backgrounded job. Language auto-detects from the system locale (Portuguese / English).

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

All settings live in universal variables (persist across sessions). Use the `fcnf` command for scoped feedback:

```fish
fcnf on | off | default         # Master toggle (default: on)
fcnf layout <style> | default   # compact, classic, minimal (default: compact)
fcnf pacman auto | manual       # skip pacman [Y/n] prompt (default: manual)
fcnf batch  on | off            # batch mode for pipelines (default: on)
fcnf sudo   on | off            # shadow sudo wrapper (default: on)

fcnf status                     # show current configuration
fcnf preview                    # preview all layouts side by side
fcnf help                       # show usage
```

Fish completions are provided for `fcnf`, including localized descriptions for commands and values.

> Direct `set -U fcnf_*` still works, but won't print the confirmation message. The `fcnf` command exists specifically to scope feedback to the originating session.

**Note:** The `fcnf off/on/default` commands act as a master toggle. When disabled, the plugin bypasses all its logic (including command-not-found prompts, batch mode, and the sudo wrapper) and reverts to standard shell behavior, overriding all other individual settings.

### Batch mode

Batch mode triggers on any line with **two or more real commands** (pipeline, `&&`, `||`, `;`, `&`), regardless of how many of them are missing. A line like `sudo nyancat | cmatrix` (only `nyancat` missing) shows the batch list because the single-mode prompt would be intrusive mid-pipeline.

When off (`fcnf batch off`):

- A line with a single command still triggers the regular single-mode prompt.
- A line with **two or more commands** is silenced entirely — no batch summary, no per-command prompts. You see only fish's native `command not found` errors. This avoids a "machine-gun" of prompts when you only wanted single mode.

Caveat: the post-batch sudo-password suppression (which prevents a stray password prompt when you cancel a `sudo cmdA; cmdB` line) only runs when batch is on. `sudo missing-cmd` alone still works normally via the sudo wrapper.

### Sudo wrapper

By default, the plugin mounts a shadow `sudo` function that intercepts `sudo missing-cmd` and offers `[I]nstall / [R]un after / [C]ancel`. It also prevents a stray password prompt when the batch flow has just handled a missing command behind `sudo`.

The wrapper is **dynamically mounted** at runtime by `conf.d/fcnf.fish`. The autoload file is named `__fcnf_sudo.fish`, so the name `sudo` is never claimed at the file level — it only exists in memory while enabled.

| State | Effect |
|---|---|
| `fcnf sudo on` (default) | Shadow `sudo` function is defined; batch flow descends into `sudo` prefixes. |
| `fcnf sudo off` | Shadow function is erased; batch flow ignores `sudo`. The `sudo` name is fully released — other plugins that wrap `sudo` work normally. |

Decision flow when the wrapper is on (top-down, fail-fast):

| Guard | Behavior |
|---|---|
| Non-interactive context (subshell, command substitution, script) | Forwards to `command sudo`. |
| Command was already handled by the batch flow this turn | Returns silently. |
| No inner command, command already exists, no pkgfile cache, or no package match | Forwards to `command sudo`. |
| TTY interactive prompt | Shows `[I]nstall / [R]un after / [C]ancel`. |

**Compatibility with other `sudo`-wrapping plugins.** Fish allows only one function definition per name. If you use another plugin that wraps `sudo`, run `fcnf sudo off` — our function is removed from memory and the other plugin takes over cleanly.

## Development

Symlink the project into your fish config to iterate without `makepkg`:

```fish
./dev-link.fish              # creates symlinks in ~/.config/fish
./dev-link.fish --unlink     # removes them
```

After running it, `exec fish` reloads the shell. For functions already loaded in the current session (e.g. `sudo`), `functions --erase <name>` first.

## License

MIT
