#!/bin/bash
# setup_colab.sh - Script to set up SSH access in Google Colab

# Print status messages
echo "Setting up SSH access for Google Colab..."

# Clone the repository containing the authorized_keys file
# Note: Replace <your-user> with your GitHub username before running in Colab
REPO_URL="https://github.com/cbrane/colab-ssh-setup.git"
echo "Cloning repository from $REPO_URL..."
git clone --depth 1 $REPO_URL

# Update and install OpenSSH server
echo "Installing OpenSSH server..."
apt-get update -y
apt-get install -qq openssh-server

# Set up SSH directory and authorized_keys
echo "Setting up authorized keys..."
mkdir -p ~/.ssh
cp colab-ssh-setup/.colab_ssh/authorized_keys ~/.ssh/
chmod 600 ~/.ssh/authorized_keys

# Start the SSH daemon
echo "Starting SSH service..."
service ssh restart

# Install colab_ssh package for tunneling
echo "Setting up SSH tunnel with cloudflared..."
pip install -q colab_ssh --upgrade

# Add a Python script to launch the SSH tunnel
cat > launch_ssh.py << 'EOF'
from colab_ssh import launch_ssh_cloudflared
launch_ssh_cloudflared()
EOF

# Execute the Python script to launch the tunnel
echo "Launching SSH tunnel..."
python launch_ssh.py

echo "SSH setup complete! Use the SSH command above to connect."
echo "You can connect using: ssh -i ~/.ssh/id_ed25519 -p <port> root@<subdomain>.trycloudflare.com"

