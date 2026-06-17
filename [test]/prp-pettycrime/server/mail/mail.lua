
local envelopeLootTables = {} 
local npcLocation = nil 
local npcTimer = nil 

local function letterNPCTimer()
    if npcTimer then
        npcTimer:forceEnd(true)
    end

    local letterNpc = SvConfig.Mail.letterNpc
    local waitMinutes = math.random(letterNpc.minLocationTime, letterNpc.maxLocationTime)
    local waitMilliSeconds = (1000 * 60) * waitMinutes

    npcTimer = lib.timer(waitMilliSeconds, function()
        npcLocation = letterNpc.locations[math.random(1, #letterNpc.locations)]
        TriggerClientEvent('prp-pettycrime:client:setMailPedPos', -1, letterNpc.model, npcLocation.coords)
        letterNPCTimer()
    end, true)
end

function NextLetterNPCLocation()
    npcTimer:forceEnd(true)
end

function GetMailNpcLocation()
    return npcLocation
end

function GetMailNpcData()
    return {
        model = SvConfig.Mail.letterNpc.model ,
        position = npcLocation.coords
    }
end

CreateThread(function()
    envelopeLootTables[SvConfig.Mail.envelopeItem] = SvConfig.Mail.envelopeLootTable
    envelopeLootTables[SvConfig.Mail.catalogEnvelopeItem] = SvConfig.Mail.catalogEnvelopeLootTable

    local letterNpc = SvConfig.Mail.letterNpc
    npcLocation = letterNpc.locations[math.random(1, #letterNpc.locations)]

    letterNPCTimer()

    for itemName in pairs(envelopeLootTables) do
        bridge.fw.registerItemUse(itemName, function(playerId, item)
            if not bridge.inv.removeItem(playerId, item.name, 1, item.metaData, item.slot) then
                return
            end

            local progressBarData = SvConfig.Mail.envelopeProgressBar
            local finished = lib.callback.await("prp-bridge:progress", playerId, {
                duration = progressBarData.duration,
                label = progressBarData.text,
                controlDisables = progressBarData.disable,
                animation = {
                    animDict = progressBarData.anim.dict,
                    animClip = progressBarData.anim.clip,
                    animFlag = progressBarData.anim.flag
                }
            })

            if not finished then
                return
            end

            local lootData = envelopeLootTables[item.name]
            if not lootData then
                TriggerClientEvent("prp-bridge:notify", playerId, "error", locale("notifications.mail.empty_envelope"))
                return
            end

            local minLootRolls = lootData.minLootRolls
            local maxLootRolls = lootData.maxLootRolls
            local amount = math.random(minLootRolls, maxLootRolls)
            local loot = GiveRewards(playerId, amount, lootData.lootTable, lootData.guaranteedRarities)

            if not loot or not next(loot) then
                TriggerClientEvent("prp-bridge:notify", playerId, "error", locale("notifications.mail.empty_envelope"))
                return
            end

            TriggerClientEvent("prp-bridge:notify", playerId, "info", locale("notifications.mail.found_something"))
        end)
    end
end)

RegisterNetEvent('prp-pettycrime:server:mailSellLetters', function()
    local playerId = source
    local count = bridge.inv.count(playerId, SvConfig.Mail.letterItem)

    if count < 1 then
        TriggerClientEvent("prp-bridge:notify", playerId, "error", locale("notifications.mail.none_found"))
        return
    end

    local itemsRemoved = bridge.inv.removeItem(playerId, SvConfig.Mail.letterItem, count)
    if not itemsRemoved then
        TriggerClientEvent("prp-bridge:notify", playerId, "error", locale("notifications.mail.cant_remove"))
        return
    end

    if SvConfig.Mail.letterSell.rep.enabled then
        local repReward = math.ceil(count * SvConfig.Mail.letterSell.rep.amountPerLetter)
        bridge.fw.addRep(playerId, SvConfig.Mail.letterSell.rep.type, repReward, "petty_crime_letter_sell")
    end

    local payout = math.floor(count * SvConfig.Mail.letterSell.amountPerLetter)
    TriggerClientEvent(
        "prp-bridge:notify",
        playerId,
        "info",
        locale(
            "notifications.mail.sold",
            payout,
            count,
            count == 1 and locale("notifications.mail.letter") or locale("notifications.mail.letters")
        )
    )
    bridge.inv.giveItem(playerId, SvConfig.Mail.letterSell.paymentItem, payout)

    -- Note Reward Logic
    local noteReward = SvConfig.Mail.letterSell.noteReward
    if noteReward and noteReward.enabled then
        local roll = math.random(1, 100)
        if roll <= noteReward.chance then
            bridge.inv.giveItem(playerId, noteReward.itemName, 1, noteReward.metadata)
            TriggerClientEvent("prp-bridge:notify", playerId, "info", locale("notifications.mail.received_note"))
        end
    end
end)

CreateThread(function()
    bridge.fw.registerItemUse("giaygoiymot", function(playerId, item)
        TriggerClientEvent("prp-pettycrime:client:useHintNote", playerId)
    end)
end)

