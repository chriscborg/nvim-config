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

See `lua/keymaps.lua` for the full keymap list.
