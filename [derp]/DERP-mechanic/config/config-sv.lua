---@param orderId integer
---@param mechanicId string
---@param plate string
---@param cart table
---@param cartTotal number
---@param cartProps table
---@param paymentMethod string
RegisterNetEvent("DERP-mechanic:server:order-placed-config", function(orderId, mechanicId, plate, cart, cartTotal, cartProps, paymentMethod)
  local mechanic = Config.MechanicLocations[mechanicId]
  local src = source
end)