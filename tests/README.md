# tests/

Exploratory scripts kept around as reference while iterating on the preexec
batch flow. Not a real test suite — these are throwaway probes that proved a
particular Fish/parser behavior.

| File | What it shows |
|---|---|
| `test.fish` | Validates the command-token regex against quoted strings |
| `test2.fish` | Probes `fish_indent --dump` for AST-style parsing (not used in production) |
| `test3.fish` | Pipeline split via `\|\|\|&&\|\|\|;\|&` regex + sentinel |
| `test4.fish` | Same with the simpler `[\|&;]+` regex (current implementation) |
| `test_parse.fish` | Phase 1 in-memory filtering, end to end |
| `test_pkg.fish` | Phase 2 pkgfile resolution loop |
| `test_flow.fish` | Full preexec invocation with mocked cmdline |
| `test_flow2.fish` | Phase 2 only, standalone |
| `test_stty.fish` | Demonstrates the raw-mode terminal issue inside `fish_preexec` |
| `test_parse_amp.fish` | Split-on-`&` probe (background ops): proves `nyancat & cmatrix & tree` segments correctly |
| `test_fg_bg.fish` | Foreground/background detection inside a function via `pgrp` vs `tpgid` |
| `test_bg_handler_read.fish` | Probe whether `read` inside `fish_command_not_found` works when invoked from a background job |

Run from the repo root, e.g. `fish tests/test_flow.fish`.
