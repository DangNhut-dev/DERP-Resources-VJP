local QBCore = exports['qb-core']:GetCoreObject()

-- local function HasArmorVest()
--     local Player = QBCore.Functions.GetPlayerData()
--     local hasVest = QBCore.Functions.HasItem(Config.RequiredVest)
--     return hasVest
-- end

-- local function CanUseArmorType(armorType)
--     local Player = QBCore.Functions.GetPlayerData()
--     local jobName = Player.job.name
    
--     if Config.ArmorPlates[armorType].jobs == nil then
--         return true
--     end
    
--     return Config.ArmorPlates[armorType].jobs[jobName] == true
-- end

local function ApplyArmorPlate(plateType)
    local armorConfig = Config.ArmorPlates[plateType]
    
    -- if not HasArmorVest() then
    --     lib.notify({
    --         title = 'Error',
    --         description = 'You need an armor vest to apply plates!',
    --         type = 'error'
    --     })
    --     return
    -- end
    
    -- if not CanUseArmorType(plateType) then
    --     lib.notify({
    --         title = 'Error',
    --         description = 'You cannot use this type of armor plate!',
    --         type = 'error'
    --     })
    --     return
    -- end
    
    local currentArmor = GetPedArmour(PlayerPedId())
    if currentArmor >= armorConfig.maxArmor then
        lib.notify({
            title = 'Đã hủy',
            description = 'Không còn chỗ để trang bị!',
            type = 'error'
        })
        return
    end
    
    if lib.progressBar({
        duration = armorConfig.useTime,
        label = 'Trang Bị Giáp...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = false,
            move = false,
            combat = true,
        },
        anim = {
            dict = 'clothingshirt',
            clip = 'try_shirt_positive_d',
            flag = 51
        },
    }) then
        local newArmor = math.min(currentArmor + armorConfig.armorIncrease, armorConfig.maxArmor)
        SetPedArmour(PlayerPedId(), newArmor)
        TriggerServerEvent('DERP-armor:server:removePlate', armorConfig.item)
        lib.notify({
            title = 'Hoàn tất',
            description = 'Giáp đã được trang bị.',
            type = 'success'
        })
    else
        lib.notify({
            title = 'Đã hủy',
            description = 'Bạn đã hủy việc trang bị giáp!',
            type = 'error'
        })
    end
end

RegisterNetEvent('DERP-armor:client:useArmor', function(plateType)
    ApplyArmorPlate(plateType)
end)