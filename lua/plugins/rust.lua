return {
    {
        "saecki/crates.nvim",
        ft = "toml",
        tag = "stable",
        opts = {
            lsp = {
                enabled = true,
                actions = true,
                completion = true,
                hover = true,
            },
            completion = {
                crates = { enabled = true },
            },
        },
    },
    {
        "mrcjkb/rustaceanvim",
        version = "*",
        ft = { "rust", "rs" },
        dependencies = "saghen/blink.cmp",
    },
}
