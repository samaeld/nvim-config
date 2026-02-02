return {
    {
        "nvim-flutter/flutter-tools.nvim",
        config = function()
            require("flutter-tools").setup({})
        end,
    },
    {
        "nssteinbrenner/dart",
        branch = "master",
        tag = "v1.0.0",
        dependencies = {
            { "nvim-lua/plenary.nvim" },
        },

        config = function()
            local dart = require("dart").setup()
        end,
    },
}
