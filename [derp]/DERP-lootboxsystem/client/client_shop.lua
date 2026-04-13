local spawnedNPCs = {}
local shopBlips   = {}
local isShopOpen  = false

-- Spawn a single shop NPC and register ox_target interaction
local function SpawnShopNPC(npcId, cfg)
    local model = joaat(cfg.model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(100)
    end

    local ped = CreatePed(4, model,
        cfg.coords.x, cfg.coords.y, cfg.coords.z - 1.0, cfg.coords.w,
        false, true)

    SetEntityHeading(ped, cfg.coords.w)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedDiesWhenInjured(ped, false)
    SetModelAsNoLongerNeeded(model)

    spawnedNPCs[npcId] = ped

    exports.ox_target:addLocalEntity(ped, {
        {
            name     = 'derp_shop_' .. npcId,
            icon     = 'fas fa-shopping-cart',
            label    = 'Mua Hòm',
            distance = 2.5,
            onSelect = function()
                if isShopOpen then return end
                OpenShop(npcId)
            end
        }
    })

    if cfg.blip and cfg.blip.enabled then
        local blip = AddBlipForCoord(cfg.coords.x, cfg.coords.y, cfg.coords.z)
        SetBlipSprite(blip, cfg.blip.sprite)
        SetBlipColour(blip, cfg.blip.color)
        SetBlipScale(blip, cfg.blip.scale)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(cfg.blip.label)
        EndTextCommandSetBlipName(blip)
        shopBlips[npcId] = blip
    end
end

-- Request shop data from server then open NUI
function OpenShop(npcId)
    local npcConfig = Config.Shop.NPCs[npcId]
    lib.callback('derp-lootbox:shop:getShopData', false, function(data)
        if not data then return end
        isShopOpen = true
        SetNuiFocus(true, true)
        SendNUIMessage({
            action         = 'openShop',
            npcId          = npcId,
            items          = data.items,
            playerName     = data.playerName,
            coinBalance    = data.coinBalance,
            cashBalance    = data.cashBalance,
            imagePath      = Config.ImageBox,
            clothesPath    = Config.ImageBasePath,
            defaultPayment = npcConfig and npcConfig.defaultPayment or 'cash',
        })
    end, npcId)
end

-- NUI callback: single item purchase (legacy)
RegisterNUICallback('shopBuy', function(data, cb)
    cb('ok')
    if not data or not data.npcId or not data.itemName
        or not data.amount or not data.paymentType then return end
        if GetResourceState('svc_runtime') == 'started' then
            exports['svc_runtime']:ExecuteServerEvent('derp-lootbox:shop:buyItem', data.npcId, data.itemName, data.amount, data.paymentType)
        else
            TriggerServerEvent('derp-lootbox:shop:buyItem', data.npcId, data.itemName, data.amount, data.paymentType)
        end
end)

-- NUI callback: cart checkout
RegisterNUICallback('shopBuyCart', function(data, cb)
    cb('ok')
    if not data or not data.npcId or not data.cartItems
        or not data.paymentType then return end
    if GetResourceState('svc_runtime') == 'started' then
        exports['svc_runtime']:ExecuteServerEvent('derp-lootbox:shop:buyCart', data.npcId, data.cartItems, data.paymentType)
    else
        TriggerServerEvent('derp-lootbox:shop:buyCart', data.npcId, data.cartItems, data.paymentType)
    end
end)

-- NUI callback: player closed the shop
RegisterNUICallback('shopClose', function(_, cb)
    cb('ok')
    SetNuiFocus(false, false)
    isShopOpen = false
end)

-- Display server purchase result as notification
RegisterNetEvent('derp-lootbox:shop:buyResult', function(success, message)
    lib.notify({
        type        = success and 'success' or 'error',
        description = message
    })
end)

-- Forward updated coin balance to NUI
RegisterNetEvent('derp-lootbox:shop:updateCoin', function(balance)
    SendNUIMessage({ action = 'updateCoin', coinBalance = balance })
end)

RegisterNetEvent('derp-lootbox:shop:updateCash', function(balance)
    SendNUIMessage({ action = 'updateCash', cashBalance = balance })
end)

-- Spawn all configured NPCs on resource start
CreateThread(function()
    for npcId, cfg in pairs(Config.Shop.NPCs) do
        SpawnShopNPC(npcId, cfg)
    end
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    for npcId, ped in pairs(spawnedNPCs) do
        exports.ox_target:removeLocalEntity(ped)
        DeleteEntity(ped)
    end
    for _, blip in pairs(shopBlips) do
        RemoveBlip(blip)
    end
end)