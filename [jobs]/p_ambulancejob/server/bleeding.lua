-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--		Cleaned By Said Ak Using Claude Sonnet 4.5
-- =====================================================



-- Wait for Config.Bleeding to be available
while not (Config and Config.Bleeding) do
  Citizen.Wait(100)
end

-- Register bleeding treatment items
Citizen.CreateThread(function()
  -- Register each bleeding item with the framework
  for itemName, itemData in pairs(Config.Bleeding.items) do
    Bridge.Framework.registerItem(itemName, function(playerId)
      -- Verify player has the item
      local itemCount = Bridge.Inventory.getItemCount(playerId, itemName)
      
      if not itemCount or itemCount < 1 then
        return
      end
      
      -- Trigger client to use the item
      TriggerClientEvent("p_ambulancejob/bleeding/client/useItem", playerId, itemName, itemData)
    end)
  end
end)

local firstAidCooldown = {}

-- Validate and process first aid revive request
RegisterNetEvent("p_ambulancejob/server/firstAid", function(targetServerId)
    local src = source

    -- Anti-spam: 35s cooldown per helper
    local now = os.time()
    if firstAidCooldown[src] and (now - firstAidCooldown[src]) < 35 then
        return
    end

    -- Input validation
    if type(targetServerId) ~= "number" or targetServerId < 1 then return end
    if not GetPlayerName(targetServerId) then return end
    if targetServerId == src then return end

    -- Validate target is actually in bleeding state
    if Player(targetServerId).state.deathType ~= "bleeding" then return end

    -- Validate helper has bandage
    local itemCount = exports.ox_inventory:GetItem(src, "bandage", nil, true)
    if not itemCount or itemCount < 5 then
        TriggerClientEvent("ox_lib:notify", src, {
            type        = "error",
            description = locale and locale("no_bandage") or "Bạn không có băng gạc"
        })
        return
    end

    exports.ox_inventory:RemoveItem(src, "bandage", 5)

    -- Set cooldown after successful action
    firstAidCooldown[src] = now

    -- Trigger revive on target
    TriggerClientEvent("p_ambulancejob/client/death/firstAid", targetServerId)
end)

-- Cleanup cooldown table on player drop
AddEventHandler("playerDropped", function()
    firstAidCooldown[source] = nil
end)

RegisterNetEvent("p_ambulancejob/server/firstAid/lock", function(targetServerId)
    local src = source
    if type(targetServerId) ~= "number" or targetServerId < 1 then return end
    if not GetPlayerName(targetServerId) then return end
    if targetServerId == src then return end
    if Player(targetServerId).state.deathType ~= "bleeding" then return end
    TriggerClientEvent("p_ambulancejob/client/firstAid/lock", targetServerId)
end)

RegisterNetEvent("p_ambulancejob/server/firstAid/unlock", function(targetServerId)
    local src = source
    if type(targetServerId) ~= "number" or targetServerId < 1 then return end
    if not GetPlayerName(targetServerId) then return end
    if targetServerId == src then return end
    TriggerClientEvent("p_ambulancejob/client/firstAid/unlock", targetServerId)
end)