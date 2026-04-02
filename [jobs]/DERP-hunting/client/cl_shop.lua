-- ============================
--   SHOP NPC (Shop + Job hub)
-- ============================

local shopNpcEntity = nil

function initShopNPC()
    local cfg = Config.ShopNPC
    if not cfg then return end

    local model = GetHashKey(cfg.model)
    RequestModel(model)
    while not HasModelLoaded(model) do Citizen.Wait(10) end

    local npc = CreatePed(4, model, cfg.coords.x, cfg.coords.y, cfg.coords.z - 1.0, cfg.coords.w, false, true)
    while not DoesEntityExist(npc) do Citizen.Wait(10) end

    shopNpcEntity = npc
    SetEntityAsMissionEntity(npc, true, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    SetPedDiesWhenInjured(npc, false)
    SetEntityInvincible(npc, true)
    FreezeEntityPosition(npc, true)
    SetPedCanRagdoll(npc, false)
    SetModelAsNoLongerNeeded(model)

    if cfg.blip and cfg.blip.show then
        local blip = AddBlipForCoord(cfg.coords.x, cfg.coords.y, cfg.coords.z)
        SetBlipSprite(blip, cfg.blip.sprite)
        SetBlipColour(blip, cfg.blip.color)
        SetBlipScale(blip, cfg.blip.scale)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(cfg.blip.label)
        EndTextCommandSetBlipName(blip)
    end

    Citizen.Wait(100)

    exports['ox_target']:addLocalEntity(npc, {
        {
            label    = cfg.targetLabel,
            icon     = cfg.targetIcon,
            distance = cfg.targetDist,
            onSelect = function()
                -- cl_group.lua handles this
                openNpcMainMenu()
            end,
        }
    })
end

-- Menu shop items (gọi từ cl_group.lua)
function openShopMenu()
    local cfg     = Config.ShopNPC
    local options = {}

    for _, item in ipairs(cfg.items) do
        local itemData = item
        table.insert(options, {
            title       = itemData.label .. '  —  $' .. itemData.price,
            description = itemData.description,
            icon        = 'fas fa-shopping-cart',
            image       = 'nui://ox_inventory/web/images/' .. string.lower(itemData.item) .. '.png',
            onSelect    = function()
                local input = lib.inputDialog('Số lượng mua', {
                    { type = 'number', label = 'Số lượng', required = true, min = 1, max = 100, default = 1 },
                })
                if not input or not input[1] then return end
                local qty = tonumber(input[1])
                if not qty or qty < 1 then return end
                TriggerServerEvent('DERP-hunting:server:buyShopItem', itemData.item, itemData.price, qty)
            end,
        })
    end

    lib.registerContext({
        id      = 'hunting_shop_menu',
        title   = 'Cửa hàng trang bị',
        options = options,
    })
    lib.showContext('hunting_shop_menu')
end

Citizen.CreateThread(function()
    while not LocalPlayer.state.isLoggedIn do
        Citizen.Wait(500)
    end
    Citizen.Wait(1000)
    initShopNPC()
end)