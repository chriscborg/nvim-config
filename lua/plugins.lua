-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({

    -- Lua LSP support + type annotations for Neovim APIs
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                "nvim-dap-ui",
            },
        },
    },

    -- Completion
    {
        "saghen/blink.cmp",
        dependencies = { "saghen/blink.lib" },
        build = function() require("blink.cmp").build():pwait() end,
        opts = {
            sources = {
                default = { "lazydev", "lsp", "path", "snippets", "buffer" },
                providers = {
                    lazydev = {
                        name = "LazyDev",
                        module = "lazydev.integrations.blink",
                        score_offset = 100,
                    },
                },
            },
        },
    },

    -- Treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter").setup({
                ensure_installed = {
                    "lua", "python", "javascript", "typescript",
                    "tsx", "json", "yaml", "markdown", "bash", "swift",
                    "kotlin", "twig", "dart",
                },
            })
        end,
    },

    -- Sticky scope header (shows enclosing function/class at top of buffer)
    {
        "nvim-treesitter/nvim-treesitter-context",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        opts = {
            max_lines = 3,
            min_window_height = 20,
            separator = "─",
        },
    },

    -- Mason: installs LSP servers, linters, formatters
    { "williamboman/mason.nvim",          config = true },
    { "williamboman/mason-lspconfig.nvim" },

    -- LSP breadcrumbs (current scope in statusline)
    {
        "SmiteshP/nvim-navic",
        dependencies = "neovim/nvim-lspconfig",
        opts = { highlight = true, separator = "  " },
    },

    -- LSP
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "SmiteshP/nvim-navic",
        },
        config = function()
            local navic = require("nvim-navic")

            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(ev)
                    local client = vim.lsp.get_client_by_id(ev.data.client_id)
                    local bufnr = ev.buf
                    if client and client.server_capabilities.documentSymbolProvider then
                        navic.attach(client, bufnr)
                    end
                    local map = function(keys, func)
                        vim.keymap.set("n", keys, func, { buffer = bufnr })
                    end
                    map("gd", vim.lsp.buf.definition)
                    map("gD", vim.lsp.buf.declaration)
                    map("gr", vim.lsp.buf.references)
                    map("gi", vim.lsp.buf.implementation)
                    map("K", vim.lsp.buf.hover)
                    map("<leader>rn", vim.lsp.buf.rename)
                    map("<leader>ca", vim.lsp.buf.code_action)
                end,
            })

            vim.lsp.config("lua_ls", {
                settings = {
                    Lua = { diagnostics = { globals = { "vim" } } },
                },
            })

            vim.lsp.config("twiggy_language_server", {
                settings = {
                    twiggy = {
                        framework = "craft",
                        phpExecutable = "/opt/homebrew/bin/php",
                    },
                },
            })

            require("mason-lspconfig").setup({
                ensure_installed = { "lua_ls", "pyright", "ts_ls", "kotlin_language_server", "twiggy_language_server" },
                automatic_installation = true,
                automatic_enable = true,
            })

            -- sourcekit ships with Xcode, not managed by Mason
            vim.lsp.enable("sourcekit")
        end,
    },

    -- Linting
    {
        "mfussenegger/nvim-lint",
        config = function()
            require("lint").linters_by_ft = {
                python     = { "flake8" },
                javascript = { "eslint_d" },
                typescript = { "eslint_d" },
            }
            vim.api.nvim_create_autocmd({ "BufWritePost" }, {
                callback = function() require("lint").try_lint() end,
            })
        end,
    },

    -- Formatting
    {
        "stevearc/conform.nvim",
        config = function()
            require("conform").setup({
                formatters_by_ft = {
                    python     = { "black" },
                    javascript = { "prettier" },
                    typescript = { "prettier" },
                    lua        = { "stylua" },
                },
            })
        end,
    },

    -- Telescope
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        },
        config = function()
            require("telescope").setup()
            require("telescope").load_extension("fzf")
            local tb = require("telescope.builtin")
            vim.keymap.set("n", "<leader>ff", tb.find_files)
            vim.keymap.set("n", "<leader>fg", tb.live_grep)
            vim.keymap.set("n", "<leader>fb", tb.buffers)
            vim.keymap.set("n", "<leader>fh", tb.help_tags)
            vim.keymap.set("n", "<leader>fd", tb.diagnostics)
            vim.keymap.set("n", "<leader>fr", tb.lsp_references)
            vim.keymap.set("n", "<leader>fs", tb.lsp_document_symbols)
            vim.keymap.set("n", "<leader>fc", tb.git_commits)
        end,
    },

    { "tpope/vim-fugitive" },

    -- Per-file diff navigation over a :Git difftool quickfix list
    {
        "jecaro/fugitive-difftool.nvim",
        dependencies = { "tpope/vim-fugitive" },
        config = function()
            -- Always compare with "..." (merge-base), not "..": two-dot
            -- ranges make fugitive's difftool quickfix resolve both diff
            -- sides to the same commit, so every file appears unchanged.
            local difftool = require("fugitive-difftool")
            vim.api.nvim_create_user_command("Gcfir", difftool.git_cfir, {}) -- jump to first
            vim.api.nvim_create_user_command("Gcla", difftool.git_cla, {})   -- jump to last
            vim.api.nvim_create_user_command("Gcn", difftool.git_cn, {})     -- next file
            vim.api.nvim_create_user_command("Gcp", difftool.git_cp, {})     -- previous file
            vim.api.nvim_create_user_command("Gcc", difftool.git_cc, {})     -- reload current

            -- "dv" on a file under the cursor in the difftool quickfix list,
            -- mirroring fugitive's own "dv" in the status buffer. git_cc()
            -- keys off the quickfix list's current idx rather than the
            -- cursor line, so point idx at the cursor first.
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "qf",
                callback = function(ev)
                    vim.keymap.set("n", "dv", function()
                        local ok, items = pcall(function()
                            return vim.fn.getqflist({ context = 0 }).context.items
                        end)
                        if not ok or not items then
                            vim.notify("Not a :Git difftool quickfix list", vim.log.levels.WARN)
                            return
                        end
                        vim.fn.setqflist({}, "a", { idx = vim.fn.line(".") })
                        difftool.git_cc()
                    end, { buffer = ev.buf, desc = "Fugitive difftool: diff file under cursor" })
                end,
            })
        end,
    },

    -- File manager
    {
        "mikavilpas/yazi.nvim",
        version = "*",
        event = "VeryLazy",
        keys = {
            { "<leader>y", "<cmd>Yazi<cr>",     desc = "Open yazi at current file" },
            { "<leader>Y", "<cmd>Yazi cwd<cr>", desc = "Open yazi at cwd" },
        },
        opts = {
            open_for_directories = true,
        },
    },

    -- Colorscheme
    {
        "dasupradyumna/midnight.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd.colorscheme("midnight")
        end,
    },

    -- Status line
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "SmiteshP/nvim-navic" },
        config = function()
            require("lualine").setup({
                options = { theme = "auto" },
                sections = {
                    lualine_c = {
                        { "filename" },
                        { "navic",   color_correction = "dynamic" },
                    },
                },
            })
        end,
    },

    {
        "lewis6991/gitsigns.nvim",
        opts = {
            signs = {
                add          = { text = "▎" },
                change       = { text = "▎" },
                delete       = { text = "" },
                topdelete    = { text = "" },
                changedelete = { text = "▎" },
                untracked    = { text = "▎" },
            },
            on_attach = require("keymaps").gitsigns_on_attach,
        },
    },

    {
        "diegok/live-autoread.nvim",
        config = function(_, opts)
            require("live-autoread").setup(opts)
        end,
    },

    -- DAP core + UI
    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
        config = function()
            require("dapui").setup()
        end,
    },

    {
        "theHamsta/nvim-dap-virtual-text",
        dependencies = { "mfussenegger/nvim-dap", "nvim-treesitter/nvim-treesitter" },
        config = function()
            require("nvim-dap-virtual-text").setup()
        end,
    },

    -- Dependency version viewing
    {
        "lvim-tech/lvim-dependencies",
        dependencies = { "MunifTanjim/nui.nvim", "lvim-tech/lvim-utils" },
        config = function()
            local dep = require("lvim-dependencies")
            dep.setup({})
        end,
    },

    -- Dart/Flutter LSP + debug adapter
    {
        "akinsho/flutter-tools.nvim",
        lazy = false,
        dependencies = { "nvim-lua/plenary.nvim", "mfussenegger/nvim-dap" },
        config = function()
            require("flutter-tools").setup({
                debugger = {
                    enabled = true,
                    run_via_dap = true,
                },
            })

            -- flutter-tools only registers this adapter as a side effect of
            -- :FlutterRun/:FlutterAttach. Register it eagerly too so configs
            -- picked up from .vscode/launch.json (type "dart") work directly
            -- via dap.continue(), without running a flutter-tools command first.
            require("dap").adapters.dart = {
                type = "executable",
                command = vim.fn.exepath("flutter"),
                args = { "debug-adapter" },
            }
        end,
    },

    -- Node.js debug adapter
    {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = { "williamboman/mason.nvim", "mfussenegger/nvim-dap" },
        config = function()
            require("mason-nvim-dap").setup({
                automatic_installation = true,
                ensure_installed = { "js" },
                handlers = { function() end },
            })

            local dap = require("dap")
            local js_debug_path = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter"

            local adapter = {
                type = "server",
                host = "localhost",
                port = "${port}",
                executable = {
                    command = "node",
                    args = { js_debug_path .. "/js-debug/src/dapDebugServer.js", "${port}" },
                },
            }
            dap.adapters["pwa-node"] = adapter
            dap.adapters["node"] = adapter

            for _, language in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
                dap.configurations[language] = {
                    {
                        type = "pwa-node",
                        request = "launch",
                        name = "Launch file",
                        program = "${file}",
                        cwd = "${workspaceFolder}",
                    },
                    {
                        type = "pwa-node",
                        request = "attach",
                        name = "Attach to process",
                        processId = require("dap.utils").pick_process,
                        cwd = "${workspaceFolder}",
                    },
                    {
                        type = "pwa-node",
                        request = "launch",
                        name = "Launch npm script",
                        runtimeExecutable = "npm",
                        runtimeArgs = function()
                            local cwd = vim.fn.getcwd()
                            local ok, data = pcall(vim.fn.readfile, cwd .. "/package.json")
                            if not ok then return { "run", "start" } end
                            local pkg = vim.fn.json_decode(table.concat(data, "\n"))
                            local scripts = pkg and pkg.scripts or {}
                            local names = vim.tbl_keys(scripts)
                            if #names == 0 then return { "run", "start" } end
                            table.sort(names)
                            local chosen = require("dap.ui").pick_one(names, "npm script: ", function(s)
                                return s .. "  →  " .. scripts[s]
                            end)
                            if not chosen then return require("dap").ABORT end
                            return { "run", chosen }
                        end,
                        cwd = "${workspaceFolder}",
                        console = "integratedTerminal",
                    },
                    {
                        type = "pwa-node",
                        request = "launch",
                        name = "Debug Jest test",
                        runtimeExecutable = "npx",
                        runtimeArgs = function()
                            local file = vim.fn.expand("%:p")
                            local args = { "jest", "--runInBand", file }
                            local pattern = vim.fn.input("Test name pattern (blank = whole file): ")
                            if pattern ~= "" then
                                table.insert(args, "-t")
                                table.insert(args, pattern)
                            end
                            return args
                        end,
                        cwd = "${workspaceFolder}",
                        console = "integratedTerminal",
                    },
                    {
                        type = "pwa-node",
                        request = "launch",
                        name = "Debug Jest E2E test",
                        runtimeExecutable = "npx",
                        runtimeArgs = function()
                            local file = vim.fn.expand("%:p")
                            -- testTimeout=0 disables Jest's timeout, since it keeps counting wall-clock
                            -- time while you're paused at a breakpoint and would otherwise fail the test.
                            local args = { "jest", "--runInBand", "--testTimeout=0", file }
                            local pattern = vim.fn.input("Test name pattern (blank = whole file): ")
                            if pattern ~= "" then
                                table.insert(args, "-t")
                                table.insert(args, pattern)
                            end
                            return args
                        end,
                        env = { E2E_INTEGRATION = "true" },
                        cwd = "${workspaceFolder}",
                        console = "integratedTerminal",
                    },
                }
            end
        end,
    },

    -- Markdown rendering (headers, code blocks, lists, etc. in normal buffers)
    {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown" },
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
        opts = {},
    },

    -- Smooth scrolling animation
    {
        "karb94/neoscroll.nvim",
        opts = { easing_function = "quad" },
    },

    --rest plugin
    {
        "rest-nvim/rest.nvim",
        config = function()
            vim.g.rest_nvim = {
                request = {
                    skip_ssl_verification = false,
                },
                env = {
                    enable = true,
                    pattern = "%.env.*",
                },
            }
        end,
    }

}, {
    rocks = {
        enabled = true,
        hererocks = true,
    },
})
