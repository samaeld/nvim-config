return {
    {
        "xzbdmw/colorful-menu.nvim",
        config = function()
            require("colorful-menu").setup({})
        end,
    },
    {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
            library = {
                -- See the configuration section for more details
                -- Load luvit types when the `vim.uv` word is found
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },
    {
        "saghen/blink.compat",
        version = "2.*",
        lazy = true,
        opts = {},
    },
    {
        "saghen/blink.cmp",
        version = "1.*",
        dependencies = {
            "rafamadriz/friendly-snippets",
            "saghen/blink.compat",
            "Exafunction/windsurf.nvim",
            "yus-works/csc.nvim",
        },
        event = { "InsertEnter", "CmdlineEnter" },
        opts = {
            keymap = {
                preset = "enter",
                ["<C-y>"] = { "select_and_accept" },
            },
            appearance = {
                nerd_font_variant = "mono",
                use_nvim_cmp_as_default = true,
            },
            completion = {
                trigger = {
                    prefetch_on_insert = true,
                    show_on_backspace = true,
                    show_on_backspace_in_keyword = true,
                },
                list = {
                    selection = {
                        auto_insert = true,
                        preselect = true,
                    },
                },
                accept = {
                    auto_brackets = {
                        enabled = true,
                    },
                },
                menu = {
                    border = "rounded",
                    draw = {
                        columns = { { "kind_icon" }, { "label", gap = 1 } },
                        components = {
                            label = {
                                text = function(ctx)
                                    return require("colorful-menu").blink_components_text(ctx)
                                end,
                                highlight = function(ctx)
                                    return require("colorful-menu").blink_components_highlight(ctx)
                                end,
                            },
                        },
                    },
                },
                documentation = {
                    auto_show = true,
                    auto_show_delay_ms = 100,
                },
                ghost_text = {
                    enabled = false,
                },
            },
            sources = {
                default = { "lazydev", "lsp", "path", "snippets", "buffer", "codeium" },
                providers = {
                    lsp = {
                        timeout_ms = 200,
                    },
                    buffer = {
                        min_keyword_length = 3,
                    },
                    codeium = {
                        name = "codeium",
                        module = "blink.compat.source",
                        score_offset = 100,
                        async = true,
                    },
                    lazydev = {
                        name = "LazyDev",
                        module = "lazydev.integrations.blink",
                        score_offset = 100,
                    },
                },
            },
            fuzzy = { implementation = "prefer_rust_with_warning" },
            signature = {
                enabled = true,
            },
        },
        config = function(_, opts)
            local disabled_fts = { "oil" }

            local function ft_allowed()
                return not vim.tbl_contains(disabled_fts, vim.bo.filetype)
            end

            for _, source in ipairs(opts.sources.compat or {}) do
                opts.sources.providers[source] = vim.tbl_deep_extend("force", {
                    name = source,
                    module = "blink.compat.source",
                    enabled = function()
                        return ft_allowed()
                    end,
                }, opts.sources.providers[source] or {})

                if type(opts.sources.default) == "table" and not vim.tbl_contains(opts.sources.default, source) then
                    table.insert(opts.sources.default, source)
                end
            end

            -- add ai_accept to <Tab> key
            if not opts.keymap["<Tab>"] then
                opts.keymap["<Tab>"] = {
                    function(fallback)
                        if vim.snippet.active({ direction = 1 }) then
                            vim.schedule(function()
                                vim.snippet.jump(1)
                            end)
                        elseif require("codeium.virtual_text").get_current_completion_item() then
                            if vim.api.nvim_get_mode().mode == "i" then
                                vim.notify("codeium active c")
                                local undo = vim.api.nvim_replace_termcodes("<c-G>u", true, true, true)
                                vim.api.nvim_feedkeys(undo, "n", false)
                            end
                            vim.api.nvim_input(require("codeium.virtual_text").accept())
                        elseif type(fallback) == "function" then
                            fallback()
                        else
                            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, true, true), "n", true)
                            -- return "fallback"
                        end
                    end,
                }
            end

            require("blink.cmp").setup(opts)
        end,
    },
    {
        "saghen/blink.nvim",
        lazy = false,
        opts = {
            chartoggle = { enabled = true },
            select = {
                enabled = true,
                mapping = {
                    selection = { "m", "n", "e", "i", "a", "r", "s", "t" },
                },
            },
            tree = { enabled = true },
        },
    },
}
