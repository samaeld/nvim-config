local function capabilities()
    local caps = vim.lsp.protocol.make_client_capabilities()
    caps = vim.tbl_deep_extend("force", caps, require("blink.cmp").get_lsp_capabilities(caps))
    return caps
end

local function qmlls_binary()
    local venv = vim.fn.getcwd() .. "/.venv"
    local lib = venv .. "/lib"
    local python = vim.fn.glob(lib .. "/python*")
    local site_packages = python .. "/site-packages"
    local pyside_qmlls = site_packages .. "/PySide6/qmlls"
    if vim.fn.executable(pyside_qmlls) == 1 then
        vim.notify("qmlls found in " .. pyside_qmlls)
        return { pyside_qmlls }
    end
    return { "qmlls" }
end

local function map_client_name(client_name)
    if client_name == "rust-analyzer" then
        return "rust_analyzer"
    end
    return client_name
end

return {
    {
        "p00f/clangd_extensions.nvim",
        lazy = true,
        config = function() end,
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            { "mason-org/mason.nvim", opts = {} },
            "mason-org/mason-lspconfig.nvim",
            "Saghen/blink.cmp",
            "benomahony/uv.nvim",
            "folke/snacks.nvim",
        },
        opts = {
            servers = {
                ["*"] = {
                    capabilities = capabilities(),
                    -- stylua: ignore
                    keys = {
                        { "<leader>cl", function() Snacks.picker.lsp_config() end, desc = "Lsp Info" },
                        { "gd", vim.lsp.buf.definition, desc = "Goto Definition" },
                        { "gr", vim.lsp.buf.references, desc = "References", nowait = true },
                        { "gI", vim.lsp.buf.implementation, desc = "Goto Implementation" },
                        { "gy", vim.lsp.buf.type_definition, desc = "Goto T[y]pe Definition" },
                        { "gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
                        { "H", function() return vim.lsp.buf.hover() end, desc = "Hover" },
                        { "gK", function() return vim.lsp.buf.signature_help() end, desc = "Signature Help" },
                        { "<c-k>", function() return vim.lsp.buf.signature_help() end, mode = "i", desc = "Signature Help" },
                        { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "x" } },
                        { "<leader>cc", vim.lsp.codelens.run, desc = "Run Codelens", mode = { "n", "x" } },
                        { "<leader>cC", vim.lsp.codelens.refresh, desc = "Refresh & Display Codelens", mode = { "n" } },
                        { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File", mode ={"n"} },
                        { "<leader>cr", vim.lsp.buf.rename, desc = "Rename" },
                        { "<leader>cA", vim.lsp.buf.code_action, desc = "Source Action" },
                        { "]]", function() Snacks.words.jump(vim.v.count1) end,
                        desc = "Next Reference", enabled = function() return Snacks.words.is_enabled() end },
                        { "[[", function() Snacks.words.jump(-vim.v.count1) end,
                        desc = "Prev Reference", enabled = function() return Snacks.words.is_enabled() end },
                        { "<a-n>", function() Snacks.words.jump(vim.v.count1, true) end,
                        desc = "Next Reference", enabled = function() return Snacks.words.is_enabled() end },
                        { "<a-p>", function() Snacks.words.jump(-vim.v.count1, true) end, 
                        desc = "Prev Reference", enabled = function() return Snacks.words.is_enabled() end },
                    },
                },
                clangd = {
                    filetypes = { "h", "hpp", "inc", "cpp", "c", "cc", "cppm" },
                    root_markers = {
                        "compile_commands.json",
                        "compile_flags.txt",
                        "configure.ac", -- AutoTools
                        "Makefile",
                        "configure.ac",
                        "configure.in",
                        "config.h.in",
                        "meson.build",
                        "meson_options.txt",
                        "build.ninja",
                        ".git",
                    },
                    capabilities = {
                        offsetEncoding = { "utf-16" },
                    },
                    cmd = {
                        "clangd",
                        "--clang-tidy",
                        "--background-index",
                        "--completion-style=detailed",
                        "--header-insertion=iwyu",
                        "--enable-config",
                        "--pch-storage=memory",
                        "--cross-file-rename=true",
                        "--suggest-missing-includes",
                        "--function-arg-placeholders",
                        "--fallback-style=llvm",
                    },
                    init_options = {
                        usePlaceholders = true,
                        completeUnimported = true,
                        clangdFileStatus = true,
                    },
                    on_attach = function(client, bufnr) end,
                    keys = {
                        {
                            "<leader>hs",
                            "<cmd>ClangdSwitchSourceHeader<cr>",
                            desc = "[H]eader/[S]ource switch",
                        },
                    },
                    setup = function(_, opts)
                        require("clangd_extensions").setup(vim.tbl_deep_extend("force", {}, {
                            server = opts,
                        }))
                    end,
                },
                pyright = {
                    settings = {
                        pyright = {
                            disableOrganizeImports = true,
                        },
                        python = {
                            analysis = {
                                typeCheckingMode = "off",
                                diagnosticMode = "openFilesOnly",
                                autoSearchPaths = true,
                                useLibraryCodeForTypes = true,
                            },
                        },
                    },
                },
                ruff = {
                    cmd_env = { RUFF_TRACE = "messages" },
                    init_options = {
                        settings = {
                            logLevel = "error",
                        },
                    },
                    on_attach = function(client, bufnr)
                        Snacks.util.lsp.on({ name = "ruff" }, function(_, client)
                            client.server_capabilities.hoverProvider = false
                        end)
                    end,
                },
                rust_analyzer = {
                    -- stylua: ignore
                    keys = {
                        { "<leader>r", function() vim.cmd.RustLsp("run") end, desc = "Run" },
                        { "<leader>me", function() vim.cmd.RustLsp("expandMacro") end, desc = "Expand Macro" },
                    },
                    settings = {
                        ["rust-analyzer"] = {
                            cargo = {
                                features = "all",
                            },
                            single_file_support = false,
                        },
                    },
                    on_attach = function(client, bufnr)
                        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                    end,
                },
                gopls = {
                    settings = {
                        gopls = {
                            analyses = {
                                unusedparams = true,
                            },
                            staticcheck = true,
                            gofumpt = true,
                        },
                    },
                },
                neocmake = {
                    settings = {
                        cmake = {
                            lint = {
                                style = {
                                    indentation = 4,
                                },
                            },
                        },
                    },
                },
                lua_ls = {
                    settings = {
                        Lua = {
                            workspace = {
                                checkThirdParty = false,
                                library = vim.api.nvim_get_runtime_file("", true),
                                ignoreDir = {
                                    ".git",
                                    "node_modules",
                                    ".venv",
                                    ".cache",
                                    "lazy-lock.json",
                                },
                            },
                            codeLens = {
                                enable = true,
                            },
                            completion = {
                                callSnippet = "Replace",
                            },
                            diagnostics = {
                                globals = { "vim", "Snacks" },
                                disable = { "missing-fields" },
                            },
                        },
                    },
                },
                stylua = {},
                qmlls = {
                    cmd = qmlls_binary(),
                    filetypes = { "qml", "qmljs" },
                    root_markers = { ".git", ".qmlls.ini" },
                },
                bashls = {
                    cmd = { "bash-language-server", "start" },
                    filetypes = { "bash", "sh" },
                },
                ts_ls = {},
                jsonls = {},
                kotlin_lsp = {},
                svelte = {},
            },
        },
        config = function(_, opts)
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
                callback = function(event)
                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if not client then
                        return
                    end

                    local server = opts.servers[map_client_name(client.name)]
                    if server == nil then
                        vim.notify("No configuration found for " .. client.name, vim.log.levels.WARN)
                        return
                    end

                    -- server specific keymaps
                    if server.keys and type(server.keys) == "table" then
                        for _, map in ipairs(server.keys) do
                            vim.keymap.set(map.mode or "n", map[1], map[2], { silent = true, desc = map.desc or "" })
                        end
                    end

                    if type(server.on_attach) == "function" then
                        server.on_attach(client, event.buf)
                    end
                end,
            })

            Snacks.util.lsp.on({ method = "textDocument/inlayHint" }, function(buffer)
                vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
            end)

            Snacks.util.lsp.on({ method = "textDocument/codeLens" }, function(buffer)
                vim.lsp.codelens.refresh()
                vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
                    buffer = buffer,
                    callback = vim.lsp.codelens.refresh,
                })
            end)

            if opts.servers["*"] then
                vim.lsp.config("*", opts.servers["*"])
                -- global keymaps
                local keys = opts.servers["*"].keys
                if keys and type(keys) == "table" then
                    for _, map in ipairs(keys) do
                        vim.keymap.set(map.mode or "n", map[1], map[2], { silent = true, desc = map.desc or "" })
                    end
                end
            end

            local configure = function(server)
                if server == "*" then
                    return false
                end

                local sopts = opts.servers[server]
                if type(sopts.setup) == "function" then
                    sopts.setup(server, sopts)
                end
                vim.lsp.config(server, sopts)
                vim.lsp.enable(server)
                return true
            end

            local install = vim.tbl_filter(configure, vim.tbl_keys(opts.servers))

            require("mason").setup({})
            require("mason-lspconfig").setup({
                ensure_installed = install,
                automatic_installation = true,
            })
        end,
    },
}
