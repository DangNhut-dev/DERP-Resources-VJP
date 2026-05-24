local utils = {}

function utils.registerNetEvent(event, fn)
    RegisterNetEvent(event, function(...)
        if source ~= '' then fn(...) end
    end)
end

function utils.addBlip(settings)
    local blip = AddBlipForCoord(settings.coords.x, settings.coords.y, settings.coords.z)
    SetBlipSprite(blip, settings.id)
    SetBlipAsShortRange(blip, true)
    SetBlipScale(blip, settings.scale)
    SetBlipColour(blip, settings.color)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(settings.name)
    EndTextCommandSetBlipName(blip)
end

return utils