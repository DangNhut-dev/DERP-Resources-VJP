local insideZone = false
local textUIShown = false

-- Kiểm tra model hiện tại có phải freemode không
local function IsFreemodeModel()
    return Config.FreemodeModels[GetEntityModel(PlayerPedId())] == true
end

-- Hiện / ẩn textUI
local function ShowTextUI()
    if textUIShown then return end
    textUIShown = true
    lib.showTextUI(Config.TextUILabel)
end

local function HideTextUI()
    if not textUIShown then return end
    textUIShown = false
    lib.hideTextUI()
end

-- Mở clothing shop của illenium
-- isPedMenu = true → bỏ qua kiểm tra tiền, chỉ mở tab components + props
local function OpenClothingMenu()
    TriggerEvent('illenium-appearance:client:openClothingShop', true)
end

-- Tạo zones từ config
local function CreateZones()
    for _, zone in ipairs(Config.Zones) do
        if zone.type == 'sphere' then
            lib.zones.sphere({
                coords  = zone.coords,
                radius  = zone.radius,
                name    = zone.name,
                debug   = false,
                onEnter = function()
                    insideZone = true
                    if not IsFreemodeModel() then
                        ShowTextUI()
                    end
                end,
                onExit  = function()
                    insideZone = false
                    HideTextUI()
                end,
            })

        elseif zone.type == 'box' then
            lib.zones.box({
                coords   = zone.coords,
                size     = zone.size,
                rotation = zone.rotation or 0.0,
                name     = zone.name,
                debug    = false,
                onEnter  = function()
                    insideZone = true
                    if not IsFreemodeModel() then
                        ShowTextUI()
                    end
                end,
                onExit   = function()
                    insideZone = false
                    HideTextUI()
                end,
            })
        end
    end
end

-- Thread xử lý phím [E]
CreateThread(function()
    while true do
        Wait(0)
        if insideZone and not IsFreemodeModel() then
            -- Hiện textUI phòng khi model vừa đổi (ví dụ respawn)
            ShowTextUI()

            if IsControlJustReleased(0, Config.Key) then
                HideTextUI()
                OpenClothingMenu()

                -- Đợi menu đóng xong rồi hiện lại textUI nếu vẫn trong zone
                Wait(500)
                if insideZone and not IsFreemodeModel() then
                    ShowTextUI()
                end
            end
        else
            -- Nếu trong zone nhưng là freemode model thì ẩn
            if insideZone and IsFreemodeModel() then
                HideTextUI()
            end
        end
    end
end)

-- Khởi tạo
CreateThread(function()
    -- Đợi resource load xong
    Wait(1000)
    CreateZones()
end)