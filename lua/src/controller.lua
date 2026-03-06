local M = {}

local providers_mod = require('src.providers')

--- It is not recommended to access this field directly
---@type Provider[]
M.providers = {}

---@param provider Provider
---@param text string
---@return boolean
local function ApplyProvider(provider, text)
    if provider.Check and not provider.Check(text) then
        return false
    end

    local e_info = provider.Apply(text)

    if e_info then
        vim.print(e_info)
        vim.api.nvim_cmd({ cmd = 'edit', args = { e_info.filename } }, {})
        if e_info.line or e_info.char then
            local line = e_info.line or 1
            local char = (e_info.char or 1) - 1
            vim.api.nvim_win_set_cursor(0, { line, char })
        end
        return true
    end
    return false
end

---@param text string
---@return nil
function M.ApplyProviders(text)
    for _, provider in ipairs(M.providers) do
        if ApplyProvider(provider, text) then
            return
        end
    end
end

---@class ProviderDump
---@field name string
---@field description string

--- Get info about currently active providers
---@return ProviderDump[]
function M.GetProviders()
    ---@type ProviderDump[]
    local dumps = {}
    for i, provider in ipairs(M.providers) do
        dumps[i] = {
            name = provider.name or 'Unknown',
            description = provider.description or 'No description'
        }
        return dumps
    end
end

--- Register a single provider as active at given priority (1 is the highest priority).
--- If priority is not given, inserts to the end (before `:edit`)
--- Does not affect other providers
---@param provider Provider
---@param priority integer?
---@return nil
function M.RegisterProvider(provider, priority)
    if not priority or priority < 1 or priority > #M.providers - 1 then
        priority = #M.providers - 1
    end
    for i = #M.providers, priority - 1, -1 do
        M.providers[i + 1] = M.providers[i]
    end
    M.providers[priority] = provider
end

--- Register providers as active.
--- Clears all currently active providers
---@param providers Provider[]?
---@return nil
function M.RegisterProviders(providers)
    M.providers = providers or {}
    M.providers[#M.providers + 1] = providers_mod.NativeEditProvider
end

return M
