local M = {}

local controller = require('smart-edit.controller')
local util = require('smart-edit.util')

---@class UcmdInfo
---@field Callable fun(args): nil
---@field Opts table?

---@type UcmdInfo
M.ApplyProvidersUcmd = {
    Callable = function(args)
        if not args.args or #args.args == 0 then
            vim.cmd('edit')
            return
        end

        controller.ApplyProviders(args.args)
    end,
    Opts = { nargs = '?', complete = 'file' },
}

M.ListActiveProvidersUcmd = {
    Callable = function(_)
        local res = 'Active providers (top-down priority):\n'
        res = res .. util.Tabulate(controller.GetProviders(), { 'name', 'description' },
            '   ', '   ')
        vim.notify(res, vim.log.levels.INFO)
    end,
}

---@param name string
---@param ucmd_info UcmdInfo
local function RegisterUcmd(name, ucmd_info)
    vim.api.nvim_create_user_command(name, ucmd_info.Callable, ucmd_info.Opts or {})
end

function M.RegisterUserCmds()
    RegisterUcmd('SmartEdit', M.ApplyProvidersUcmd)
    RegisterUcmd('SmartEditListProviders', M.ListActiveProvidersUcmd)
end

return M
