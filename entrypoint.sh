#!/bin/sh

# Set default username, password, and SSH port
DEFAULT_USERNAME="admin"
DEFAULT_PASSWORD="admin"
DEFAULT_SSH_PORT="22"

# Get username from environment variable, or use default
USERNAME="${USERNAME:-$DEFAULT_USERNAME}"

# Get password from environment variable, or use default
PASSWORD="${PASSWORD:-$DEFAULT_PASSWORD}"

# Get SSH port from environment variable, or use default
SSH_PORT="${SSH_PORT:-$DEFAULT_SSH_PORT}"

# Add the specified group and user
GROUP_ID=1000
USER_ID=1000
addgroup -g $GROUP_ID "$USERNAME"
adduser -u $USER_ID -G "$USERNAME" -s /bin/sh -D "$USERNAME"

# Set the user's password
echo "$USERNAME:$PASSWORD" | chpasswd

# Grant sudo privileges, requiring a password
echo "%$USERNAME ALL=(ALL) ALL" >> /etc/sudoers

# Configure SSH port in sshd_config
sed -i "s/^#Port 22/Port $SSH_PORT/" /etc/ssh/sshd_config

# Start the SSH server in the background
/usr/sbin/sshd -D &

# Keep the container running indefinitely
sleep infinity