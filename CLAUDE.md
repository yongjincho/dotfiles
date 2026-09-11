# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal dotfiles. There is no build, no test suite, and no lint step — the "product" is a set of
config files that get symlinked into `$HOME`. Verification means loading a config, not running a test.

## Stow layout — the one structural rule

Each top-level directory is a **package** whose contents mirror `$HOME` exactly:

```
nvim/.config/nvim/init.lua   →  ~/.config/nvim/init.lua
tmux/.tmux.conf              →  ~/.tmux.conf
git/.gitconfig               →  ~/.gitconfig
git/.gitignore_global        →  ~/.gitignore_global
ghostty/.config/ghostty/config → ~/.config/ghostty/config
```

Everything below a package root is a literal path under `$HOME`. When adding a file, place it at the
path it should occupy in `$HOME` — never invent a flat name and map it later.

`git/.gitignore` is **not** a package file in this sense; it is this repo's own ignore file, sitting
inside the `git/` package directory. Do not confuse it with `git/.gitignore_global`, which is the one
that gets linked out to `~/.gitignore_global` (referenced by `core.excludesfile`).

### Installing

`/install` (skill at `.claude/skills/install/SKILL.md`) walks packages, backs up any existing target
to `<target>.bak.<timestamp>`, and symlinks. `/install nvim tmux` restricts to named packages.

**The skill's package list is hardcoded and currently stale** — it names `nvim`, `tmux`, `git` but
not `ghostty`. Adding a new package means updating that list in `SKILL.md` too.

## Neovim config architecture (`nvim/.config/nvim/init.lua`)

Single 335-line file, no `lua/` module tree. The pattern that matters:

1. Each plugin is a **local variable holding a lazy.nvim spec table**, grouped under banner comments
   (UI / Explorer / Coding / Agents / Language specific).
2. The very bottom bootstraps lazy.nvim and passes those locals as a flat list to `require("lazy").setup{}`.

**To add a plugin you must do both**: define the local spec *and* add its name to the list at the
bottom. A spec that is defined but not listed is silently dead code.

Keymaps live in two places by design:
- Global/plugin maps are set inside each spec's `config` function via the `nmap` helper defined at the top.
- LSP buffer-local maps (`gd`, `gr`, `K`, `<space>rn`, …) are set in a single `LspAttach` autocmd near
  the LSP section — not per-server.

### LSP — uses the Neovim 0.11+ API

Configuration goes through `vim.lsp.config(name, {...})` + `vim.lsp.enable({...})`, **not** the older
`require("lspconfig").<server>.setup{}`. Match this style; mixing the two causes servers to attach twice.

Servers actually configured: **`lua_ls` and `pyright` only**. Adding a server means touching three
spots in the `mason_lspconfig` spec: `ensure_installed`, a `vim.lsp.config` block, and `vim.lsp.enable`.

`lazy-lock.json` pins plugin commits; commit it alongside config changes after `:Lazy update`.

### Verifying a Neovim change

```bash
nvim --headless "+Lazy! sync" +qa      # resolve/install plugins headlessly
nvim --headless +qa                    # smoke test: config loads without error
```

## setup-neovim installs Linux binaries

`/setup-neovim` downloads prebuilt **Linux** tarballs (`nvim-linux-*`, `*-unknown-linux-musl`,
`node-*-linux-*`) into `~/opt/` and appends PATH lines to the shell RC. It is for remote/cluster
boxes, not this macOS laptop — on macOS use Homebrew instead. Do not "fix" it to be cross-platform
unless asked.

## Other configs

- **tmux**: prefix-based bindings only (`|`/`-` split, `hjkl` navigate, `HJKL` resize, `S` sync-panes,
  `r` reload). Plugins via TPM; `run '~/.tmux/plugins/tpm/tpm'` must stay the last line of the file.
  Reload with `tmux source-file ~/.tmux.conf`.
- **git**: `pull.ff = only`, `core.ignorecase = false`, `merge.conflictStyle = zdiff3`, and an
  `insteadOf` rule rewriting `https://github.com/` → `ssh://git@github.com/`. Verify with
  `git config --list --show-origin`.
- **`git/.gitignore_global`** carries ML-experiment ignores (`/experiments`, `/runs`,
  `/docs/experiments/status.json`, `/tmp`) plus `.claude/settings.local.json`. These are deliberate:
  they keep experiment artifacts out of every work repo without per-repo `.gitignore` edits.
- **ghostty**: depends on `D2CodingLigature Nerd Font` being installed separately; no skill installs it.

## Theme

Solarized **light** everywhere — nvim (`solarized.nvim` + `lualine` `solarized_light`), tmux
(`seebi/tmux-colors-solarized` with `@colors-solarized 'light'`), ghostty (`iTerm2 Solarized Light`).
Changing theme means changing all three.
