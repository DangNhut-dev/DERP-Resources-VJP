--[[
    ╔═══════════════════════════════════════════════════════════════╗
    ║ 🔓 DECRYPTED & FIXED BY RIP_BYTECODE 🔓                       ║
    ║    💀 R.I.P ESCROW • discord.gg/buwp9gDp6v • 2024 💀          ║
    ╚═══════════════════════════════════════════════════════════════╝
]]--

Buckets = {}
Buckets.LoggedOffPlayer = function(src)
    debugPrint('Player ['..src..'] ('..GetPlayerName(src)..') is in Multicharacter bucket.')
    SetPlayerRoutingBucket(src, src)
    SetRoutingBucketPopulationEnabled(src, Config.Buckets.PopulationEnabled)
    SetPlayerInvincible(src, true)
end

Buckets.LoggedInPlayer = function(src)
    debugPrint('Player ['..src..'] ('..GetPlayerName(src)..') is no longer in Multicharacter bucket.')
    SetPlayerRoutingBucket(src, 0)
    SetPlayerInvincible(src, false)
end

RegisterNetEvent('DERP-multicharacter:Event:SetPlayerState')
AddEventHandler('DERP-multicharacter:Event:SetPlayerState', function(state)
    Player(source).state:set('isInMulticharacter', state == 'LOG_OFF_USER', true)
    if state == 'LOG_OFF_USER' then
        Buckets.LoggedOffPlayer(source)
    elseif state == 'LOG_IN_USER' then
        Buckets.LoggedInPlayer(source)
    end
end)  

