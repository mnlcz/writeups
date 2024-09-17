# Bandit

## Room 00

Understand general workflow of the rooms.

- Connect via SSH with given credentials at specific host with specific port.
- Get password of the next room from `readme` file.

## Room 01

Basic commands (`cd`, `ls`, `file`, etc) and working with special characters.

- Connect via SSH with new user and the password found on the previous room.
- Next password is located in a file named `-` in home directory.

### Special characters

To interact with the file named `-` the user has to write it with the path: `./-`. Because doing, for example, `file -` or `file '-'` won't work.

## Room 02

Same commands as previous room. This time the file contains spaces.

- Use the password from previous room.
- Password is located in a file name `spaces in this filename`.

### Spaces in filename

Nothing out of the ordinary, interact with the file using quotes. Example: `cat "file one"`.

## Room 03

The password is in a hidden file.

- Use the password from previous room.
- The hidden file is in the directory named `inhere`.

### Hidden files

Using `ls` just like that won't show hidden files, im pretty sure there are some parameters to change its behavior. I personally use the command `ll`.

## Room 04

Unreadable files, using the command `reset` to fix the terminal.

- Use the password from previous room.
- Using `cat` on unreadable files will mess up the terminal. Use `reset` and keep searching until finding the only human-readable
file.

### Fix the terminal

OverTheWire tells the user to use the command `reset`. I tried using CTRL+L (clear) and works too, at least on my terminal.

## Room 05

Multi-property file search with `find` . The password is stored in a file that has all the properties given by the problem.

- As always, use the password from previous room to log in via SSH.
- Move to the `inhere` directory and find the file that has the following properties:
  - Human readable.
  - 1033 bytes in size.
  - Not executable.

### Multi-property file search

This problem can be solved by using the `find` command with specific filters. In particular, the following ones:

```shell
find . -type f -size 1033c ! -executable
```

Where each part corresponds to:

- `find .`: search on the current directory.
- `-type f`: search a file of type *regular file*.
- `-size 1033c`: search a file that is exactly 1033 bytes, `c` corresponds to byte.
- `! -executable` or `! -perm /111`: exclude executable files.

We can pipe it to `cat` to show the contents immediately:

```shell
find . -type f -size 1033c ! -executable | xargs cat
```

The command `xargs` is used to process and pass data between commands.

## Room 06

Multi-property file search with `file` and filter output with `grep`. This time we only have the properties and that is stored somewhere on the server.

- As always, use the password from the previous room to log in via SSH.
- Same logic as the previous room, this time we have to search on root and apply some filtering to the output using `grep`.

### Filtering output

We will use the following chain of commands:

```shell
find / -type f -group bandit6 -user bandit7 -size 33c 2>&1 | grep -v "find" | xargs cat
```

The new params and commands used do the following:

- `-group` and `-user`: searches for a file that is owned by X group and X user.
- `2>&1`: redirects *standard error* (file descriptor 2) to *standard output* (file descriptor 1), so both stderr and stdout are combined on a single stream that can be redirected.
- `grep -v "find"`: to filter the results that are not correct. Considering that if we don't add this we will get a lot of lines that look like this: `find: ‘/boot/efi’: Permission denied`. We are using the word *find* (that appears on all invalid results) to filter those lines.

## Room 07

The password is located in a file next to a particular word. The suggestion for commands include: `sort`, `strings`, a couple of  
compress/decompress commands, `tr`, `xxd`, etc.  

- Use previous password to login via SSH.
- Search for the particular word using `grep`.

### Search and clean

The following command will perform the search and return the line that has the word and password.

```shell
grep "millionth" data.txt'
```

## Room 08

The password is located in the line of text that appears only once. So we will be using `uniq` with `sort`.

- Use previous password to login via SSH.
- Use a chain of commands that allows us to get the line that contains the password.

### Find unique line

We use `sort` to prepare the text for the `uniq` command, ensuring that duplicates are adjacent.

```shell
sort data.txt | uniq -u
```

Where each command corresponds to:

- `sort`: sorts the lines.
- `uniq -u`: prints **only** the lines that appear exactly once in the input.

## Room 09

This time the file contains non human-readable data alongside the password.

- As usual, use the password found on the previous round to access via SSH.
- Filter the non-readable text with `strings` and use `grep` to find the pattern we are looking for.  

## Room 10

The password is stored in the specified file that, this time, has base64 encoded data. Use `base64` command.

- Use `base64 -d` to decode the password.

## Room 11

The password is stored in a file that has the *ROT13* cipher. Use `tr` command.  

- Use `tr` command with the correct mapping to get the password.

### Decipher ROT13

The mapping is the following:

```shell
tr 'A-Za-z' 'N-ZA-Mn-za-m' < inputfile
```

The map follows this logic:

- `A-Z`: uppercase letters.
- `a-z`: lowercase letters.
- `N-ZA-M`: letters *N* to *Z*, followed by *A* to *M*.
- `n-za-m`: letters *n* to *z*, followed by *a* to *m*.

## Room 12

The password for the next level is stored in the file data.txt, which is a hexdump of a file that has been repeatedly compressed. Commands to use are `xxd` and the compress/decompress ones.  

- Use `xxd` to convert the hexdump back to binary.
- Check the type of conversion used on the binary.
- Decompress the binary.

### From hexdump into password

First we convert the hexdump into a binary.

```shell
xxd -r data.txt data.bin
```

We inspect the compressed binary with the goal of finding the conversion type used.

```shell
file data.bin
```

The first compressor used is `gzip`. So we use `gunzip` to decompress:  

```shell
gunzip < data.bin > data.dec
```

We continue with this process of checking the file and decompressing it if necessary until we find the password.

## Room 13

This room instead of giving the user a password, it gives a private SSH key, used to log in to the next room. Once logged in, the user has to search for the password in the path specified.

- The user has a file `sshkey.private` that can be used with the command `ssh`.  
- After the login, the user has to search for the password, in order to be able to connect later without using the private key.

### Login SSH using private key

The user has to use the private key with the following command:

```shell
ssh -i sshkey.private bandit14@localhost -p 2220
```

Where each part corresponds to:

- `ssh -i sshkey.private`: use private key stored in specified file.
- `bandit14@localhost`: the user that has the rights to read the password we need.
- `-p 2220`: optional, I had a problem with the port 22, normally used by SSH, so I had to change it as specified by a user that had the same issue.

## Room 14

The password can be retrieved by submitting the current password to the specified port on localhost.

- To submit text the user has to use the command `nc`.

### Using nc to submit things

This time the user has to submit text to localhost on a specific port. To do this, the user has to use the command `nc`:

```shell
echo "CURRENT_PASSWORD" | nc localhost 30000
```

## Room 15

This room is similar to the last one, the user has to submit the current password to the specified port on localhost. This time, the user also has to use SSL/TSL encryption.

- To submit the text the user has to use the command `ncat`, because `nc` does not support SSL/TSL.  

### Submitting data with ncat and SSL

As `nc` is a simple networking utility, it does not support encryption. The user has to use `ncat`, which is a more advanced version of `nc` from the Nmap suite.

```shell
echo "CURRENT_PASSWORD" | ncat --ssl localhost 30001
```

## Room 16

This room is similar to the previous one, the user submits the current password. This time the user does not have a specified port, instead it has a range of possible ports.

- First the user has to find out what ports have a server listening on them.
- Then the user has to find out which one speaks SSL/TLS. There is only one correct port.
- Lastly the user has to use the `ncat` command like in the previous room.

### Looking for the correct port

The user can combine step 1 and 2 by using the correct options for the `nmap` command. To get the open ports that user SSL/TLS:

```shell
nmap -p 31000-32000 --script ssl-enum-ciphers localhost
```

The output is fairly large, so the user can use different tools to parse it. For extracting only the ports that use SSL/TLS:

```shell
nmap -p 31000-32000 --script ssl-enum-ciphers localhost | grep -B1 'ssl-enum-ciphers' | grep '^[0-9]' | awk -F'/' '{print $1}'
```

Optionally the user can save the ports into a file by adding `> FILENAME.txt` at the end.

### Get the key from the correct port

The previous step outputs two ports, the user has to manually test then with the command:

```shell
cat /etc/bandit_pass/bandit16 | ncat --ssl localhost <PORT>
```

If the command outputs the current round password it means that port is not the one. The correct port will give the user a private key that the user can use to log in with SSH.
Once the user knows the correct port, this command can be user to save the key into a file:

```shell
cat /etc/bandit_pass/bandit16 | ncat --ssl localhost 31790 | grep -v 'Correct' > sshkey.private
```

Before attempting to use the key, the user has to give it the correct permissions.

```shell
chmod 600 sshkey.private
```

Lastly the user has to connect to the next round:

```shell
ssh -i sshkey.private bandit17@localhost -p 2220
```

And the user can get the password for later access.

```shell
cat /etc/bandit_pass/bandit17
```

## Room 17

This room provides the user with two files: `passwords.new` and `passwords.old`. The password is located in `passwords.new` in the only line that has been modified from `passwords.old`.

- To compare the files the user can use the `diff` command.

### Comparing files

The user can compare the files like this:

```shell
diff passwords.new passwords.old
```

The output will be something like:

```text
3c3
< old line
---
> new line
```

Where each part corresponds to:

- `3c3`: indicates that line 3 in the first file should be changed to line 3 in the second file.
- `<`: shows the line from the **first file**.
- `>`: shows the line from the **second file**.

The user passed the file `password.new` as the first parameter, so the relevant result is the one after the `<` symbol. For parsing the user can use the following chain of commands:

```shell
diff passwords.new passwords.old | grep '<' | cut -d' ' -f2-
```

This command does the following:

- `grep '<'`: gets the relevant line.
- `cut -d' ' -f2-`: extracts the password.
  - `-d' '`: splits the text by spaces.
  - `-f2-`: the `-f` specifies the fields to print, `2-` means *print from the second field to the end of the line*.

## Room 18

The password is in a file located in the home directory. The catch is that this time, the `.bashrc` has been modified so the user immediately logs out after logging in.

- The user can solve this problem really easily by using the correct options when running `ssh`.

### Ignoring .bashrc for SSH session

The user can use the following option to ignore the usage of the `.bashrc`:

```shell
ssh bandit18@bandit.labs.overthewire.org -p 2220 'bash --norc'
```

The previous command alone gives the user a default bash shell session. A quick alternative to that command is the following one:

```shell
ssh bandit18@bandit.labs.overthewire.org -p 2220 'bash --norc -c "cat readme"'
```

The new option allows the user to run a single command before terminating the session, really useful for this particular case:

- `-c`: runs a command without loading the `.bashrc`.
- `"cat readme"`: the `cat` command shows the contents of a file, `readme` is the name of the file that contains the password.

## Room 19

This round is an introduction to **setuid binaries**. TLDR: binaries that run with the permissions of the creator/owner rather than with the ones of the user running it.

- Run the binary to see how it works.
- Get the password from the usual path, using the binary.

### Escalate privilege with the setuid binary

The binary provided this time allows the user to execute any command with the privileges of the owner (bandit20). The user can use this binary to access the location of the password for the next room.

```shell
./bandit20-do cat /etc/bandit_pass/bandit20
```

Where each part corresponds to:

- `./bandit20-do`: the name of the setuid binary.
- `cat ...`: the command to execute with the privileges of user bandit20.

## Room 20

Another room with setuid binaries. This time the setuid binary makes a connection to localhost on the specified port. It then reads a line of text from the connection and compares it to the password in the previous level. If the password is correct, it will transmit the password for the next level.

- Setup a netcat listener.
- Send current password and get the next one.

### Job management tldr

- `jobs`: lists all current jobs running.
- `&`: makes a command run in the background.
- `CTRL+Z`: suspends the current job.
- `bg %JOB_NUMBER`: resume specified suspended job.
- `fg %JOB_NUMBER`: brings background specified job to the foreground.
- `kill %JOB_NUMBER`: kills the specified job.
- `jobs -p | xargs kill`: kills all jobs.

### Sending and receiving with netcat

To set up the listener the user has to use the following command:

```shell
nc -lvnp 35000 &
```

Where each parts correspond to:

- `nc -lvnp`: listen, verbose, no dns resolution, on specified port.
- `35000`: port to listen to.
- `&`: since the user is in an ssh session, is a good idea to run the listener on the background.

Then the user has to start the setuid with the listener's port:

```shell
./suconnect 35000 &
```

Lastly, with both jobs running on the background, hop into the listener and send the current password to the setuid.

## Room 21

This room has a program running at regular intervals from `cron`, a time-based job scheduler. The user is given the path to the configuration of `cron` and it's hinted to find out what command is being executed.

- Find out what command does the scheduler execute.
- Examine the command for clues on how to find the password.

### Job scheduler cron TLDR

`cron`:

- **Purpose**: daemon that runs scheduled tasks at specific intervals. Used to execute commands or scripts automatically.
- **Usage**: typically runs in the background and checks the schedule defined in the `crontab` files to execute the scheduled tasks.

`crontab`:

- **Purpose**: command used to manage cron jobs (tasks). Allows the user to create, view, edit and delete cron schedules.
- **Usage**:
  - `crontab -e`: edit crontab file.
  - `crontab -l`: list current cron jobs.
  - `crontab -r`: remove crontab file (delete all cron jobs).

`crontab(5)`:

- **Purpose**: refers to man page section 5, which describes the format and configuration of the crontab file.
- **Usage**: to read this documentation, use `man 5 crontab`.

### Finding the password 21

The user can check the location of the crontab files and look out for the relevant one. Because for this particular case, the user does not have the required permissions to execute `crontab -l`.

```shell
ls /etc/cron.d/
```

The file that stands out is the one named `cronjob_bandit22`, mainly because it has the name of the next room. The user can use `cat` to inspect its contents. The schedule executes a shell script that looks something like this:

```bash
#!/bin/bash
chmod 644 /SOME/PATH
cat /etc/bandit_pass/bandit22 > /SOME/PATH
```

The user can easily understand that the cron job is pasting the password for the next room in a folder with permission 644 (user can read from this file). Now it's just a matter of inspecting the contents of that file.

Just for the sake of practicing, the one-liner that parses the path and shows the contents of the password file:

```shell
cat /usr/bin/cronjob_bandit22.sh | grep '>' | awk -F'>' '{ print $NF }' | xargs cat
```

Details:

- `cat ...`: gets the contents of the cron job, like explained before.
- `grep '>'`: focuses on the line with the path.
- `awk ...`: splits the text with '<' as separator and prints the last element.
- `xargs cat`: trims the output from awk and shows the contents of the file.

## Room 22

This room is similar to the last one, it has a program running at regular intervals from cron. The user has to inspect the crontab files and look for the password.

- Find out what command does the scheduler execute.
- Examine the command for clues on how to find the password.

### Finding the password 22

The firsts steps are the same as the previous room. This time the script that the cron job executes is a little bit more complex, it requires manual inspection from the user.

```bash
#!/bin/bash

myname=$(whoami)
mytarget=$(echo I am user $myname | md5sum | cut -d ' ' -f 1)

echo "Copying passwordfile /etc/bandit_pass/$myname to /tmp/$mytarget"

cat /etc/bandit_pass/$myname > /tmp/$mytarget
```

For this user, the variable `$myname` will be `bandit22`. Understanding this and how it affects the rest of the operations will be key to continue.
If the user can run all commands but with `$myname` as `bandit23`, it will get the location of the password for the next room.

Replicating the logic from the script:

```shell
echo I am user bandit23 | md5sum | cut -d ' ' -f 1
```

That is enough for getting the name of the file that contains the password in /tmp/. The one-liner for replicating the logic and printing the password will be:

```shell
echo I am user bandit23 | md5sum | cut -d ' ' -f 1 | awk '{ print "/tmp/" $1 }' | xargs cat
```

## Room 23

Another cron related room. This time it hints the user has to create its own shell script.

- Find out what command does the scheduler execute.
- Examine the command for clues on how to find the password. This time the command **runs and deletes** all scripts in a particular location.
- Write the needed script and find the password.

### Understanding the cron job

As said before, the command that executes the cron job runs and deletes all scripts located on the specified path. Inspecting the file:

```bash
#!/bin/bash

myname=$(whoami)

cd /var/spool/$myname/foo
echo "Executing and deleting all scripts in /var/spool/$myname/foo:"
for i in * .*;
do
    if [ "$i" != "." -a "$i" != ".." ];
    then
        echo "Handling $i"
        owner="$(stat --format "%U" ./$i)"
        if [ "${owner}" = "bandit23" ]; then
            timeout -s 9 60 ./$i
        fi
        rm -f ./$i
    fi
done
```

Interpretation of the code:

- `myname=$(whoami)`: sets bandit23 (in this case) as `myname`.
- `for i in * .*;`: iterates over all visible (`*`) and hidden (`.*`) files in current directory.
- `if [ "$i" != "." -a "$i" != ".." ];`: checks if variable is not current directory (`.`) and parent directory (`..`).
- `owner="$(stat --format "%U" ./$i)"`: uses `stat` command to get the status of the current file iteration, formatted to only see the owner.
- `if [ "${owner}" = "bandit23" ]; then`: checks if the owner is bandit23.
- `timeout -s 9 60 ./$i`: runs the script with a time limit of 60 seconds.
- `rm -f ./$i`: removes the file.

### Creating the script

The file that the cron job runs has bandit24 as its owner, so the user can write a script that retrieves the password from `/etc/bandit_pass/bandit24`.
First the user has to create a temporary directory on which eventually the cron job will send the password.

```bash
mktemp -d
```

The user can create the script here first, set up all permissions and then move it into the correct spot.

```bash
#!/bin/bash

cat /etc/bandit_pass/bandit24 > /tmp/ztk9bn8CtG/pass
```

This script needs execution permissions:

```bash
chmod +x script.sh
```

And the user that is going to run the cron job (bandit24) has to be able to write to the `/tmp/something/` folder specified earlier. So the user has to change its permissions:

```bash
cd /tmp/ztk9bn8CtG/pass
chmod 777 .
```

Then the user can copy the file into the `/var/spool/bandit/foo/` path and wait for the cron job to run.

```bash
cp solve.sh /var/spool/bandit24/foo/
```

Finally, the user can `cat` into the new file and save the password.

## Room 24

This time, a daemon is listening on port 30002 and will give the password if given the previous password and a secret numeric 4-digit pincode. There is no way to retrieve the pincode except by going through all the 10000 combinations.

- Understand what a daemon is and how they work.
- Find out how to brute force the operation.

### Daemon TLDR

A daemon is a background process that runs continuously, usually without direct user interaction. It typically starts when the system boots and remains running to perform certain tasks.

Key features:

- **Runs in the background**: often do not even require a user to be logged in.
- **No terminal or ui**: daemons are not associated with a terminal session, so they run independently.
- **System services**: daemons often provide essential system services. Examples: `sshd`, `cron` and `httpd`.
- **Start at boot**: start automatically at boot through system initialization processes like `systemd`.
- **Process naming convention**: daemons typically have names that end in the letter `d` to indicate their role, such as `sshd`, `crond` or `systemd`.

### Brute forcing

An easy way to generate all the posible pin codes is with a for loop:

```bash
for i in {0000..9999}; do echo $i; done
```

The user can modify the one-liner to create the string that the daemon wants inline:

```bash
for i in {0000..9999}; do echo "CURRENT_PASSWORD $i"; done
```

Lastly the user can send all that to the daemon with netcat:

```bash
(for i in {0000..9999}; do echo "gb8KRRCsshuZXI0tUuR6ypOFjiZbf3G8 $i"; done) | nc localhost 30002
```

Quick explanation of how does this work:

- `(for ...)`: by surrounding the operation in parentheses, the command inside is executed in a subshell. The output is a sequence of strings.
- `| nc localhost 30002` by piping the sequence of strings (already generated) into netcat, the daemon gets all of them in a single connection.

## Room 25

This room is different, it says that the current user (bandit25) can easily hop into bandit26, the problem is that the shell that bandit26 uses is not `/bin/bash`. The user has to find out how to break out of it.

- Find out what shells are available (OPTIONAL).
- Find out what shell is bandit26 using.
- Login to bandit26 using the provided sshkey.
- Understand how that shell works and how to get out of it.

### Listing available shells

Fairly easy thing to do, there is a file on the system with this information:

```bash
cat /etc/shells
```

### Get information about user shells

To find out what shell bandit26 is using, the user can inspect the file (`/etc/passwd`) that contains this information:

```bash
cat /etc/passwd | grep bandit26
```

Inspecting the "shell" that bandit26 is using:

```bash
#!/bin/sh

export TERM=linux

exec more ~/text.txt
exit 0
```

The command that immediately kicks out the user when trying to log in is `exit 0`. So the user has to somehow pause the execution of `more`.

### Forcing the more command into paged view

The file `~/text.txt` is really short, so normally the `more` command won't enter its "paged" view. To force this the user can resize the terminal window into a smaller version.

### Getting a bash terminal from more

Once paused in `more` paged view, the user can use the `v` key to open *vi*, as detailed in the man pages of `more`.
In vi, the user can execute shell commands with `:!COMMAND`. But trying a regular command like this won't work:

```Bash
:!ls
```

It won't work because behind the scenes the shell used to run that command is the default bandit26 shell. To change it to bash the user has to do the following:

```Bash
:set shell=/bin/bash
```

Then the user can start bash with the command:

```Bash
:shell
```

And grab the password from `/etc/bandit_pass/bandit26`.

## Room 26

Just before trying anything, the user has to remember that the default shell of bandit26 is problematic. So the first thing is to get a regular bash shell. After that, the only instructions are to quickly grab the password for the next room.

- Get a bash shell.
- Get the password for the next room.

### Getting the password

After logging in, the user will find an executable named `bandit27-do`. This file allows the user to run any command as bandit27. To get the password, the user has to inspect the file in bandit27's password location.

```bash
./bandit27-do cat /etc/bandit_pass/bandit27
```

## Room 27

This room contains the password somewhere in a git repository. The user is given the git credentials needed for cloning the repo.

- Clone the repository.
- Find the password.

### Cloning and inspecting the repository

```bash
git clone ssh://bandit27-git@localhost:2220/home/bandit27-git/repo
```

Inside the repository there is a single markdown file that contains the password for the next room.

## Room 28

The instructions for this room are the same as the previous one. There is a git repository and the user has to clone it and find the password.

- Clone the repository.
- Find the password.

### Inspect commits

This time the markdown file does not contain the password. If the user checks the history with:

```bash
git log
```

There is a commit that fixed the info leak (the password). Using this commit's hash the user can find the password:

```bash
git show COMMIT_HASH
```

## Room 29

Same as the 2 previous rooms, there is a git repository and the user has to find the password.

- Clone the repo.
- Find the password.

### Inspect branches

This time the password cannot be found in the file or the commits. The user can list the branches with:

```bash
git branch --all
```

To check the branches commits the user can use:

```bash
git show-branch BRANCH_NAME
```

The user can switch branches it using:

```bash
git checkout BRANCH_NAME
```

> **HINT**: check all branches and commits. The suspiciously named branch turned out to have no relevant information.

## Room 30

Yet another git related room. As usual, the user has to clone the repository and find the password.

- Clone the repository.
- Find the password.

### Inspect tags

Problematic room to say the least, this time there is no other commits and no extra branches. The last place to store information would be the tags (a tag is like a bookmark or label placed on a commit).
To list all tags the user can run:

```bash
git tag
```

And to inspect a specific tag the user can use:

```bash
git show TAG_NAME
```

## Room 31

Last git related room. As usual, clone and find the password.

- Clone the repository.
- Find the password.

### Following the instructions

This time the markdown file located in the repository has some instructions for the user:

1. Create a file named `key.txt`.
2. Put a specific phrase in the file.
3. Push it to the remote repository.

The user will find out that the `.gitignore` file ignores all `.txt` files. A quick workaround to this without touching that file:

```bash
git add -f key.txt
```

After doing the commit and push the user will get a message with the password.

## Room 32

The only instruction that the user has for this room is to escape. It suggests the usage of the commands `man` and `sh`.

- Understand the shell the user has to escape.
- Escape.

### Uppercase shell

The shell the user is logged in immediately after ssh is called "Uppercase shell" and as the name suggest, every command that the user inputs it is turned into uppercase. For example: if the user types `ls` the shell will interpret `LS`.

### Positional parameters

If the user researches about the way of making something uppercase in a shell, it will stumble upon something called *positional parameters*.
Suppose the user types the following:

```bash
./example.sh apple banana
```

In this particular case, the positional parameters will be:

- `$0`: it is always the command to run, in this case `./example.sh`.
- `$1`: parameter number 1, in this case `apple`
- `$2`: parameter number 2, in this case `banana`

Translating this into what the uppercase shell is doing, the user can assume that the bourne shell (`sh`) is interpreting the commands after the uppercase operation runs. So returning to the `ls` example, it will be something like this:

```bash
sh LS
```

For clarity, the whole operation probably looks like this:

```bash
command="ls"
uppercase=${command^^}
sh $uppercase
```

Going back to the `sh LS` example, as previously explained, the first positional parameter is always the command. The user can quickly understand that for the whole operation to work, the parameter `$0` cannot be modified by the uppercase operation.
If the user runs the positional parameter 0, like this:

```bash
$0
```

It will be the same as running `sh`, allowing the user to finally reach a regular shell.

### Finding the password?

The user has no extra instructions on how to get the password for the next room. But if the user runs:

```bash
whoami
```

It will find out that it is bandit33, the user for the next room. Therefore, the only thing the user has to do is check `/etc/bandit_pass/bandit33` for the password.

## Room 33

This room does not exist yet. (13 sep 2024)
