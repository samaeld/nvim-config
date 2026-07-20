return {
    {
        "Bekaboo/dropbar.nvim",
        event = "BufReadPost",
        keys = {
            {
                "<leader>;",
                function()
                    require("dropbar.api").pick()
                end,
                desc = "Pick symbol in winbar",
            },
            {
                "[;",
                function()
                    require("dropbar.api").goto_context_start()
                end,
                desc = "Go to start of current context",
            },
            {
                "];",
                function()
                    require("dropbar.api").select_next_context()
                end,
                desc = "Select next context",
            },
        },
    },
}
