set cmdline 'sudo missing_cmd'
echo $cmdline | fish_indent --dump 2>&1 | string match -rg "! string: '(.*)'"
