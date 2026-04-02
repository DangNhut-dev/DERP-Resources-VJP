local localeData = {}

local languages = {'pt', 'vi'}
for _, lang in ipairs(languages) do
    local localeFile = LoadResourceFile(GetCurrentResourceName(), 'locale/' .. lang .. '.json')
    if localeFile then
        localeData[lang] = json.decode(localeFile)
    end
end

local currentLanguage = Config.Language or 'pt'


function SetLanguage(lang)
    if localeData[lang] then
        currentLanguage = lang
        return true
    end
    return false
end


function GetTranslation(key, ...)
    if localeData[currentLanguage] and localeData[currentLanguage][key] then
        local template = localeData[currentLanguage][key]
        local args = {...}
        

        for i, v in ipairs(args) do
            if type(v) == 'number' then
                args[i] = math.floor(v)
            end
        end
        
        return string.format(template, table.unpack(args))
    end

    return key
end


function T(key, ...)
    return GetTranslation(key, ...)
end


exports('GetTranslation', GetTranslation)
exports('SetLanguage', SetLanguage)
exports('T', T)
