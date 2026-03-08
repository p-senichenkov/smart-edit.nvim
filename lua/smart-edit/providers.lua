local M = {}

---@class EditInfo
---@field filename string
---@field line integer?
---@field char integer?

---@alias CheckFun fun(param: string): boolean

---@alias ApplyFun fun(param: string): EditInfo?

---@class Provider
---@field Check CheckFun?
---@field Apply ApplyFun
---@field name string?
---@field description string?

-- NOTE: Mulitline descriptions are allowed.

---@type Provider
M.FileWithPosProvider = {
    Check = function(path)
        return path:find(':') ~= nil
    end,
    Apply = function(path)
        local l = vim.lpeg
        local loc = l.locale()

        local fname_patt = l.Cg((1 - (loc.space + l.P(':'))) ^ 1, 'filename')
        local line_patt = l.P(':') * l.Cg(loc.digit ^ 1 / tonumber, 'line')
        local char_patt = l.P(':') * l.Cg(loc.digit ^ 1 / tonumber, 'char')
        local pattern = l.Ct(fname_patt ^ 1 ^ -1 * (line_patt ^ -1) * (char_patt ^ -1) * l.P(-1))

        return pattern:match(path)
    end,
    name = 'File with position',
    description = 'Parses path/to/file:line:char into {"path/to/file", line, char}',
}

-- This is a fallback provider, and it shouldn't be used directly
M.NativeEditProvider = {
    Apply = function (path)
        vim.api.nvim_cmd({ cmd = 'edit', args = { path } }, {})
    end,
    name = ':edit',
    description = [[Apply vim's native `:edit` command.]],
}

return M
