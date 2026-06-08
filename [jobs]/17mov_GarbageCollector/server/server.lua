local PlayersPairs = {}
local Invites = {}
local ActiveRequests = {}
local PendingRequests = {}
local UnloadedLocations = {}
local BagCounterCooldown = {}
local CooldownsLicenses = {}
local MaxPartySize = 4

local lastGarbageKeyReq = {}

local function trimGarbagePlate(p)
    if not p then return nil end
    p = tostring(p):gsub('%s+', '')
    if p == '' then return nil end
    return string.upper(p)
end

AddEventHandler('playerDropped', function() lastGarbageKeyReq[source] = nil end)

RegisterNetEvent('17mov_GarbageCollector:sv:grantKey', function(netId, plate)
    local src = source
    if GetResourceState('wasabi_carlock') ~= 'started' then return end
    local now = GetGameTimer()
    if (lastGarbageKeyReq[src] or 0) + 500 > now then return end
    lastGarbageKeyReq[src] = now
    netId = tonumber(netId)
    plate = trimGarbagePlate(plate)
    if not netId or not plate then return end
    local veh = NetworkGetEntityFromNetworkId(netId)
    if not veh or veh == 0 or not DoesEntityExist(veh) then return end
    if trimGarbagePlate(GetVehicleNumberPlateText(veh)) ~= plate then return end
    local ped = GetPlayerPed(src)
    if ped == 0 then return end
    local pCoords = GetEntityCoords(ped)
    local vCoords = GetEntityCoords(veh)
    if #(pCoords - vCoords) > 8.0 then return end
    pcall(function() exports.wasabi_carlock:GiveKey(src, plate) end)
end)

local oldGetPlayerIdentifierByType = GetPlayerIdentifierByType
local oldGetPlayerPing = GetPlayerPing
local oldTriggerClientEvent = TriggerClientEvent

function TriggerClientEventToMultiple(eventName, targets, ...)
    local payload = msgpack.pack_args(...)
    local payloadLen = #payload
    if type(targets) == "table" then
        for i = 1, #targets, 1 do
            TriggerClientEventInternal(eventName, targets[i], payload, payloadLen)
        end
        return
    end
    TriggerClientEventInternal(eventName, targets, payload, payloadLen)
end

function GetPlayerIdentifierByType(playerSrc, idType)
    if playerSrc == nil then
        return 0
    end
    if oldGetPlayerIdentifierByType ~= nil then
        return oldGetPlayerIdentifierByType(playerSrc, idType)
    else
        return GetPlayerIdentifier(playerSrc, 1)
    end
end

function GetPlayerPing(playerSrc, ...)
    if playerSrc ~= nil then
        oldGetPlayerPing(playerSrc, ...)
    end
end

function TriggerClientEvent(eventName, target, ...)
    if target ~= nil then
        oldTriggerClientEvent(eventName, target, ...)
    end
end

function RecalculateRewards(hostSrc)
    local lobbyIdx = 0
    for idx, lobby in pairs(PlayersPairs) do
        if lobby.host == hostSrc then
            lobbyIdx = idx
        end
    end
    if not lobbyIdx then
        return
    end
    PlayersPairs[lobbyIdx].rewardsOptions = {}
    local totalMembers = #PlayersPairs[lobbyIdx].clients + 1
    for i = 1, totalMembers - 1, 1 do
        local clientId = PlayersPairs[lobbyIdx].clients[i]
        if not clientId then
            return
        end
        PlayersPairs[lobbyIdx].rewardsOptions[clientId] = math.floor(100 / totalMembers)
    end
    PlayersPairs[lobbyIdx].rewardsOptions[hostSrc] = math.floor(100 / totalMembers)
    TriggerForAllMembers(hostSrc, "17mov_Garbage:SetMyReward", math.floor(100 / totalMembers))
    TriggerClientEvent("17mov_Garbage:UpdateHostPercentages", hostSrc, math.floor(100 / totalMembers))
end

RegisterNetEvent("17mov_GarbageCollector:server:fixRotation", function(netId)
    local entity = NetworkGetEntityFromNetworkId(netId)
    if DoesEntityExist(entity) then
        if Entity(entity).state.validPos then
            TriggerClientEvent("17mov_GarbageCollector:client:fixRotation", -1, netId)
        end
    end
end)

RegisterNetEvent("17mov_GarbageCollector:server:GarbageAnim", function(closestPlayers, netId, bagModel, stage, playerProgress, extra)
    local src = source
    TriggerClientEventToMultiple("17mov_GarbageCollector:client:GarbageAnim", closestPlayers, netId, bagModel, stage, src, playerProgress, extra)
end)

function RestartBagsQueue(entity, addQueue, decrementAllowed)
    if not DoesEntityExist(entity) then
        return
    end
    local queuedBags = Entity(entity).state.queued_bags or 0
    if addQueue then
        queuedBags = queuedBags + 1
        Entity(entity).state:set("queued_bags", queuedBags, true)
    end
    if queuedBags == 1 or (decrementAllowed and queuedBags > 0) then
        Citizen.SetTimeout(math.random(Config.BinsRestartingDelay.min, Config.BinsRestartingDelay.max) * 1000, function()
            if not DoesEntityExist(entity) then
                return
            end
            local curQueued = Entity(entity).state.queued_bags or 0
            if curQueued == 0 then
                return
            end
            local curStage = Entity(entity).state.currentStage
            if curStage then
                Entity(entity).state:set("currentStage", math.max(curStage - 1, 1), true)
            end
            Entity(entity).state:set("queued_bags", math.max(curQueued - 1, 0), true)
            RestartBagsQueue(entity, false, true)
        end)
    end
end

RegisterNetEvent("17mov_GarbageCollector:server:GarbageSetOcupied", function(netId, stageCount, validPos, increaseStage)
    local entity = NetworkGetEntityFromNetworkId(netId)
    if DoesEntityExist(entity) then
        if stageCount then
            local currentStage = Entity(entity).state.currentStage or 1
            local stageStep = 1
            if increaseStage then
                stageStep = 0
                if stageStep then
                    goto skipStep
                end
            end
            stageStep = 1
            ::skipStep::
            currentStage = math.min(currentStage + stageStep, stageCount)
            Entity(entity).state:set("currentStage", currentStage, true)
            RestartBagsQueue(entity, true, false)
            Entity(entity).state:set("GarbageOccupied", nil, true)
        else
            Entity(entity).state:set("GarbageOccupied", true, true)
        end
        if validPos then
            if Config.FixBinsPosition then
                Entity(entity).state:set("validPos", json.encode(validPos), true)
            end
        end
    end
end)

RegisterNetEvent("17mov_GarbageCollector:server:BlockBags", function(netIds)
    for i = 1, #netIds, 1 do
        local entity = NetworkGetEntityFromNetworkId(netIds[i])
        if DoesEntityExist(entity) then
            Entity(entity).state:set("GarbageBlock", true, true)
        end
    end
end)

Functions.RegisterServerCallback("17mov_GarbageCollector:server:GarbageGetOcupied", function(src, netId)
    local entity = NetworkGetEntityFromNetworkId(netId)
    if not DoesEntityExist(entity) then
        return false
    end
    if Entity(entity).state.GarbageOccupied then
        return true
    end
    Entity(entity).state:set("GarbageOccupied", true, true)
    return false
end)

Functions.RegisterServerCallback("17mov_Garbage:GetPlayersNames", function(src, playerIds)
    local result = {}
    for i = 1, #playerIds, 1 do
        table.insert(result, {
            id = playerIds[i],
            name = GetPlayerIdentity(playerIds[i]),
        })
    end
    return result
end)

Functions.RegisterServerCallback("17mov_Garbage:CheckThisReward", function(src, percent, targetPlayerId)
    local lobbyIdx = 0
    local totalOtherPercent = 0
    for idx, lobby in pairs(PlayersPairs) do
        if src == lobby.host then
            lobbyIdx = idx
            break
        end
        for i = 1, #lobby.clients, 1 do
            if src == lobby.clients[i] then
                lobbyIdx = idx
                break
            end
        end
    end
    for playerId, value in pairs(PlayersPairs[lobbyIdx].rewardsOptions) do
        if playerId ~= targetPlayerId then
            totalOtherPercent = totalOtherPercent + value
        end
    end
    if totalOtherPercent + percent > 100 then
        return false
    else
        PlayersPairs[lobbyIdx].rewardsOptions[targetPlayerId] = percent
        TriggerClientEvent("17mov_Garbage:SetMyReward", targetPlayerId, percent)
        return true
    end
end)

Functions.RegisterServerCallback("17mov_Garbage:IfPlayerOwnsTeam", function(src)
    local isOwner = false
    for _, lobby in pairs(PlayersPairs) do
        if lobby.host == src then
            isOwner = true
            break
        end
    end
    return isOwner
end)

Functions.RegisterServerCallback("17mov_Garbage:IfPlayerIsHost", function(src)
    local isHost = true
    local lobbyIdx = 0
    for idx, lobby in pairs(PlayersPairs) do
        for i = 1, #lobby.clients, 1 do
            if lobby.clients[i] == src then
                isHost = false
                lobbyIdx = idx
                break
            end
        end
    end
    if not isHost then
        if PlayersPairs[lobbyIdx] and PlayersPairs[lobbyIdx].host ~= nil then
            if GetPlayerPing(PlayersPairs[lobbyIdx].host) ~= 0 then
                goto done
            end
        end
        isHost = true
        PlayersPairs[lobbyIdx].host = src
    end
    ::done::
    return isHost
end)

Functions.RegisterServerCallback("17mov_Garbage:init", function(src)
    return {
        name = GetPlayerIdentity(src),
        source = src,
    }
end)

Functions.RegisterServerCallback("17mov_Garbage:GetLobbyMembers", function(src, hostSrc)
    if hostSrc == nil then
        return {}
    end
    local members = { hostSrc }
    for _, lobby in pairs(PlayersPairs) do
        if lobby.host == hostSrc then
            for i = 1, #lobby.clients, 1 do
                table.insert(members, lobby.clients[i])
            end
        end
    end
    return members
end)

RegisterNetEvent("17mov_Garbage:SendRequestToClient_sv", function(targetId)
    local src = source
    for _, lobby in pairs(PlayersPairs) do
        if lobby.host == targetId then
            return Notify(src, _L("Lobby.Player.AlreadyHost"))
        else
            for i = 1, #lobby.clients, 1 do
                if lobby.clients[i] == targetId then
                    return Notify(src, _L("Lobby.Player.AlreadyInTeam"))
                end
            end
        end
    end
    for _, invite in pairs(Invites) do
        if invite.client == targetId then
            return Notify(src, _L("Lobby.Player.AlreadyGotInvite"))
        else
            if invite.host == src then
                if invite.client ~= nil then
                    return Notify(src, _L("Lobby.Player.AlreadyInvited"))
                end
            end
        end
    end
    local clients = {}
    for _, lobby in pairs(PlayersPairs) do
        if lobby.host == src then
            clients = lobby.clients
        end
    end
    if #clients + 1 >= MaxPartySize then
        return Notify(src, _L("Lobby.StartJob.PartyFull"))
    end
    table.insert(Invites, {
        host = src,
        client = targetId,
    })
    Notify(src, _L("Lobby.StartJob.InviteSent"))
    TriggerClientEvent("17mov_Garbage:SendRequestToClient_cl", targetId, GetPlayerIdentity(src))
end)

RegisterNetEvent("17mov_Garbage:UpdateServerPartyBagsCounter", function(bagModel)
    local src = source
    if ActiveRequests[src] == nil then
        return
    end
    if BagCounterCooldown[src] ~= nil then
        if os.time() - BagCounterCooldown[src] < 2 then
            return
        end
    end
    local counterValue = Config.BagAttachments[bagModel].counterValue or 1
    BagCounterCooldown[src] = os.time()
    if counterValue == nil then
        counterValue = 1
    end
    if counterValue >= 100 then
        return
    end
    local lobbyIdx = 0
    for idx, lobby in pairs(PlayersPairs) do
        if lobby.host == src then
            lobbyIdx = idx
            break
        else
            for i = 1, #lobby.clients, 1 do
                if src == lobby.clients[i] then
                    lobbyIdx = idx
                    break
                end
            end
        end
    end
    local vehicle = NetworkGetEntityFromNetworkId(PlayersPairs[lobbyIdx].vehNetId)
    local playerCoords = GetEntityCoords(GetPlayerPed(src))
    if #(GetEntityCoords(vehicle) - playerCoords) > 10.0 then
        return
    end
    ActiveRequests[src] = nil
    local hostSrc = nil
    local foundInLobby = false
    local totalBags = 0
    for _, lobby in pairs(PlayersPairs) do
        if lobby.host == src then
            foundInLobby = true
            hostSrc = lobby.host
        else
            for i = 1, #lobby.clients, 1 do
                if src == lobby.clients[i] then
                    foundInLobby = true
                    hostSrc = lobby.host
                end
            end
        end
        if foundInLobby then
            if lobby.bags ~= nil then
                if lobby.bags < 100 then
                    lobby.bags = lobby.bags + counterValue
                end
                totalBags = lobby.bags
                break
            end
        end
    end
    TriggerForAllMembers(hostSrc, "17mov_Garbage:UpdateBagsCounter", totalBags)
end)

RegisterNetEvent("17mov_Garbage:ClientReactRequest", function(accepted)
    local src = source
    local hostSrc = nil
    local added = false
    for idx, invite in pairs(Invites) do
        if invite.client == src then
            hostSrc = invite.host
            Invites[idx] = nil
            break
        end
    end
    if accepted then
        if hostSrc ~= nil and src ~= nil then
            for _, lobby in pairs(PlayersPairs) do
                if lobby.host == hostSrc then
                    if lobby.clients ~= nil then
                        table.insert(lobby.clients, src)
                        added = true
                    end
                end
            end
            if not added then
                table.insert(PlayersPairs, {
                    host = hostSrc,
                    clients = { src },
                    bags = 0,
                })
            end
            if Config.UseModernUI then
                RecalculateRewards(hostSrc)
            end
            Notify(hostSrc, _L("Lobby.Player.Accepted"))
            local mugs = GetAllPartyMugs(hostSrc)
            TriggerForAllMembers(hostSrc, "17mov_Garbage:RefreshMugs", mugs)
        else
            Notify(src, _L("Lobby.Player.InviteError"))
            Notify(hostSrc, _L("Lobby.Player.InviteError"))
        end
    else
        Notify(hostSrc, _L("Lobby.Player.Declined"))
    end
end)

RegisterNetEvent("17mov_Garbage:KickPlayerFromLobby", function(targetId, notifyKick, targetByHost)
    local src = source
    local kickedId = targetId
    if targetByHost == nil then
        for _, lobby in pairs(PlayersPairs) do
            for i = 1, #lobby.clients, 1 do
                if lobby.host == src then
                    if lobby.clients[i] == kickedId then
                        lobby.clients[i] = nil
                        break
                    end
                end
            end
        end
    else
        for _, lobby in pairs(PlayersPairs) do
            for i = 1, #lobby.clients, 1 do
                if lobby.clients[i] == targetByHost then
                    src = lobby.host
                    lobby.clients[i] = nil
                    break
                end
            end
        end
    end
    if notifyKick then
        Notify(kickedId, _L("Lobby.Player.Kicked"))
    end
    if Config.UseModernUI then
        local selfMugs = { {
            id = kickedId,
            name = GetPlayerIdentity(kickedId),
            isHost = true,
        } }
        TriggerClientEvent("17mov_Garbage:RefreshMugs", kickedId, selfMugs, kickedId)
        TriggerClientEvent("17mov_Garbage:clearMyLobby", kickedId)
        TriggerClientEvent("17mov_Garbage:SetMyReward", kickedId, 100)
        local hostMugs = GetAllPartyMugs(src)
        TriggerForAllMembers(src, "17mov_Garbage:RefreshMugs", hostMugs)
        RecalculateRewards(src)
        for idx, lobby in pairs(PlayersPairs) do
            if #lobby.clients == 0 then
                if lobby.host == src then
                    PlayersPairs[idx] = nil
                    TriggerClientEvent("17mov_Garbage:clearMyLobby", src)
                end
            end
        end
    else
        local selfMugs = { {
            id = kickedId,
            name = GetPlayerIdentity(kickedId),
            isHost = true,
        } }
        TriggerClientEvent("17mov_Garbage:RefreshMugs", kickedId, selfMugs, kickedId)
        local hostMugs = GetAllPartyMugs(src)
        TriggerForAllMembers(src, "17mov_Garbage:RefreshMugs", hostMugs)
        for idx, lobby in pairs(PlayersPairs) do
            if #lobby.clients == 0 then
                if lobby.host == src then
                    PlayersPairs[idx] = nil
                end
            end
        end
    end
end)

RegisterNetEvent("17mov_GarbageJob:SendVehicleNetId", function(netId)
    local src = source
    for _, lobby in pairs(PlayersPairs) do
        if lobby.host == src then
            lobby.vehNetId = netId
        end
    end
end)

local stageEndedBy = {}

RegisterNetEvent("17mov_Garbage:server:endStage", function()
    local src = source
    stageEndedBy[tostring(src)] = true
    TriggerForAllMembers(src, "17mov_Garbage:client:endStage", src)
end)

RegisterNetEvent("17mov_GarbageCollector:server:startUnloadAnim", function(progress, closestPlayers)
    local src = source
    for _, lobby in pairs(PlayersPairs) do
        if lobby.host == src then
            TriggerClientEvent("17mov_GarbageCollector:client:startUnloadAnim", src, progress, true)
            return TriggerClientEventToMultiple("17mov_GarbageCollector:client:startUnloadAnim", closestPlayers, progress, false)
        end
    end
end)

RegisterNetEvent("17mov_Garbage:endJob_sv", function(hasVehicle, unused)
    local src = source
    local bagsCollected = nil
    TriggerForAllMembers(src, "17mov_Garbage:endJob_cl", 0)
    for idx, lobby in pairs(PlayersPairs) do
        if lobby.host == src then
            lobby.working = false
            bagsCollected = lobby.bags
            lobby.bags = 0
            local allMembers = {}
            for i = 1, #lobby.clients, 1 do
                table.insert(allMembers, lobby.clients[i])
            end
            table.insert(allMembers, lobby.host)
            Citizen.CreateThread(function()
                local vehicle = NetworkGetEntityFromNetworkId(lobby.vehNetId)
                if DoesEntityExist(vehicle) then
                    for i = 1, #allMembers, 1 do
                        TaskLeaveVehicle(GetPlayerPed(allMembers[i]), vehicle, 0)
                    end
                    Wait(1750)
                    DeleteEntity(vehicle)
                end
            end)
            local totalReward = bagsCollected * Config.Price
            if Config.MultiplyRewardWhileWorkingInGroup then
                totalReward = math.floor(totalReward * (#lobby.clients + 1))
            end
            if Config.UseModernUI then
                if #lobby.clients == 0 then
                    RecalculateRewards(src)
                end
            end
            local paidMap = {}
            for i = 1, #allMembers, 1 do
                local playerReward = 0
                if Config.UseModernUI then
                    if Config.LetBossSplitReward then
                        playerReward = math.floor(totalReward * (lobby.rewardsOptions[allMembers[i]] / 100))
                    end
                else
                    if Config.SplitReward then
                        playerReward = math.floor(totalReward / (#lobby.clients + 1))
                    else
                        playerReward = totalReward
                    end
                end
                if not hasVehicle then
                    PayPenalty(allMembers[i], Config.PenaltyAmount)
                    Notify(allMembers[i], _L("Job.Gameplay.RewardPenalty", Config.PenaltyAmount))
                end
                if not hasVehicle then
                    if hasVehicle then
                        goto skipPay
                    end
                    if false ~= Config.DontPayRewardWithoutVehicle then
                        goto skipPay
                    end
                end
                if not paidMap[allMembers[i]] then
                    paidMap[allMembers[i]] = true
                    Pay(allMembers[i], playerReward, #allMembers, bagsCollected)
                    Notify(allMembers[i], _L("Job.Gameplay.Reward", playerReward))
                end
                ::skipPay::
            end
            if #lobby.clients == 0 then
                PlayersPairs[idx] = nil
                TriggerClientEvent("17mov_Garbage:clearMyLobby", src)
            end
        end
    end
    if stageEndedBy[tostring(src)] then
        stageEndedBy[tostring(src)] = nil
    end
end)

RegisterNetEvent("17mov_Garbage:StartJob_sv", function()
    local src = source
    local teamClients = nil
    local lobbyIdx = nil
    for idx, lobby in pairs(PlayersPairs) do
        if lobby.host == src then
            teamClients = lobby.clients
            lobbyIdx = idx
            break
        end
    end
    if Config.RequireJobAlsoForFriends then
        if Config.RequiredJob ~= "none" and teamClients ~= nil then
            for i = 1, #teamClients, 1 do
                if GetPlayerJob(teamClients[i]) ~= Config.RequiredJob then
                    return Notify(src, _L("Lobby.StartJob.NoRequiredJob"))
                end
            end
        end
    end
    if not IsHaveRequiredItem(src) then
        return Notify(src, _L("Lobby.StartJob.NoItem"))
    end
    if Config.RequireItemFromWholeTeam and teamClients ~= nil then
        for i = 1, #teamClients, 1 do
            if not IsHaveRequiredItem(teamClients[i]) then
                return Notify(src, _L("Lobby.StartJob.NoItem"))
            end
        end
    end
    if Config.JobCooldown > 0 then
        CooldownsTime = CooldownsTime or {}
        local now = os.time()
        local hostLicense = GetPlayerIdentifierByType(src, "license")
        if CooldownsLicenses[hostLicense] then
            local elapsed = now - CooldownsTime[hostLicense]
            if elapsed >= Config.JobCooldown then
                CooldownsLicenses[hostLicense] = nil
                CooldownsTime[hostLicense] = nil
            else
                local remaining = Config.JobCooldown - elapsed
                local hours = math.floor(remaining / 3600)
                local minutes = math.floor((remaining % 3600) / 60)
                local seconds = remaining % 60
                local formatted = ""
                if hours > 0 then
                    formatted = formatted .. hours .. _L("Job.Time.Hours") .. " "
                end
                if minutes > 0 then
                    formatted = formatted .. minutes .. _L("Job.Time.Minutes") .. " "
                end
                formatted = formatted .. seconds .. _L("Job.Time.Seconds")
                return Notify(src, _L("Lobby.StartJob.Cooldown", GetPlayerIdentity(src), formatted))
            end
        end
        if teamClients ~= nil then
            for i = 1, #teamClients, 1 do
                local clientLicense = GetPlayerIdentifierByType(teamClients[i], "license")
                if CooldownsLicenses[clientLicense] then
                    local elapsed = now - CooldownsTime[clientLicense]
                    if elapsed >= Config.JobCooldown then
                        CooldownsLicenses[clientLicense] = nil
                        CooldownsTime[clientLicense] = nil
                    else
                        local remaining = Config.JobCooldown - elapsed
                        local hours = math.floor(remaining / 3600)
                        local minutes = math.floor((remaining % 3600) / 60)
                        local seconds = remaining % 60
                        local formatted = ""
                        if hours > 0 then
                            formatted = formatted .. hours .. _L("Job.Time.Hours") .. " "
                        end
                        if minutes > 0 then
                            formatted = formatted .. minutes .. _L("Job.Time.Minutes") .. " "
                        end
                        formatted = formatted .. seconds .. _L("Job.Time.Seconds")
                        return Notify(src, _L("Lobby.StartJob.Cooldown", GetPlayerIdentity(teamClients[i]), formatted))
                    end
                end
            end
        end
        CooldownsLicenses[hostLicense] = true
        CooldownsTime[hostLicense] = now
        if teamClients ~= nil then
            for i = 1, #teamClients, 1 do
                local clientLicense = GetPlayerIdentifierByType(teamClients[i], "license")
                CooldownsLicenses[clientLicense] = true
                CooldownsTime[clientLicense] = now
            end
        end
    end
    if Config.RequireOneFriendMinimum then
        if teamClients ~= nil then
            if #teamClients > 0 then
                if lobbyIdx ~= nil then
                    PlayersPairs[lobbyIdx].working = true
                    if Config.Debug.enabled then
                        Citizen.CreateThread(function()
                            PlayersPairs[lobbyIdx].bags = Config.Debug.base_progress
                            Wait(5000)
                            TriggerForAllMembers(src, "17mov_Garbage:UpdateBagsCounter", Config.Debug.base_progress)
                        end)
                    end
                end
                TriggerForAllMembers(src, "17mov_Garbage:StartJob_cl", src)
            end
        else
            Notify(src, _L("Lobby.StartJob.MemberRequired"))
        end
    else
        if teamClients == nil then
            table.insert(PlayersPairs, {
                host = src,
                clients = {},
                bags = 0,
            })
        end
        lobbyIdx = 0
        for idx, lobby in pairs(PlayersPairs) do
            if lobby.host == src then
                lobbyIdx = idx
                break
            end
        end
        PlayersPairs[lobbyIdx].working = true
        if Config.Debug.enabled then
            Citizen.CreateThread(function()
                PlayersPairs[lobbyIdx].bags = Config.Debug.base_progress
                Wait(5000)
                TriggerForAllMembers(src, "17mov_Garbage:UpdateBagsCounter", Config.Debug.base_progress)
            end)
        end
        TriggerForAllMembers(src, "17mov_Garbage:StartJob_cl", src)
    end
end)

RegisterNetEvent("17mov_GarbageCollector:ToggleTrunk", function(netId, open)
    local entity = NetworkGetEntityFromNetworkId(netId)
    if entity then
        if DoesEntityExist(entity) then
            if GetEntityModel(entity) == 1917016601 then
                local owner = NetworkGetEntityOwner(entity)
                if owner == 0 then
                    if open then
                        SetVehicleDoorOpen(entity, 5, false, false)
                    else
                        SetVehicleDoorShut(entity, 5, false)
                    end
                else
                    TriggerClientEvent("17mov_GarbageCollector:ToggleTrunk", owner, netId, open)
                end
            end
        end
    end
end)

RegisterNetEvent("17mov_GarbageCollector:BagCollected", function(playerIds, netId)
    for i = 1, #playerIds, 1 do
        TriggerClientEvent("17mov_GarbageCollector:BagCollected", playerIds[i], netId)
    end
end)

RegisterNetEvent("17mov_GarbageCollector:server:BagCollected", function(netId)
    local entity = NetworkGetEntityFromNetworkId(netId)
    if DoesEntityExist(entity) then
        DeleteEntity(entity)
    end
end)

local function GetLobbyClients(hostSrc)
    for _, lobby in pairs(PlayersPairs) do
        if hostSrc == lobby.host then
            return lobby.clients
        end
    end
end

RegisterNetEvent("17mov_GarbageCollector:server:TeleportCrewMembers", function(vehNetId, vehCoords)
    local src = source
    local clients = GetLobbyClients(src)
    if clients then
        if #clients ~= 0 then
            goto proceed
        end
    end
    do return end
    ::proceed::
    for i = 1, #clients, 1 do
        TriggerClientEvent("17mov_GarbageCollector:client:TeleportCrewMembers", clients[i], vehNetId, i - 1, vehCoords)
    end
end)

Functions.RegisterServerCallback("17mov_GarbageCollector:CheckAllow", function(src, coords, increaseDistance, requestNetId)
    if requestNetId then
        local entity = NetworkGetEntityFromNetworkId(requestNetId)
        if DoesEntityExist(entity) then
            if Entity(entity).state.ServerRequest then
                return false
            end
            Entity(entity).state:set("ServerRequest", true, true)
            return true
        end
    end
    PendingRequests[src] = {
        coords = coords,
        increaseDistance = increaseDistance,
    }
    for otherSrc, info in pairs(PendingRequests) do
        local distanceThreshold
        if increaseDistance then
            if info.increaseDistance then
                distanceThreshold = 2.0
                if distanceThreshold then
                    goto useDistance
                end
            end
        end
        distanceThreshold = 0.1
        ::useDistance::
        if distanceThreshold > #(info.coords - coords) and otherSrc ~= src then
            PendingRequests[src] = nil
            return false
        end
    end
    ActiveRequests[src] = true
    return true
end)

RegisterNetEvent("17mov_GarbageCollector:server:clearRequest", function()
    local src = source
    PendingRequests[src] = nil
end)

function GetPlayersOnDuty()
    local result = {}
    for _, lobby in pairs(PlayersPairs) do
        if lobby.working then
            table.insert(result, lobby.host)
            for i = 1, #lobby.clients, 1 do
                table.insert(result, lobby.clients[i])
            end
        end
    end
    return result
end

function GetAllPartyMugs(hostSrc)
    local mugs = {}
    local clients = {}
    local lobbyIdx = 0
    for idx, lobby in pairs(PlayersPairs) do
        if hostSrc == lobby.host then
            clients = lobby.clients
            lobbyIdx = idx
        end
    end
    if Config.UseModernUI then
        for i = 1, #clients, 1 do
            table.insert(mugs, {
                id = clients[i],
                name = GetPlayerIdentity(clients[i]),
                isHost = false,
                rewardPercent = PlayersPairs[lobbyIdx].rewardsOptions[clients[i]],
            })
        end
        if #clients == 0 then
            table.insert(mugs, {
                id = hostSrc,
                name = GetPlayerIdentity(hostSrc),
                isHost = true,
                rewardPercent = PlayersPairs[lobbyIdx].rewardsOptions[hostSrc],
            })
        else
            table.insert(mugs, {
                id = hostSrc,
                name = GetPlayerIdentity(hostSrc),
                isHost = true,
                rewardPercent = PlayersPairs[lobbyIdx].rewardsOptions[hostSrc],
            })
        end
    else
        for i = 1, #clients, 1 do
            table.insert(mugs, {
                id = clients[i],
                name = GetPlayerIdentity(clients[i]),
                isHost = false,
            })
        end
        if #clients == 0 then
            table.insert(mugs, {
                id = hostSrc,
                name = GetPlayerIdentity(hostSrc),
                isHost = true,
            })
        else
            table.insert(mugs, {
                id = hostSrc,
                name = GetPlayerIdentity(hostSrc),
                isHost = true,
            })
        end
    end
    return mugs
end

RegisterNetEvent("17mov_GarbageCollector:server:hideBox", function()
    local src = source
    TriggerForAllMembers(src, "17mov_GarbageCollector:client:hideBox")
end)

function TriggerForAllMembers(hostSrc, eventName, payload)
    local clients = GetLobbyClients(hostSrc) or {}
    for i = 1, #clients + 1, 1 do
        local target = clients[i] or hostSrc
        if target ~= nil then
            if type(target) == "number" then
                if eventName == "17mov_Garbage:RefreshMugs" or eventName == "17mov_Garbage:StartJob_cl" then
                    TriggerClientEvent(eventName, target, payload, target)
                else
                    TriggerClientEvent(eventName, target, payload)
                end
            end
        end
    end
end

RegisterNetEvent("onResourceStop", function(stoppedResource)
    if GetCurrentResourceName() ~= stoppedResource then
        return
    end
    local vehicles = GetAllVehicles()
    local objects = GetAllObjects()
    local peds = GetAllPeds()
    local resourceName = GetCurrentResourceName()
    for i = 1, math.max(#vehicles, #objects, #peds), 1 do
        if vehicles[i] then
            local script = GetEntityScript(vehicles[i])
            if script == resourceName then
                DeleteEntity(vehicles[i])
            end
        end
        if objects[i] then
            local script = GetEntityScript(objects[i])
            if Entity(objects[i]).state.currentStage then
                Entity(objects[i]).state:set("currentStage", nil, true)
            end
            if Entity(objects[i]).state.queued_bags then
                Entity(objects[i]).state:set("queued_bags", nil, true)
            end
            if Entity(objects[i]).state.GarbageOccupied then
                Entity(objects[i]).state:set("GarbageOccupied", nil, true)
            end
            if Entity(objects[i]).state.validPos then
                Entity(objects[i]).state:set("validPos", nil, true)
            end
            if script == resourceName then
                DeleteEntity(objects[i])
            end
        end
        if peds[i] then
            local script = GetEntityScript(peds[i])
            if script == resourceName then
                DeleteEntity(peds[i])
            end
        end
    end
end)

RegisterNetEvent("playerDropped", function()
    local src = source
    if PendingRequests[src] then
        PendingRequests[src] = nil
    end
    local lobbyIdx = nil
    local wasHost = false
    for idx, lobby in pairs(PlayersPairs) do
        if lobby.host == src then
            for i = 1, #lobby.clients, 1 do
                if GetPlayerPing(lobby.clients[i]) ~= 0 then
                    lobby.host = lobby.clients[i]
                    Notify(lobby.clients[i], _L("Lobby.Player.NewBoss"))
                    table.remove(lobby.clients, i)
                    break
                end
            end
            wasHost = true
            lobbyIdx = idx
            break
        end
        for i = 1, #lobby.clients, 1 do
            if lobby.clients[i] == src then
                table.remove(lobby.clients, i)
                lobbyIdx = idx
                break
            end
        end
    end
    if lobbyIdx == nil then
        return
    end
    local hostSrc = PlayersPairs[lobbyIdx].host
    if PlayersPairs[lobbyIdx].working then
        if #PlayersPairs[lobbyIdx].clients == 0 then
            TriggerClientEvent("17mov_Garbage:clearMyLobby", hostSrc)
        else
            TriggerForAllMembers(hostSrc, "17mov_Garbage:RefreshMugs", GetAllPartyMugs(hostSrc))
            if Config.UseModernUI then
                RecalculateRewards(hostSrc)
            end
        end
        if wasHost then
            if stageEndedBy[tostring(src)] then
                stageEndedBy[tostring(src)] = nil
                local vehicle = NetworkGetEntityFromNetworkId(PlayersPairs[lobbyIdx].vehNetId)
                if DoesEntityExist(vehicle) then
                    DeleteEntity(vehicle)
                end
                TriggerClientEvent("17mov_GarbageCollector:client:forceEndJob", hostSrc)
                TriggerForAllMembers(hostSrc, "17mov_GarbageCollector:client:hideBox")
            end
        end
    else
        if #PlayersPairs[lobbyIdx].clients == 0 then
            TriggerClientEvent("17mov_Garbage:clearMyLobby", hostSrc)
            PlayersPairs[lobbyIdx] = nil
        end
    end
end)
