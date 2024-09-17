# Looking for the correct port
nmap -p 31000-32000 --script ssl-enum-ciphers localhost
nmap -p 31000-32000 --script ssl-enum-ciphers localhost | grep -B1 'ssl-enum-ciphers' | grep '^[0-9]' | awk -F'/' '{print $1}'

# Get key from correct path
cat /etc/bandit_pass/bandit16 | ncat --ssl localhost <PORT>
cat /etc/bandit_pass/bandit16 | ncat --ssl localhost 31790 | grep -v 'Correct' > sshkey.private
chmod 600 sshkey.private
ssh -i sshkey.private bandit17@localhost -p 2220
cat /etc/bandit_pass/bandit17