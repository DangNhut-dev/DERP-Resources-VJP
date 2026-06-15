local vfuel = {}

---@param netId number
---@param amount number
local function setFuel(netId, amount)
    local localVehicle = NetworkGetEntityFromNetworkId(netId)
    if not localVehicle then return end
    
    exports['qb-fuel']:SetFuel(localVehicle, amount)
end
if bridge.name == bridge.currentResource then
    RegisterNetEvent("prp-bridge:client:setFuel", setFuel)
end

return vfuel