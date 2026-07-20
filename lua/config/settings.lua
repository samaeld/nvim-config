vim.g.mapleader = " "
vim.g.formatting_enabled = true

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true
vim.opt.wrap = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8

vim.opt.clipboard = "unnamedplus"

vim.opt.showmode = false

vim.opt.breakindent = true
vim.opt.undofile = true

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true

vim.opt.signcolumn = "yes"

vim.opt.inccommand = "split"

vim.opt.foldmethod = "expr" -- default is "normal"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
-- if this option is true and fold method option is other than normal, every time a document is opened everything will be folded.
vim.opt.foldenable = false
vim.opt.foldcolumn = "0"
vim.opt.foldtext = ""
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 1

vim.opt.cursorline = true

vim.opt.mousemoveevent = true

vim.opt.listchars = "eol:↵,trail:~,tab:>-,nbsp:␣"
vim.opt.fillchars = "eob: "

vim.opt.laststatus = 3

local default_diagnostic_config = {
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.HINT] = "󰌶",
            [vim.diagnostic.severity.INFO] = "",
        },
    },
    virtual_text = true,
    update_in_insert = false,
    underline = true,
    severity_sort = true,
    float = {
        focusable = true,
        style = "minimal",
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
    },
}

vim.diagnostic.config(default_diagnostic_config)

vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

vim.opt.cmdheight = 0

require("vim._core.ui2").enable({
    msg = {
        cmd = { height = 0.4 },
        dialog = { height = 0.4 },
        msg = { height = 0.35, timeout = 3000 },
        targets = {
            list_cmd = "pager",
            shell_cmd = "msg",
            shell_out = "msg",
            shell_err = "msg",
            shell_ret = "msg",
            verbose = "msg",
            progress = "msg",
            lua_print = "msg",
        },
    },
})
