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
                        { "<leader>cC", function() vim.lsp.codelens.enable(true, { bufnr = vim.api.nvim_get_current_buf() }) end, desc = "Refresh & Display Codelens", mode = { "n" } },
                        { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File", mode ={"n"} },
                        { "<leader>cr", vim.lsp.buf.rename, desc = "Rename" },
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
                                features = {},
                            },
                            single_file_support = false,
                        },
                    },
                },
                gopls = {
                    settings = {
                        gopls = {
                            analyses = {
                                unusedparams = true,
                                unusedwrite = true,
                                nilness = true,
                                useany = true,
                                unusedvariable = true,
                            },
                            staticcheck = true,
                            gofumpt = true,
                        },
                    },
                },
                golangci_lint_ls = {},
                neocmake = {
                    root_markers = { "CMakeLists.txt", ".git", "build", "cmake" },
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
                qmlls = {
                    cmd = qmlls_binary(),
                    filetypes = { "qml", "qmljs" },
                    root_markers = { ".git", ".qmlls.ini", "qmlls.ini" },
                    handlers = {
                        ["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
                            if result and result.diagnostics then
                                result.diagnostics = vim.tbl_filter(function(d)
                                    return not d.message:match("Unqualified access")
                                end, result.diagnostics)
                            end
                            vim.lsp.handlers["textDocument/publishDiagnostics"](err, result, ctx, config)
                        end,
                    },
                    on_attach = function(client, bufnr)
                        vim.keymap.set("n", "gd", function()
                            local word = vim.fn.expand("<cword>")
                            local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
                            vim.lsp.buf_request_all(0, "textDocument/definition", params, function(results)
                                local locations = {}
                                for _, res in pairs(results) do
                                    if res.result then
                                        vim.list_extend(
                                            locations,
                                            type(res.result) == "table" and res.result or { res.result }
                                        )
                                    end
                                end
                                if #locations > 0 then
                                    vim.lsp.util.show_document(locations[1], client.offset_encoding, { focus = true })
                                else
                                    Snacks.picker.grep({
                                        search = "class " .. word,
                                        glob = { "*.hpp", "*.h", "*.cpp" },
                                    })
                                end
                            end)
                        end, { buffer = bufnr, desc = "Goto Definition (C++ fallback)" })
                    end,
                },
                bashls = {
                    cmd = { "bash-language-server", "start" },
                    filetypes = { "bash", "sh" },
                },
                ts_ls = {
                    settings = {
                        typescript = {
                            inlayHints = {
                                includeInlayParameterNameHints = "all",
                                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                                includeInlayFunctionParameterTypeHints = true,
                                includeInlayVariableTypeHints = true,
                                includeInlayPropertyDeclarationTypeHints = true,
                                includeInlayFunctionLikeReturnTypeHints = true,
                                includeInlayEnumMemberValueHints = true,
                            },
                        },
                        javascript = {
                            inlayHints = {
                                includeInlayParameterNameHints = "all",
                                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                                includeInlayFunctionParameterTypeHints = true,
                                includeInlayVariableTypeHints = true,
                                includeInlayPropertyDeclarationTypeHints = true,
                                includeInlayFunctionLikeReturnTypeHints = true,
                                includeInlayEnumMemberValueHints = true,
                            },
                        },
                    },
                },
                jsonls = {},
                kotlin_lsp = {},
                svelte = {},
                eslint = {
                    on_attach = function(_, bufnr)
                        vim.api.nvim_create_autocmd("BufWritePre", {
                            buffer = bufnr,
                            command = "LspEslintFixAll",
                        })
                    end,
                },
            },
        },
        config = function(_, opts)
            local function apply_keys(keys, extra_opts)
                for _, map in ipairs(keys) do
                    if type(map.enabled) == "function" and not map.enabled() then
                        goto continue
                    end
                    vim.keymap.set(
                        map.mode or "n",
                        map[1],
                        map[2],
                        vim.tbl_extend("force", { silent = true, desc = map.desc or "" }, extra_opts or {})
                    )
                    ::continue::
                end
            end

            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
                callback = function(event)
                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if not client then
                        return
                    end

                    -- apply global keys buffer-locally on each attach
                    if opts.servers["*"] and opts.servers["*"].keys then
                        apply_keys(opts.servers["*"].keys, { buffer = event.buf })
                    end

                    local server = opts.servers[map_client_name(client.name)]
                    if server == nil then
                        return
                    end

                    -- server specific keymaps
                    if server.keys and type(server.keys) == "table" then
                        apply_keys(server.keys, { buffer = event.buf })
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
                vim.lsp.codelens.enable(true, { bufnr = buffer })
                vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
                    buffer = buffer,
                    callback = function()
                        vim.lsp.codelens.enable(true, { bufnr = buffer })
                    end,
                })
            end)

            local _pending_hint_refresh = {}
            local _orig_ih_handler = vim.lsp.handlers["textDocument/inlayHint"]
            if _orig_ih_handler then
                vim.lsp.handlers["textDocument/inlayHint"] = function(err, result, ctx, config)
                    local ret = _orig_ih_handler(err, result, ctx, config)
                    local bufnr = ctx.bufnr
                    if bufnr and _pending_hint_refresh[bufnr] then
                        _pending_hint_refresh[bufnr] = nil
                        vim.schedule(function()
                            if vim.api.nvim_buf_is_valid(bufnr) then
                                vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                            end
                        end)
                    end
                    return ret
                end
            end

            vim.api.nvim_create_autocmd("BufWritePre", {
                group = vim.api.nvim_create_augroup("lsp-inlay-hint-write", { clear = true }),
                callback = function(args)
                    local bufnr = args.buf
                    if vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }) then
                        vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
                        _pending_hint_refresh[bufnr] = true
                    end
                end,
            })

            if opts.servers["*"] then
                vim.lsp.config("*", opts.servers["*"])
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
