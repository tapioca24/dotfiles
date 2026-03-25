# dotfiles

## Tools

### System

| Tool | Description |
|------|-------------|
| [nix-darwin](https://github.com/nix-darwin/nix-darwin) | macOS system configuration with Nix |
| [chezmoi](https://github.com/twpayne/chezmoi) | dotfiles manager |
| [mise](https://github.com/jdx/mise) | runtime version manager (Node, etc.) |
| [just](https://github.com/casey/just) | task runner |

### Terminal & Shell

| Tool | Description |
|------|-------------|
| [Ghostty](https://ghostty.org) | terminal emulator |
| [zsh](https://www.zsh.org) | shell |
| [starship](https://github.com/starship/starship) | prompt |
| [sheldon](https://github.com/rossmacarthur/sheldon) | zsh plugin manager |
| [zsh-abbr](https://github.com/olets/zsh-abbr) | abbreviation expansion |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | command suggestions |
| [fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting) | syntax highlighting |
| [fzf](https://github.com/junegunn/fzf) | fuzzy finder |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | smart cd |

### Editor

| Tool | Description |
|------|-------------|
| [Helix](https://github.com/helix-editor/helix) | modal text editor |

### CLI Utilities

| Tool | Description |
|------|-------------|
| [eza](https://github.com/eza-community/eza) | `ls` replacement |
| [bat](https://github.com/sharkdp/bat) | `cat` replacement |
| [fd](https://github.com/sharkdp/fd) | `find` replacement |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | fast grep |
| [sd](https://github.com/chmln/sd) | `sed` replacement |
| [dust](https://github.com/bootandy/dust) | `du` replacement |
| [jaq](https://github.com/01mf02/jaq) | `jq` compatible JSON processor |
| [btop](https://github.com/aristocratos/btop) | system monitor |

### Git

| Tool | Description |
|------|-------------|
| [delta](https://github.com/dandavison/delta) | diff pager |
| [gh](https://github.com/cli/cli) | GitHub CLI |
| [ghq](https://github.com/x-motemen/ghq) | repository manager |

### macOS

| Tool | Description |
|------|-------------|
| [AeroSpace](https://github.com/nikitabobko/AeroSpace) | tiling window manager |
| [JankyBorders](https://github.com/FelixKratz/JankyBorders) | window border highlight |

### Theme & Font

| Tool | Description |
|------|-------------|
| [Catppuccin Macchiato](https://github.com/catppuccin/catppuccin) | color theme (used across all tools) |
| [Maple Mono NF CN](https://github.com/subframe7536/maple-font) | programming font |

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
