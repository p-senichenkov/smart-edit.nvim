local M = {}

local providers = require('src.providers')
local controller = require('src.controller')
local options = require('src.options')
local ucmds = require('src.ucmds')

---@type { string: fun(param: any): any }
M.api = {
    GetProviders = controller.GetProviders,
    RegisterProvider = controller.RegisterProvider,
}

---@type Provider[]
M.available_providers = {
    providers.FileWithPosProvider,
}

---@type { string: fun(args): nil }
M.user_cmds = {
    ApplyProviders = ucmds.ApplyProvidersUcmd,
}

---@param user_opts SmartEditUserOptions?
---@return nil
function M.setup(user_opts)
    options.EnrichOptions(user_opts or {})
    local opts = options.options
    controller.RegisterProviders(opts.providers)

    if opts.register_user_cmds then
        ucmds.RegisterUserCmds()
    end

    if opts.hijack_e then
        vim.keymap.set('ca', 'e', 'SmartEdit')
    end
end

return M
