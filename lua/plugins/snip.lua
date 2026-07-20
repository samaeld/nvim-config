return {
    {
        "L3MON4D3/LuaSnip",
        build = "make install_jsregexp",
        config = function()
            require("luasnip.loaders.from_lua").lazy_load({})
            require("luasnip.loaders.from_vscode").lazy_load({
                paths = {
                    require("utils.global").get_plugins_dir() .. "/friendly-snippets",
                },
            })
        end,
        dependencies = { "rafamadriz/friendly-snippets" },
    },
}
