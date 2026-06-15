
local vfuel = {}

---@param source number
---@param vehicle number
---@param amount number
---@return boolean
function vfuel.set(source, vehicle, amount)
    exports["lc_fuel"]:SetFuel(vehicle, amount)
    
    return true
end

return vfuel