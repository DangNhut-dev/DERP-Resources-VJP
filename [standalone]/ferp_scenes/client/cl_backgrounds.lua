if Config.CustomBackgrounds then
    for i = 1, #Config.CustomBackgrounds do
        local bg = Config.CustomBackgrounds[i]

        local exists = false
        for _, existingBg in ipairs(Config.BackgroundStyles) do
            if existingBg.value == bg.value then
                exists = true
                break
            end
        end

        if not exists then
            table.insert(Config.BackgroundStyles, {value = bg.value, label = bg.label})
        end
    end
end

local loadedDicts = {}

function LoadBackgroundTexture(dict, texture)
    if not loadedDicts[dict] then
        lib.requestStreamedTextureDict(dict)
        loadedDicts[dict] = true
    end
end

function DrawCustomBackground(dict, texture, width, height, x, y, alpha, r, g, b)
    if not dict or not texture then return false end
    
    LoadBackgroundTexture(dict, texture)
    
    if HasStreamedTextureDictLoaded(dict) then
        DrawSprite(dict, texture, x, y, width, height, 0.0, r, g, b, alpha)
        return true
    end
    
    return false
end

function GetCustomBackgroundData(backgroundId)
    for i = 1, #Config.CustomBackgrounds do
        if Config.CustomBackgrounds[i].value == backgroundId then
            return Config.CustomBackgrounds[i]
        end
    end
    return nil
end


exports('LoadBackgroundTexture', LoadBackgroundTexture)
exports('DrawCustomBackground', DrawCustomBackground)
exports('GetCustomBackgroundData', GetCustomBackgroundData)
