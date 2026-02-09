local terminals = {}

local function get_project_terminal()
    local cwd = vim.fn.getcwd()
    if not terminals[cwd] then
        local Terminal = require("toggleterm.terminal").Terminal

        terminals[cwd] = Terminal:new({
            direction = "float",
            close_on_exit = false,
            hidden = true,
            float_opts = {
                border = "curved",
                width = math.floor(vim.o.columns * 0.9),
                height = math.floor(vim.o.lines * 0.9),
            },
            on_open = function(term)
                vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<esc>", [[<C-\><C-n>]], { noremap = true, silent = true })
            end,
        })
    end
    return terminals[cwd]
end

local function open_external_terminal()
    local cwd = vim.fn.getcwd()
    vim.fn.jobstart({ "kitty", "--directory", cwd }, { detach = true })
end

return {
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        config = function()
            require("toggleterm").setup({})

            vim.keymap.set("n", "<leader>tt", function()
                get_project_terminal():toggle()
            end)
            vim.keymap.set("n", "<leader>te", open_external_terminal)
        end,
    },
}
