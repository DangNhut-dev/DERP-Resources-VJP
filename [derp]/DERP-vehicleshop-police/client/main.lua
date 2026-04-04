local npcEntities = {}
local lastInteraction = 0
local currentDealerIndex = nil
local PlayerData = {}

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = exports.qbx_core:GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(jobInfo)
    PlayerData.job = jobInfo
end)

local function LoadModel(model)
    if HasModelLoaded(model) then return true end

    RequestModel(model)
    local timeout = 100
    while not HasModelLoaded(model) and timeout > 0 do
        Wait(50)
        timeout = timeout - 1
    end

    if not HasModelLoaded(model) then
        SetModelAsNoLongerNeeded(model)
        return false
    end

    return true
end

local function FormatMoney(amount)
    local formatted = tostring(amount)
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1.%2')
        if k == 0 then break end
    end
    return formatted
end

local function createDealerNPCs()
    for i, dealer in ipairs(Config.Dealers) do
        if dealer.npc and dealer.npc.model then
            local model = GetHashKey(dealer.npc.model)
            
            if not LoadModel(model) then
                print(("^1[DERP-VehicleShop] Failed to load NPC model: %s^0"):format(dealer.npc.model))
                goto continue
            end

            local npc = CreatePed(4, model, dealer.npc.coords.x, dealer.npc.coords.y, dealer.npc.coords.z - 1.0, dealer.npc.coords.w, false, true)
            
            SetEntityAsMissionEntity(npc, true, true)
            SetEntityInvincible(npc, true)
            SetBlockingOfNonTemporaryEvents(npc, true)
            FreezeEntityPosition(npc, true)

            exports.ox_target:addLocalEntity(npc, {
                {
                    name = 'vehicle_shop_' .. i,
                    label = dealer.name,
                    icon = 'fa-solid fa-car',
                    distance = 2.5,
                    onSelect = function()
                        local now = GetGameTimer()
                        if now - lastInteraction < (Config.Cooldown or 2000) then return end
                        lastInteraction = now

                        currentDealerIndex = i
                        TriggerServerEvent('DERP-vehicleshop:server:openMenu', i)
                    end
                }
            })

            npcEntities[i] = npc
            SetModelAsNoLongerNeeded(model)

            ::continue::
        end
    end
end

local function deleteNPCs()
    for i, npc in ipairs(npcEntities) do
        if DoesEntityExist(npc) then
            exports.ox_target:removeLocalEntity(npc, 'vehicle_shop_' .. i)
            DeleteEntity(npc)
        end
    end
    npcEntities = {}
end

RegisterNetEvent('DERP-vehicleshop:client:openMenu', function(vehicles, dealerName)
    local options = {}

    for _, vehicle in ipairs(vehicles) do
        local statusText = ""
        local isDisabled = false

        if not vehicle.canBuy then
            if vehicle.minGrade then
                statusText = " (Yêu cầu Grade " .. vehicle.minGrade .. " trở lên)"
            else
                statusText = " (Đã mua)"
            end
            isDisabled = true
        end

        table.insert(options, {
            title = vehicle.label,
            description = ("Giá: $%s%s"):format(FormatMoney(vehicle.price), statusText),
            icon = 'fa-solid fa-car',
            onSelect = function()
                if currentDealerIndex and not isDisabled then
                    local alert = lib.alertDialog({
                        header = 'Xác nhận mua xe',
                        content = ('Bạn có chắc muốn mua **%s** với giá **$%s**?'):format(vehicle.label, FormatMoney(vehicle.price)),
                        centered = true,
                        cancel = true,
                        labels = {
                            confirm = 'Mua',
                            cancel = 'Hủy',
                        },
                    })

                    if alert == 'confirm' then
                        TriggerServerEvent('DERP-vehicleshop:server:buyVehicle', currentDealerIndex, vehicle.model)
                    end
                end
            end,
            disabled = isDisabled
        })
    end

    if #options == 0 then
        lib.notify({
            type = 'inform',
            description = 'Không có xe nào khả dụng!',
            duration = 3000
        })
        return
    end

    lib.registerContext({
        id = 'vehicle_shop_menu',
        title = dealerName,
        options = options
    })

    lib.showContext('vehicle_shop_menu')
end)

RegisterNetEvent('DERP-vehicleshop:client:spawnVehicle', function(vehicleModel, plate, spawnPoint, dealerIndex)
    local model = GetHashKey(vehicleModel)

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(50)
    end

    local vehicle = CreateVehicle(model, spawnPoint.x, spawnPoint.y, spawnPoint.z, spawnPoint.w, true, true)

    while not DoesEntityExist(vehicle) do
        Wait(10)
    end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    SetNetworkIdCanMigrate(netId, true)
    SetNetworkIdExistsOnAllMachines(netId, true)
    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetVehicleNeedsToBeHotwired(vehicle, false)
    SetVehicleNumberPlateText(vehicle, plate)
    SetVehicleFuelLevel(vehicle, 100.0)
    SetVehicleDirtLevel(vehicle, 0.0)
    Entity(vehicle).state:set('fuel', 100.0, true)
    SetModelAsNoLongerNeeded(model)
    TriggerEvent('qb-vehiclekeys:client:AddKeys', plate)

    -- Spawn xong mới báo server trừ tiền
    TriggerServerEvent('DERP-vehicleshop:server:confirmPurchase', dealerIndex, vehicleModel, plate)
end)

CreateThread(function()
    while not exports.ox_target do
        Wait(100)
    end

    Wait(1000)

    createDealerNPCs()
    -- print("^2[DERP-VehicleShop] ^7Client đã sẵn sàng!")
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        deleteNPCs()
    end
end)