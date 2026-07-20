local function find_clang_format_up(path)
    local depth = 0
    local max_depth = 5
    while path ~= "/" and depth < max_depth do
        if vim.fn.filereadable(path .. "/.clang-format") == 1 then
            vim.notify("clang-format found in " .. path .. "/.clang-format")
            return true
        end
        path = vim.fn.fnamemodify(path, ":h")
        depth = depth + 1
    end
    return false
end

local function webkit_format_args()
    if find_clang_format_up(vim.fn.getcwd()) then
        return { "--style={BasedOnStyle: InheritParentConfig}" }
    end

    return {
        "--style={BasedOnStyle: WebKit, "
            .. "AlignAfterOpenBracket: AlwaysBreak, "
            .. "AllowShortFunctionsOnASingleLine: None, "
            .. "AlwaysBreakTemplateDeclarations: Yes, "
            .. "BinPackArguments: false, "
            .. "BinPackParameters: false, "
            .. "IndentWidth: 4, "
            .. "ColumnLimit: 100, "
            .. "FixNamespaceComments: true, "
            .. "IncludeBlocks: Regroup, "
            .. "IncludeCategories: ["
            .. "{Regex: '^\".+\\.(h|hh|hpp|hxx)\"$', Priority: 1}, "
            .. "{Regex: '^<.+\\.(h|hh|hpp|hxx)>$', Priority: 2}, "
            .. "{Regex: '^<[^.]+>$', Priority: 3}"
            .. "], "
            .. 'IncludeIsMainRegex: "(_unittest)?$", '
            .. "Cpp11BracedListStyle: true, "
            .. "NamespaceIndentation: None, "
            .. "SpaceAfterTemplateKeyword: false, "
            .. "SpaceBeforeCpp11BracedList: false, "
            .. "PenaltyReturnTypeOnItsOwnLine: 999, "
            .. "SeparateDefinitionBlocks: Always}",
    }
end

local function llvm_format_args()
    if find_clang_format_up(vim.fn.getcwd()) then
        return { "--style={BasedOnStyle: InheritParentConfig}" }
    end

    return {
        "--style={BasedOnStyle: llvm, "
            .. "AlignAfterOpenBracket: AlwaysBreak, "
            .. "AllowShortFunctionsOnASingleLine: None, "
            .. "AlwaysBreakTemplateDeclarations: Yes, "
            .. "BinPackArguments: false, "
            .. "BinPackParameters: false, "
            .. "IndentWidth: 4, "
            .. "ColumnLimit: 100, "
            .. "FixNamespaceComments: true, "
            .. "IncludeBlocks: Regroup, "
            .. "IncludeCategories: ["
            .. "{Regex: '^\".+\\.(h|hh|hpp|hxx)\"$', Priority: 1}, "
            .. "{Regex: '^<.+\\.(h|hh|hpp|hxx)>$', Priority: 2}, "
            .. "{Regex: '^<[^.]+>$', Priority: 3}"
            .. "], "
            .. 'IncludeIsMainRegex: "(_unittest)?$", '
            .. "Cpp11BracedListStyle: true, "
            .. "NamespaceIndentation: None, "
            .. "SpaceAfterTemplateKeyword: false, "
            .. "SpaceBeforeCpp11BracedList: false, "
            .. "PenaltyReturnTypeOnItsOwnLine: 999, "
            .. "SeparateDefinitionBlocks: Always}",
    }
end

return {
    {
        "stevearc/conform.nvim",
        lazy = false,
        keys = {
            {
                "<leader>f",
                function()
                    require("conform").format({ async = true, lsp_fallback = true })
                end,
                mode = "",
                desc = "[F]ormat buffer",
            },
            {
                "<leader>tf",
                function()
                    vim.g.formatting_enabled = not vim.g.formatting_enabled
                    vim.notify("Formatting " .. (vim.g.formatting_enabled and "enabled" or "disabled"))
                end,
                mode = "",
                desc = "[T]oggle [F]ormatting",
            },
        },
        config = function()
            require("conform").setup({
                notify_on_error = true,
                format_on_save = function()
                    if not vim.g.formatting_enabled then
                        return
                    end
                    return { timeout_ms = 1000, lsp_format = "fallback" }
                end,
                formatters_by_ft = {
                    cpp = { "cpp_format" },
                    c = { "c_format" },
                    python = { "isort", "black" },
                    lua = { "stylua" },
                    cmake = { "gersemi" },
                    qml = { "qmlformat" },
                    go = { "goimports", "gofumpt" },
                    svelte = { "prettierd", "prettier", stop_after_first = true },
                    typescript = { "prettierd", "prettier", stop_after_first = true },
                    javascript = { "prettierd", "prettier", stop_after_first = true },
                },
                formatters = {
                    cpp_format = {
                        command = "clang-format",
                        args = webkit_format_args(),
                    },
                    c_format = {
                        command = "clang-format",
                        args = '--style="{BasedOnStyle: llvm, IndentWidth: 4, ColumnLimit: 100,}"',
                    },
                },
            })
        end,
    },
}
