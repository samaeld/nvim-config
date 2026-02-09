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
    {
        "greggh/claude-code.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        config = function()
            require("claude-code").setup()
        end,
    },
}
