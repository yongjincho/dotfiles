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
git/.gitignore_global        →  ~/.gitignore_global
ghostty/.config/ghostty/config → ~/.config/ghostty/config
```

Everything below a package root is a literal path under `$HOME`. When adding a file, place it at the
path it should occupy in `$HOME` — never invent a flat name and map it later.

One file breaks the mirror rule: `git/gitconfig` — **deliberately has no leading dot and is never
symlinked.** See below. Everything else in `git/` is a normal package file; today that is only
`git/.gitignore_global` → `~/.gitignore_global`, which `core.excludesFile` points at.

### `~/.gitconfig` is not managed — it includes the managed file

`~/.gitconfig` used to be a symlink to this repo. Sourcetree rewrites difftool/mergetool sections via
`git config --global` on every launch, writes follow the symlink, and the tracked file came back dirty
after every launch. The split:

```
~/.gitconfig          real, untracked, machine-local  ← GUI tools scribble here freely
    [include]
        path = ~/.dotfiles/git/gitconfig

git/gitconfig         tracked, managed                ← never linked, referenced in place
```

Rules that follow from this:

- **Never restore `~/.gitconfig` as a symlink**, and never have `/install` back it up or overwrite it —
  Sourcetree's sections live there legitimately.
- Settings that should be version-controlled go in `git/gitconfig`. `git config --global` from the CLI
  writes to the shim instead, so a permanent change means editing `git/gitconfig` directly.
- **`merge.conflictStyle` is the exception — it must stay out of `git/gitconfig`.** `zdiff3` needs
  git >= 2.35; the kakao cluster runs 2.34.1, where it aborts `checkout`, `switch`, `cherry-pick`,
  `revert` and `apply` with `fatal: unknown style 'zdiff3'`. Git dies while *parsing* config, so a
  later override cannot rescue it — the value must never reach an old-git machine. `/install` picks
  `zdiff3` or `diff3` from the local git version and writes it to the shim.
- Included content comes *before* whatever the shim appends, so on a key set in both, the shim wins.
  `git/gitconfig` sets no difftool/mergetool keys, which is why there is no conflict today.

**Other machines lag behind.** This repo is checked out on the clusters too, where `~/.gitconfig`
may still be the old symlink to `git/.gitconfig`. Pulling the rename there leaves a dangling symlink,
and git treats that as *no config at all* — silently, so `user.email`, `insteadOf` and
`core.excludesFile` vanish with no error. Migrate a machine's shim before pulling, not after.

**Diagnostic trap**: `git config --global --list` does not follow includes — it prints only
`include.path`, making the managed settings look absent. Use `git config --list` or
`git config --get <key>`, which resolve normally.

XDG (`~/.config/git/config`) is not an alternative here: git reads it *only* when `~/.gitconfig` is
absent, and if you delete `~/.gitconfig` then `git config --global` writes land in the XDG file
instead — the pollution just moves. `core.excludesFile` likewise overrides `~/.config/git/ignore`
entirely, so that path is dead in this setup.

### Installing

`/install` (skill at `.claude/skills/install/SKILL.md`) walks packages, backs up any existing target
to `<target>.bak.<timestamp>`, and symlinks. `/install nvim tmux` restricts to named packages. It
special-cases `git/gitconfig` (skips it, ensures the shim exists).

**The skill's package list is hardcoded** — adding a new top-level package means updating that list
in `SKILL.md` too.

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
- **git** (`git/gitconfig`): `pull.ff = only`, `core.ignorecase = false`,
  an `insteadOf` rule rewriting `https://github.com/` →
  `ssh://git@github.com/`. Verify with `git config --list --show-origin`, which shows which file
  each value came from — useful for telling managed settings from shim scribbles.
- **`git/.gitignore_global`** carries ML-experiment ignores (`/experiments`, `/runs`,
  `/docs/experiments/status.json`, `/tmp`) plus `.claude/settings.local.json`. These are deliberate:
  they keep experiment artifacts out of every work repo without per-repo `.gitignore` edits.
- **ghostty**: depends on `D2CodingLigature Nerd Font` being installed separately; no skill installs it.

## Theme

Solarized **light** everywhere — nvim (`solarized.nvim` + `lualine` `solarized_light`), tmux
(`seebi/tmux-colors-solarized` with `@colors-solarized 'light'`), ghostty (`iTerm2 Solarized Light`).
Changing theme means changing all three.
