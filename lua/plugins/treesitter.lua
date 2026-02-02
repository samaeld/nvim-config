return {
    {
        "nvim-treesitter/nvim-treesitter",
        dependencies = {
            "nvim-treesitter/nvim-treesitter-context",
            "nvim-treesitter/nvim-treesitter-textobjects",
            "JoosepAlviste/nvim-ts-context-commentstring",
        },
        build = ":TSUpdate",
        branch = "main",
        lazy = false,
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            local ts = require("nvim-treesitter")

            local parsers = {
                "python",
                "lua",
                "c",
                "cpp",
                "vim",
                "json",
                "toml",
                "yaml",
                "rust",
                "bitbake",
                "cmake",
                "bash",
                "kotlin",
                "go",
                "svelte",
                "css",
                "html",
                "typescript",
                "javascript",
                "dart",
            }

            for _, parser in ipairs(parsers) do
                pcall(ts.install, parser)
            end

            vim.api.nvim_create_autocmd("FileType", {
                callback = function()
                    pcall(vim.treesitter.start)
                end,
            })
        end,
        cmd = {
            "TSInstall",
            "TSUninstall",
            "TSUpdate",
            "TSUpdateSync",
            "TSInstallInfo",
            "TSInstallSync",
            "TSInstallFromGrammar",
        },
    },
}
