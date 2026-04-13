local onDuty          = false
local isWorking       = false
local textUIShown     = false
local doubleReward    = false
local doubleRewardEnd = 0
local npcEntity       = nil
local zoneId          = nil

local GetEntityCoords       = GetEntityCoords
local PlayerPedId           = PlayerPedId
local IsPedDeadOrDying      = IsPedDeadOrDying
local IsPedInAnyVehicle     = IsPedInAnyVehicle
local IsPedCuffed           = IsPedCuffed
local IsControlJustPressed  = IsControlJustPressed
local RequestAnimDict       = RequestAnimDict
local HasAnimDictLoaded     = HasAnimDictLoaded
local TaskPlayAnim          = TaskPlayAnim
local ClearPedTasks         = ClearPedTasks
local RequestModel          = RequestModel
local HasModelLoaded        = HasModelLoaded
local CreatePed             = CreatePed
local SetEntityHeading      = SetEntityHeading
local FreezeEntityPosition  = FreezeEntityPosition
local SetEntityInvincible   = SetEntityInvincible
local SetBlockingOfNonTemporaryEvents = SetBlockingOfNonTemporaryEvents
local DoesEntityExist       = DoesEntityExist
local DeleteEntity          = DeleteEntity

-- ============================
--   VALIDATION HELPERS
-- ============================

local function canWork()
    local ped = cache.ped
    if IsPedDeadOrDying(ped, false) then return false end
    if IsPedInAnyVehicle(ped, false) then return false end
    if IsPedCuffed(ped) then return false end
    return true
end

local function loadAnimDict(dict)
    if HasAnimDictLoaded(dict) then return end
    RequestAnimDict(dict)
    local t = 0
    while not HasAnimDictLoaded(dict) and t < 50 do
        Wait(100)
        t = t + 1
    end
end

-- ============================
--   ANIM START / STOP
-- ============================

local function playWorkAnim()
    local ped = cache.ped
    local cfg = Config.Anim
    loadAnimDict(cfg.base.dict)
    TaskPlayAnim(ped, cfg.base.dict, cfg.base.anim, 8.0, -8.0, -1, cfg.base.flag, 0, false, false, false)
    Wait(800)
    loadAnimDict(cfg.upper.dict)
    TaskPlayAnim(ped, cfg.upper.dict, cfg.upper.anim, 8.0, -8.0, -1, cfg.upper.flag, 0, false, false, false)
end

local function stopWorkAnim()
    ClearPedTasks(cache.ped)
    ClearPedSecondaryTask(cache.ped)
end

-- ============================
--   MINIGAME
-- ============================

local function triggerMinigame()
    local cfg = Config.Work.minigame
    exports[cfg.export]:key_drop(cfg.params, function(success)
        if success then
            doubleReward    = true
            doubleRewardEnd = GetGameTimer() + Config.Work.doubleRewardDuration
            lib.notify({ title = 'Cắt Giấy', description = 'x2 phần thưởng trong 1 phút!', type = 'success' })
        else
            lib.notify({ title = 'Cắt Giấy', description = 'Thất bại!', type = 'error' })
        end
    end)
end

-- ============================
--   WORK LOOP (progress bar cycle)
-- ============================

local function startWorkLoop()
    isWorking = true
    playWorkAnim()

    if textUIShown then lib.hideTextUI(); textUIShown = false end
    lib.showTextUI(Config.TextUI.stop, { position = 'left-center' })
    textUIShown = true

    local mgCfg        = Config.Work.minigame
    local nextMinigame  = GetGameTimer() + math.random(mgCfg.minDelay, mgCfg.maxDelay)

    CreateThread(function()
        while isWorking do
            if not canWork() then
                stopWork()
                return
            end

            local now = GetGameTimer()

            if doubleReward and now >= doubleRewardEnd then
                doubleReward = false
                lib.notify({ title = 'Cắt Giấy', description = 'Hết hiệu lực x2.', type = 'inform' })
            end

            if now >= nextMinigame then
                triggerMinigame()
                nextMinigame = now + math.random(mgCfg.minDelay, mgCfg.maxDelay)
            end

            if lib.progressBar({
                duration = Config.Work.interval,
                label    = 'Đang cắt giấy...',
                useWhileDead  = false,
                canCancel     = false,
                disable = {
                    move   = true,
                    car    = true,
                    combat = true,
                },
            }) then
                if isWorking and canWork() then
                    if GetResourceState('svc_runtime') == 'started' then
                        exports['svc_runtime']:ExecuteServerEvent('DERP-cutpaper:server:giveItem', doubleReward)
                    else
                        TriggerServerEvent('DERP-cutpaper:server:giveItem', doubleReward)
                    end
                    playWorkAnim()
                end
            else
                stopWork()
                return
            end
        end
    end)
end

function stopWork()
    if not isWorking then return end
    isWorking       = false
    doubleReward    = false
    doubleRewardEnd = 0
    stopWorkAnim()
    if lib.progressActive() then lib.cancelProgress() end
    if textUIShown then lib.hideTextUI(); textUIShown = false end
    if onDuty and zoneId and zoneId:contains(GetEntityCoords(cache.ped)) then
        lib.showTextUI(Config.TextUI.start, { position = 'left-center' })
        textUIShown = true
    end
end

-- ============================
--   ZONE
-- ============================

local function createZone()
    zoneId = lib.zones.sphere({
        coords = Config.Zone.coord,
        radius = Config.Zone.radius,
        debug  = false,
        onEnter = function()
            if onDuty and not isWorking then
                lib.showTextUI(Config.TextUI.start, { position = 'left-center' })
                textUIShown = true
            end
        end,
        onExit = function()
            if isWorking then stopWork() end
            if textUIShown then lib.hideTextUI(); textUIShown = false end
        end,
    })
end

local function removeZone()
    if zoneId then
        zoneId:remove()
        zoneId = nil
    end
end

-- ============================
--   KEY PRESS (G)
-- ============================

CreateThread(function()
    while true do
        if onDuty and zoneId and zoneId:contains(GetEntityCoords(cache.ped)) then
            if IsControlJustPressed(0, 58) then
                if isWorking then
                    stopWork()
                elseif canWork() then
                    local slots = exports.ox_inventory:Search('slots', Config.Work.requiredItem)
                    local hasUsable = false
                    if slots and next(slots) then
                        for _, slot in pairs(slots) do
                            local dur = slot.metadata and slot.metadata.durability
                            if dur == nil or dur > 0 then
                                hasUsable = true
                                break
                            end
                        end
                    end
                    if hasUsable then
                        startWorkLoop()
                    elseif slots and next(slots) then
                        lib.notify({ title = 'Cắt Giấy', description = 'Kéo của bạn đã hỏng.', type = 'error' })
                    else
                        lib.notify({ title = 'Cắt Giấy', description = 'Bạn cần kéo mới có thể cắt.', type = 'error' })
                    end
                end
            end
            Wait(0)
        else
            Wait(500)
        end
    end
end)

-- ============================
--   DUTY TOGGLE
-- ============================

local function toggleDuty()
    if onDuty then
        if isWorking then stopWork() end
        if textUIShown then lib.hideTextUI(); textUIShown = false end
        removeZone()
        onDuty = false
        lib.notify({ title = 'Cắt Giấy', description = 'Đã rời ca.', type = 'inform' })
    else
        onDuty = true
        createZone()
        lib.notify({ title = 'Cắt Giấy', description = 'Đã vào ca.', type = 'success' })
    end
end

-- ============================
--   NPC + TARGET
-- ============================

local function spawnNPC()
    local cfg   = Config.NPC
    local model = joaat(cfg.model)

    RequestModel(model)
    local t = 0
    while not HasModelLoaded(model) and t < 50 do
        Wait(100)
        t = t + 1
    end
    if not HasModelLoaded(model) then return end

    npcEntity = CreatePed(0, model, cfg.coord.x, cfg.coord.y, cfg.coord.z, cfg.coord.w, false, false)
    SetEntityHeading(npcEntity, cfg.coord.w)
    FreezeEntityPosition(npcEntity, cfg.frozen)
    SetEntityInvincible(npcEntity, cfg.invincible)
    SetBlockingOfNonTemporaryEvents(npcEntity, cfg.blockevents)

    local blip = AddBlipForCoord(cfg.coord.x, cfg.coord.y, cfg.coord.z)
    SetBlipSprite(blip, Config.Blip.sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, Config.Blip.scale)
    SetBlipColour(blip, Config.Blip.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(Config.Blip.label)
    EndTextCommandSetBlipName(blip)

    exports.ox_target:addLocalEntity(npcEntity, {
        {
            name     = 'cutpaper_duty',
            icon     = Config.Target.icon,
            label    = Config.Target.onDuty,
            distance = Config.Target.distance,
            canInteract = function()
                return not onDuty
            end,
            onSelect = function()
                toggleDuty()
            end,
        },
        {
            name     = 'cutpaper_offduty',
            icon     = Config.Target.icon,
            label    = Config.Target.offDuty,
            distance = Config.Target.distance,
            canInteract = function()
                return onDuty
            end,
            onSelect = function()
                toggleDuty()
            end,
        },
    })
end

-- ============================
--   INIT + CLEANUP
-- ============================

CreateThread(function()
    while not LocalPlayer.state.isLoggedIn do Wait(500) end
    Wait(1000)
    spawnNPC()
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    if isWorking then stopWork() end
    if textUIShown then lib.hideTextUI() end
    if zoneId then zoneId:remove() end
    if npcEntity and DoesEntityExist(npcEntity) then
        DeleteEntity(npcEntity)
    end
end)