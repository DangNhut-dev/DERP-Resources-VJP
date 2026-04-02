-- client.lua (Qbox)

local PlayerData  = {}
local isMenuOpen  = false

-- ==================== PLAYER EVENTS ====================

AddEventHandler('qbx_core:client:onPlayerLoaded', function()
    PlayerData = exports.qbx_core:GetPlayerData()
end)

AddEventHandler('qbx_core:client:onJobUpdate', function(jobInfo)
    PlayerData.job = jobInfo
end)


-- ==================== ANIMATION ====================

local notepadProp      = nil
local penProp          = nil
local isPlayingAnimation = false

local function PlayWritingAnimation()
    local ped = PlayerPedId()

    RequestAnimDict('amb@medic@standing@timeofdeath@base')
    while not HasAnimDictLoaded('amb@medic@standing@timeofdeath@base') do Wait(100) end

    RequestModel('prop_notepad_01')
    while not HasModelLoaded('prop_notepad_01') do Wait(100) end

    RequestModel('prop_pencil_01')
    while not HasModelLoaded('prop_pencil_01') do Wait(100) end

    TaskPlayAnim(ped, 'amb@medic@standing@timeofdeath@base', 'base', 8.0, 8.0, -1, 49, 0, false, false, false)

    local coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.0, 0.0)

    notepadProp = CreateObject(GetHashKey('prop_notepad_01'), coords.x, coords.y, coords.z, true, true, true)
    AttachEntityToEntity(notepadProp, ped, GetPedBoneIndex(ped, 18905), 0.1, 0.02, 0.03, -5.0, 0.0, 0.0, true, true, false, true, 1, true)

    penProp = CreateObject(GetHashKey('prop_pencil_01'), coords.x, coords.y, coords.z, true, true, true)
    AttachEntityToEntity(penProp, ped, GetPedBoneIndex(ped, 57005), 0.09, 0.04, 0.01, -90.0, 0.0, 0.0, true, true, false, true, 1, true)

    isPlayingAnimation = true
end

local function StopAnimation()
    if not isPlayingAnimation then return end
    ClearPedTasks(PlayerPedId())
    if notepadProp then DeleteEntity(notepadProp) notepadProp = nil end
    if penProp     then DeleteEntity(penProp)     penProp     = nil end
    isPlayingAnimation = false
end

-- ==================== OPEN MENU ====================

local function OpenBillingMenu()
    if isMenuOpen then return end

    lib.callback('tommy-billing:server:getUIData', false, function(uiData)
        if not uiData then return end

        if uiData.canCreateBill then
            lib.callback('tommy-billing:server:getNearbyPlayers', false, function(nearbyPlayers)
                PlayWritingAnimation()
                isMenuOpen = true
                SetNuiFocus(true, true)
                SendNUIMessage({ action = 'openMenu', uiData = uiData, nearbyPlayers = nearbyPlayers or {} })
            end)
        else
            PlayWritingAnimation()
            isMenuOpen = true
            SetNuiFocus(true, true)
            SendNUIMessage({ action = 'openMenu', uiData = uiData, nearbyPlayers = {} })
        end
    end)
end

-- ==================== RADIAL MENU ====================

local function AddRadialOption()
    exports.ox_lib:addRadialItem({
        {
            id       = 'billing_menu',
            label    = 'Hóa Đơn',
            icon     = 'file-invoice-dollar',
            onSelect = function()
                TriggerEvent('tommy-billing:client:openMenu')
            end
        }
    })
end

CreateThread(function()
    Wait(1000)
    PlayerData = exports.qbx_core:GetPlayerData()
    AddRadialOption()
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    Wait(1000)
    PlayerData = exports.qbx_core:GetPlayerData()
    AddRadialOption()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    exports.ox_lib:removeRadialItem('billing_menu')
    StopAnimation()
    SetNuiFocus(false, false)
end)

-- ==================== CLIENT EVENTS ====================

RegisterNetEvent('tommy-billing:client:openMenu', function()
    OpenBillingMenu()
end)

RegisterNetEvent('tommy-billing:client:newBillReceived', function(data)
    Wait(500)
    OpenBillingMenu()
end)

RegisterNetEvent('tommy-billing:client:refreshBills', function()
    if isMenuOpen then
        SendNUIMessage({ action = 'refreshBills' })
    end
end)

-- ==================== NUI CALLBACKS ====================

RegisterNUICallback('closeMenu', function(data, cb)
    isMenuOpen = false
    SetNuiFocus(false, false)
    StopAnimation()
    cb('ok')
end)

RegisterNUICallback('notify', function(data, cb)
    lib.notify({ description = data.message, type = data.type })
    cb('ok')
end)

RegisterNUICallback('getPendingBills', function(data, cb)
    lib.callback('tommy-billing:server:getPendingBills', false, function(bills, total)
        cb({ bills = bills, total = total })
    end, data.page or 1)
end)

RegisterNUICallback('getMyHistory', function(data, cb)
    lib.callback('tommy-billing:server:getMyHistory', false, function(bills, total)
        cb({ bills = bills, total = total })
    end, data.page or 1)
end)

RegisterNUICallback('getMyCreatedBills', function(data, cb)
    lib.callback('tommy-billing:server:getMyCreatedBills', false, function(bills, total)
        cb({ bills = bills, total = total })
    end, data.page or 1)
end)

RegisterNUICallback('getCompanyBills', function(data, cb)
    lib.callback('tommy-billing:server:getCompanyBills', false, function(bills, total, stats)
        cb({ bills = bills, total = total, stats = stats })
    end, data.page or 1)
end)

RegisterNUICallback('getNearbyPlayers', function(data, cb)
    lib.callback('tommy-billing:server:getNearbyPlayers', false, function(players)
        cb(players or {})
    end)
end)

RegisterNUICallback('createBill', function(data, cb)
    TriggerServerEvent('tommy-billing:server:createBill', data)
    cb('ok')
end)

RegisterNUICallback('payBill', function(data, cb)
    TriggerServerEvent('tommy-billing:server:payBill', data.billId)
    cb('ok')
end)

RegisterNUICallback('rejectBill', function(data, cb)
    TriggerServerEvent('tommy-billing:server:rejectBill', data.billId)
    cb('ok')
end)

RegisterNUICallback('cancelBill', function(data, cb)
    TriggerServerEvent('tommy-billing:server:cancelBill', data.billId, data.reason)
    cb('ok')
end)

-- ==================== DEBUG ====================

if Config.DebugMode then
    RegisterCommand('billdebug', function()
        OpenBillingMenu()
    end, false)
end