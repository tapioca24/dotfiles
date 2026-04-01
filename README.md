# dotfiles

## Package Management Policy

- **Nix** — CLI tools and system packages. Nix is preferred by default.
- **Homebrew** — Fallback for packages unavailable in Nix.
- **mise** — Language runtimes and tools that require per-project version switching (Node, etc.).
- **Manual** — GUI applications are not managed here; install them manually.

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
| [pure](https://github.com/sindresorhus/pure) | prompt |
| [sheldon](https://github.com/rossmacarthur/sheldon) | zsh plugin manager |
| [zsh-abbr](https://github.com/olets/zsh-abbr) | abbreviation expansion |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | command suggestions |
| [fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting) | syntax highlighting |
| [ni.zsh](https://github.com/azu/ni.zsh) | package manager auto-detection (`ni`, `nr`, etc.) |
| [fzf-git.sh](https://github.com/junegunn/fzf-git.sh) | fzf keybindings for git objects |
| [fzf](https://github.com/junegunn/fzf) | fuzzy finder |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | smart cd |

### Editor

| Tool | Description |
|------|-------------|
| [Helix](https://github.com/helix-editor/helix) | modal text editor |

### CLI Utilities

| Tool | Description |
|------|-------------|
| [yazi](https://github.com/sxyazi/yazi) | terminal file manager |
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
| [lazygit](https://github.com/jesseduffield/lazygit) | TUI git client |
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
| [Maple Mono Normal NL NF](https://github.com/subframe7536/maple-font) | programming font |
| [HackGen](https://github.com/yuru7/HackGen) | programming font (Japanese fallback) |

## Setup on a New Machine

### Prerequisites

Set the hostname:

```sh
sudo scutil --set LocalHostName <hostname>
sudo scutil --set ComputerName <hostname>
```

### Installation

```sh
# 1. Install Nix (DeterminateSystems)
curl -fsSL https://install.determinate.systems/nix | sh -s -- install

# 2. Setup chezmoi
nix run nixpkgs#chezmoi -- init tapioca24
nix run nixpkgs#chezmoi -- apply

# 3. Add your host to ~/.config/nix-darwin/hosts and register it in flake.nix

# 4. Install nix-darwin (initial bootstrap)
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/.config/nix-darwin#$(scutil --get LocalHostName)
```

### Manual Steps

Install the following tools that have configs in this repo but are not managed by Nix:

- [Ghostty](https://ghostty.org) — terminal emulator
