#!/usr/bin/env bash

# =============================================================================
# VIM ENVIRONMENT PROVISIONER (No-Package-Manager Edition)
# Targets: Node.js, Vim-Plug, LaTeX, and Nerd Fonts
# =============================================================================

# Define local paths
LOCAL_BIN="$HOME/.local/bin"
LOCAL_SRC="$HOME/.local/src"
mkdir -p "$LOCAL_BIN" "$LOCAL_SRC"

# Add local bin to current session path
export PATH="$LOCAL_BIN:$PATH"

echo "--- Starting Smart Provisioning ---"

# 1. Install Node.js (Static Binary)
# Required for CoC and Copilot
if ! command -v node &> /dev/null; then
    echo "[*] Installing Node.js via static binary..."
    NODE_VER="v20.11.0" # Stable LTS
    NODE_DIST="node-$NODE_VER-linux-x64"
    
    cd "$LOCAL_SRC"
    curl -LO "https://nodejs.org/dist/$NODE_VER/$NODE_DIST.tar.xz"
    tar -xJf "$NODE_DIST.tar.xz"
    
    # Link binaries to local bin
    ln -sf "$LOCAL_SRC/$NODE_DIST/bin/node" "$LOCAL_BIN/node"
    ln -sf "$LOCAL_SRC/$NODE_DIST/bin/npm" "$LOCAL_BIN/npm"
    echo "[+] Node.js installed at $LOCAL_BIN/node"
else
    echo "[ok] Node.js already exists"
fi

# 2. Install Vim-Plug
# The foundation for your .vimrc structure
if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
    echo "[*] Installing vim-plug..."
    curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    echo "[+] vim-plug installed."
else
    echo "[ok] vim-plug already exists"
fi

# 3. Install Fira Code Nerd Font
# Critical for your KindLabels and icons
FONT_DIR="$HOME/.local/share/fonts"
if [ ! -d "$FONT_DIR" ] || [ -z "$(ls -A $FONT_DIR)" ]; then
    echo "[*] Installing FiraCode Nerd Font..."
    mkdir -p "$FONT_DIR"
    cd "$LOCAL_SRC"
    curl -LO https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/FiraCode.zip
    unzip -o FiraCode.zip -d "$FONT_DIR"
    # Update font cache if fc-cache exists, else skip
    command -v fc-cache &> /dev/null && fc-cache -f "$FONT_DIR"
    echo "[+] Fonts installed to $FONT_DIR"
else
    echo "[ok] Fonts directory populated"
fi

# 4. Install/Upgrade Vim from Source
# This part ensures you have the latest version with +python3 and +terminal support
VIM_VERSION="master" # Pulls the latest stable development version

if [[ "$(vim --version | head -n 1)" != *"Vim 9.1"* ]]; then
    echo "[*] Current Vim is outdated or missing. Compiling latest Vim..."

    # Create source directory if not exists
    mkdir -p "$LOCAL_SRC"
    cd "$LOCAL_SRC"

    # Clone Vim repository (shallow clone for speed)
    if [ ! -d "vim" ]; then
        git clone --depth 1 https://github.com/vim/vim.git
    fi

    cd vim
    git pull

    # Configure build:
    # --prefix: installs to your local home directory
    # --with-features=huge: enables all advanced features
    # --enable-python3interp: critical for AI/CoC plugins
    ./configure --prefix="$HOME/.local" \
                --with-features=huge \
                --enable-multibyte \
                --enable-python3interp=yes \
                --with-python3-config-dir=$(python3-config --configdir) \
                --enable-gui=no \
                --enable-cscope \
                --enable-terminal

    echo "[*] Building Vim (this may take a minute)..."
    make -j$(nproc)
    sudo make install

    echo "[+] Vim $(./src/vim --version | head -n 1) installed to $LOCAL_BIN/vim"
else
    echo "[ok] Vim is already up to date."
fi

# 5. Finalize Vim Setup
echo "[*] Triggering Vim PlugInstall and CoC updates..."
# Run vim in ex-mode to install plugins without opening the UI
vim +PlugInstall +qall

echo "--- Provisioning Complete ---"
echo "IMPORTANT: Ensure your ~/.bashrc or ~/.profile contains:"
echo "export PATH=\"\$HOME/.local/bin:\$PATH\""
