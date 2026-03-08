local M = {}

---@class Set<T>: {[T]: boolean}

--- Convert both keys and values to string
---@param data table
---@return {[string]: string}
local function Stringify(data)
    ---@type {[string]: string}
    local res = {}
    for key, value in pairs(data) do
        res[tostring(key)] = tostring(value)
    end
    return res
end

--- After this operation all tables contain same keys (nil values are replaced with empty strings)
---@param data {[string]: string}[]
---@return {[string]: string}[]
local function Enrich(data)
    ---@type Set<string>
    local all_keys = {}
    for _, tab in ipairs(data) do
        for key, _ in pairs(tab) do
            all_keys[key] = true
        end
    end

    ---@type {[string]: string}[]
    local res = {}
    for _, tab in ipairs(data) do
        ---@type {[string]: string}
        local new_tab = {}
        for key, _ in pairs(all_keys) do
            new_tab[key] = tab[key] or ''
        end
        res[#res+1] = new_tab
    end
    return res
end

---@class Tableau: string[][]

--- Pretty-save tabular data
---@param data {[string]: string}[]
---@param cols string[]
---@return Tableau
local function Tabulify(data, cols)
    ---@type Tableau
    local res = {}
    for _, tab in ipairs(data) do
        ---@type string[]
        local row = {}
        for _, key in ipairs(cols) do
            row[#row+1] = tab[key]
        end
        res[#res+1] = row
    end
    return res
end

---@param str string
---@return string[]
local function BreakLinesStr(str)
    ---@types string[]
    local lines = {}
    for line in string.gmatch(str, '[^\n]*') do
        if #line > 0 then
            lines[#lines+1] = line
        end
    end
    return lines
end

--- Break pretty-saved tableau into lines (for multiline text)
---@param tableau Tableau
---@return Tableau
local function BreakLines(tableau)
    ---@type string[][][]
    local broken_tableau = {}
    for i, row in ipairs(tableau) do
        ---@type string[][]
        local broken_row = {}
        for j, val in ipairs(row) do
            broken_row[j] = BreakLinesStr(val)
        end
        broken_tableau[i] = broken_row
    end

    ---@type integer[]
    local heights = {}
    for i, row in ipairs(broken_tableau) do
        local height = 0
        for _, broken_value in ipairs(row) do
            height = math.max(height, #broken_value)
        end
        heights[i] = height
    end

    ---@type Tableau
    local res = {}
    for i, row in ipairs(broken_tableau) do
        for j = 1, heights[i] do
            ---@type string[]
            local subrow = {}
            for k, broken_val in ipairs(row) do
                subrow[k] = broken_val[j] or ''
            end
            res[#res+1] = subrow
        end
    end
    return res
end

--- Pretty-print tabular data
--- Currently, only left-alignment is implemented
---@param data table[]
---@param cols string[]?    Column names (keys in tables)
---@param inter string?     Characters between columns
---@param before string?    Characters before each row
---@return string
function M.Tabulate(data, cols, inter, before)
    ---@type {[string]: string}[]
    local string_data = {}
    for _, tab in ipairs(data) do
        string_data[#string_data+1] = Stringify(tab)
    end
    string_data = Enrich(string_data)

    if not cols then
        cols = {}
        for key, _ in pairs(data[1]) do
            cols[#cols + 1] = key
        end
        table.sort(cols)
    end
    inter = inter or '   '
    before = before or ''

    ---@type Tableau
    -- Guaranteed to be square-shaped
    local tableau = Tabulify(string_data, cols)
    tableau = BreakLines(tableau)
    if #tableau == 0 then
        return ''
    end
    local num_cols = #tableau[1]

    ---@type integer[]
    local max_lens = {}
    for col_num = 1, num_cols do
        local len = 0
        for _, row in ipairs(tableau) do
            len = math.max(len, #row[col_num])
        end
        max_lens[col_num] = len
    end

    local res = ''
    for num_row, row in ipairs(tableau) do
        res = res .. before
        for i, val in ipairs(row) do
            local padding = max_lens[i] - #val
            res = res .. val .. string.rep(' ', padding)
            if i ~= #row then
                res = res .. inter
            end
        end
        if num_row ~= #tableau then
            res = res .. '\n'
        end
    end
    return res
end

return M
