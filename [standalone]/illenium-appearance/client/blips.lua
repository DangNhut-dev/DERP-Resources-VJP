local Blips = {}
local client = client

local function ShowBlip(blipConfig, blip)
    if blip.job and blip.job ~= client.job.name then
        return false
    elseif blip.gang and blip.gang ~= client.gang.name then
        return false
    end

    if Config.RCoreTattoosCompatibility and blip.type == "tattoo" then
        return false
    end

    return (blipConfig.Show and blip.showBlip == nil) or blip.showBlip
end

local function CreateBlip(blipConfig, coords)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, blipConfig.Sprite)
    SetBlipColour(blip, blipConfig.Color)
    SetBlipScale(blip, blipConfig.Scale)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(blipConfig.Name)
    EndTextCommandSetBlipName(blip)
    return blip
end

local function SetupBlips()
    for k, _ in pairs(Config.Stores) do
        local blipConfig = Config.Blips[Config.Stores[k].type]
        if ShowBlip(blipConfig, Config.Stores[k]) then
            local blip = CreateBlip(blipConfig, Config.Stores[k].coords)
            Blips[#Blips + 1] = blip
        end
    end
end

-- Custom Ped Room blips — chỉ hiện khi model không phải freemode
local FreemodeModels = {
    [GetHashKey('mp_m_freemode_01')] = true,
    [GetHashKey('mp_f_freemode_01')] = true,
}

local CustomPedBlips = {}

local function SetupCustomPedBlips()
    if FreemodeModels[GetEntityModel(cache.ped)] then return end

    for _, v in pairs(Config.CustomPedRooms or {}) do
        local blipConfig = Config.Blips['customPedRoom']
        if blipConfig then
            local blip = CreateBlip(blipConfig, v.coords)
            CustomPedBlips[#CustomPedBlips + 1] = blip
        end
    end
end

local function RemoveCustomPedBlips()
    for i = 1, #CustomPedBlips do
        RemoveBlip(CustomPedBlips[i])
    end
    CustomPedBlips = {}
end

-- Theo dõi model thay đổi
CreateThread(function()
    local lastModel = nil
    while true do
        Wait(2000)
        local currentModel = GetEntityModel(cache.ped)
        if currentModel ~= lastModel then
            lastModel = currentModel
            RemoveCustomPedBlips()
            SetupCustomPedBlips()
        end
    end
end)

function ResetBlips()
    if Config.ShowNearestShopOnly then
        return
    end

    for i = 1, #Blips do
        RemoveBlip(Blips[i])
    end
    Blips = {}
    SetupBlips()
end

local function ShowNearestShopBlip()
    for k in pairs(Config.Blips) do
        Blips[k] = 0
    end
    while true do
        local coords = GetEntityCoords(cache.ped)
        for shopType, blipConfig in pairs(Config.Blips) do
            local closest = 1000000
            local closestCoords

            for _, shop in pairs(Config.Stores) do
                if shop.type == shopType and ShowBlip(blipConfig, shop) then
                    local dist = #(coords - vector3(shop.coords.xyz))
                    if dist < closest then
                        closest = dist
                        closestCoords = shop.coords
                    end
                end
            end
            if DoesBlipExist(Blips[shopType]) then
                RemoveBlip(Blips[shopType])
            end

            if closestCoords then
                Blips[shopType] = CreateBlip(blipConfig, closestCoords)
            end
        end
        Wait(Config.NearestShopBlipUpdateDelay)
    end
end

if Config.ShowNearestShopOnly then
    CreateThread(ShowNearestShopBlip)
end
