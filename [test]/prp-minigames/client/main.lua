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

local gameState = {}
gameState.success = false
gameState.canceled = false
gameState.isPlaying = false
local currentPromise = nil
local currentOptions = nil

local function sendAppEvent(appName, action, payload)
    SendNUIMessage({
        event = "sendAppEvent",
        app = appName,
        action = action,
        payload = payload
    })
end

local function playAnimation(gameName, options)
    local anim = options.animation
    if anim then
        CancelEmote()
        ClearPedTasks(cache.ped)
        if not IsPedInAnyVehicle(cache.ped, true) then
            ClearPedTasksImmediately(cache.ped)
        end
    end
    if options.animation then
        if not options.animation.scenario then
            RequestAnimDict(options.animation.dict)
            while not HasAnimDictLoaded(options.animation.dict) do
                Wait(0)
            end
            TaskPlayAnim(cache.ped, options.animation.dict, options.animation.name, 4.0, 4.0, -1, options.animation.flag, 0, false, false, false)
        elseif options.animation and options.animation.scenario then
            TaskStartScenarioInPlace(cache.ped, options.animation.scenario, 0, true)
        end
    end
end

local function resolveMinigame(result)
    if currentPromise then
        currentPromise:resolve(result)
        currentPromise = nil
    end
    if currentOptions then
        if currentOptions.animation then
            CancelEmote()
            if currentOptions.animation then
                if not currentOptions.animation.scenario then
                    StopAnimTask(cache.ped, currentOptions.animation.dict, currentOptions.animation.name, 1.0)
                else
                    ClearPedTasks(cache.ped)
                end
            end
            if not IsPedInAnyVehicle(cache.ped, true) then
                ClearPedTasksImmediately(cache.ped)
            end
        end
    end
    currentOptions = nil
    gameState.isPlaying = false
end

local function startMinigame(gameName, gameParams, options)
    if gameState.isPlaying then
        return false
    end
    gameState.isPlaying = true
    gameState.success = false
    gameState.canceled = false
    currentOptions = options
    if options then
        playAnimation(gameName, options)
    end
    if not gameParams then
        gameParams = {}
    end
    if gameParams then
        if nil ~= gameParams.cursorX then
            if nil ~= gameParams.cursorY then
                SetCursorLocation(gameParams.cursorX, gameParams.cursorY)
            end
        end
    else
        SetCursorLocation(0.5, 0.5)
    end
    local cursorEnabled = true
    if options then
        if nil ~= options.cursor then
            cursorEnabled = options.cursor
        end
    end
    SetNuiFocus(true, cursorEnabled)
    sendAppEvent(gameName, "setOptions", gameParams)
    SendNUIMessage({
        event = "setCurrentGame",
        game = gameName
    })
    if options then
        if options.onTick then
            Citizen.CreateThread(function()
                while gameState.isPlaying do
                    options.onTick()
                    Citizen.Wait(0)
                end
            end)
        end
    end
    currentPromise = promise.new()
    return Citizen.Await(currentPromise)
end

StartMinigame = startMinigame

local function stopMinigame()
    SetNuiFocus(false, false)
    if gameState.isPlaying then
        SendNUIMessage({
            event = "setCurrentGame",
            game = nil
        })
        gameState.canceled = true
    end
    resolveMinigame(false)
end

StopMinigame = stopMinigame

local function isPlaying()
    return gameState.isPlaying
end

IsPlaying = isPlaying

RegisterNUICallback("setStatus", function(data, cb)
    cb("ok")
    local status = data.status
    SetNuiFocus(false, false)
    gameState.success = status
    gameState.canceled = false
    resolveMinigame(status)
end)

exports("Start", StartMinigame)
exports("Stop", StopMinigame)
exports("IsPlaying", IsPlaying)

RegisterNUICallback("arrowClicker:finishGame", function(data, cb)
    cb("ok")
    TriggerEvent("arrowClicker:onGameFinish", data.gameNumber)
end)

lib.callback.register("prp-minigames:startMinigame", StartMinigame)
RegisterNetEvent("prp-minigames:stopMinigame", StopMinigame)

