# Linux Commands Cheat Sheet

A quick reference for commonly used Linux commands.

---

## 📁 File & Directory Management

| Command  | What it does                 |
| -------- | ---------------------------- |
| `ls`     | List directory contents      |
| `pwd`    | Show current directory path  |
| `cd`     | Change directory             |
| `locate` | Search files by name         |
| `find`   | Search files and directories |
| `mkdir`  | Create a directory           |
| `rmdir`  | Remove an empty directory    |
| `rm`     | Delete files or directories  |
| `cp`     | Copy files or directories    |
| `mv`     | Move or rename files         |
| `touch`  | Create an empty file         |
| `file`   | Show file type               |
| `ln`     | Create file links            |

### Examples

```bash
ls
pwd
cd /var/log
mkdir projects
touch app.sh
cp app.sh backup.sh
mv backup.sh backup/
rm app.sh
```

---

## 📦 Compression & Archives

| Command | What it does                    |
| ------- | ------------------------------- |
| `zip`   | Compress files into ZIP archive |
| `unzip` | Extract ZIP archive             |
| `tar`   | Archive files and directories   |

### Examples

```bash
zip backup.zip file.txt
unzip backup.zip

tar -cvf backup.tar my_folder/
tar -xvf backup.tar
tar -czvf backup.tar.gz my_folder/
tar -xzvf backup.tar.gz
```

---

## 📝 Text Editors

| Command | What it does         |
| ------- | -------------------- |
| `nano`  | Edit files with Nano |
| `vi`    | Edit files with Vi   |
| `vim`   | Edit files with Vim  |
| `jed`   | Edit files with Jed  |

### Examples

```bash
nano script.sh
vi script.sh
vim script.sh
```

---

## 📄 Reading & Processing Text

| Command | What it does                    |
| ------- | ------------------------------- |
| `cat`   | Display file content            |
| `grep`  | Search text patterns in files   |
| `sed`   | Replace or modify text patterns |
| `head`  | Show first lines of a file      |
| `tail`  | Show last lines of a file       |
| `awk`   | Process and analyze text        |
| `sort`  | Sort file content               |
| `cut`   | Extract sections of text        |
| `diff`  | Compare two files               |
| `tee`   | Output to terminal and file     |

### Examples

```bash
cat file.txt

grep "error" app.log

head file.txt
tail file.txt
tail -f app.log

sort names.txt

cut -d "," -f 1 users.csv

diff file1.txt file2.txt

echo "Hello" | tee output.txt
```

---

## 🔐 Users & Permissions

| Command   | What it does                 |
| --------- | ---------------------------- |
| `sudo`    | Run command as administrator |
| `su`      | Switch user account          |
| `whoami`  | Show current user            |
| `chmod`   | Change file permissions      |
| `chown`   | Change file ownership        |
| `useradd` | Create new user              |
| `userdel` | Delete user account          |
| `passwd`  | Set or change password       |

### Examples

```bash
sudo apt update

whoami

sudo useradd developer

sudo passwd developer

chmod +x script.sh

chown user:user file.txt
```

---

## 💾 Disk & System Information

| Command    | What it does                   |
| ---------- | ------------------------------ |
| `df`       | Show disk space usage          |
| `du`       | Show directory size            |
| `uname`    | Show system information        |
| `hostname` | Show or set hostname           |
| `time`     | Measure command execution time |

### Examples

```bash
df -h

du -sh /var/log

uname -a

hostname

time ./script.sh
```

---

## ⚙️ Processes & Services

| Command     | What it does                |
| ----------- | --------------------------- |
| `top`       | Display running processes   |
| `htop`      | Interactive process viewer  |
| `ps`        | Show process snapshot       |
| `systemctl` | Manage system services      |
| `watch`     | Run command repeatedly      |
| `jobs`      | List shell background jobs  |
| `kill`      | Terminate a process         |
| `shutdown`  | Shut down or restart system |

### Examples

```bash
top

htop

ps aux

systemctl status nginx

systemctl start nginx
systemctl stop nginx
systemctl restart nginx

watch df -h

jobs

kill 1234

sudo shutdown -h now
```

---

## 🌐 Networking

| Command      | What it does                |
| ------------ | --------------------------- |
| `ping`       | Test network connectivity   |
| `wget`       | Download files from the web |
| `curl`       | Transfer data via URL       |
| `scp`        | Copy files over SSH         |
| `rsync`      | Sync files between systems  |
| `ip`         | Manage network settings     |
| `netstat`    | Show network connections    |
| `traceroute` | Trace network packet path   |
| `nslookup`   | Query DNS records           |
| `dig`        | Detailed DNS lookup         |

### Examples

```bash
ping google.com

wget https://example.com/file.zip

curl https://example.com

scp file.txt user@server:/home/user/

rsync -av ./project/ user@server:/home/user/project/

ip addr

ip route

netstat -tuln

traceroute google.com

nslookup google.com

dig google.com
```

> **Note:** On modern Linux systems, `ss` is commonly preferred over `netstat`.

---

## 🖥️ Shell & Terminal Utilities

| Command   | What it does            |
| --------- | ----------------------- |
| `history` | Show command history    |
| `man`     | Show command manual     |
| `echo`    | Print text to terminal  |
| `alias`   | Create command shortcut |
| `unalias` | Remove command shortcut |
| `cal`     | Display calendar        |

### Examples

```bash
history

man ls

echo "Hello Linux"

alias ll="ls -la"

unalias ll

cal
```

---

## 📦 Package Management

### Debian / Ubuntu

| Command | What it does                            |
| ------- | --------------------------------------- |
| `apt`   | Manage packages on Debian-based systems |

```bash
sudo apt update
sudo apt upgrade
sudo apt install nginx
sudo apt remove nginx
sudo apt search nginx
```

### RHEL / Fedora

| Command | What it does                          |
| ------- | ------------------------------------- |
| `dnf`   | Manage packages on RHEL-based systems |

```bash
sudo dnf update
sudo dnf install nginx
sudo dnf remove nginx
sudo dnf search nginx
```

---

# 🚀 DevOps Commands to Learn First

If you're learning Linux specifically for **DevOps**, prioritize these first:

```text
pwd
ls
cd
mkdir
touch
cp
mv
rm
cat
less
nano
vim
grep
find
chmod
chown
sudo
ps
top
systemctl
df
du
ip
ping
curl
wget
ssh
scp
rsync
tar
apt
```

A useful learning progression is:

```text
Linux Files
    ↓
Permissions
    ↓
Users
    ↓
Processes
    ↓
Services
    ↓
Networking
    ↓
SSH
    ↓
Shell Scripting
    ↓
Git
    ↓
Docker
    ↓
CI/CD
    ↓
Kubernetes
```
