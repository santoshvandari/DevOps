# Linux Guide

## What is Linux?
Linux is an open-source Unix-like operating system kernel. It is the foundation for many popular operating systems (called distributions or "distros") like Ubuntu, Debian, and CentOS. For DevOps, Linux is the mostly used OS standard for servers, containers, and cloud infrastructure due to its stability, security, and flexibility.

## Key Concepts

### Kernel
The core of the operating system that manages the CPU, memory, and peripheral devices.

### Shell
A command-line interface (CLI) that allows users to interact with the operating system. `bash` (Bourne Again SHell) is the most common shell.

### Filesystem Hierarchy
A tree-like structure of directories, starting from the root (`/`). Key directories include `/bin` (binaries), `/etc` (configuration), `/home` (user directories), `/var` (variable data like logs), and `/tmp` (temporary files).

### Users and Permissions
Linux is a multi-user system. Files and directories have owners, groups, and permissions (read, write, execute) that control access.

### Package Management
Tools used to install, update, and remove software. Common examples are `apt` (Debian/Ubuntu) and `yum`/`dnf` (CentOS/RHEL).

## Essential Linux Commands

### File and Directory Management
```bash
# List files and directories
ls
ls -l          # Long format
ls -a          # Show hidden files
ls -lh         # Human-readable sizes

# Change directory
cd /var/log
cd ..          # Go up one level
cd ~           # Go to home directory

# Print working directory
pwd

# Create and remove directories
mkdir my-app
rmdir my-app   # Only removes empty directories
rm -r my-app   # Recursively remove directory and its contents

# Create, copy, move, and remove files
touch new-file.txt
cp source.txt destination.txt
mv old-name.txt new-name.txt
rm file.txt

# Find files
find . -name "*.log"
find /etc -type f -name "sshd_config"
```

### Viewing and Editing Files
```bash
# View file content
cat file.txt
less file.txt      # View with scrolling (recommended for large files)
more file.txt      # Similar to less

# View beginning or end of a file
head file.txt      # First 10 lines
tail file.txt      # Last 10 lines
tail -f /var/log/syslog  # Follow a file as it grows

# Command-line text editors
nano /etc/hosts    # Simple editor
vim /etc/hosts     # Powerful editor
```

### Text Processing
```bash
# Search for patterns in text
grep "error" /var/log/syslog
grep -i "error" /var/log/syslog  # Case-insensitive
grep -r "database_url" .         # Recursive search

# Stream editor for filtering and transforming text
sed 's/old-text/new-text/g' file.txt

# Powerful pattern scanning and processing language
awk '{print $1, $3}' /var/log/nginx/access.log

# Cut out sections from each line of files
cut -d':' -f1 /etc/passwd
```

### User and Permission Management
```bash
# Execute command as superuser
sudo apt update

# Change file permissions
chmod 755 script.sh        # rwx for owner, r-x for group/others
chmod +x script.sh         # Make executable

# Change file ownership
chown user:group file.txt
chown -R user:group /app/data # Recursive

# Manage users
useradd newuser
usermod -aG docker newuser # Add user to a group
passwd newuser             # Set password for user
```

### Process Management
```bash
# List running processes
ps aux
ps -ef

# Interactive process viewer
top
htop               # Improved version of top (may need installation)

# Send signals to processes (e.g., terminate)
kill <pid>
kill -9 <pid>      # Force kill
pkill nginx        # Kill process by name

# Manage system services with systemd
systemctl start nginx
systemctl stop nginx
systemctl restart nginx
systemctl status nginx
systemctl enable nginx   # Start on boot
systemctl disable nginx  # Don't start on boot
```

### System Information
```bash
# Show disk space usage
df -h

# Show directory space usage
du -sh /var/log

# Show memory usage
free -h

# Show system uptime
uptime

# Show kernel and system info
uname -a

# Show CPU information
lscpu
```

### Networking
```bash
# Show/manipulate IP addresses and routes
ip addr show
ip route

# Show network connections (modern replacement for netstat)
ss -tuln

# Check network connectivity
ping google.com

# Transfer data from or to a server
curl https://api.github.com
wget https://releases.ubuntu.com/20.04/ubuntu-20.04.4-desktop-amd64.iso

# Secure Shell (remote login)
ssh user@hostname

# Secure copy (copy files over SSH)
scp file.txt user@hostname:/remote/path/
scp user@hostname:/remote/path/file.txt .
```

### Package Management (Debian/Ubuntu)
```bash
# Update package lists
sudo apt update

# Upgrade installed packages
sudo apt upgrade

# Install a package
sudo apt install nginx

# Remove a package
sudo apt remove nginx
sudo apt purge nginx       # Remove with configuration files

# Search for a package
apt-cache search nginx
```

### Archiving and Compression
```bash
# Create and extract tar archives
tar -cvf archive.tar /path/to/dir    # Create
tar -xvf archive.tar                 # Extract
tar -czvf archive.tar.gz /path/to/dir # Create and compress with gzip
tar -xzvf archive.tar.gz             # Extract from gzipped archive

# Compress and decompress files
gzip file.txt                        # Compresses to file.txt.gz
gunzip file.txt.gz                   # Decompresses
```

## Shell Scripting Basics

A simple script to back up a directory.

```bash
#!/bin/bash

# A simple backup script

# Configuration
BACKUP_SOURCE="/var/www/html"
BACKUP_DEST="/mnt/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DEST/backup-$TIMESTAMP.tar.gz"

# Check if destination exists
if [ ! -d "$BACKUP_DEST" ]; then
  echo "Backup destination $BACKUP_DEST does not exist. Creating it."
  mkdir -p "$BACKUP_DEST"
fi

# Create the backup
echo "Backing up $BACKUP_SOURCE to $BACKUP_FILE..."
tar -czvf "$BACKUP_FILE" "$BACKUP_SOURCE"

echo "Backup complete."

# List recent backups
ls -lh "$BACKUP_DEST"
```

### Running the script
```bash
# Save the code above as backup.sh
chmod +x backup.sh
./backup.sh
```

## Useful Aliases

Add these to your `~/.bashrc` or `~/.zshrc`:
```bash
# General
alias ..="cd .."
alias ...="cd ../.."

# ls
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# grep
alias grep='grep --color=auto'

# System
alias dfh='df -h'
alias duh='du -h -d 1'

# Networking
alias ports='ss -tuln'
```

## Troubleshooting

### Checking Logs
The first place to look for errors is usually in the system logs.
```bash
# View system-wide logs
journalctl -u nginx.service
journalctl -f                # Follow all logs

# View application-specific logs
tail -f /var/log/nginx/error.log
```

### Checking Network Connectivity
```bash
# Check if a port is open and listening
ss -tuln | grep ':80'

# Check DNS resolution
nslookup my-api.internal

# Trace the route to a host
traceroute google.com
```

### Checking Resource Usage
```bash
# Check for processes consuming high CPU/memory
top
htop

# Check for low disk space
df -h

# Check for low memory
free -h
```

This guide covers the fundamental Linux commands and concepts essential for any DevOps professional. Mastering these will significantly improve your efficiency and effectiveness in managing server environments.