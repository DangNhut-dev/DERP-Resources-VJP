Option = {}
Option.Print = true
Notify = 'ox_lib'

local originalPrint = print
print = function(...)
    if not Option.Print then return end
    local info = debug.getinfo(2, "Sl")
    local lineInfo = info.short_src .. ":" .. info.currentline
    return originalPrint("[" .. lineInfo .. "]", ...)
end