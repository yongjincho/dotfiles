---
name: install
description: Install dotfiles by creating symbolic links from this repository to $HOME, mimicking GNU Stow behavior.
---

# Install Dotfiles

Create symbolic links from this repository to `$HOME`, mimicking GNU Stow behavior.

## Instructions

1. Identify the dotfiles repository root (the directory containing the `.claude/` folder).
2. Find all package directories in the repo root. A package directory is any top-level directory that is NOT `.git`, `.claude`, or any other non-package directory (like `node_modules`). Currently the packages are: `nvim`, `tmux`, `git`.
3. For each package directory, walk its contents recursively. For each file found, compute the target path by replacing the package directory prefix with `$HOME`. For example:
   - `nvim/.config/nvim/init.lua` -> `$HOME/.config/nvim/init.lua`
   - `tmux/.tmux.conf` -> `$HOME/.tmux.conf`
   - `git/.gitconfig` -> `$HOME/.gitconfig`
4. For each target:
   - Create parent directories if they don't exist (`mkdir -p`).
   - If the target already exists and is a symlink pointing to the correct source, skip it and report as "already linked".
   - If the target already exists (file or different symlink), back it up by renaming to `<target>.bak.<timestamp>` and report the backup.
   - Create a symbolic link: `ln -s <source> <target>`.
5. Print a summary of all actions taken (links created, files backed up, already linked).

## Important

- Use absolute paths for both source and target in symlinks.
- Never overwrite files without backing them up first.
- If the user provides arguments (e.g., `$ARGUMENTS`), treat them as specific package names to install. If no arguments are given, install all packages.
- Do NOT install the `.claude` directory itself as a dotfile package.
