local M = {}

local providers = require('smart-edit.providers')
local controller = require('smart-edit.controller')
local options = require('smart-edit.options')
local ucmds = require('smart-edit.ucmds')

--- Exposed API
---@type { [string]: fun(param: any): any }
M.api = {
    GetProviders = controller.GetProviders,
    RegisterProvider = controller.RegisterProvider,
}

--- Providers, provided by the plugin itself
---@type {[string]: Provider}
M.available_providers = {
    FilenameWithPos = providers.FileWithPosProvider,
}

--- User commands provided by the plugin (if you want to register them by yourself)
---@type { [string]: UcmdInfo }
M.user_cmds = {
    SmartEdit = ucmds.ApplyProvidersUcmd,
    ListActiveProviders = ucmds.ListActiveProvidersUcmd,
}

---@param user_opts SmartEditUserOptions?
---@return nil
function M.setup(user_opts)
    options.EnrichOptions(user_opts)
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
