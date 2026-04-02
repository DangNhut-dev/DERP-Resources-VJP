--[[
    ╔═══════════════════════════════════════════════════════════════╗
    ║ 🔓 DECRYPTED & FIXED BY RIP_BYTECODE 🔓                       ║
    ║    💀 R.I.P ESCROW • discord.gg/buwp9gDp6v • 2024 💀          ║
    ╚═══════════════════════════════════════════════════════════════╝
]]--

-- Dispatch services to disable (1-15)
local dispatchServices = {
    false, -- 1: Police Automobile
    false, -- 2: Police Helicopter
    false, -- 3: Fire Department
    false, -- 4: SWAT Automobile
    false, -- 5: Ambulance
    false, -- 6: Police Riders
    false, -- 7: Police Vehicle Request
    false, -- 8: Police Road Block
    false, -- 9: Police Automobile Wait Pulled Over
    false, -- 10: Police Automobile Wait Cruising
    false, -- 11: Gang Members
    false, -- 12: SWAT Helicopter
    false, -- 13: Police Boat
    false, -- 14: Army Vehicle
    false  -- 15: Biker Backup
}

-- Disable all dispatch services and wanted level
function DisableDispatch()
    for serviceId, enabled in ipairs(dispatchServices) do
        EnableDispatchService(serviceId, enabled)
    end
    
    SetMaxWantedLevel(0)
end
