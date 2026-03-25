# dotfiles

## Tools

- terminal: Ghostty
- shell: zsh
- editor: Helix

## Setup

### Prerequisites

### Installation

```sh
# 1. Install Nix

# 2. Install nix-darwin

# 3. Setup chezmoi
chezmoi init tapioca24

# 4 Add your host to ~/.config/nix-darwin/hosts

# 5. darwin-rebuild switch
sudo darwin-rebuild switch --flake ~/.config/nix-darwin#(scutil --get LocalHostName)
```
