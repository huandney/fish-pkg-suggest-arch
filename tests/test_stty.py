import pexpect
child = pexpect.spawn('fish', encoding='utf-8')
child.expect(r'> ')
child.sendline('function pre --on-event fish_preexec; stty -a; end')
child.expect(r'> ')
child.sendline('echo foo')
child.expect(r'> ')
print(child.before)
