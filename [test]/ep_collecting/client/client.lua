local itemZones, spawnedProps = {}, {}

local function tableSize(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

local function getRandomPointInBox(_coords, _size)
    local coords = vector3(_coords.x,_coords.y,_coords.z)
    local size = _size / 2
    local rotation = tonumber(_coords.w) or 0
    local x = coords.x + math.random(math.floor(-size.x), math.floor(size.x))
    local y = coords.y + math.random(math.floor(-size.y), math.floor(size.y))
    local z = coords.z + math.random(math.floor(-size.z), math.floor(size.z))
    local radian = math.rad(rotation)
    local sin = math.sin(radian)
    local cos = math.cos(radian)
    local xOffset = x - coords.x
    local yOffset = y - coords.y
    x = coords.x + (xOffset * cos - yOffset * sin)
    y = coords.y + (yOffset * cos + xOffset * sin)
    return vec3(x, y, z)
end

local function spawnitems(zone)
    if not itemZones[zone].items then return end
    for _,v in pairs(itemZones[zone].items) do
        local prop = CreateObject(v.model, v.coords.x, v.coords.y, v.coords.z, false, false, false)
        while not DoesEntityExist(prop) do Wait(100) end
        PlaceObjectOnGroundProperly(prop)
        FreezeEntityPosition(prop, true)
        local propTarget = exports.ox_target:addLocalEntity(prop, {
            {
                icon = 'fas fa-shopping-basket',
                label = v.name,
                onSelect = v?.onSelect,
                distance = 2.0
            }
		})

        spawnedProps[prop] = {
            target = propTarget,
            id = v.id,
            zone = zone,
            coords = v.coords,
            model = v.model,
            name = v.name,
            max = v.max,
            loot = v.loot
        }
    end
end

local function removeitems(zone)
    for k,v in pairs(spawnedProps) do
        if v.zone == zone then
            if DoesEntityExist(k) then
                DeleteEntity(k)
                spawnedProps[k] = nil
            end
        end
    end
end

local function exitCropPlot(data)
    removeitems(data.name)
end

local function enterCropPlot(data)
    spawnitems(data.name)
end

CreateThread(function()
    for _,v in pairs(Config.Zones) do
        itemZones[v.name] = {
            items = {},
            Zone = nil
        }
        for i=1,v.maxItems do
            local randomItem = math.random(1, tableSize(v.items))
            itemZones[v.name].items[#itemZones[v.name].items + 1] = {
                id = i,
                coords = getRandomPointInBox(v.coords, v.size),
                model = v.items[randomItem].model,
                name = v.items[randomItem].name,
                onSelect = v.items[randomItem].onSelect,
            }
        end
        itemZones[v.name].Zone = lib.zones.box({
            coords = vector3(v.coords.x,v.coords.y,v.coords.z),
            size = v.size,
            name = v.name,
            rotation = v.coords.w,
            drawSprite = false,
            debug = Config.Debug,
            onEnter = enterCropPlot,
            onExit = exitCropPlot
        })
        Wait(25)
    end
end)

AddEventHandler('onResourceStop', function(name)
	if name == GetCurrentResourceName() then
        for k,_ in pairs(spawnedProps) do
            if DoesEntityExist(k) then
                DeleteEntity(k)
                spawnedProps[k] = nil
            end
        end
	end
end)