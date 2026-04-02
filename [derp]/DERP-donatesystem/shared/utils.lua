function FormatMoney(amount)
    local formatted = tostring(math.floor(amount))
    local result = ''
    local count = 0
    for i = #formatted, 1, -1 do
        count = count + 1
        result = formatted:sub(i, i) .. result
        if count % 3 == 0 and i ~= 1 then
            result = '.' .. result
        end
    end
    return result
end

function SanitizeString(str, maxLen)
    if type(str) ~= 'string' then return '' end
    str = str:gsub('[<>"\']', '')
    if maxLen and #str > maxLen then
        str = str:sub(1, maxLen)
    end
    return str
end