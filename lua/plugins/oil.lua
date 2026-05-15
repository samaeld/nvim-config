local function parse_output(proc)
    local result = proc:wait()
    local ret = {}
    if result.code == 0 then
        for line in vim.gsplit(result.stdout, "\n", { plain = true, trimempty = true }) do
            line = line:gsub("/$", "")
            ret[line] = true
        end
    end
    return ret
end

local function new_git_status()
    return setmetatable({}, {
        __index = function(self, key)
            local ignore_proc = vim.system(
                { "git", "ls-files", "--ignored", "--exclude-standard", "--others", "--directory" },
                {
                    cwd = key,
                    text = true,
                }
            )
            local tracked_proc = vim.system({ "git", "ls-tree", "HEAD", "--name-only" }, {
                cwd = key,
                text = true,
            })
            local ret = {
                ignored = parse_output(ignore_proc),
                tracked = parse_output(tracked_proc),
            }

            rawset(self, key, ret)
            return ret
        end,
    })
end

return {
    {
        "barrettruth/canola.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("oil").setup({
                default_file_explorer = true,
                delete_to_trash = true,
                view_options = {
                    show_hidden = true,
                    is_always_hidden = function(name, bufnr)
                        return name == ".git"
                    end,
                    is_hidden_file = function(name, bufnr)
                        local git_status = new_git_status()
                        local dir = require("oil").get_current_dir(bufnr)
                        local is_dotfile = vim.startswith(name, ".") and name ~= ".."
                        if not dir then
                            return is_dotfile
                        end
                        if is_dotfile then
                            return not git_status[dir].tracked[name]
                        else
                            return git_status[dir].ignored[name]
                        end
                    end,
                },
                win_options = {
                    wrap = false,
                    signcolumn = "yes:2",
                },
                watch_for_changes = true,
                use_default_keymaps = false,
                keymaps = {
                    ["g?"] = { "actions.show_help", mode = "n" },
                    ["<CR>"] = "actions.select",
                    ["<C-t>"] = { "actions.select", opts = { tab = true } },
                    ["<C-p>"] = "actions.preview",
                    ["<C-c>"] = { "actions.close", mode = "n" },
                    ["<C-r>"] = "actions.refresh",
                    ["-"] = { "actions.parent", mode = "n" },
                    ["_"] = { "actions.open_cwd", mode = "n" },
                    ["`"] = { "actions.cd", mode = "n" },
                    ["~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
                    ["gs"] = { "actions.change_sort", mode = "n" },
                    ["gx"] = "actions.open_external",
                    ["g."] = { "actions.toggle_hidden", mode = "n" },
                    ["g\\"] = { "actions.toggle_trash", mode = "n" },
                },
            })

            vim.keymap.set("n", "-", "<cmd>Oil<CR>", { desc = "Open parent directory", noremap = true, silent = true })
        end,
    },
    {
        "refractalize/oil-git-status.nvim",
        dependencies = {
            "barrettruth/canola.nvim",
        },
        config = true,
    },
    {
        "benomahony/oil-git.nvim",
        dependencies = { "barrettruth/canola.nvim" },
    },
    {
        "JezerM/oil-lsp-diagnostics.nvim",
        dependencies = { "barrettruth/canola.nvim" },
        opts = {},
    },
}
