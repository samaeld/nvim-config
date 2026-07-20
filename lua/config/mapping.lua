local keymap = vim.keymap

keymap.set("n", "<C-s>", "<cmd>w<cr>", { silent = true, desc = "Save file" })
keymap.set("v", "J", ":m '>+1<CR>gv=gv", { silent = true })
keymap.set("v", "K", ":m '<-2<CR>gv=gv", { silent = true })
keymap.set("n", "J", ":m .+1<CR>==", { silent = true })
keymap.set("n", "K", ":m .-2<CR>==", { silent = true })
keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
-- remap neovim increment/decrement to Alt+, as as Ctrl+A - is used by tmux
keymap.set("n", "<A-a>", "<C-a>", { noremap = true, silent = true })
keymap.set("n", "<A-x>", "<C-x>", { noremap = true, silent = true })

-- diagnostics
keymap.set("n", "<leader>qo", "<cmd>lopen<CR>", { silent = true, desc = "[L]ocation list [O]pen" })
keymap.set("n", "<leader>qc", "<cmd>lclose<CR>", { silent = true, desc = "[L]ocation list [C]lose" })
keymap.set("n", "<leader>qx", "<cmd>lexpr []<CR>", { silent = true, desc = "[L]ocation list [X]clear" })
keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })

keymap.set({ "n", "i", "v" }, "<CapsLock>", "<Esc>")

keymap.set("n", "<leader>yp", function()
    local path = vim.fn.expand("%:.")
    vim.fn.setreg("+", path)
    vim.notify("Copied relative path: " .. path)
end, { desc = "Copy relative file path" })

keymap.set("n", "<leader>yP", function()
    local path = vim.fn.expand("%:p")
    vim.fn.setreg("+", path)
    vim.notify("Copied absolute path: " .. path)
end, { desc = "Copy absolute file path" })
