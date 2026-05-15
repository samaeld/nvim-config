return {
    {
        "rmagatti/auto-session",
        lazy = false,
        opts = {
            suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
        },
    },
    {
        "natecraddock/workspaces.nvim",
        dependencies = { "rmagatti/auto-session" },
        config = function()
            require("workspaces").setup({
                hooks = {
                    open_pre = {
                        function()
                            require("auto-session").save_session()
                        end,
                    },
                    open = {
                        function()
                            require("auto-session").restore_session()
                        end,
                    },
                },
            })
        end,
    },
}
