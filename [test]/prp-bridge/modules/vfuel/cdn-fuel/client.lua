local vfuel = {}

---@param netId number
---@param amount number
local function setFuel(netId, amount)
    local localVehicle = NetworkGetEntityFromNetworkId(netId)
    if not localVehicle then return end
    
    SetVehicleFuelLevel(localVehicle, amount + 0.0)
    DecorSetFloat(localVehicle, "_FUEL_LEVEL", GetVehicleFuelLevel(localVehicle))
end
if bridge.name == bridge.currentResource then
    RegisterNetEvent("prp-bridge:client:setFuel", setFuel)
end

return vfuel