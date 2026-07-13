# AGENTS.md

Personal dotfiles, deployed with GNU Stow on Arch Linux (niri + noctalia).

## Repo structure

Each top-level directory is a GNU Stow package. Files mirror `$HOME` exactly.

| Package | Stows to |
|---|---|
| `bin/` | `$HOME/.local/bin` |
| `colors/` | `$HOME/.local/colors` |
| `config/` | `$HOME/.config` |
| `desktop/` | `$HOME/.local/share/applications` |
| `firefox-css/` | `$HOME/.mozilla/firefox/*.default-release/` (per profile) |

The `restow` script deploys everything via `stow --restow --no-folding`. It also stows from `$HOME/Docs/.local` (an external directory not in this repo).

`Docs/.local` is synced across devices with syncthing.

## Making changes

1. Edit files in place. The stow packages mirror `$HOME`, so `config/nvim/init.lua` is `~/.config/nvim/init.lua`.
2. Run `./restow` from the repo root to deploy.
3. Verify manually. There are no automated tests.

### Commits

Follow existing convention: `subsystem: description`. Examples from history:

```
nvim: replace pyright with basedpyright
zsh: fix auto venv updates
foot: reduce padding
systemd: add timer to shutdown on critical temp
```

## Key systems

### Theme system

Colors live in `colors/` with one subdirectory per target format (ini, nvim, OSC, zathura). Each subdirectory has gruvbox variant files. At runtime, `bin/theme-switch` creates symlinks named `default.*` pointing to the active variant. Apps reference these symlinks:

- `foot/foot.ini` includes `~/.local/colors/ini/default.ini`
- Neovim `init.lua` calls `dofile("~/.local/colors/nvim/default.lua")`
- Zsh `.zshrc` sends OSC sequences from `$COLORS/OSC/default.ini`

The `default.*` symlinks are not tracked in git. Breaking them breaks theming.

### Zsh environment

Load chain: `/etc/zshenv` sets `ZDOTDIR` to `$HOME/.config/zsh`, then:
1. `.zshenv` sources `env/*.sh` (skips `wayland.sh` when `$WAYLAND_DISPLAY` is unset)
2. `.zshrc` sources plugins, theme, bindkeys, and starts starship

Plugins are auto-cloned via `get_plug()` into `$ZDOTDIR/plugins/` on first run. Zsh determines where many other tools look (XDG dirs, PATH, editor vars set in `env/opts.sh`).

### Neovim

Lazy.nvim with modular plugin specs under `lua/lazy/base/`, `lua/lazy/lsp/`, and `lua/lazy/dev/`. Four local dev plugins live in `dev/` (recharge.nvim, timesaver.nvim, websearch.nvim, workout.nvim). The `nvimwrapper` bin script enables tmux-wide single nvim instance via `--remote-silent`.

### Firefox

`firefox-css/` mirrors the Firefox profile root: `user.js` + `chrome/userChrome.css`. The `restow` script loops over `*.default-release` profiles only. Other profile types (nightly, dev-edition) are not covered.

## Gotchas

- **`bat/config` is mutated at runtime**. `theme-switch` uses `sed --follow-symlinks` to toggle `--theme=`. If this file is committed, it will show dirty git state after theme changes.
- **Niri config has 6 monitor outputs by hardware ID**. `config/niri/config.kdl` is not portable across machines.
- **No `.gitignore` at root**. `config/autostart/` and `.opencode/` currently show as untracked.
- **`restow` is not a bootstrap script**. It assumes `stow` is installed and `$HOME/Docs/.local` exists. There is no install script for system dependencies.
- **No CI, no tests, no linting**. All verification is manual. The `neotest` config in nvim is for testing other projects, not the dotfiles.
- **No license, no top-level README**. The only README is `config/zsh/README.md`.
- **Arch-specific**. systemd user services, yay, niri, wireplumber, and pacman aliases assume Arch Linux.
