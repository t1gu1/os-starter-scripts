#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Function to check if a command exists
command_exists () {
    type "$1" &> /dev/null ;
}

echo "Starting Ubuntu system setup..."

# --- System Updates and Core Packages ---
echo "Updating system and installing core packages..."
sudo apt update
sudo apt upgrade -y # -y flag to automatically answer yes to prompts
sudo apt install -y curl git build-essential wl-clipboard ripgrep fd-find luarocks fzf imagemagick

# --- LazyGit Installation ---
echo "Installing LazyGit..."
# Define LAZYGIT_VERSION. It's better to define it or fetch it dynamically.
# For simplicity, I'm setting a common recent version. You might want to update this.
LAZYGIT_VERSION="0.40.2" # As of May 2025, 0.40.2 is a recent stable version.
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
sudo tar xf lazygit.tar.gz -C /usr/local/bin lazygit # Extract directly to /usr/local/bin
rm lazygit.tar.gz

# --- NVM and Node.js Installation ---
echo "Installing NVM and Node.js..."
# The nvm install script needs to be sourced, and then nvm needs to be sourced
# into the current shell for commands to be available immediately.
# This part is tricky in a non-interactive script.
# We'll install it and then manually source it for the current script's execution.
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# Source nvm for the current shell session
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

bash # Reload bash with env variables

if command_exists nvm; then
    nvm install --lts
    npm install -g neovim # npm install -g for global packages
else
    echo "NVM not found after installation attempt. Please install Node.js manually or troubleshoot NVM."
fi

# --- SSH Key Generation ---
echo "Generating SSH key..."
# Check if an SSH key already exists to avoid overwriting
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    ssh-keygen -t ed25519 -N "" -f "$HOME/.ssh/id_ed25519" # -N "" for no passphrase, -f to specify file
    echo "SSH key generated at ~/.ssh/id_ed25519"
else
    echo "SSH key already exists at ~/.ssh/id_ed25519. Skipping generation."
fi

# --- Snap Installations ---
echo "Installing Snap packages..."
# Using --classic, --beta, --candidate, --edge as specified
sudo snap install --beta nvim --classic # --classic is important for nvim
sudo snap install obs-studio --candidate
sudo snap install steam --edge
sudo snap install defold

# TODO: Should check how I install GoXLR .deb on that link: https://github.com/GoXLR-on-Linux/goxlr-utility/releases/download/v1.2.2/goxlr-utility_1.2.2-1_amd64.deb

# --- TODOs (Manual Steps/Further Investigation) ---
echo "--- Important TODOs ---"
echo "1. OBS Studio: Review your specific needs for OBS Studio here: https://snapcraft.io/obs-studio"
echo "2. GoXLR Utility: The .deb file installation needs to be handled carefully."
echo "   You can download and install it like this:"
echo "   wget https://github.com/GoXLR-on-Linux/goxlr-utility/releases/download/v1.2.2/goxlr-utility_1.2.2-1_amd64.deb"
echo "   sudo dpkg -i goxlr-utility_1.2.2-1_amd64.deb"
echo "   sudo apt --fix-broken install # To resolve any dependency issues after dpkg"
echo "   (Consider checking for the latest version on the GitHub releases page for GoXLR Utility)"
echo "3. Remember to configure your newly installed tools and applications!"

echo "Ubuntu system setup script finished!"
