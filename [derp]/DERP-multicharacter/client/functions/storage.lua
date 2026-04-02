--[[
    ╔═══════════════════════════════════════════════════════════════╗
    ║ 🔓 DECRYPTED & FIXED BY RIP_BYTECODE 🔓                       ║
    ║    💀 R.I.P ESCROW • discord.gg/buwp9gDp6v • 2024 💀          ║
    ╚═══════════════════════════════════════════════════════════════╝
]]--

Storage = {
    Data = false
}

-- Set storage data
function Storage.Set(data)
    debugPrint("Storage has been set")
    
    if Config.DebugStorageData then
        debugPrint("[OUTPUT OF STORAGE DATA]")
        print(json.encode(data))
    end
    
    Storage.Data = data
    Storage.Send()
end

-- Get storage data
function Storage.Get(key)
    if key == nil then
        return Storage.Data
    end
    
    return Storage.Data[key]
end

-- Send storage data to filters and cameras
function Storage.Send()
    Filters.Data.filter = Storage.Data.userSettings.filters.name
    Filters.Data.strength = Storage.Data.userSettings.filters.value
    Cameras.Data.Anim = Storage.Data.userSettings.cameras
end
