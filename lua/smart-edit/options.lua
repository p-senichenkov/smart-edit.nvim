local M = {}

local providers = require('smart-edit.providers')

---@class SmartEditUserOptions
---@field providers Provider[]?
---@field hijack_e boolean?
---@field register_user_cmds boolean?

---@class SmartEditOptions
---@field providers Provider[]
---@field hijack_e boolean
---@field register_user_cmds boolean

---@type SmartEditOptions
local default_options = {
    providers = { providers.FileWithPosProvider },
    hijack_e = true,
    register_user_cmds = true,
}

---@type SmartEditOptions
M.options = default_options

---@param user_opts SmartEditUserOptions?
---@return nil
function M.EnrichOptions(user_opts)
    for key, value in pairs(user_opts or {}) do
        M.options[key] = value
    end
end

return M
