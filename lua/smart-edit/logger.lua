local M = {}

---@alias LogLevel 'off' | 'trace' | 'debug' | 'info' | 'warning' | 'error'

---@type LogLevel
M.current_log_level = 'debug'

---@type {[LogLevel]: vim.log.levels}
local LOG_LEVEL_TO_VIM_LOG_LEVEL = {
    trace = vim.log.levels.TRACE,
    debug = vim.log.levels.DEBUG,
    info = vim.log.levels.INFO,
    warning = vim.log.levels.WARN,
    error = vim.log.levels.ERROR,
    off = vim.log.levels.OFF,
}

---@param message string
---@param level LogLevel?
function M.log(message, level)
    level = level or 'debug'

    if level == 'off' then
        vim.notify('Message cannot have "OFF" log level', vim.log.levels.ERROR)
        return
    end

    local vim_level = LOG_LEVEL_TO_VIM_LOG_LEVEL[level]
    local current_vim_level = LOG_LEVEL_TO_VIM_LOG_LEVEL[M.current_log_level]
    if vim_level >= current_vim_level then
        vim.notify(message, vim_level)
    end
end

return M
