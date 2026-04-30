import pexpect
import sys

child = pexpect.spawn('fish', encoding='utf-8')
child.expect(r'> ')  # Wait for fish prompt
print("Got prompt, sending command...")
child.sendline('nyancat | cmatrix')

try:
    child.expect('2 pacotes ausentes para executar esta linha', timeout=5)
    print("MATCHED BATCH SUMMARY!")
    child.expect(r'\[T\]odos / \[S\]elecionar / \[C\]ancelar', timeout=5)
    print("Got choice prompt. Sending 'c' for cancel to abort cleanly.")
    child.sendline('c')
    child.expect('Linha cancelada', timeout=5)
    print("SUCCESS: The interactive batch prompt worked!")
except Exception as e:
    print("FAILED TO MATCH BATCH PROMPT")
    print("Before:", child.before)
    print("After:", child.after)
    sys.exit(1)

child.sendline('exit')
child.wait()
