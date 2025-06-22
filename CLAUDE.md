# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository containing configuration files for development tools. The repository is organized by application with each tool having its own directory containing configuration files.

## Directory Structure

- `nvim/` - Neovim configuration with Lua-based setup
- `vim/` - Legacy Vim configuration with vimrc and plugin management
- `tmux/` - Terminal multiplexer configuration
- `git/` - Git configuration and aliases
- `.claude/` - Claude Code settings (local permissions configuration)

## Key Configuration Files

### Neovim (`nvim/.config/nvim/init.lua`)
- Modern Lua-based configuration using lazy.nvim plugin manager
- Configured LSP servers: lua_ls, pyright, gopls via Mason
- Includes Copilot integration and custom keybindings
- Solarized light theme with lualine status bar
- Claude Code integration via claudecode.nvim plugin with leader key mappings

### Git (`git/.gitconfig`)
- Personal git configuration for Yongjin Cho
- Common aliases: st (status), ci (commit), co (checkout), br (branch)
- HTTPS to SSH URL rewriting for GitHub
- Global gitignore file reference

### Tmux (`tmux/.tmux.conf`)
- Custom key bindings for pane management and window operations
- Solarized light color scheme via tmux-colors-solarized plugin
- Plugin management via TPM (Tmux Plugin Manager)

### Vim (`vim/.vimrc`)
- Legacy Vim configuration with vim-plug for plugin management
- YouCompleteMe for code completion
- Airline status bar with solarized theme
- Language-specific indentation settings

## Installation/Setup Commands

This repository doesn't have automated installation scripts. Configuration files are typically symlinked to their appropriate locations:

- Neovim: `~/.config/nvim/init.lua` → `nvim/.config/nvim/init.lua`
- Vim: `~/.vimrc` → `vim/.vimrc`
- Tmux: `~/.tmux.conf` → `tmux/.tmux.conf`
- Git: `~/.gitconfig` → `git/.gitconfig`

## Development Workflow

### Neovim Plugin Management
- Uses lazy.nvim as plugin manager
- Plugins auto-install on first run
- LSP servers managed via Mason (`:Mason` to open interface)
- Treesitter parsers auto-install based on file types

### Git Workflow
- Fast-forward only pulls configured (`pull.ff = only`)
- SSH preferred over HTTPS for GitHub repositories
- Global gitignore excludes common development artifacts

### Claude Code Integration
- Claude Code plugin configured in Neovim with keybindings under `<leader>a`
- Local permissions configured in `.claude/settings.local.json`
- Key mappings: `<leader>ac` (toggle), `<leader>af` (focus), `<leader>ar` (resume)

## Theme and Appearance

All tools are configured with Solarized light theme for consistency:
- Neovim: solarized.nvim with light background
- Tmux: tmux-colors-solarized light variant
- Vim: airline-solarized theme

## Language Support

- **Go**: Full LSP support with gopls, auto-formatting with goimports on save
- **Python**: LSP support with pyright, workspace-level diagnostics
- **Lua**: LSP support with lua_ls, Neovim API globals configured
- **Markdown**: Preview support via markdown-preview.nvim