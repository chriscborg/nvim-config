# nvim-config

Personal Neovim configuration, managed with [lazy.nvim](https://github.com/folke/lazy.nvim). Leader key is `<space>`.

## Install

```sh
git clone git@github.com:chriscborg/nvim-config.git ~/.config/nvim
nvim
```

`lua/plugins.lua` bootstraps `lazy.nvim` automatically on first launch and installs everything from `lazy-lock.json`.

## Requirements

- Neovim 0.10+
- `git`
- A [Nerd Font](https://www.nerdfonts.com/) for icons
- `ripgrep` and `fd` (Telescope), `make` (builds `telescope-fzf-native`)
- `node` (TS/JS LSP, `eslint_d`, `prettier`, JS debug adapter)
- `python3` (`pyright`, `flake8`, `black`)
- `stylua` (Lua formatting), `jq` (JSON formatting)
- `flutter`/Dart SDK, if working on Flutter/Dart projects (DAP adapter + `:AndroidSync`)
- Xcode command line tools, if working on Swift (`sourcekit-lsp`)
- `php`, if working on Craft/Twig templates (`twiggy_language_server`); the PHP binary path in `lua/plugins.lua` assumes a Homebrew install

Everything else (LSP servers, linters, formatters, DAP adapters) is installed on demand via `mason.nvim`.

## Layout

- `init.lua` — entry point, sets leader keys and loads the modules below
- `lua/options.lua` — editor options
- `lua/keymaps.lua` — keymaps and the `gitsigns` `on_attach` helper
- `lua/plugins.lua` — `lazy.nvim` plugin specs and config
- `lazy-lock.json` — pinned plugin commits

## Highlights

- **LSP**: `nvim-lspconfig` + `mason-lspconfig` (`lua_ls`, `pyright`, `ts_ls`, `kotlin_language_server`, `twiggy_language_server`, `sourcekit`), breadcrumbs via `nvim-navic`
- **Completion**: `blink.cmp`
- **Linting/formatting**: `nvim-lint`, `conform.nvim`
- **Debugging**: `nvim-dap` + `nvim-dap-ui`, with adapters for Dart/Flutter and Node.js
- **Fuzzy finding**: `telescope.nvim` (`<leader>ff/fg/fb/fh/fd/fr/fs/fc`)
- **Git**: `vim-fugitive`, `gitsigns.nvim` (`<leader>h*` hunk operations, `<leader>gs` stage-and-close)
- **File explorer**: `yazi.nvim` (`<leader>y`, `<leader>Y`)
- **HTTP client**: `rest.nvim` (`<leader>rr/rl/re`)
- **Colorscheme**: `midnight.nvim`

## Keymaps

Leader is `<space>`. Everything below is a real mapping in this config — grouped by the plugin or feature that backs it, so it doubles as a tour of what the setup can do.

### Editing & navigation

Nothing fancy — just friction removed from stock Vim.

| Keys | Mode | Action |
| --- | --- | --- |
| `jk` | Insert | Escape to normal mode |
| `Y` | Normal | Yank to end of line (matches `C`/`D`) |
| `<leader><space>` | Normal | Clear search highlight |
| `<leader>w` | Normal | Save file |
| `<C-h/j/k/l>` | Normal | Move between splits |
| `[b` / `]b` | Normal | Previous / next buffer |
| `<leader>bd` | Normal | Delete buffer |
| `<leader>cl` | Visual | Copy `path/to/file:line` (or `:start-end` for a range) to the system clipboard — for pasting a precise code reference into a PR, issue, or chat |

### Diagnostics

Wired to the built-in diagnostic API directly, so these work in any buffer regardless of which LSP client is attached.

| Keys | Mode | Action |
| --- | --- | --- |
| `<leader>df` | Normal | Open diagnostic under cursor in a float |
| `[d` / `]d` | Normal | Previous / next diagnostic |

### Terminal

| Keys | Mode | Action |
| --- | --- | --- |
| `<leader>th` | Normal | Open horizontal terminal split |
| `<leader>tv` | Normal | Open vertical terminal split |
| `<Esc><Esc>` | Terminal | Exit terminal insert mode |

### LSP — `nvim-lspconfig` + `mason-lspconfig`

Buffer-local, attached only once a language server is actually running (`LspAttach`), with breadcrumbs from `nvim-navic` in the statusline. One set of mappings works across every configured server: `lua_ls`, `pyright`, `ts_ls`, `kotlin_language_server`, `twiggy_language_server`, `sourcekit`.

| Keys | Mode | Action |
| --- | --- | --- |
| `gd` | Normal | Go to definition |
| `gD` | Normal | Go to declaration |
| `gr` | Normal | List references |
| `gi` | Normal | Go to implementation |
| `K` | Normal | Hover docs |
| `<leader>rn` | Normal | Rename symbol |
| `<leader>ca` | Normal | Code action |

### Fuzzy finding — `telescope.nvim`

Backed by `telescope-fzf-native` for native-speed sorting; several pickers pull straight from LSP or Git rather than the filesystem.

| Keys | Action |
| --- | --- |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | List open buffers |
| `<leader>fh` | Search help tags |
| `<leader>fd` | List diagnostics |
| `<leader>fr` | LSP references (picker instead of quickfix) |
| `<leader>fs` | LSP document symbols |
| `<leader>fc` | Browse git commits |

### Git — `vim-fugitive`

Full Git porcelain inside Vim — commit, blame, diff, and log without leaving the editor.

| Keys | Mode | Action |
| --- | --- | --- |
| `<leader>gs` | Normal | Stage the current file (resolving through Fugitive's real path) and close the tab — built for closing out a `:Gdiffsplit` review in one keystroke |
| `<leader>gl` | Normal | Show full commit history for the line under the cursor (`git log -L`), loaded into the quickfix list so you can step through every change ever made to that exact line |

### Git — `gitsigns.nvim`

Live diff signs in the gutter plus buffer-local hunk operations — the fast, incremental counterpart to Fugitive's full commands.

| Keys | Mode | Action |
| --- | --- | --- |
| `]c` / `[c` | Normal | Next / previous hunk |
| `<leader>hs` | Normal, Visual | Stage hunk |
| `<leader>hr` | Normal, Visual | Reset hunk |
| `<leader>hS` | Normal | Stage entire buffer |
| `<leader>hu` | Normal | Undo last stage |
| `<leader>hR` | Normal | Reset entire buffer |
| `<leader>hp` | Normal | Preview hunk diff |
| `<leader>hb` | Normal | Blame current line (who/when for just that line) |
| `<leader>hd` | Normal | Diff buffer against index |
| `ih` | Operator/Visual | Text object: select current hunk (e.g. `dih`) |

### File explorer — `yazi.nvim`

| Keys | Action |
| --- | --- |
| `<leader>y` | Open Yazi at the current file |
| `<leader>Y` | Open Yazi at the working directory |

### HTTP client — `rest.nvim`

Run HTTP requests from `.http`/`.rest` files without leaving Neovim, with `.env` support for variables.

| Keys | Action |
| --- | --- |
| `<leader>rr` | Run request under cursor |
| `<leader>rl` | Re-run last request |
| `<leader>re` | Select environment |

### Debugging — `nvim-dap` + `nvim-dap-ui`

One mapping set drives both the Node.js and Dart/Flutter adapters. Includes a "focus stopped session" jump that walks the DAP session tree to find whichever thread actually hit a breakpoint — useful once more than one debug session is running at a time.

| Keys | Mode | Action |
| --- | --- | --- |
| `<leader>Db` | Normal | Toggle breakpoint |
| `<leader>DB` | Normal | Set conditional breakpoint (prompts for condition) |
| `<leader>Dc` | Normal | Continue |
| `<leader>Ds` | Normal | Step over |
| `<leader>Di` | Normal | Step into |
| `<leader>Do` | Normal | Step out |
| `<leader>Dr` | Normal | Restart |
| `<leader>Dq` | Normal | Terminate all sessions |
| `<leader>Df` | Normal | Focus whichever session is actually stopped |
| `<leader>Dl` | Normal | Re-run last configuration |
| `<leader>Du` | Normal | Toggle DAP UI |
| `<leader>De` | Normal, Visual | Evaluate expression / selection |

### Android / Flutter

| Keys | Action |
| --- | --- |
| `<leader>as` | Run `./gradlew assembleDebug` from the nearest parent project (found by walking up for `gradlew`), then restart the LSP so `kotlin_language_server` picks up freshly generated `R.jar`/`BuildConfig` classpath entries. Also available as `:AndroidSync`. |

Source of truth is `lua/keymaps.lua` — if it drifts from this table, trust the code.
