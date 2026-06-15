local hiddenShopCoords = vector3(876.37, -1353.16, 25.32)
local hiddenShopHeading = 3.31
local npcModel = `s_m_y_dealer_01`
local hiddenShopZone = nil

CreateThread(function()
    exports["prp-bridge"]:AddPedInteraction("prp-pettycrime-hiddenshop", {
        model = npcModel,
        coords = hiddenShopCoords,
        heading = hiddenShopHeading,
        radius = 50.0,
        options = {}
    })

    hiddenShopZone = exports.ox_target:addBoxZone({
        coords = hiddenShopCoords + vector3(0.0, 0.0, 0.9),
        size = vec3(1.2, 1.2, 2.0),
        rotation = hiddenShopHeading,
        debug = Config.Debug,
        options = {
            {
                name = "hidden_weapon_shop",
                icon = "fas fa-store",
                label = "Cửa hàng vũ khí ẩn (Black Market)",
                onSelect = function()
                    exports.ox_inventory:openInventory('shop', { type = 'HiddenWeaponShop' })
                end,
                distance = 2.0
            }
        }
    })

    if Config.Debug then
        TriggerEvent("prp-pettycrime:client:registerDebugCoords", "hiddenshop", hiddenShopCoords, "Hidden Shop (Black Market)")
    end
end)

RegisterNetEvent("prp-pettycrime:client:useHintNote", function()
    SetNewWaypoint(hiddenShopCoords.x, hiddenShopCoords.y)
    bridge.fw.notify("info", "Đã đánh dấu vị trí gợi ý trên bản đồ GPS của bạn.")
end)

AddEventHandler("onResourceStop", function(resourceName)
    if cache.resource ~= resourceName then return end
    exports["prp-bridge"]:RemovePedInteraction("prp-pettycrime-hiddenshop")
    if hiddenShopZone then
        exports.ox_target:removeZone(hiddenShopZone)
    end
    if Config.Debug then
        TriggerEvent("prp-pettycrime:client:removeDebugCoords", "hiddenshop")
    end
end)
