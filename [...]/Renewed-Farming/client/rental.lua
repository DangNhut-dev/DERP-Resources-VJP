lib.locale()

local Config = require 'shared.Rental'
local utils = require 'client.utils'

local rentalBlip = nil
local rentalPoint = nil
local rentalRouteActive = false
local rentalRouteTimer = nil
local rentalCoords = nil
local rentalName = nil

local function removeRentalBlip()
    if rentalBlip then
        RemoveBlip(rentalBlip)
        rentalBlip = nil
    end
    if rentalPoint then
        rentalPoint:remove()
        rentalPoint = nil
    end
    rentalRouteTimer = nil
    rentalRouteActive = false
    rentalCoords = nil
    rentalName = nil
end

local function drawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

local function createPoint()
    if rentalPoint then return end
    if not rentalCoords then return end

    rentalPoint = lib.points.new({
        coords = rentalCoords,
        distance = 15.0,
    })

    function rentalPoint:nearby()
        DrawMarker(2, self.coords.x, self.coords.y, self.coords.z + 1.2, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.35, 0.35, 0.35, 5, 242, 242, 150, true, true, 2, false, nil, nil, false)
        if self.currentDistance < 5.0 then
            drawText3D(self.coords.x, self.coords.y, self.coords.z + 1.6, "~n~~b~Mảnh đất của bạn")
        end
    end
end

local function removePoint()
    if rentalPoint then
        rentalPoint:remove()
        rentalPoint = nil
    end
end

local function setRouteState(active)
    if not rentalBlip or not rentalCoords then return end

    rentalRouteActive = active

    if active then
        SetBlipRoute(rentalBlip, true)
        SetBlipRouteColour(rentalBlip, Config.plotBlip.color or 2)
        createPoint()
    else
        SetBlipRoute(rentalBlip, false)
        removePoint()
    end

    SendNUIMessage({
        action = 'updateRouteState',
        active = active,
    })
end

local function startAutoOffTimer(seconds)
    local timerId = {}
    rentalRouteTimer = timerId

    CreateThread(function()
        Wait(seconds * 1000)
        if rentalRouteTimer == timerId and rentalRouteActive then
            setRouteState(false)
            rentalRouteTimer = nil
        end
    end)
end

local function createRentalBlip(coords, name, autoShow)
    removeRentalBlip()
    rentalCoords = vec3(coords.x, coords.y, coords.z)
    rentalName = name

    rentalBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(rentalBlip, Config.plotBlip.id)
    SetBlipScale(rentalBlip, Config.plotBlip.scale)
    SetBlipColour(rentalBlip, Config.plotBlip.color)
    SetBlipAsShortRange(rentalBlip, true)
    SetBlipRoute(rentalBlip, false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(name)
    EndTextCommandSetBlipName(rentalBlip)

    if autoShow then
        setRouteState(true)
        startAutoOffTimer(30)
    end
end

CreateThread(function()
    if Config.ped then
        Renewed.addPed({
            model = Config.ped.model or `a_m_m_farmer_01`,
            dist = 300,
            coords = Config.ped.coords.xyz,
            heading = Config.ped.coords.w,
            freeze = true,
            invincible = true,
            tempevents = true,
            id = 'renewed-farming-rental-ped',

            target = {
                {
                    name = 'renewed-farming-rental-ped',
                    icon = 'fas fa-shopping-basket',
                    label = locale('rent_land'),
                    onSelect = function()
                        local data = lib.callback.await('Renewed-Farming:server:getRentalData', false)
                        if not data then return end

                        SendNUIMessage({
                            action = 'openRental',
                            data = data,
                            routeActive = rentalRouteActive,
                        })
                        SetNuiFocus(true, true)
                    end,
                    distance = Config.ped.dist or 2.0,
                },
            }
        })

        if Config.ped.blip then
            utils.addBlip({
                coords = Config.ped.coords.xyz,
                id = Config.ped.blip.id,
                scale = Config.ped.blip.scale,
                color = Config.ped.blip.color,
                name = Config.ped.blip.name,
            })
        end
    end
end)

RegisterNUICallback('rentPlot', function(data, cb)
    local result = lib.callback.await('Renewed-Farming:server:rentPlot', false, data.plotId, data.days, data.payType)
    if result and result.success and result.coords then
        createRentalBlip(result.coords, result.plotName, true)
    end
    cb(result)
end)

RegisterNUICallback('toggleRoute', function(data, cb)
    if not rentalBlip then
        cb({ success = false, active = false })
        return
    end

    rentalRouteTimer = nil

    if rentalRouteActive then
        setRouteState(false)
    else
        setRouteState(true)
        startAutoOffTimer(30)
    end

    cb({ success = true, active = rentalRouteActive })
end)

RegisterNUICallback('closeRental', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

local registerNetEvent = utils.registerNetEvent

registerNetEvent('Renewed-Farming:client:rentalExpired', function(farmId, plotId)
    removeRentalBlip()
    lib.notify({ type = 'error', description = locale('rent_expired') })
end)

registerNetEvent('Renewed-Farming:client:rentalBlip', function(coords, name)
    createRentalBlip(coords, name, false)
end)

CreateThread(function()
    Wait(2000)
    local data = lib.callback.await('Renewed-Farming:server:getRentalData', false)
    if data and data.myRental then
        for _, plot in pairs(data.plots) do
            if plot.id == data.myRental.plot_id and plot.isOwner then
                if plot.coords then
                    createRentalBlip(plot.coords, plot.name, false)
                end
                break
            end
        end
    end
end)