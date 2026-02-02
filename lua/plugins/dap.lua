return {
    {
        "mfussenegger/nvim-dap",
        config = function()
            local dap = require("dap")
            -- local install_root_dir = vim.fn.stdpath("data") .. "/mason"
            -- local extension_path = install_root_dir .. "/packages/codelldb/extension/"
            -- local codelldb_path = extension_path .. "adapter/codelldb"

            -- TODO: add configuration for
            -- c/cpp
            -- lua

            -- TODO: configure mappings
            vim.keymap.set("n", "<Leader>b", function()
                dap.toggle_breakpoint()
            end, { desc = "DAP: toggle breakpoint" })
        end,
    },
    {
        "mfussenegger/nvim-dap-python",
        lazy = true,
        dependencies = { "mfussenegger/nvim-dap" },
        config = function()
            require("dap-python").setup("python")
            require("dap-python").test_runner = "pytest"
        end,
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
        config = function()
            local dap, dapui = require("dap"), require("dapui")
            dapui.setup({
                expand_lines = true,
                icons = { expanded = "", collapsed = "", circular = "" },
                mappings = {
                    -- Use a table to apply multiple mappings
                    expand = { "<CR>", "<2-LeftMouse>" },
                    open = "o",
                    remove = "d",
                    edit = "e",
                    repl = "r",
                    toggle = "t",
                },
                layouts = {
                    {
                        elements = {
                            { id = "scopes", size = 0.33 },
                            { id = "breakpoints", size = 0.17 },
                            { id = "stacks", size = 0.25 },
                            { id = "watches", size = 0.25 },
                        },
                        size = 0.33,
                        position = "right",
                    },
                    {
                        elements = {
                            { id = "repl", size = 0.45 },
                            { id = "console", size = 0.55 },
                        },
                        size = 0.27,
                        position = "bottom",
                    },
                },
                floating = {
                    max_height = 0.9,
                    max_width = 0.5, -- Floats will be treated as percentage of your screen.
                    border = vim.g.border_chars, -- Border style. Can be 'single', 'double' or 'rounded'
                    mappings = {
                        close = { "q", "<Esc>" },
                    },
                },
            }) -- use default
            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open({})
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close({})
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close({})
            end

            local dap_breakpoint = {
                breakpoint = {
                    text = "",
                    texthl = "LspDiagnosticsSignError",
                    linehl = "",
                    numhl = "",
                },
                rejected = {
                    text = "",
                    texthl = "LspDiagnosticsSignHint",
                    linehl = "",
                    numhl = "",
                },
                stopped = {
                    text = "",
                    texthl = "LspDiagnosticsSignInformation",
                    linehl = "DiagnosticUnderlineInfo",
                    numhl = "LspDiagnosticsSignInformation",
                },
            }

            vim.fn.sign_define("DapBreakpoint", dap_breakpoint.breakpoint)
            vim.fn.sign_define("DapStopped", dap_breakpoint.stopped)
            vim.fn.sign_define("DapBreakpointRejected", dap_breakpoint.rejected)
        end,
    },
    {
        "theHamsta/nvim-dap-virtual-text",
    },
    {
        "jedrzejboczar/nvim-dap-cortex-debug",
        requires = "mfussenegger/nvim-dap",
        config = function()
            require("dap-cortex-debug").setup({
                debug = true,
            })
        end,
    },
    {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = {
            "mfussenegger/nvim-dap",
            "mason-org/mason.nvim",
        },
        config = function()
            require("mason-nvim-dap").setup({
                automatic_setup = true,
                ensure_installed = { "python" },
            })
            local keymap = vim.keymap
            keymap.set("v", "<leader>ds", "<cmd>lua require('dap-python').debug_selection()<cr>")
        end,
    },
    {
        "nvim-telescope/telescope-dap.nvim",
    },
}
