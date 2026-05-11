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
        build = function() require("blink.cmp").build():wait(60000) end,
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

    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")
            cmp.setup({
                snippet = {
                    expand = function(args) luasnip.lsp_expand(args.body) end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"]     = cmp.mapping.abort(),
                    ["<CR>"]      = cmp.mapping.confirm({ select = true }),
                    ["<Tab>"]     = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"]   = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "buffer" },
                    { name = "path" },
                }),
            })
        end,
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
                },
            })
        end,
    },

    -- Mason: installs LSP servers, linters, formatters
    { "williamboman/mason.nvim",          config = true },
    { "williamboman/mason-lspconfig.nvim" },

    -- LSP
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        },
        config = function()
            local lspconfig = require("lspconfig")

            local on_attach = function(_, bufnr)
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
            end

            require("mason-lspconfig").setup({
                ensure_installed = { "lua_ls", "pyright", "ts_ls" },
                automatic_installation = true,
                handlers = {
                    function(server)
                        lspconfig[server].setup({ on_attach = on_attach })
                    end,
                    ["lua_ls"] = function()
                        lspconfig.lua_ls.setup({
                            on_attach = on_attach,
                            settings = {
                                Lua = { diagnostics = { globals = { "vim" } } },
                            },
                        })
                    end,
                },
            })
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
                format_on_save = { timeout_ms = 500, lsp_fallback = true },
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
        config = function()
            require("lualine").setup({ options = { theme = "auto" } })
        end,
    },

    { "lewis6991/gitsigns.nvim", config = true },

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

    -- Node.js debug adapter
    {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = { "williamboman/mason.nvim", "mfussenegger/nvim-dap" },
        config = function()
            require("mason-nvim-dap").setup({
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
                            local chosen = coroutine.yield({
                                type = "select",
                                title = "npm script",
                                items = names,
                                format_item = function(s) return s .. "  →  " .. scripts[s] end,
                            })
                            return { "run", chosen }
                        end,
                        cwd = "${workspaceFolder}",
                        console = "integratedTerminal",
                    },
                }
            end
        end,
    },

})
