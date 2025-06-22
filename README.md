# Dotfiles

Personal development environment configuration files.

## Overview

This repository contains configuration files for various development tools, organized by application. Each tool has its own directory with relevant configuration files.

## Tools Configured

- **Neovim** - Modern Lua-based configuration with LSP, Copilot, and Claude Code integration
- **Tmux** - Terminal multiplexer with custom keybindings and Solarized theme
- **Git** - Personal configuration with aliases and SSH preference

## Quick Setup

### Using GNU Stow (Recommended)

```bash
# Install stow if not already installed
# macOS: brew install stow
# Ubuntu/Debian: sudo apt install stow

git clone git@github.com:yongjincho/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Use stow to create symlinks
stow nvim
stow tmux
stow git
```

### Manual Symlinks (Alternative)

```bash
git clone git@github.com:yongjincho/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Create symlinks manually
ln -sf ~/.dotfiles/nvim/.config/nvim/init.lua ~/.config/nvim/init.lua
ln -sf ~/.dotfiles/tmux/.tmux.conf ~/.tmux.conf
ln -sf ~/.dotfiles/git/.gitconfig ~/.gitconfig
```

## Features

### Neovim
- **Plugin Manager**: lazy.nvim with auto-installation
- **LSP Support**: lua_ls, pyright, gopls via Mason
- **AI Integration**: GitHub Copilot and Claude Code
- **Theme**: Solarized light with lualine status bar

### Git
- **Aliases**: `st` (status), `ci` (commit), `co` (checkout), `br` (branch)
- **SSH Preference**: Automatic HTTPS to SSH rewriting for GitHub
- **Case Sensitivity**: Configured for case-sensitive file handling

### Tmux
- **Plugin Management**: TPM (Tmux Plugin Manager)
- **Theme**: Solarized light color scheme
- **Custom Keybindings**: Enhanced pane and window management

## Language Support

- **Go**: Full LSP with auto-formatting on save
- **Python**: LSP with workspace-level diagnostics
- **Lua**: LSP with Neovim API globals
- **Markdown**: Live preview support

## Claude Code Integration

Neovim includes Claude Code plugin with comprehensive keybindings under `<leader>a`:
- `<leader>ac` - Toggle Claude
- `<leader>af` - Focus Claude
- `<leader>ar` - Resume Claude
- `<leader>ab` - Add current buffer
- `<leader>aa` - Accept diff
- `<leader>ad` - Deny diff

See `CLAUDE.md` for detailed Claude Code configuration and usage.
