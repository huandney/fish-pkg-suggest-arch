#!/usr/bin/env fish
# Manual end-to-end exercise of the preexec batch flow.
# Run from repo root: fish tests/test_flow.fish

set fcnf_layout compact
source functions/__fcnf_i18n.fish
source functions/__fcnf_print.fish
source functions/__fcnf_print_batch_item.fish
source functions/__fcnf_prompt.fish
source functions/__fcnf_install.fish
source functions/fish_command_not_found.fish
source conf.d/fcnf.fish

__fcnf_preexec "nyancat | cmatrix"
