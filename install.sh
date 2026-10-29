#!/usr/bin/env bash

set -e

# Configuration
GITHUB_USERNAME="${GITHUB_USERNAME:-sergiomercado19}"
DOTFILES_REPO_SSH="git@github.com:${GITHUB_USERNAME}/dotfiles.git"
DOTFILES_REPO_HTTPS="https://github.com/${GITHUB_USERNAME}/dotfiles.git"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_step() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_progress() {
    echo -e "${BLUE}...${NC} $1"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check required dependencies
check_dependencies() {
    print_step "Checking required dependencies..."

    local missing_deps=()

    if ! command_exists curl; then
        missing_deps+=("curl")
    fi

    if ! command_exists tee; then
        missing_deps+=("tee")
    fi

    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
        print_error "Please install these tools and try again."
        exit 1
    fi

    print_success "All required dependencies present"
}

# Verify SSH access to GitHub
check_github_ssh() {
    print_step "Checking GitHub SSH access..."

    if ssh -T git@github.com -o StrictHostKeyChecking=accept-new -o ConnectTimeout=5 2>&1 | grep -q "successfully authenticated"; then
        print_success "GitHub SSH access verified"
        return 0
    else
        print_warning "GitHub SSH access not available"
        return 1
    fi
}

# Verify installation of a tool
verify_installation() {
    local tool_name="$1"
    local version_command="$2"

    print_progress "Verifying ${tool_name} installation..."

    if command_exists "$tool_name"; then
        if [ -n "$version_command" ]; then
            local version
            version=$(eval "$version_command" 2>&1 || echo "unknown")
            print_success "${tool_name} verified (${version})"
        else
            print_success "${tool_name} verified"
        fi
        return 0
    else
        print_error "${tool_name} verification failed"
        return 1
    fi
}

# Detect OS
OS="unknown"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    if command_exists apt-get; then
        PKG_MANAGER="apt-get"
    elif command_exists yum; then
        PKG_MANAGER="yum"
    elif command_exists pacman; then
        PKG_MANAGER="pacman"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    PKG_MANAGER="brew"
fi

print_step "Detected OS: $OS"

# ============================================================================
# Step 1: Install Git, ZSH & tmux
# ============================================================================
install_git_zsh() {
    print_step "Installing Git, ZSH, and tmux..."

    if command_exists git && command_exists zsh && command_exists tmux; then
        print_success "Git, ZSH, and tmux already installed"
        return
    fi

    case "$OS" in
        linux)
            case "$PKG_MANAGER" in
                apt-get)
                    sudo apt-get update
                    sudo apt-get install -y git zsh tmux
                    ;;
                yum)
                    sudo yum install -y git zsh tmux
                    ;;
                pacman)
                    sudo pacman -S --noconfirm git zsh tmux
                    ;;
            esac
            ;;
        macos)
            if ! command_exists brew; then
                print_error "Homebrew not found. Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            brew install git zsh tmux
            ;;
    esac

    print_success "Git, ZSH, and tmux installed"

    # Verify installations
    verify_installation "git" "git --version"
    verify_installation "zsh" "zsh --version"
    verify_installation "tmux" "tmux -V"
}

# ============================================================================
# Step 2: Install Mise (formerly rtx)
# ============================================================================
install_mise() {
    print_step "Installing Mise..."

    if command_exists mise; then
        print_success "Mise already installed"
        verify_installation "mise" "mise --version"
        return
    fi

    # Install mise with better error handling
    print_progress "Downloading and installing mise..."
    if ! curl -fsSL https://mise.run | sh; then
        print_error "Failed to install mise"
        return 1
    fi

    # Add mise to PATH for this session
    export PATH="$HOME/.local/bin:$PATH"

    # Add mise shims to PATH for this session
    if [[ -d "$HOME/.local/share/mise/shims" ]]; then
        export PATH="$HOME/.local/share/mise/shims:$PATH"
    fi

    print_success "Mise installed and added to PATH"

    # Verify installation
    verify_installation "mise" "mise --version"
}

# ============================================================================
# Step 3: Install chezmoi
# ============================================================================
install_chezmoi() {
    print_step "Installing chezmoi..."

    if command_exists chezmoi; then
        print_success "chezmoi already installed"
        verify_installation "chezmoi" "chezmoi --version"
    else
        # Install chezmoi with better error handling
        print_progress "Downloading and installing chezmoi..."
        if ! sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"; then
            print_error "Failed to install chezmoi"
            return 1
        fi

        # Add to PATH for this session
        export PATH="$HOME/.local/bin:$PATH"

        print_success "chezmoi installed"

        # Verify installation
        verify_installation "chezmoi" "chezmoi --version"
    fi

    # Initialize chezmoi with your dotfiles repo
    print_step "Initializing chezmoi from your dotfiles repo..."

    if [[ -d "$HOME/.local/share/chezmoi/.git" ]]; then
        print_warning "chezmoi already initialized, skipping init"
    else
        # Determine which repo URL to use
        local repo_url
        if check_github_ssh; then
            repo_url="$DOTFILES_REPO_SSH"
            print_step "Using SSH: ${repo_url}"
        else
            repo_url="$DOTFILES_REPO_HTTPS"
            print_step "Using HTTPS: ${repo_url}"
            print_warning "Consider setting up SSH keys for GitHub authentication"
        fi

        print_progress "Cloning dotfiles repository..."
        if chezmoi init "$repo_url"; then
            print_success "chezmoi initialized from ${repo_url}"
        else
            print_error "Failed to initialize chezmoi from ${repo_url}"
            return 1
        fi
    fi
}

# ============================================================================
# Step 4: Install Oh My Zsh
# ============================================================================
install_oh_my_zsh() {
    print_step "Installing Oh My Zsh..."

    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        print_success "Oh My Zsh already installed"
    else
        # Install Oh My Zsh (non-interactive) with better error handling
        print_progress "Downloading and installing Oh My Zsh..."
        if ! RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; then
            print_error "Failed to install Oh My Zsh"
            return 1
        fi
        print_success "Oh My Zsh installed"
    fi

    # Install zsh-autosuggestions
    print_step "Installing zsh-autosuggestions plugin..."
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    if [[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
        print_success "zsh-autosuggestions already installed"
    else
        print_progress "Cloning zsh-autosuggestions..."
        if git clone --progress https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"; then
            print_success "zsh-autosuggestions installed"
        else
            print_error "Failed to install zsh-autosuggestions"
        fi
    fi

    # Install zsh-syntax-highlighting
    print_step "Installing zsh-syntax-highlighting plugin..."

    if [[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
        print_success "zsh-syntax-highlighting already installed"
    else
        print_progress "Cloning zsh-syntax-highlighting..."
        if git clone --progress https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"; then
            print_success "zsh-syntax-highlighting installed"
        else
            print_error "Failed to install zsh-syntax-highlighting"
        fi
    fi
}

# ============================================================================
# Step 5: Install Powerlevel10k
# ============================================================================
install_powerlevel10k() {
    print_step "Installing Powerlevel10k theme..."

    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    if [[ -d "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
        print_success "Powerlevel10k already installed"
    else
        print_progress "Cloning Powerlevel10k theme..."
        if git clone --depth=1 --progress https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"; then
            print_success "Powerlevel10k installed"
        else
            print_error "Failed to install Powerlevel10k"
            return 1
        fi
    fi
}

# ============================================================================
# Step 6: Apply dotfiles with chezmoi
# ============================================================================
apply_dotfiles() {
    print_step "Applying dotfiles with chezmoi..."

    if command_exists chezmoi; then
        chezmoi update
        print_success "Dotfiles applied successfully"
    else
        print_error "chezmoi not found, skipping dotfiles update"
    fi
}

# ============================================================================
# Step 7: Set ZSH as default shell
# ============================================================================
set_zsh_default() {
    print_step "Setting ZSH as default shell..."

    if [[ "$SHELL" == "$(which zsh)" ]]; then
        print_success "ZSH is already the default shell"
    else
        # Add zsh to /etc/shells if not present
        if ! grep -q "$(which zsh)" /etc/shells; then
            print_step "Adding ZSH to /etc/shells..."
            echo "$(which zsh)" | sudo tee -a /etc/shells
        fi

        # Change default shell
        chsh -s "$(which zsh)"
        print_success "Default shell changed to ZSH (restart terminal to apply)"
    fi
}

# ============================================================================
# Main installation
# ============================================================================
main() {
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   CLI Setup Installation Script       ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""

    if [ -n "$GITHUB_USERNAME" ] && [ "$GITHUB_USERNAME" != "sergiomercado19" ]; then
        print_step "Using custom GitHub username: ${GITHUB_USERNAME}"
    fi

    check_dependencies
    install_git_zsh
    install_mise
    install_chezmoi
    install_oh_my_zsh
    install_powerlevel10k
    apply_dotfiles
    set_zsh_default

    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   Installation Complete! 🎉            ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""
    print_step "Next steps:"
    echo "  1. Restart your terminal or run: exec zsh"
    echo "  2. Configure Powerlevel10k: p10k configure"
    echo "  3. Verify plugins are enabled in ~/.zshrc:"
    echo "     plugins=(git zsh-autosuggestions zsh-syntax-highlighting)"
    echo ""
    print_step "Configuration:"
    echo "  • GitHub username: ${GITHUB_USERNAME}"
    echo "  • To use a different GitHub username, set GITHUB_USERNAME before running:"
    echo "    export GITHUB_USERNAME=your-username"
    echo ""
}

main
