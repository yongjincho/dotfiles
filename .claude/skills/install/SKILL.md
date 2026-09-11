---
name: install
description: Install dotfiles by creating symbolic links from this repository to $HOME, mimicking GNU Stow behavior.
---

# Install Dotfiles

Create symbolic links from this repository to `$HOME`, mimicking GNU Stow behavior.

## Instructions

1. Identify the dotfiles repository root (the directory containing the `.claude/` folder).
2. Find all package directories in the repo root. A package directory is any top-level directory that is NOT `.git`, `.claude`, or any other non-package directory (like `node_modules`). Currently the packages are: `nvim`, `tmux`, `git`, `ghostty`.
3. For each package directory, walk its contents recursively. For each file found, compute the target path by replacing the package directory prefix with `$HOME`. For example:
   - `nvim/.config/nvim/init.lua` -> `$HOME/.config/nvim/init.lua`
   - `tmux/.tmux.conf` -> `$HOME/.tmux.conf`
   - `ghostty/.config/ghostty/config` -> `$HOME/.config/ghostty/config`
4. For each target:
   - Create parent directories if they don't exist (`mkdir -p`).
   - If the target already exists and is a symlink pointing to the correct source, skip it and report as "already linked".
   - If the target already exists (file or different symlink), back it up by renaming to `<target>.bak.<timestamp>` and report the backup.
   - Create a symbolic link: `ln -s <source> <target>`.
5. **Special case — `git/gitconfig` is never symlinked.** It is included by reference from
   `~/.gitconfig`, which must stay a real machine-local file so GUI clients (Sourcetree) can write
   to it without dirtying the repo. Skip it during the walk, and instead:
   - If `~/.gitconfig` does not exist, create it containing exactly:
     ```
     [include]
     	path = ~/.dotfiles/git/gitconfig
     ```
   - If `~/.gitconfig` exists but contains no `[include]` line pointing at `git/gitconfig`, prepend
     that stanza and report it. **Never overwrite or back up `~/.gitconfig`** — other tools own the
     rest of its contents.
   - Note this assumes `~/.dotfiles` resolves to the repo. If it does not, use the repo's absolute path.

6. Print a summary of all actions taken (links created, files backed up, already linked).

## Important

- Use absolute paths for both source and target in symlinks.
- Never overwrite files without backing them up first.
- If the user provides arguments (e.g., `$ARGUMENTS`), treat them as specific package names to install. If no arguments are given, install all packages.
- Do NOT install the `.claude` directory itself as a dotfile package.
- Do NOT symlink `git/gitconfig` (see the special case above). `git/.gitignore_global` IS
  symlinked normally, to `~/.gitignore_global`.
