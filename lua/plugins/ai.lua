return {
    {
        "Exafunction/windsurf.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "hrsh7th/nvim-cmp",
        },
        config = function()
            require("codeium").setup({
                enable_cmp_source = true,
                enable_chat = true,
                virtual_text = {
                    enabled = true,
                    key_bindings = {
                        accept = false, -- handled by nvim-cmp / blink.cmp
                        next = "<M-]>",
                        prev = "<M-[>",
                    },
                },
            })
        end,
    },
    -- {
    --     "github/copilot.vim"
    -- }
    {
        "NickvanDyke/opencode.nvim",
        dependencies = {
            { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
        },
        config = function()
            vim.g.opencode_opts = {}
            vim.o.autoread = true

            vim.keymap.set({ "n", "x" }, "<C-a>", function()
                require("opencode").ask("@this: ", { submit = true })
            end, { desc = "Ask opencode" })
            vim.keymap.set({ "n", "x" }, "<C-x>", function()
                require("opencode").select()
            end, { desc = "Execute opencode action…" })
            vim.keymap.set({ "n", "x" }, "ga", function()
                require("opencode").prompt("@this")
            end, { desc = "Add to opencode" })
            vim.keymap.set({ "n", "t" }, "<C-.>", function()
                require("opencode").toggle()
            end, { desc = "Toggle opencode" })
            vim.keymap.set("n", "<S-C-u>", function()
                require("opencode").command("session.half.page.up")
            end, { desc = "opencode half page up" })
            vim.keymap.set("n", "<S-C-d>", function()
                require("opencode").command("session.half.page.down")
            end, { desc = "opencode half page down" })
        end,
    },
}
