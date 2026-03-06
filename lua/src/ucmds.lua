local M = {}

local controller = require('src.controller')

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

---@param name string
---@param ucmd_info UcmdInfo
local function RegisterUcmd(name, ucmd_info)
    vim.api.nvim_create_user_command(name, ucmd_info.Callable, ucmd_info.Opts or {})
end

function M.RegisterUserCmds()
    RegisterUcmd('SmartEdit', M.ApplyProvidersUcmd)
end

return M
