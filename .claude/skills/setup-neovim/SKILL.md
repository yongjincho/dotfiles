---
name: setup-neovim
description: Install Neovim and its dependencies (ripgrep, Node.js) as prebuilt binaries to ~/opt/.
---

# Setup Neovim

Install Neovim and its plugin dependencies as prebuilt binaries to `~/opt/`.

## Tools

| Tool | Install Path | Binary | Source |
|------|-------------|--------|--------|
| Neovim | `~/opt/nvim/` | `~/opt/nvim/bin/nvim` | GitHub releases (latest stable) |
| ripgrep | `~/opt/ripgrep/` | `~/opt/ripgrep/rg` | GitHub releases (latest) |
| Node.js | `~/opt/node/` | `~/opt/node/bin/node` | nodejs.org (latest LTS) |

## Instructions

1. **Parse arguments**: If `$ARGUMENTS` is provided, treat each word as a tool name to install (valid names: `neovim`, `ripgrep`, `node`). If no arguments are given, install all three tools.

2. **Detect architecture**: Run `uname -m` to determine the CPU architecture. Map `x86_64` to x86_64/x64, `aarch64` to arm64.

3. **Detect shell RC file**: Use `~/.zshrc` if it exists, otherwise `~/.bashrc`.

4. **For each tool to install**, perform the following steps:

### Neovim

1. Fetch the latest stable release tag from the GitHub API: `https://api.github.com/repos/neovim/neovim/releases/latest`
2. Download the tarball from the release assets:
   - x86_64: `nvim-linux-x86_64.tar.gz`
   - aarch64: `nvim-linux-arm64.tar.gz`
3. Download to `/tmp/`, extract, and move the contents to `~/opt/nvim/` (remove existing `~/opt/nvim/` first if present).
4. The tarball extracts to a directory like `nvim-linux-x86_64/` — move its contents so that `~/opt/nvim/bin/nvim` exists.
5. Clean up the tarball from `/tmp/`.
6. Verify: `~/opt/nvim/bin/nvim --version`

### ripgrep

1. Fetch the latest release tag from: `https://api.github.com/repos/BurntSushi/ripgrep/releases/latest`
2. Download the tarball from the release assets:
   - x86_64: `ripgrep-<version>-x86_64-unknown-linux-musl.tar.gz`
   - aarch64: `ripgrep-<version>-aarch64-unknown-linux-gnu.tar.gz`
3. Download to `/tmp/`, extract to a temp directory.
4. Create `~/opt/ripgrep/` (remove existing first if present) and copy the `rg` binary into it. There is no `bin/` subdirectory — the binary goes directly at `~/opt/ripgrep/rg`.
5. Clean up the tarball and extracted directory from `/tmp/`.
6. Verify: `~/opt/ripgrep/rg --version`

### Node.js

1. Fetch the latest LTS version from: `https://nodejs.org/dist/index.json` — find the first entry where `lts` is not `false`.
2. Download the tarball:
   - x86_64: `node-<version>-linux-x64.tar.xz`
   - aarch64: `node-<version>-linux-arm64.tar.xz`
   - URL pattern: `https://nodejs.org/dist/<version>/node-<version>-linux-<arch>.tar.xz`
3. Download to `/tmp/`, extract, and move contents to `~/opt/node/` (remove existing first if present).
4. The tarball extracts to `node-<version>-linux-<arch>/` — move its contents so that `~/opt/node/bin/node` exists.
5. Clean up the tarball from `/tmp/`.
6. Verify: `~/opt/node/bin/node --version`

## PATH Configuration

After installing all requested tools, ensure the shell RC file contains the necessary PATH exports. For each installed tool, check if the corresponding export line already exists in the RC file before adding:

- Neovim: `export PATH="$HOME/opt/nvim/bin:$PATH"`
- ripgrep: `export PATH="$HOME/opt/ripgrep:$PATH"`
- Node.js: `export PATH="$HOME/opt/node/bin:$PATH"`

Append missing lines to the end of the RC file. Do NOT duplicate existing entries.

## Important

- Always use `curl -fSL` for downloads (fail on HTTP errors, follow redirects, show errors).
- Remove existing `~/opt/<tool>/` directory before extracting to ensure a clean install.
- Create `~/opt/` if it does not exist.
- After all installs, print a summary of what was installed and the versions.
- If a download or extraction fails, report the error clearly and continue with remaining tools.
