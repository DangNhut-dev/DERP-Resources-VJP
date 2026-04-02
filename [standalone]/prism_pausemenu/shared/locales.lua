Locales = {}

function _(str, ...)
    if Locales[CFG.Locale] and Locales[CFG.Locale][str] then
        return string.format(Locales[CFG.Locale][str], ...)
    else
        return 'Translation [' .. CFG.Locale .. '][' .. str .. '] does not exist'
    end
end

