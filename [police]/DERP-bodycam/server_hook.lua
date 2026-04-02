if CAS.Framework == "qbx" then
    -- QBX không cần GetCoreObject, import trực tiếp
    local QBX = exports.qbx_core
else
    ESX = exports["es_extended"]:getSharedObject()
end

GetPlayersFw = function()
    if CAS.Framework == "qbx" then
        -- QBX sử dụng exports trực tiếp
        return exports.qbx_core:GetPlayers()
    else
        return ESX.GetPlayers()
    end
end

GetPlayer = function(player)
    if CAS.Framework == "qbx" then
        -- QBX dùng exports trực tiếp
        return exports.qbx_core:GetPlayer(player)
    else
        return ESX.GetPlayerFromId(player)
    end
end

GetJob = function(player)
    if CAS.Framework == "qbx" then
        return player.PlayerData.job
    else
        return player.getJob()
    end
end

GetGrade = function(player)
    if CAS.Framework == "qbx" then
        return player.PlayerData.job.grade.name
    else
        return player.getJob().grade_name
    end
end

GetSource = function(player)
    if CAS.Framework == "qbx" then
        return player.PlayerData.source
    else
        return player.source
    end
end

GetPlayerRName = function(player)
    local xPlayer = GetPlayer(player)
    if CAS.Framework == "qbx" then
        return xPlayer.PlayerData.charinfo.firstname.." "..xPlayer.PlayerData.charinfo.lastname
    else
        return xPlayer.getName()
    end
end

CreateThread(function()
    if CAS.Framework == "qbx" then
        -- QBX sử dụng exports trực tiếp
        exports.qbx_core:CreateUseableItem("bodycam", function(source)
            if source ~= 0 then
                TriggerClientEvent("useBodycam", source)
            end
        end)
    else
        ESX.RegisterUsableItem('bodycam', function(playerId)
            TriggerClientEvent("useBodycam", playerId)
        end)
    end
end)

Notify = function(src, text)
    if CAS.Framework == "qbx" then
        -- QBX dùng exports.qbx_core:Notify
        return exports.qbx_core:Notify(src, text)
    else
        local xPlayer = GetPlayer(src)
        return xPlayer.showNotification(text)
    end
end