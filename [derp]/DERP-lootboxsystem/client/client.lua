local isUIOpen   = false
local currentBox = nil

CreateThread(function()
    while true do
        Wait(0)
        if isUIOpen then
            DisableControlAction(0, 30, true)
            DisableControlAction(0, 31, true)
            DisableControlAction(0, 21, true)
            DisableControlAction(0, 22, true)
        end
    end
end)

RegisterNetEvent('derp-lootbox:useItem', function(data, item)
    if isUIOpen then return end

    currentBox = item.name
    isUIOpen   = true

    SetNuiFocus(true, true)

    SendNUIMessage({
        action    = 'showPreview',
        boxType   = item.name,
        boxLabel  = Config.Lootboxes[item.name] and Config.Lootboxes[item.name].label or item.name,
        imagePath = Config.ImageBox
    })
end)

RegisterNUICallback('confirmOpen', function(_, cb)
    cb('ok')
    if not currentBox then return end
    TriggerServerEvent('derp-lootbox:openBox', currentBox)
end)

RegisterNetEvent('derp-lootbox:notify', function(data)
    lib.notify(data)
    SendNUIMessage({ action = 'closeUI' })
    SetNuiFocus(false, false)
    isUIOpen   = false
    currentBox = nil
end)

RegisterNUICallback('closePreview', function(_, cb)
    cb('ok')
    SetNuiFocus(false, false)
    isUIOpen   = false
    currentBox = nil
end)

RegisterNetEvent('derp-lootbox:startUI', function(data)
    SendNUIMessage({
        action       = 'startSpin',
        winningItem  = data.winningItem,
        items        = data.items,
        imagePath    = Config.ImageBox,
        clothPath    = Config.ImageBasePath,
        rarityColors = data.rarityColors
    })
end)

RegisterNetEvent('derp-lootbox:afterClaim', function(hasMore)
    if hasMore then
        SendNUIMessage({
            action    = 'showPreview',
            boxType   = currentBox,
            boxLabel  = Config.Lootboxes[currentBox] and Config.Lootboxes[currentBox].label or currentBox,
            imagePath = Config.ImageBox
        })
    else
        SendNUIMessage({ action = 'closeUI' })
        SetNuiFocus(false, false)
        isUIOpen   = false
        currentBox = nil
    end
end)

RegisterNUICallback('spinDone', function(_, cb)
    cb('ok')
    TriggerServerEvent('derp-lootbox:claimReward')
end)

RegisterNUICallback('closeUI', function(_, cb)
    cb('ok')
    SetNuiFocus(false, false)
    isUIOpen   = false
    currentBox = nil
end)

RegisterNUICallback('confirmOpenMulti', function(_, cb)
    cb('ok')
    if not currentBox then return end
    TriggerServerEvent('derp-lootbox:openBoxMulti', currentBox)
end)

RegisterNetEvent('derp-lootbox:startUIMulti', function(data)
    SendNUIMessage({
        action       = 'startMultiSpin',
        winners      = data.winners,
        items        = data.items,
        imagePath    = Config.ImageBox,
        clothPath    = Config.ImageBasePath,
        rarityColors = data.rarityColors
    })
end)

RegisterNUICallback('spinDoneMulti', function(_, cb)
    cb('ok')
    TriggerServerEvent('derp-lootbox:claimRewardMulti')
end)