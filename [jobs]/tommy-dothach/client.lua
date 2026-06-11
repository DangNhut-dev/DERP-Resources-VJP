local isProcessing = false

local RequestAnimDict = RequestAnimDict
local HasAnimDictLoaded = HasAnimDictLoaded
local TaskPlayAnim = TaskPlayAnim
local StopAnimTask = StopAnimTask
local PlayerPedId = PlayerPedId

local function loadAnimDict(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(10)
        end
    end
end

local function playAnim(dict, anim)
    loadAnimDict(dict)
    TaskPlayAnim(PlayerPedId(), dict, anim, 8.0, -8.0, -1, 1, 0, false, false, false)
end

local function stopAnim(dict, anim)
    StopAnimTask(PlayerPedId(), dict, anim, 3.0)
end

local function getStoneList(cb)
    lib.callback('tommy-dothach:getPlayerStones', false, function(stones)
        cb(stones)
    end)
end

local function buildStoneOptions(stones, action)
    table.sort(stones, function(a, b)
        local function grindOrder(s)
            if not s.polished then return 0 end
            return s.grindCount or 1
        end
        return grindOrder(a) < grindOrder(b)
    end)
    local options = {}
    for _, stone in ipairs(stones) do
        local label
        if stone.polished then
            local g = stone.grindCount or 0
            local grindText
            if g == 1 then
                grindText = 'Đã kiểm định 1 lần'
            else
                grindText = 'Đã kiểm định 2 lần'
            end
            label = ('Viên đá | Màu: %s | Vân: %s | Tinh khiết: %s | %s'):format(
                stone.color, stone.vein, stone.purity, grindText
            )
        else
            label = 'Viên đá thô | Chưa kiểm định'
        end
        options[#options + 1] = {
            title = label,
            onSelect = function()
                action(stone.slot)
            end,
        }
    end
    return options
end

local function doGrind(slot)
    if isProcessing then return end
    isProcessing = true

    local animDict = "missmechanic"
    local animName = "work2_base"

    playAnim(animDict, animName)

    lib.callback('tommy-dothach:getSlotMeta', false, function(isPolished, grindCount)
        if grindCount and grindCount >= 2 then
            stopAnim(animDict, animName)
            isProcessing = false
            lib.notify({ title = 'Đổ Thạch', description = 'Viên đá này đã được kiểm định tối đa 2 lần.', type = 'error' })
            return
        end

        local duration = isPolished and Config.ProgressTime.grind_reroll or Config.ProgressTime.grind_first
        local labelText
        if not isPolished then
            labelText = 'Đang kiểm định đá lần 1/2...'
        else
            labelText = ('Đang kiểm định lại đá lần %d/2...'):format((grindCount or 0) + 1)
        end

        local ok = lib.progressBar({
            duration = duration,
            label = 'Đang kiểm định đá...',
            useWhileDead = false,
            canCancel = true,
            disable = { move = true, car = true, combat = true },
        })

        stopAnim(animDict, animName)
        isProcessing = false

        if ok then
            TriggerServerEvent('tommy-dothach:grindStone', slot)
        end
    end, slot)
end

local function doCut(slot)
    if isProcessing then return end
    isProcessing = true

    local animDict = "anim@heists@fleeca_bank@drilling"
    local animName = "drill_straight_fail"

    playAnim(animDict, animName)

    local ok = lib.progressBar({
        duration = Config.ProgressTime.cut,
        label = 'Đang cắt đá...',
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
    })

    stopAnim(animDict, animName)
    isProcessing = false

    if ok then
        TriggerServerEvent('tommy-dothach:cutStone', slot)
    end
end

local function openGrindMenu()
    getStoneList(function(stones)
        if not stones or #stones == 0 then
            lib.notify({ title = 'Đổ Thạch', description = 'Bạn không có đá nào.', type = 'error' })
            return
        end

        local options = buildStoneOptions(stones, doGrind)
        lib.registerContext({
            id = 'dothach_grind_menu',
            title = 'Chọn Viên Đá Để Kiểm định',
            options = options,
        })
        lib.showContext('dothach_grind_menu')
    end)
end

local function openCutMenu()
    getStoneList(function(stones)
        if not stones or #stones == 0 then
            lib.notify({ title = 'Đổ Thạch', description = 'Bạn không có đá nào.', type = 'error' })
            return
        end

        local polishedStones = {}
        for _, stone in ipairs(stones) do
            if stone.polished then
                polishedStones[#polishedStones + 1] = stone
            end
        end

        if #polishedStones == 0 then
            lib.notify({ title = 'Đổ Thạch', description = 'Không có viên đá nào đã được kiểm định.', type = 'error' })
            return
        end

        local options = buildStoneOptions(polishedStones, doCut)
        lib.registerContext({
            id = 'dothach_cut_menu',
            title = 'Chọn Viên Đá Để Cắt',
            options = options,
        })
        lib.showContext('dothach_cut_menu')
    end)
end

for _, loc in ipairs(Config.GrindLocations) do
    exports.ox_target:addSphereZone({
        coords = loc.coords,
        radius = Config.TargetRadius,
        debug = false,
        options = {
            {
                label = 'Kiểm định Đá',
                icon = 'fas fa-hammer',
                onSelect = openGrindMenu,
            },
        },
    })
end

for _, loc in ipairs(Config.CutLocations) do
    exports.ox_target:addSphereZone({
        coords = loc.coords,
        radius = Config.TargetRadius,
        debug = false,
        options = {
            {
                label = 'Cắt Đá',
                icon = 'fas fa-cut',
                onSelect = openCutMenu,
            },
        },
    })
end

RegisterNetEvent('tommy-dothach:notify', function(data)
    lib.notify(data)
end)

local guideOpen = false

local function spawnGuideNpc()
    local model = joaat('s_m_y_dealer_01')
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end

    local ped = CreatePed(4, model, 2434.09, 1516.13, 38.89, 358.85, false, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)
    SetModelAsNoLongerNeeded(model)

    exports.ox_target:addLocalEntity(ped, {
        {
            label = 'Hỏi về Đổ Thạch',
            icon  = 'fas fa-book-open',
            onSelect = function()
                if guideOpen then return end
                guideOpen = true
                SetNuiFocus(true, true)
                SendNUIMessage({ action = 'openGuide' })
            end,
        },
    })
end

RegisterNUICallback('closeGuide', function(_, cb)
    guideOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

CreateThread(spawnGuideNpc)