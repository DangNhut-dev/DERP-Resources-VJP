--[[
░▒▓████████▓▒░▒▓██████▓▒░       ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓███████▓▒░  
   ░▒▓█▓▒░  ░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
   ░▒▓█▓▒░  ░▒▓█▓▒░             ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
   ░▒▓█▓▒░  ░▒▓█▓▒░             ░▒▓████████▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓███████▓▒░  
   ░▒▓█▓▒░  ░▒▓█▓▒░             ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
   ░▒▓█▓▒░  ░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
   ░▒▓█▓▒░   ░▒▓██████▓▒░       ░▒▓█▓▒░░▒▓█▓▒░░▒▓██████▓▒░░▒▓███████▓▒░  
                                                                         
 This File Leaked By TC HUB Team, Join Our Server For More
 DISCORD: - https://discord.gg/k3S8RjkPWc - https://t.me/+RgDxwPX3L7w2ODBk - https://tchub.shop/
--]]


local activeBombs = {} 
local decalTypes = { 
    9000,
}

local function resetExpired()
    local timeNow = os.time()

    local expiredIds = {}

    for id, v in pairs(activeBombs) do
        if timeNow > v.expiresAt then
            table.insert(expiredIds, id)
            activeBombs[id] = nil
        end
    end

    if #expiredIds > 0 then
        TriggerClientEvent('prp-pettycrime:client:gbResetPoints', -1, expiredIds)
    end
end

function GetGlitterBombs()
    return activeBombs
end

function CreateGlitterBomb(source, model)
    local ped = GetPlayerPed(source)
    local heading = GetEntityHeading(ped)
    local pointId = lib.string.random('..........', 10)
    local entityCoords, decalCoords, decalForward, decalRight = lib.callback.await('prp-pettycrime:client:getGlitterBombData', source)
    local pointData = {
        coords = entityCoords,
        objects = {},
        decalCoords = {},
        expiresAt = os.time() + (60 * SvConfig.PorchPirate.glitterBomb.expiresIn),
        particleModels = {
            {
                model = model,
                dict = 'core',
                name = 'exp_grd_bzgas_smoke',
                scale = 1.0,
                offsetX = 0.0,
                offsetY = 0.0,
                offsetZ = 0.1,
                duration = 2000,
                sounds = {
                    {name = 'Pin_Good', ref = 'DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS', times = 5, timeBetween = 300},
                    {name = 'Pin_Bad', ref = 'DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS', times = 5, timeBetween = 500},
                    {name = 'Hack_Failed', ref = 'DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS', times = 1, timeBetween = 500},
                },
            },
            {
                model = model,
                dict = 'core',
                name = 'ent_amb_smoke_foundry_white',
                scale = 1.0,
                offsetX = 0.0,
                offsetY = 0.0,
                offsetZ = 0.1,
            },
            {
                model = model,
                dict = 'core',
                name = 'bul_plaster_brittle',
                scale = 3.0,
                offsetX = 0.0,
                offsetY = 0.0,
                offsetZ = 0.5,
            },
        },
    }

    table.insert(pointData.objects, {hash = model, coords = entityCoords, heading = heading})

    if decalCoords then
        table.insert(pointData.decalCoords, {
            type = decalTypes[math.random(1, #decalTypes)],
            coords = decalCoords,
            forward = decalForward,
            right = decalRight,
            size = vector2(3.0, 3.0),
            red = 0.0 + (math.random(1, 100) / 100.0),
            green = 0.0 + (math.random(1, 100) / 100.0),
            blue = 0.0 + (math.random(1, 100) / 100.0),
        })
    end

    activeBombs[pointId] = pointData

    TriggerClientEvent('prp-pettycrime:client:gbAddPoint', -1, pointId, pointData)
    HeatAction(source, "glitter_bomb", entityCoords)
end

RegisterNetEvent('prp-pettycrime:server:gbDisarm', function(pointId)
    local src = source

    if not pointId then
        return
    end

    if Config.GlitterBomb.disarming.jobRequired then
        local allowed = false
        for i = 1, #Config.GlitterBomb.disarming.jobs do
            local job = Config.GlitterBomb.disarming.jobs[i]
            if bridge.fw.hasJob(src, job.id, job.minGrade or nil, job.duty or nil) then
                allowed = true
                break
            end
        end

        if not allowed then
            return
        end
    end

    local progressBarData = SvConfig.PorchPirate.glitterBomb.disarmProgressBar
    local finished = lib.callback.await("prp-bridge:progress", src, {
        duration = progressBarData.duration,
        label = progressBarData.text,
        controlDisables = progressBarData.disable,
        canCancel = true,
        animation = {
            animDict = progressBarData.anim.dict,
            animClip = progressBarData.anim.clip,
            animFlag = progressBarData.anim.flag
        }
    })

    if not finished then
        return
    end

    activeBombs[pointId] = nil
    TriggerClientEvent("prp-bridge:notify", src, "info", locale("notifications.porch_pirate.glitterbomb_disarmed"))
    TriggerClientEvent('prp-pettycrime:client:gbResetPoints', -1, { pointId })
end)

CreateThread(function()
    while true do
        Wait(1000 * 60)

        pcall(function()
            resetExpired()
        end)
    end
end)

