local resourceName = GetCurrentResourceName()
local runtimeTxd = CreateRuntimeTxd(resourceName)
local nextId = 0
local registry = {}

local nuiPrototype = {
    initialized = false,
    id = nil,
    txn = nil,
    coords = nil,
    scale = 1.0,
    aspectRatio = nil,
    attachData = nil,
    dui = nil,
    render = false
}

function nuiPrototype:init(htmlPath, width, height, scale)
    self.scale = scale
    if not self.id then
        nextId = nextId + 1
        self.id = resourceName .. "-" .. math.random(1, 999999) .. "-" .. nextId
    end
    if not self.txn then
        self.txn = ("%s_%s"):format(resourceName, self.id)
    end
    if not self.dui then
        local w = width or 1920
        local h = height or 1080
        self.aspectRatio = w / h
        local duiObj = CreateDui(("https://cfx-nui-%s/%s"):format(resourceName, htmlPath), w, h)
        while true do
            if IsDuiAvailable(duiObj) then
                break
            end
            Wait(10)
        end
        local handle = GetDuiHandle(duiObj)
        CreateRuntimeTextureFromDuiHandle(runtimeTxd, self.txn, handle)
        self.dui = {
            obj = duiObj,
            handle = handle
        }
    end
    self.initialized = true
end

function nuiPrototype:destroy()
    if self.dui then
        DestroyDui(self.dui.obj)
        self.dui = nil
    end
    if self.id then
        for i = #registry, 1, -1 do
            if registry[i].id == self.id then
                table.remove(registry, i)
                break
            end
        end
    end
end

function nuiPrototype:show(coords, scale)
    if coords then
        self.coords = coords
    end
    if scale then
        self.scale = scale
    end
    self.render = true
end

function nuiPrototype:hide()
    self.render = false
end

function nuiPrototype:visible()
    return self.render
end

function nuiPrototype:attach(attachData)
    if attachData then
        if type(attachData) == "table" then
            self.attachData = attachData
        end
    end
    if self.attachData then
        if self.attachData.entity then
            if DoesEntityExist(self.attachData.entity) then
                if self.attachData.boneIndex then
                    self.coords = GetWorldPositionOfEntityBone(self.attachData.entity, self.attachData.boneIndex)
                elseif self.attachData.offset then
                    self.coords = GetOffsetFromEntityInWorldCoords(self.attachData.entity, self.attachData.offset.x, self.attachData.offset.y, self.attachData.offset.z)
                else
                    self.coords = GetEntityCoords(self.attachData.entity)
                end
            end
        else
            if self.coords then
                if self.attachData.offset then
                    self.coords = self.coords + self.attachData.offset
                end
            end
        end
    end
end

function nuiPrototype:detach()
    if self.attachData then
        if self.attachData.entity then
            if DoesEntityExist(self.attachData.entity) then
                self.coords = GetEntityCoords(self.attachData.entity)
            end
        end
        self.attachData = nil
    end
end

function nuiPrototype:msg(payload)
    if self.dui then
        SendDuiMessage(self.dui.obj, json.encode(payload))
    end
end

function create3DNui(htmlPath, width, height, scale)
    local instance = setmetatable({}, { __index = nuiPrototype })
    instance:init(htmlPath, width, height, scale)
    instance.init = nil
    while true do
        if instance.initialized then
            break
        end
        Wait(10)
    end
    registry[#registry + 1] = instance
    return instance
end

CreateThread(function()
    while true do
        if #registry > 0 then
            for i = 1, #registry, 1 do
                local nui = registry[i]
                if nui.render then
                    if nui.attachData then
                        if nui.attachData.entity then
                            if DoesEntityExist(nui.attachData.entity) then
                                if nui.attachData.boneIndex then
                                    nui.coords = GetWorldPositionOfEntityBone(nui.attachData.entity, nui.attachData.boneIndex)
                                elseif nui.attachData.offset then
                                    nui.coords = GetOffsetFromEntityInWorldCoords(nui.attachData.entity, nui.attachData.offset.x, nui.attachData.offset.y, nui.attachData.offset.z)
                                else
                                    nui.coords = GetEntityCoords(nui.attachData.entity)
                                end
                            end
                        end
                    end
                    local playerCoords = GetEntityCoords(PlayerPedId())
                    local distance = #(playerCoords - nui.coords)
                    local markerSize = vec2(nui.scale * nui.aspectRatio, nui.scale) * math.exp(-0.05 * distance)
                    local pos = nui.coords + vec3(0, 0, markerSize.y * 0.5)
                    DrawMarker(43, pos.x, pos.y, pos.z, 0, 0, 0, 90.0, 180.0, 155.0, markerSize.x, markerSize.y, 0.0, 255, 255, 255, 255, false, true, 0, false, resourceName, nui.txn, false)
                end
            end
        else
            Wait(1000)
        end
        Wait(0)
    end
end)

AddEventHandler("onResourceStop", function(stoppedResource)
    if stoppedResource == resourceName then
        for i = 1, #registry, 1 do
            local nui = registry[i]
            nui:destroy()
        end
    end
end)
