#!/usr/bin/env bash

# =============================================================================
# VIM ENVIRONMENT PROVISIONER (No-Package-Manager Edition)
# Author: Yenovq Hakobyan
# Targets: Node.js, Vim-Plug, LaTeX, Nerd Fonts, and Vim (Source Build)
# =============================================================================

# Enable Strict Mode
set -euo pipefail
IFS=$'\n\t'

# Define local paths
LOCAL_BIN="$HOME/.local/bin"
LOCAL_SRC="$HOME/.local/src"
FONT_DIR="$HOME/.local/share/fonts"

# Export path for the current session
export PATH="$LOCAL_BIN:$PATH"

# =============================================================================
# Helper Functions
# =============================================================================

log_info() { echo -e "\e[34m[*]\e[0m $1"; }
log_success() { echo -e "\e[32m[+]\e[0m $1"; }
log_error() { echo -e "\e[31m[!]\e[0m $1"; >&2; }

check_dependencies() {
    local deps=("curl" "tar" "unzip" "git" "make" "gcc" "python3")
    local missing=()
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done

    if [ ${#missing[@]} -ne 0 ]; then
        log_error "Missing required system dependencies: ${missing[*]}"
        log_error "Please install them via your system package manager (e.g., apt, dnf, pacman) and rerun."
        exit 1
    fi
}

# =============================================================================
# Provisioning Steps
# =============================================================================

echo "--- Starting Smart Provisioning ---"
mkdir -p "$LOCAL_BIN" "$LOCAL_SRC"
check_dependencies

# 1. Install Node.js (Static Binary)
if ! command -v node &> /dev/null; then
    log_info "Installing Node.js via static binary..."
    NODE_VER="v20.11.0"
    NODE_DIST="node-$NODE_VER-linux-x64"
    NODE_ARCHIVE="$NODE_DIST.tar.xz"
    
    cd "$LOCAL_SRC"
    curl -fSLO "https://nodejs.org/dist/$NODE_VER/$NODE_ARCHIVE"
    tar -xJf "$NODE_ARCHIVE"
    
    # Link binaries to local bin (adding npx as well)
    ln -sf "$LOCAL_SRC/$NODE_DIST/bin/node" "$LOCAL_BIN/node"
    ln -sf "$LOCAL_SRC/$NODE_DIST/bin/npm" "$LOCAL_BIN/npm"
    ln -sf "$LOCAL_SRC/$NODE_DIST/bin/npx" "$LOCAL_BIN/npx"
    
    rm -f "$NODE_ARCHIVE"
    log_success "Node.js installed at $LOCAL_BIN/node"
else
    log_success "Node.js already exists ($(node -v))"
fi

# 2. Install Vim-Plug
if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
    log_info "Installing vim-plug..."
    curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    log_success "vim-plug installed."
else
    log_success "vim-plug already exists"
fi

# 3. Install Fira Code Nerd Font
if ! ls "$FONT_DIR"/FiraCode* &> /dev/null; then
    log_info "Installing FiraCode Nerd Font..."
    mkdir -p "$FONT_DIR"
    cd "$LOCAL_SRC"
    curl -fSLO https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/FiraCode.zip
    unzip -qo FiraCode.zip -d "$FONT_DIR"
    
    rm -f FiraCode.zip
    if command -v fc-cache &> /dev/null; then
        fc-cache -f "$FONT_DIR"
    fi
    log_success "Fonts installed to $FONT_DIR"
else
    log_success "FiraCode Nerd Font already installed"
fi

# 4. Install/Upgrade Vim from Source
# Checks for version >= 9.1 AND ensures python3 support is compiled in
if ! command -v vim &> /dev/null || \
   [[ "$(vim --version | head -n 1)" != *"Vim 9.1"* ]] || \
   ! vim --version | grep -q "+python3"; then
    
    log_info "Compiling latest Vim with Python3 support..."
    cd "$LOCAL_SRC"

    if [ ! -d "vim" ]; then
        git clone --depth 1 https://github.com/vim/vim.git
        cd vim
    else
        cd vim
        # Ensure a clean state before pulling updates
        git fetch --depth 1 origin master
        git reset --hard origin/master
        make distclean # Clean previous build artifacts
    fi

    # Fallback for python3-config if standard command isn't in path
    PY3_CONF_DIR=$(python3-config --configdir 2>/dev/null || echo "")

    log_info "Configuring build..."
    ./configure --prefix="$HOME/.local" \
                --with-features=huge \
                --enable-multibyte \
                --enable-python3interp=yes \
                ${PY3_CONF_DIR:+--with-python3-config-dir="$PY3_CONF_DIR"} \
                --enable-gui=no \
                --enable-cscope \
                --enable-terminal

    log_info "Building Vim (utilizing $(nproc) cores)..."
    make -j"$(nproc)"
    
    # CRITICAL FIX: Removed sudo. $HOME/.local belongs to the user.
    make install

    log_success "Vim $(./src/vim --version | head -n 1 | awk '{print $5}') installed to $LOCAL_BIN/vim"
else
    log_success "Vim is up to date and has +python3 support."
fi

# 5. Finalize Vim Setup
log_info "Triggering Vim PlugInstall..."
# Temporarily disable strict mode in case a plugin install throws a non-zero exit code
set +e
vim -E -s -c "source ~/.vimrc" -c PlugInstall -c qa
set -e

echo -e "\n\e[32m--- Provisioning Complete ---\e[0m"
echo "IMPORTANT: Ensure your ~/.bashrc or ~/.profile contains:"
echo -e "\e[33mexport PATH=\"\$HOME/.local/bin:\$PATH\"\e[0m"
