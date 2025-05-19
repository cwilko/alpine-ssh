# Use an Alpine Linux base image that supports ARM64 architecture
FROM alpine:latest

# Set environment variables to avoid interactive prompts during package installation
ENV TZ=Europe/London 

# Update package lists and install necessary software
RUN apk update && apk add --no-cache openssh openssh-keygen shadow sudo

# Configure SSH server
RUN mkdir -p /run/sshd
RUN sed -i 's@#PermitRootLogin prohibit-password@PermitRootLogin no@' /etc/ssh/sshd_config

# Generate SSH host keys
RUN ssh-keygen -A

# Copy the user setup script into the image
COPY entrypoint.sh /entrypoint.sh

# Make the script executable
RUN chmod +x /entrypoint.sh

# Run the script to create the user and set the password
# The script will take the username and password as arguments
ENTRYPOINT ["/entrypoint.sh"]
