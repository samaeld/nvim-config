return {
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-fzf-native.nvim",
            "nvim-telescope/telescope-ui-select.nvim",
            "nvim-telescope/telescope-live-grep-args.nvim",
            "j-hui/fidget.nvim",
        },
        event = "VimEnter",
        config = function()
            local previewers = require("telescope.previewers")
            local conf = require("telescope.config").values
            local utils = require("telescope.previewers.utils")

            local function defaulter(f, default_opts)
                default_opts = default_opts or {}
                return {
                    new = function(opts)
                        if conf.preview == false and not opts.preview then
                            return false
                        end
                        opts.preview = type(opts.preview) ~= "table" and {} or opts.preview
                        if type(conf.preview) == "table" then
                            for k, v in pairs(conf.preview) do
                                opts.preview[k] = vim.F.if_nil(opts.preview[k], v)
                            end
                        end
                        return f(opts)
                    end,
                    __call = function()
                        local ok, err = pcall(f(default_opts))
                        if not ok then
                            error(debug.traceback(err))
                        end
                    end,
                }
            end

            local function search_teardown(self)
                if self.state and self.state.hl_id then
                    pcall(vim.fn.matchdelete, self.state.hl_id, self.state.hl_win)
                    self.state.hl_id = nil
                end
            end

            local function search_cb_jump(self, bufnr, query)
                if not query then
                    return
                end
                vim.api.nvim_buf_call(bufnr, function()
                    pcall(vim.fn.matchdelete, self.state.hl_id, self.state.winid)
                    vim.cmd("keepjumps norm! gg")
                    vim.fn.search(query, "W")
                    vim.cmd("norm! zz")

                    self.state.hl_id = vim.fn.matchadd("TelescopePreviewMatch", query)
                end)
            end

            local diff_to_parent_previewer = defaulter(function(opts)
                return previewers.new_buffer_previewer({
                    title = "Git Diff to Parent Preview",
                    teardown = search_teardown,

                    get_buffer_by_name = function(_, entry)
                        return entry.value
                    end,

                    define_preview = function(self, entry, status)
                        local cmd = { "git", "show", "--stat", "--patch", "--pretty=fuller", entry.value .. "^!" }
                        if opts.current_file then
                            table.insert(cmd, "--")
                            table.insert(cmd, opts.current_file)
                        end

                        utils.job_maker(cmd, self.state.bufnr, {
                            value = entry.value,
                            bufname = self.state.bufname,
                            cwd = opts.cwd,
                            callback = function(bufnr)
                                if vim.api.nvim_buf_is_valid(bufnr) then
                                    search_cb_jump(self, bufnr, opts.current_file)
                                    utils.highlighter(bufnr, "diff", opts)
                                end
                            end,
                        })
                    end,
                })
            end)

            require("telescope").setup({
                defaults = {
                    git_worktrees = vim.g.git_worktrees,
                    preview = {
                        msg_bg_fillchar = " ",
                    },
                    buffer_previewer_maker = previewers.buffer_previewer_maker,
                    file_previewer = previewers.vim_buffer_cat.new,
                    grep_previewer = previewers.vim_buffer_vimgrep.new,
                    qflist_previewer = previewers.vim_buffer_qflist.new,
                    git_status_previewer = previewers.new_termopen_previewer({
                        get_command = function(entry)
                            return { "git", "diff", entry.value, "--", entry.path }
                        end,
                        scroll_fn = function(self, direction)
                            if direction == 1 then
                                vim.api.nvim_feedkeys(
                                    vim.api.nvim_replace_termcodes("<C-D>", true, false, true),
                                    "n",
                                    true
                                )
                            else
                                vim.api.nvim_feedkeys(
                                    vim.api.nvim_replace_termcodes("<C-U>", true, false, true),
                                    "n",
                                    true
                                )
                            end
                        end,
                    }),
                    file_ignore_patterns = {
                        ".git/",
                        "tests/",
                    },
                    layout_strategy = "flex",
                    sorting_strategy = "ascending",
                    layout_config = {
                        prompt_position = "top",
                    },
                    path_display = {
                        filename_first = {
                            reverse_directories = true,
                        },
                    },
                    mappings = {
                        n = {
                            ["d"] = require("telescope.actions").delete_buffer,
                            ["q"] = require("telescope.actions").close,
                        },
                    },
                },
                extensions = {
                    ["ui-select"] = {
                        require("telescope.themes").get_dropdown(),
                    },
                    live_grep_args = {
                        auto_quoting = true,
                    },
                    fzf = {
                        fuzzy = true,
                        override_generic_sorter = true,
                        override_file_sorter = true,
                        case_mode = "smart_case",
                    },
                    workspaces = {
                        keep_insert = false,
                        initial_mode = "normal",
                        path_hl = "String",
                    },
                },
                pickers = {
                    find_files = {
                        hidden = true,
                    },
                },
            })

            previewers.git_commit_diff_to_parent = diff_to_parent_previewer

            pcall(require("telescope").load_extension, "fzf")
            pcall(require("telescope").load_extension, "ui-select")
            pcall(require("telescope").load_extension, "live_grep_args")
            pcall(require("telescope").load_extension, "fidget")
            pcall(require("telescope").load_extension, "workspaces")

            -- See `:help telescope.builtin`
            local builtin = require("telescope.builtin")
            vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
            vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
            vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
            vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
            vim.keymap.set(
                "n",
                "<leader>sw",
                require("telescope-live-grep-args.shortcuts").grep_word_under_cursor,
                { desc = "[S]earch current [W]ord" }
            )
            vim.keymap.set(
                "n",
                "<leader>sg",
                ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>",
                { desc = "[S]earch by [G]rep" }
            )
            vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
            vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
            vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
            vim.keymap.set("n", "<leader>su", builtin.lsp_references, { desc = "[S]earch [U]sage (references)" })
            vim.keymap.set("n", "<leader><leader>", function()
                builtin.buffers({
                    sort_mru = true,
                    sort_lastused = true,
                    initial_mode = "normal",
                })
            end, { desc = "[ ] Find existing buffers" })
            vim.keymap.set("n", "<leader>tk", builtin.git_commits, { desc = "Show git history" })
            vim.keymap.set("n", "<leader>k", builtin.git_bcommits, { desc = "Show git history for an open file" })
            vim.keymap.set("n", "<leader>ck", builtin.git_bcommits_range, { desc = "Show git commit for current line" })
            vim.keymap.set("n", "<leader>gb", builtin.git_branches, { desc = "Show git branches" })

            vim.keymap.set("n", "<leader>/", function()
                builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
                    previewer = false,
                }))
            end, { desc = "[/] Fuzzily search in current buffer" })

            vim.keymap.set("n", "<leader>s/", function()
                builtin.live_grep({
                    grep_open_files = true,
                    prompt_title = "Live Grep in Open Files",
                })
            end, { desc = "[S]earch [/] in Open Files" })

            vim.keymap.set("n", "<leader>sn", function()
                builtin.find_files({ cwd = vim.fn.stdpath("config") })
            end, { desc = "[S]earch [N]eovim files" })

            vim.keymap.set("n", "<leader>p", "<cmd>Telescope workspaces<cr>", { desc = "[P]rojects" })
        end,
    },
}
