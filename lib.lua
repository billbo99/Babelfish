local lib = {} ---@class HelperLibrary

---Check strings ends with phrase
---@param str string
---@param ending string
---@return boolean
lib.ends_with = function(str, ending)
    return ending == "" or str:sub(-(#ending)) == ending
end

---Check strings starts with phrase
---@param str string
---@param start string
---@return boolean
lib.starts_with = function(str, start)
    return str:sub(1, #start) == start
end

---Split strings
---@param s string
---@param regex string|nil
---@return table
lib.splitString = function(s, regex)
    local chunks = {}
    local count = 0
    if regex == nil then
        regex = "%S+"
    end

    for substring in s:gmatch(regex) do
        count = count + 1
        chunks[count] = substring
    end
    return chunks
end

return lib
