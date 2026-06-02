local map = vim.keymap.set

-- Escape
map("i", "jk", "<Esc>")

-- Consistency
map("n", "Y", "y$")

-- Search
map("n", "<leader><space>", ":nohlsearch<CR>")

-- Save
map("n", "<leader>w", ":w<CR>")

-- Split navigation
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- Buffer navigation
map("n", "[b", ":bprevious<CR>")
map("n", "]b", ":bnext<CR>")
map("n", "<leader>bd", ":bdelete<CR>")

-- Diagnostics (global, works without LSP)
map("n", "<leader>df", vim.diagnostic.open_float)
map("n", "[d", vim.diagnostic.goto_prev)
map("n", "]d", vim.diagnostic.goto_next)

-- Terminal
map("n", "<leader>th", function()
    vim.cmd("split | term")
    vim.cmd("startinsert")
end)
map("n", "<leader>tv", function()
    vim.cmd("vsplit | term")
    vim.cmd("startinsert")
end)
map("t", "<Esc><Esc>", "<C-\\><C-n>")

-- DAP (debugger)
map("n", "<leader>Db", function() require("dap").toggle_breakpoint() end, { desc = "DAP: Toggle breakpoint" })
map("n", "<leader>DB", function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end,
    { desc = "DAP: Conditional breakpoint" })
map("n", "<leader>Dc", function() require("dap").continue() end, { desc = "DAP: Continue" })
map("n", "<leader>Ds", function() require("dap").step_over() end, { desc = "DAP: Step over" })
map("n", "<leader>Di", function() require("dap").step_into() end, { desc = "DAP: Step into" })
map("n", "<leader>Do", function() require("dap").step_out() end, { desc = "DAP: Step out" })
map("n", "<leader>Dr", function() require("dap").restart() end, { desc = "DAP: Restart" })
map("n", "<leader>Dq", function() require("dap").terminate() end, { desc = "DAP: Terminate" })
map("n", "<leader>Dl", function() require("dap").run_last() end, { desc = "DAP: Run last" })
map("n", "<leader>Du", function() require("dapui").toggle() end, { desc = "DAP: Toggle UI" })
map("n", "<leader>De", function() require("dapui").eval() end, { desc = "DAP: Eval expression" })
map("v", "<leader>De", function() require("dapui").eval() end, { desc = "DAP: Eval selection" })

-- Git vim-fugitive

-- gs to close tab and stage it
map("n", "<leader>gs", function()
    local file_path = vim.fn.FugitiveReal()

    -- Stage the file safely using its real path
    vim.cmd("Git add " .. vim.fn.fnameescape(file_path))

    -- Close the current difftool tab
    vim.cmd("tabclose")
end, { desc = "Fugitive: Stage file and close tab" })

-- Rest
vim.keymap.set("n", "<leader>rr", "<cmd>Rest run<cr>")
vim.keymap.set("n", "<leader>rl", "<cmd>Rest run last<cr>")
vim.keymap.set("n", "<leader>re", "<cmd>Rest env select<cr>")

-- Gitsigns (buffer-local, called from on_attach)
local M = {}

M.gitsigns_on_attach = function(bufnr)
    local gs = package.loaded.gitsigns
    local bmap = function(mode, keys, func, desc)
        vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = desc })
    end

    bmap("n", "]c", function()
        if vim.wo.diff then return "]c" end
        vim.schedule(function() gs.next_hunk() end)
        return "<Ignore>"
    end, "Gitsigns: Next hunk")

    bmap("n", "[c", function()
        if vim.wo.diff then return "[c" end
        vim.schedule(function() gs.prev_hunk() end)
        return "<Ignore>"
    end, "Gitsigns: Prev hunk")

    bmap({ "n", "v" }, "<leader>hs", gs.stage_hunk,       "Gitsigns: Stage hunk")
    bmap({ "n", "v" }, "<leader>hr", gs.reset_hunk,       "Gitsigns: Reset hunk")
    bmap("n",          "<leader>hS", gs.stage_buffer,     "Gitsigns: Stage buffer")
    bmap("n",          "<leader>hu", gs.undo_stage_hunk,  "Gitsigns: Undo stage hunk")
    bmap("n",          "<leader>hR", gs.reset_buffer,     "Gitsigns: Reset buffer")
    bmap("n",          "<leader>hp", gs.preview_hunk,     "Gitsigns: Preview hunk")
    bmap("n",          "<leader>hb", gs.blame_line,       "Gitsigns: Blame line")
    bmap("n",          "<leader>hd", gs.diffthis,         "Gitsigns: Diff this")
    bmap({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Gitsigns: Select hunk")
end

return M
