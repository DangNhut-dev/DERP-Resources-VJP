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

local playerHeat = {} 

local function getPlayerHeat(source)
    return playerHeat[source] or 0
end

local function addPlayerHeat(source, amount)
    if not playerHeat[source] then
        playerHeat[source] = 0
    end

    local newAmount = math.min(SvConfig.Heat.max, playerHeat[source] + amount)

    playerHeat[source] = newAmount
end

local function removePlayerHeat(source, amount)
    if not playerHeat[source] then
        return
    end

    local newAmount = math.max(0, playerHeat[source] - amount)

    playerHeat[source] = newAmount
end

local function getPlayerExtraDispatchPercentage(source)
    local heat = getPlayerHeat(source)

    if heat < 1 then
        return 0
    end

    return heat * SvConfig.Heat.dispatchChancePerHeat
end

function HeatAction(source, id, coords)
    local dispatch = SvConfig.DispatchAlerts[id]
    if not dispatch then
        lib.print.debug("No dispatch data found for heat action", id)
        return
    end

    addPlayerHeat(source, dispatch.heatPerAction)

    local totalPercentage = getPlayerExtraDispatchPercentage(source)
    if math.random(1, SvConfig.Heat.max) > totalPercentage then
        return
    end

    bridge.dispatch.sendAlert(
        source,
        dispatch.jobs,
        coords,
        {
            code = dispatch.code,
            title = dispatch.title,
            description = dispatch.description,
        },
        {
            sprite = dispatch.blip.sprite,
            scale = dispatch.blip.scale,
            colour = dispatch.blip.colour,
            length = dispatch.blip.duration
        }
    )
end

CreateThread(function()
    while true do
        Wait(SvConfig.Heat.resetInterval * 1000)

        for playerId, _ in pairs(playerHeat) do
            removePlayerHeat(playerId, SvConfig.Heat.degradePerMinute)
        end
    end
end)

