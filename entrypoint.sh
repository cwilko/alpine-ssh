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
GROUP_ID=1003
USER_ID=1003
addgroup -g $GROUP_ID "$USERNAME"
adduser -u $USER_ID -G "$USERNAME" -s /bin/sh -D "$USERNAME"

# Set the user's password
echo "$USERNAME:$PASSWORD" | chpasswd

# Grant sudo privileges, requiring a password
echo "%$USERNAME ALL=(ALL) ALL" >> /etc/sudoers

# Disable root login via SSH
sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
echo "Root login via SSH has been disabled."

# Configure SSH key-based authentication if a public key is provided
if [ -n "$PUBLIC_KEY" ]; then
  mkdir -p /home/"$USERNAME"/.ssh
  chmod 700 /home/"$USERNAME"/.ssh
  echo "$PUBLIC_KEY" >> /home/"$USERNAME"/.ssh/authorized_keys
  chmod 600 /home/"$USERNAME"/.ssh/authorized_keys
  chown -R "$USERNAME":"$USERNAME" /home/"$USERNAME"/.ssh
  echo "Public key added for user '$USERNAME'."

  # Disable password authentication in sshd_config
  sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
  echo "Password authentication has been disabled."
else
  sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
  echo "Password authentication is enabled."
fi

# Configure SSH port in sshd_config
sed -i "s/^#Port 22/Port $SSH_PORT/" /etc/ssh/sshd_config
sed -i "s/^AllowTcpForwarding no/AllowTcpForwarding yes/" /etc/ssh/sshd_config


# Start the SSH server in the background
/usr/sbin/sshd -D &

# Keep the container running indefinitely
sleep infinity