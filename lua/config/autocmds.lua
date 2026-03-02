local function resolve_cmake_vars(path, current_dir, root)
    return path:gsub("%${CMAKE_CURRENT_SOURCE_DIR}", current_dir)
        :gsub("%${CMAKE_CURRENT_LIST_DIR}", current_dir)
        :gsub("%${CMAKE_SOURCE_DIR}", root)
        :gsub("%${PROJECT_SOURCE_DIR}", root)
end

local function collect_module_paths(root)
    local paths = {}
    local seen = {}

    local files = {}
    vim.list_extend(files, vim.fn.glob(root .. "/CMakeLists.txt", false, true))
    vim.list_extend(files, vim.fn.glob(root .. "/**/*.cmake", false, true))
    vim.list_extend(files, vim.fn.glob(root .. "/**/CMakeLists.txt", false, true))

    for _, file in ipairs(files) do
        local ok, lines = pcall(vim.fn.readfile, file)
        if not ok then
            goto continue
        end
        local file_dir = vim.fn.fnamemodify(file, ":h")
        for _, line in ipairs(lines) do
            local args = line:match("[Ss]et%s*%(%s*CMAKE_MODULE_PATH%s+(.-)%s*%)")
            if args then
                for part in args:gmatch('[^%s"]+') do
                    if not part:find("CMAKE_MODULE_PATH") then
                        local resolved = resolve_cmake_vars(part, file_dir, root)
                        if vim.fn.isdirectory(resolved) == 1 and not seen[resolved] then
                            seen[resolved] = true
                            table.insert(paths, resolved)
                        end
                    end
                end
            end
        end
        ::continue::
    end
    return paths
end

local function open_dir(dir)
    local entry = dir .. "/CMakeLists.txt"
    if vim.fn.filereadable(entry) == 1 then
        vim.cmd("edit " .. vim.fn.fnameescape(entry))
        return true
    end
    return false
end

local function cmake_goto_file()
    local line = vim.api.nvim_get_current_line()
    local current_dir = vim.fn.expand("%:p:h")
    local root = vim.fn.getcwd()

    local subdir = line:match("[Aa]dd_subdirectory%s*%(%s*([^)%s,]+)")
    if subdir then
        subdir = resolve_cmake_vars(subdir, current_dir, root)
        if not subdir:match("^/") then
            subdir = current_dir .. "/" .. subdir
        end
        if open_dir(subdir) then
            return
        end
    end

    local path = line:match("[Ii]nclude%s*%(%s*([^)%s]+)")
    if path and (path:find("[/\\]") or path:find("%$%{")) then
        path = resolve_cmake_vars(path, current_dir, root)
        if vim.fn.filereadable(path) == 1 then
            vim.cmd("edit " .. vim.fn.fnameescape(path))
            return
        elseif vim.fn.isdirectory(path) == 1 then
            if open_dir(path) then
                return
            end
        end
    end

    local module = line:match("[Ii]nclude%s*%(%s*([%w_%-]+)%s*%)")
    if module then
        local module_dirs = collect_module_paths(root)
        for _, dir in ipairs(module_dirs) do
            local candidate = dir .. "/" .. module .. ".cmake"
            if vim.fn.filereadable(candidate) == 1 then
                vim.cmd("edit " .. vim.fn.fnameescape(candidate))
                return
            end
        end
    end

    vim.lsp.buf.definition()
end

vim.api.nvim_create_autocmd("FileType", {
    pattern = "cmake",
    callback = function(event)
        vim.keymap.set("n", "gd", cmake_goto_file, { buffer = event.buf, desc = "Goto Definition (cmake)" })
    end,
})
