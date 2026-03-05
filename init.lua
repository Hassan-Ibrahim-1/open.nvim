local M = {}

local config = {
    default_dir = nil,
    filetype = {},
}

M.setup = function(opts)
    opts = opts or {}
    config.default_dir = opts.default_dir or vim.fn.getcwd()
    config.filetype = opts.filetype or {}

    vim.api.nvim_create_user_command('OpenFile', function(user_opts)
        M.run(user_opts.args)
    end, { nargs = 1, complete = 'file' })
end

local function get_extension(filename)
    return vim.fn.fnamemodify(filename, ':e')
end

local function run_cmd(cmd, filepath)
    filepath = vim.fn.expand(filepath)

    local cmd_list = {}

    if type(cmd) == "table" then
        cmd_list = vim.list_extend({ cmd[1] }, cmd[2] or {})
    else
        cmd_list = { cmd }
    end

    table.insert(cmd_list, filepath)

    vim.system(cmd_list, { detach = true })
end

local function build_find_command()
    local cmd = { "rg", "--files" }

    for ext, _ in pairs(config.filetype) do
        table.insert(cmd, "-g")
        table.insert(cmd, "*." .. ext)
    end

    return cmd
end

local function open_file(filepath)
    local ext = get_extension(filepath)
    local cmd = config.filetype[ext]

    if cmd then
        run_cmd(cmd, filepath)
    end
end

M.run = function(filepath)
    local ext = get_extension(filepath)
    local cmd = config.filetype[ext]

    if cmd then
        run_cmd(cmd, filepath)
    else
        vim.notify('No command registered for .' .. ext .. ' files', vim.log.levels.WARN)
    end
end

M.open = function(dir)
    local telescope_ok, telescope = pcall(require, 'telescope.builtin')
    if not telescope_ok then
        vim.notify('telescope not installed', vim.log.levels.ERROR)
        return
    end

    local search_dir = dir or config.default_dir or vim.fn.getcwd()

    telescope.find_files({
        cwd = search_dir,
        find_command = build_find_command(),
        attach_mappings = function(prompt_bufnr)
            local actions = require('telescope.actions')
            actions.select_default:replace(function()
                local selection = require('telescope.actions.state').get_selected_entry()
                actions.close(prompt_bufnr)
                if selection and selection[1] then
                    local full_path = vim.fs.joinpath(search_dir, selection[1])
                    open_file(full_path)
                end
            end)
            return true
        end,
    })
end

return M
