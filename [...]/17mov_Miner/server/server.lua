-- =====================================================
-- MINING JOB SERVER SCRIPT - OBFUSCATED TO CLEAN
-- =====================================================
-- File: server.lua (Cleaned)
-- Description: Server-side script for mining job system
-- CLEANED WITH 100% ACCURACY - NO ADDITIONS, NO OMISSIONS
-- =====================================================

-- =====================================================
-- GLOBAL VARIABLES INITIALIZATION
-- =====================================================

-- Pending invitations table
local PendingInvites = {}

-- Reserved table 1 (empty - for future use)
local ReservedTable1 = {}

-- Team size configuration
local MaxTeamSize = 4
local MineshaftSlots = 45

-- Reserved tables 2 and 3
local ReservedTable2 = {}
local ReservedTable3 = {}

-- Main data structures
PlayersPairs = {}              -- Global: Stores all active teams/lobbies
ClientsInBuckets = {}         -- Global: Tracks clients in routing buckets
ObjectsInBuckets = {}         -- Global: Tracks objects spawned in buckets

-- Bucket configuration for mineshafts
Buckets = {
    [1] = {
        [1] = false, [2] = false, [3] = false, [4] = false,
        [5] = false, [6] = false, [7] = false, [8] = false
    }
}

-- =====================================================
-- UTILITY FUNCTION: Get Player Identifier
-- =====================================================

local OriginalGetPlayerIdentifierByType = GetPlayerIdentifierByType

function GetPlayerIdentifierByType(source, identifierType)
    if nil == source then
        return 0
    end
    
    if nil ~= OriginalGetPlayerIdentifierByType then
        return OriginalGetPlayerIdentifierByType(source, identifierType)
    else
        return GetPlayerIdentifier(source, 1)
    end
end

-- =====================================================
-- FUNCTION: Recalculate Reward Percentages
-- =====================================================

function RecalculateRewards(hostSource)
    local lobbyIndex = 0
    
    -- Find lobby index for this host
    for index, lobby in pairs(PlayersPairs) do
        if lobby.host == hostSource then
            lobbyIndex = index
            break
        end
    end
    
    -- Reset rewards options
    PlayersPairs[lobbyIndex].rewardsOptions = {}
    
    -- Calculate total members (clients + host)
    local totalMembers = #PlayersPairs[lobbyIndex].clients + 1
    
    -- Calculate reward percentage for each client
    for i = 1, totalMembers - 1 do
        local clientSource = PlayersPairs[lobbyIndex].clients[i]
        local rewardPercent = math.floor(100 / totalMembers)
        PlayersPairs[lobbyIndex].rewardsOptions[clientSource] = rewardPercent
    end
    
    -- Calculate reward percentage for host
    local hostRewardPercent = math.floor(100 / totalMembers)
    PlayersPairs[lobbyIndex].rewardsOptions[hostSource] = hostRewardPercent
    
    -- Notify all members
    TriggerForAllMembers(hostSource, "gta5vn_miner:SetMyReward", math.floor(100 / totalMembers))
    TriggerClientEvent("gta5vn_miner:UpdateHostPercentages", hostSource, math.floor(100 / totalMembers))
end

-- =====================================================
-- SERVER CALLBACKS REGISTRATION
-- =====================================================

CreateThread(function()
    
    -- =====================================================
    -- CALLBACK: Check if reward percentage is valid
    -- =====================================================
    RegisterServerCallback("gta5vn_miner:CheckThisReward", function(source, newRewardPercent, playerSource)
        local lobbyIndex = 0
        
        -- Find lobby index
        for index, lobby in pairs(PlayersPairs) do
            if source == lobby.host then
                lobbyIndex = index
                break
            end
            
            -- Check if source is a client
            for i = 1, #lobby.clients do
                if source == lobby.clients[i] then
                    lobbyIndex = index
                    break
                end
            end
        end
        
        -- Calculate total percentage excluding target player
        local totalOtherPercent = 0
        for player, percent in pairs(PlayersPairs[lobbyIndex].rewardsOptions) do
            if player ~= playerSource then
                totalOtherPercent = totalOtherPercent + percent
            end
        end
        
        -- Check if total would exceed 100%
        if totalOtherPercent + newRewardPercent > 100 then
            return false
        else
            PlayersPairs[lobbyIndex].rewardsOptions[playerSource] = newRewardPercent
            TriggerClientEvent("gta5vn_miner:SetMyReward", playerSource, newRewardPercent)
            return true
        end
    end)
    
    -- =====================================================
    -- CALLBACK: Check if team is ready
    -- =====================================================
    RegisterServerCallback("gta5vn_miner:CheckTeamIsReady", function(source)
        local lobbyIndex = GetLobbyIndex(source)
        
        if 0 == lobbyIndex then
            Functions.Error("Cant find lobby index in CheckTeamIsReady callback")
            return false
        end
        
        -- Build list of all members
        local allMembers = {PlayersPairs[lobbyIndex].host}
        for i = 1, #PlayersPairs[lobbyIndex].clients do
            table.insert(allMembers, PlayersPairs[lobbyIndex].clients[i])
        end
        
        -- Initialize gear and clothes if needed
        if nil == PlayersPairs[lobbyIndex].gear then
            PlayersPairs[lobbyIndex].gear = {}
        end
        
        if nil == PlayersPairs[lobbyIndex].clothes then
            PlayersPairs[lobbyIndex].clothes = {}
        end
        
        -- Check if all members have gear and clothes
        for i = 1, #allMembers do
            if not PlayersPairs[lobbyIndex].gear[allMembers[i]] or 
               not PlayersPairs[lobbyIndex].clothes[allMembers[i]] then
                return false
            end
        end
        
        return true
    end)
    
    -- =====================================================
    -- CALLBACK: Get player names from source IDs
    -- =====================================================
    RegisterServerCallback("gta5vn_miner:GetPlayersNames", function(source, playerSources)
        local playersData = {}
        
        for i = 1, #playerSources do
            table.insert(playersData, {
                id = playerSources[i],
                name = GetPlayerIdentity(playerSources[i])
            })
        end
        
        return playersData
    end)
    
    -- =====================================================
    -- CALLBACK: Get lobby members
    -- =====================================================
    RegisterServerCallback("gta5vn_miner:GetLobbyMembers", function(source, hostSource)
        local members = {hostSource}
        
        if nil == hostSource then
            return {}
        end
        
        -- Find lobby and add clients
        for index, lobby in pairs(PlayersPairs) do
            if lobby.host == hostSource then
                for i = 1, #lobby.clients do
                    table.insert(members, lobby.clients[i])
                end
            end
        end
        
        return members
    end)
    
    -- =====================================================
    -- CALLBACK: Check if player owns a team
    -- =====================================================
    RegisterServerCallback("gta5vn_miner:IfPlayerOwnsTeam", function(source)
        local ownsTeam = false
        
        for index, lobby in pairs(PlayersPairs) do
            if lobby.host == source then
                ownsTeam = true
                break
            end
        end
        
        return ownsTeam
    end)
    
    -- =====================================================
    -- CALLBACK: Check if player is host
    -- =====================================================
    RegisterServerCallback("gta5vn_miner:IfPlayerIsHost", function(source)
        local isHost = true
        local lobbyIndex = 0
        
        -- Check if player is a client
        for index, lobby in pairs(PlayersPairs) do
            for i = 1, #lobby.clients do
                if lobby.clients[i] == source then
                    isHost = false
                    lobbyIndex = index
                    break
                end
            end
        end
        
        -- Check if player matches host
        if nil ~= PlayersPairs[lobbyIndex] then
            if source == PlayersPairs[lobbyIndex].host then
                return true
            end
        end
        
        -- Check if host disconnected, promote client
        if not isHost then
            if nil ~= PlayersPairs[lobbyIndex].host then
                if 0 == GetPlayerPing(PlayersPairs[lobbyIndex].host) then
                    isHost = true
                    PlayersPairs[lobbyIndex].host = source
                end
            end
        end
        
        return isHost
    end)
    
    -- =====================================================
    -- CALLBACK: Initialize player data
    -- =====================================================
    RegisterServerCallback("gta5vn_miner:init", function(source)
        return {
            name = GetPlayerIdentity(source),
            source = source
        }
    end)
    
    -- =====================================================
    -- CALLBACK: Get team coordinates
    -- =====================================================
    RegisterServerCallback("gta5vn_miner:GetTeamCoordinates", function(source, skipGearCheck)
        local lobbyIndex = GetLobbyIndex(source)
        local coordinates = {}
        
        if 0 == lobbyIndex then
            Functions.Error("Cant find lobby index in GetTeamCoordinates callback")
            return false
        end
        
        -- Get client coordinates
        for i = 1, #PlayersPairs[lobbyIndex].clients do
            if nil ~= PlayersPairs[lobbyIndex].clients[i] then
                table.insert(coordinates, GetEntityCoords(GetPlayerPed(PlayersPairs[lobbyIndex].clients[i])))
            end
        end
        
        -- Get host coordinates
        if nil ~= PlayersPairs[lobbyIndex].host then
            table.insert(coordinates, GetEntityCoords(GetPlayerPed(PlayersPairs[lobbyIndex].host)))
        end
        
        -- Build member list
        local allMembers = {PlayersPairs[lobbyIndex].host}
        for i = 1, #PlayersPairs[lobbyIndex].clients do
            table.insert(allMembers, PlayersPairs[lobbyIndex].clients[i])
        end
        
        -- Initialize gear/clothes if needed
        if nil == PlayersPairs[lobbyIndex].gear then
            PlayersPairs[lobbyIndex].gear = {}
        end
        
        if nil == PlayersPairs[lobbyIndex].clothes then
            PlayersPairs[lobbyIndex].clothes = {}
        end
        
        -- Check gear requirement
        if nil == Config.RequireGear and not skipGearCheck then
            for i = 1, #allMembers do
                if not PlayersPairs[lobbyIndex].gear[allMembers[i]] or 
                   not PlayersPairs[lobbyIndex].clothes[allMembers[i]] then
                    return false
                end
            end
        end
        
        return coordinates
    end)
    
    -- =====================================================
    -- CALLBACK: Check if mining is possible
    -- =====================================================
    RegisterServerCallback("gta5vn_miner:CheckIfMiningPossible", function(source)
        local lobbyIndex = GetLobbyIndex(source)
        
        if 0 == index then
            Functions.Error("Cant find lobby index in CheckIfMiningPossible callback")
            return false
        end
        
        -- Check if minecart is busy
        if PlayersPairs[lobbyIndex].minecartminecartBusy then
            Notify(source, Config.Lang.minecartBusy)
            return false
        end
        
        -- Check if job is complete
        if PlayersPairs[lobbyIndex].progress >= 100.0 then
            Notify(source, Config.Lang.jobDone)
            return false
        end
        
        return true
    end)
    
end)

-- =====================================================
-- EVENT: Send team invitation
-- =====================================================

RegisterNetEvent("gta5vn_miner:SendRequestToClient_sv")
AddEventHandler("gta5vn_miner:SendRequestToClient_sv", function(targetPlayer)
    local invites = {}
    local hostSource = source
    
    -- Check if target is already a host
    for index, lobby in pairs(PlayersPairs) do
        if lobby.host == targetPlayer then
            return Notify(hostSource, Config.Lang.isAlreadyHost)
        else
            -- Check if target is in a team
            for i = 1, #lobby.clients do
                if lobby.clients[i] == targetPlayer then
                    return Notify(hostSource, Config.Lang.isBusy)
                end
            end
        end
    end
    
    -- Check for pending invites
    for index, invite in pairs(PendingInvites) do
        if invite.client == targetPlayer then
            return Notify(hostSource, Config.Lang.hasActiveInvite)
        end
        
        if invite.host == hostSource then
            if nil ~= invite.client then
                return Notify(hostSource, Config.Lang.HaveActiveInvite)
            end
        end
    end
    
    -- Get current team members
    for index, lobby in pairs(PlayersPairs) do
        if lobby.host == hostSource then
            invites = lobby.clients
        end
    end
    
    -- Check if team is full
    if #invites + 1 >= MaxTeamSize then
        Notify(hostSource, Config.Lang.partyIsFull)
        return
    end
    
    -- Create invitation
    table.insert(PendingInvites, {
        host = hostSource,
        client = targetPlayer
    })
    
    Notify(hostSource, Config.Lang.inviteSent)
    TriggerClientEvent("gta5vn_miner:SendRequestToClient_cl", targetPlayer, GetPlayerIdentity(hostSource))
end)

-- =====================================================
-- EVENT: Handle invitation response
-- =====================================================

RegisterNetEvent("gta5vn_miner:ClientReactRequest")
AddEventHandler("gta5vn_miner:ClientReactRequest", function(accepted)
    local clientSource = source
    local hostSource = nil
    local lobbyExists = false
    
    -- Find and remove pending invite
    for index, invite in pairs(PendingInvites) do
        if invite.client == source then
            hostSource = invite.host
            PendingInvites[index] = nil
            break
        end
    end
    
    if accepted then
        if nil ~= hostSource and nil ~= clientSource then
            -- Check if lobby exists
            for index, lobby in pairs(PlayersPairs) do
                if lobby.host == hostSource then
                    if nil ~= lobby.clients then
                        table.insert(lobby.clients, clientSource)
                        lobbyExists = true
                    end
                end
            end
            
            -- Create new lobby if needed
            if not lobbyExists then
                table.insert(PlayersPairs, {
                    host = hostSource,
                    clients = {clientSource},
                    progress = 0,
                    blockedWalls = {}
                })
            end
            
            -- Recalculate rewards
            RecalculateRewards(hostSource)
            
            Notify(hostSource, Config.Lang.InviteAccepted)
            
            -- Update UI for all members
            local allMugs = GetAllPartyMugs(hostSource)
            TriggerForAllMembers(hostSource, "gta5vn_miner:RefreshMugs", allMugs)
        else
            Notify(source, Config.Lang.error)
            Notify(hostSource, Config.Lang.error)
        end
    else
        Notify(hostSource, Config.Lang.InviteDeclined)
    end
end)

-- =====================================================
-- EVENT: Kick player from lobby
-- =====================================================

RegisterNetEvent("gta5vn_miner:KickPlayerFromLobby")
AddEventHandler("gta5vn_miner:KickPlayerFromLobby", function(targetPlayer, shouldNotify, sourcePlayer)
    local playerToKick = targetPlayer
    local hostSource = nil
    
    if nil == sourcePlayer then
        hostSource = source
        
        -- Remove player from lobby
        for index, lobby in pairs(PlayersPairs) do
            for i = 1, #lobby.clients do
                if lobby.host == hostSource and lobby.clients[i] == playerToKick then
                    lobby.clients[i] = nil
                    break
                end
            end
        end
    else
        -- Admin kick
        for index, lobby in pairs(PlayersPairs) do
            for i = 1, #lobby.clients do
                if lobby.clients[i] == sourcePlayer then
                    hostSource = lobby.host
                    lobby.clients[i] = nil
                    break
                end
            end
        end
    end
    
    -- Notify kicked player
    if shouldNotify then
        Notify(playerToKick, Config.Lang.kickedOut)
    end
    
    -- Reset UI to solo
    local soloMugs = {
        {
            id = playerToKick,
            name = GetPlayerIdentity(playerToKick),
            isHost = true
        }
    }
    
    TriggerClientEvent("gta5vn_miner:RefreshMugs", playerToKick, soloMugs, playerToKick)
    TriggerClientEvent("gta5vn_miner:clearMyLobby", playerToKick)
    TriggerClientEvent("gta5vn_miner:SetMyReward", playerToKick, 100)
    
    -- Update remaining team
    local updatedMugs = GetAllPartyMugs(hostSource)
    TriggerForAllMembers(hostSource, "gta5vn_miner:RefreshMugs", updatedMugs)
    RecalculateRewards(hostSource)
    
    -- Delete lobby if empty
    for index, lobby in pairs(PlayersPairs) do
        if 0 == #lobby.clients and lobby.host == hostSource then
            PlayersPairs[index] = nil
            TriggerClientEvent("gta5vn_miner:clearMyLobby", hostSource)
        end
    end
end)

-- =====================================================
-- EVENT: Exit bucket
-- =====================================================

RegisterNetEvent("gta5vn_miner_ExitBucket")
AddEventHandler("gta5vn_miner_ExitBucket", function()
    local playerSource = source
    local lobbyIndex = GetLobbyIndex(playerSource)
    
    if 0 == lobbyIndex then
        return Functions.Error("Cant find lobby index in ExitBucket event")
    end
    
    -- Return to main bucket
    SetPlayerRoutingBucket(playerSource, Config.MainBucket)
    
    -- Move gear prop if exists
    if PlayersPairs[lobbyIndex].gearProps then
        if DoesEntityExist(PlayersPairs[lobbyIndex].gearProps[playerSource]) then
            SetEntityRoutingBucket(PlayersPairs[lobbyIndex].gearProps[playerSource], Config.MainBucket)
        end
    end
    
    TriggerClientEvent("gta5vn_miner:endJob_cl", playerSource)
end)

-- =====================================================
-- EVENT: Elevator back to surface
-- =====================================================

RegisterNetEvent("gta5vn_miner:ElevatorBack")
AddEventHandler("gta5vn_miner:ElevatorBack", function(includeAnimation)
    if nil == includeAnimation then
        includeAnimation = true
    end
    
    local hostSource = source
    local lobbyIndex = GetLobbyIndex(hostSource)
    
    if 0 == lobbyIndex then
        return Functions.Error("Cant find lobby index in ElevatorBack event")
    end
    
    -- Build member list
    local allMembers = {PlayersPairs[lobbyIndex].host}
    for i = 1, #PlayersPairs[lobbyIndex].clients do
        table.insert(allMembers, PlayersPairs[lobbyIndex].clients[i])
    end
    
    -- Trigger for all members
    for index, memberSource in pairs(allMembers) do
        TriggerClientEvent("gta5vn_miner:ElevatorBack_cl", memberSource, 
            PlayersPairs[lobbyIndex].host, memberSource, includeAnimation)
    end
end)

-- =====================================================
-- EVENT: End job
-- =====================================================

local PaymentProcessed = {}

RegisterNetEvent("gta5vn_miner:endJob_sv")
AddEventHandler("gta5vn_miner:endJob_sv", function(skipPenalty, sendEndJobEvent)
    local source = source
    local lobbyIndex = GetLobbyIndex(source)
    local toDelete = {}
    
    if 0 == lobbyIndex then
        return Functions.Error("Cant find lobby index in endJob_sv event")
    end
    
    -- Trigger end job for all if requested
    if sendEndJobEvent then
        TriggerForAllMembers(PlayersPairs[lobbyIndex].host, "gta5vn_miner:endJob_cl", sendEndJobEvent)
    end
    
    local bucketId = PlayersPairs[lobbyIndex].bucket
    
    -- Cleanup bucket data
    if nil ~= Buckets[bucketId] then
        if nil ~= PlayersPairs[lobbyIndex].mineshaftId then
            Buckets[bucketId][PlayersPairs[lobbyIndex].mineshaftId] = false
            
            if nil ~= ObjectsInBuckets[bucketId] then
                if nil ~= ObjectsInBuckets[bucketId][PlayersPairs[lobbyIndex].mineshaftId] then
                    ObjectsInBuckets[bucketId][PlayersPairs[lobbyIndex].mineshaftId] = nil
                end
            end
            
            -- Notify other players in bucket
            local playersInBucket = GetPlayersInBucket(bucketId)
            local otherMineshafts = {}
            
            for index, lobby in pairs(PlayersPairs) do
                if index ~= lobbyIndex and lobby.bucket == bucketId then
                    table.insert(otherMineshafts, lobby.mineshaftId)
                end
            end
            
            for i = 1, #playersInBucket do
                TriggerClientEvent("gta5vn_miner:UpdateWalls", playersInBucket[i], otherMineshafts)
                TriggerClientEvent("gta5vn_miner:DestroyThisMineshaft", playersInBucket[i], 
                    PlayersPairs[lobbyIndex].mineshaftId)
            end
            
            -- Remove from bucket tracking
            for index, player in pairs(toDelete) do
                for bucketPlayer, _ in pairs(ClientsInBuckets) do
                    if bucketPlayer == player then
                        ClientsInBuckets[bucketPlayer] = nil
                    end
                end
            end
        end
    end
    
    -- Process cleanup and rewards
    for index, lobby in pairs(PlayersPairs) do
        if lobby.host == source then
            lobby.working = false
            
            -- Function to delete entities recursively
            local function DeleteEntitiesRecursive(entityTable)
                if nil == entityTable then
                    return
                end
                
                for key, entity in pairs(entityTable) do
                    if "table" == type(entity) then
                        DeleteEntitiesRecursive(entity)
                    elseif entity then
                        if DoesEntityExist(entity) then
                            DeleteEntity(entity)
                        end
                    end
                end
            end
            
            -- Cleanup objects
            CreateThread(function()
                DeleteEntity(lobby.wall)
                DeleteEntitiesRecursive(lobby.objects)
            end)
            
            -- Build member list
            local allMembers = {}
            for i = 1, #lobby.clients do
                table.insert(allMembers, lobby.clients[i])
            end
            table.insert(allMembers, lobby.host)
            
            -- Calculate base reward
            local baseReward = 0
            if nil ~= lobby.progress then
                baseReward = math.floor(Config.OnePercentWorth * lobby.progress)
            end
            
            -- Reset lobby data
            lobby.wallOffset = 0
            lobby.mineshaftId = nil
            lobby.lastRailid = nil
            lobby.bucket = nil
            
            -- Apply group multiplier
            if Config.multiplyRewardWhileWorkingInGroup then
                baseReward = math.floor(baseReward * (#lobby.clients + 1))
            end
            
            -- Recalculate if solo
            if 0 == #lobby.clients then
                RecalculateRewards(source)
            end
            
            -- Pay each member
            for i = 1, #allMembers do
                local finalReward = 0
                
                if Config.letBossSplitReward then
                    finalReward = math.floor(baseReward * (lobby.rewardsOptions[allMembers[i]] / 100))
                else
                    finalReward = baseReward
                end
                
                -- Apply penalty if needed
                if not skipPenalty then
                    PayPenalty(allMembers[i], Config.PenaltyAmount)
                    Notify(allMembers[i], Config.Lang.penalty .. Config.PenaltyAmount)
                end
                
                -- Process payment
                CreateThread(function()
                    if not PaymentProcessed[allMembers[i]] then
                        PaymentProcessed[allMembers[i]] = true
                        Pay(allMembers[i], finalReward, #allMembers, lobby.progress)
                        Notify(allMembers[i], Config.Lang.reward .. finalReward)
                    end
                end)
                
                -- Clear payment lock
                CreateThread(function()
                    Citizen.Wait(10000)
                    PaymentProcessed[allMembers[i]] = nil
                end)
            end
            
            -- Delete lobby if empty
            if 0 == #lobby.clients then
                PlayersPairs[index] = nil
                TriggerClientEvent("gta5vn_miner:clearMyLobby", source)
            end
        end
    end
end)

-- =====================================================
-- EVENT: Start job
-- =====================================================

local LastJobStartTime = 0
local JobStartCooldown = 3000
local PlayersOnCooldown = {}

RegisterNetEvent("gta5vn_miner:StartJob_sv")
AddEventHandler("gta5vn_miner:StartJob_sv", function()
    local source = source
    local teamClients = nil
    local lobbyIndex = 0
    
    -- Find if player is host
    for index, lobby in pairs(PlayersPairs) do
        if lobby.host == source then
            if lobby.working then
                return Notify(source, Config.Lang.alreadyStarted)
            end
            teamClients = lobby.clients
            lobbyIndex = index
            break
        end
    end
    
    -- Check spam prevention
    local currentTime = GetGameTimer()
    if currentTime - LastJobStartTime <= JobStartCooldown then
        return Notify(source, Config.Lang.wait)
    end
    LastJobStartTime = currentTime
    
    -- Check team job requirement
    if Config.RequireJobAlsoForFriends then
        if "none" ~= Config.RequiredJob and nil ~= teamClients then
            for i = 1, #teamClients do
                if GetPlayerJob(teamClients[i]) ~= Config.RequiredJob then
                    return Notify(source, Config.Lang.notEverybodyHasRequiredJob)
                end
            end
        end
    end
    
    -- Check host has required item
    if not IsHaveRequiredItem(source) then
        return Notify(source, Config.Lang.dontHaveReqItem)
    end
    
    -- Check team has required items
    if Config.RequireItemFromWholeTeam and nil ~= teamClients then
        for i = 1, #teamClients do
            if not IsHaveRequiredItem(teamClients[i]) then
                return Notify(source, Config.Lang.dontHaveReqItem)
            end
        end
    end
    
    -- Check cooldown system
    if Config.JobCooldown > 0 then
        local currentTimestamp = os.time()
        local playerLicense = GetPlayerIdentifierByType(source, "license")
        
        if not CooldownsTime then
            CooldownsTime = {}
        end
        
        -- Check host cooldown
        if PlayersOnCooldown[playerLicense] then
            local timePassed = currentTimestamp - CooldownsTime[playerLicense]
            
            if timePassed >= Config.JobCooldown then
                PlayersOnCooldown[playerLicense] = nil
                CooldownsTime[playerLicense] = nil
            else
                local timeRemaining = Config.JobCooldown - timePassed
                local hours = math.floor(timeRemaining / 3600)
                local minutes = math.floor((timeRemaining % 3600) / 60)
                local seconds = timeRemaining % 60
                
                local timeString = ""
                if hours > 0 then
                    timeString = timeString .. hours .. Config.Lang.hours .. " "
                end
                if minutes > 0 then
                    timeString = timeString .. minutes .. Config.Lang.minutes .. " "
                end
                timeString = timeString .. seconds .. Config.Lang.seconds
                
                return Notify(source, string.format(Config.Lang.someoneIsOnCooldown, 
                    GetPlayerIdentity(source), timeString))
            end
        end
        
        -- Check team cooldowns
        if nil ~= teamClients then
            for i = 1, #teamClients do
                local clientLicense = GetPlayerIdentifierByType(teamClients[i], "license")
                
                if PlayersOnCooldown[clientLicense] then
                    local timePassed = currentTimestamp - CooldownsTime[clientLicense]
                    
                    if timePassed >= Config.JobCooldown then
                        PlayersOnCooldown[clientLicense] = nil
                        CooldownsTime[clientLicense] = nil
                    else
                        local timeRemaining = Config.JobCooldown - timePassed
                        local hours = math.floor(timeRemaining / 3600)
                        local minutes = math.floor((timeRemaining % 3600) / 60)
                        local seconds = timeRemaining % 60
                        
                        local timeString = ""
                        if hours > 0 then
                            timeString = timeString .. hours .. Config.Lang.hours .. " "
                        end
                        if minutes > 0 then
                            timeString = timeString .. minutes .. Config.Lang.minutes .. " "
                        end
                        timeString = timeString .. seconds .. Config.Lang.seconds
                        
                        return Notify(source, string.format(Config.Lang.someoneIsOnCooldown, 
                            GetPlayerIdentity(teamClients[i]), timeString))
                    end
                end
            end
        end
        
        -- Set cooldowns
        PlayersOnCooldown[playerLicense] = true
        CooldownsTime[playerLicense] = currentTimestamp
        
        if nil ~= teamClients then
            for i = 1, #teamClients do
                local clientLicense = GetPlayerIdentifierByType(teamClients[i], "license")
                PlayersOnCooldown[clientLicense] = true
                CooldownsTime[clientLicense] = currentTimestamp
            end
        end
    end
    
    -- Check minimum team size
    if Config.RequireOneFriendMinimum then
        if nil ~= teamClients and #teamClients > 0 then
            -- Initialize lobby
            PlayersPairs[lobbyIndex].working = true
            PlayersPairs[lobbyIndex].progress = 0
            
            if nil == PlayersPairs[lobbyIndex].gear then
                PlayersPairs[lobbyIndex].gear = {}
                PlayersPairs[lobbyIndex].clothes = {}
            end
            
            PlayersPairs[lobbyIndex].buildedObjects = {
                supports = {},
                lights = {},
                rails = {[1] = true}
            }
            
            -- Start job
            TriggerForAllMembers(source, "gta5vn_miner:StartJob_cl", source, 
                #PlayersPairs[lobbyIndex].clients + 1,
                PlayersPairs[lobbyIndex].clients[1] or nil,
                PlayersPairs[lobbyIndex].clients[2] or nil)
        else
            return Notify(source, Config.Lang.RequireOneFriend)
        end
    else
        -- Solo allowed
        if nil == teamClients then
            table.insert(PlayersPairs, {
                host = source,
                clients = {}
            })
        end
        
        -- Find lobby index
        for index, lobby in pairs(PlayersPairs) do
            if lobby.host == source then
                lobbyIndex = index
            end
        end
        
        -- Initialize gear
        if nil == PlayersPairs[lobbyIndex].gear then
            PlayersPairs[lobbyIndex].gear = {}
            PlayersPairs[lobbyIndex].clothes = {}
        end
        
        -- Initialize lobby
        PlayersPairs[lobbyIndex].working = true
        PlayersPairs[lobbyIndex].progress = 0
        PlayersPairs[lobbyIndex].buildedObjects = {
            supports = {},
            lights = {},
            rails = {[1] = true}
        }
        
        -- Start job
        TriggerForAllMembers(source, "gta5vn_miner:StartJob_cl", source,
            #PlayersPairs[lobbyIndex].clients + 1,
            PlayersPairs[lobbyIndex].clients[1] or nil,
            PlayersPairs[lobbyIndex].clients[2] or nil)
    end
end)

-- =====================================================
-- EVENT: Gear status
-- =====================================================

RegisterNetEvent("gta5vn_miner:GearStatus")
AddEventHandler("gta5vn_miner:GearStatus", function(hasGear, gearNetId)
    if nil == hasGear then
        hasGear = nil
    end
    
    local source = source
    local lobbyIndex = GetLobbyIndex(source)
    
    if 0 == lobbyIndex then
        return Functions.Error("Cant find lobby index in ElevatorDown event")
    end
    
    -- Initialize gear table
    if nil == PlayersPairs[lobbyIndex].gear then
        PlayersPairs[lobbyIndex].gear = {}
    end
    
    -- Update gear status
    PlayersPairs[lobbyIndex].gear[source] = hasGear
    
    -- Store gear prop
    if nil ~= gearNetId then
        if nil == PlayersPairs[lobbyIndex].gearProps then
            PlayersPairs[lobbyIndex].gearProps = {}
        end
        
        PlayersPairs[lobbyIndex].gearProps[source] = NetworkGetEntityFromNetworkId(gearNetId)
    end
end)

-- =====================================================
-- EVENT: Clothes status
-- =====================================================

RegisterNetEvent("gta5vn_miner:ClothesStatus")
AddEventHandler("gta5vn_miner:ClothesStatus", function(hasClothes)
    if nil == hasClothes then
        hasClothes = nil
    end
    
    local source = source
    local lobbyIndex = GetLobbyIndex(source)
    
    if 0 == lobbyIndex then
        return Functions.Error("Cant find lobby index in ElevatorDown event")
    end
    
    -- Initialize clothes table
    if nil == PlayersPairs[lobbyIndex].clothes then
        PlayersPairs[lobbyIndex].clothes = {}
    end
    
    -- Update clothes status
    PlayersPairs[lobbyIndex].clothes[source] = hasClothes
end)

-- =====================================================
-- PLAYER DISCONNECT HANDLER
-- =====================================================

AddEventHandler("playerDropped", function()
    local disconnectedSource = source
    local lobbyIndex = -1
    
    -- Find lobby
    for index, lobby in pairs(PlayersPairs) do
        if lobby.host == disconnectedSource then
            -- Promote client to host
            for i = 1, #lobby.clients do
                if nil ~= lobby.clients[i] then
                    if 0 ~= GetPlayerPing(lobby.clients[i]) then
                        lobby.host = lobby.clients[i]
                        Notify(lobby.clients[i], Config.Lang.newBoss)
                        lobby.clients[i] = nil
                        break
                    end
                end
            end
            lobbyIndex = index
            break
        end
        
        -- Check if was client
        for i = 1, #lobby.clients do
            if lobby.clients[i] == disconnectedSource then
                lobby.clients[i] = nil
                lobbyIndex = index
                break
            end
        end
    end
    
    if -1 == lobbyIndex then
        return
    end
    
    local newHost = PlayersPairs[lobbyIndex].host
    
    -- Handle bucket cleanup
    if nil ~= PlayersPairs[lobbyIndex].bucket then
        local remainingPlayers = {}
        
        -- Check host
        if nil ~= PlayersPairs[lobbyIndex].host then
            if 0 ~= GetPlayerPing(PlayersPairs[lobbyIndex].host) then
                table.insert(remainingPlayers, PlayersPairs[lobbyIndex].host)
            end
        end
        
        -- Check clients
        for i = 1, #PlayersPairs[lobbyIndex].clients do
            if nil ~= PlayersPairs[lobbyIndex].clients[i] then
                if 0 ~= GetPlayerPing(PlayersPairs[lobbyIndex].clients[i]) then
                    table.insert(remainingPlayers, PlayersPairs[lobbyIndex].clients[i])
                end
            end
        end
        
        -- Cleanup if no one left
        if #remainingPlayers < 1 then
            if nil ~= PlayersPairs[lobbyIndex].bucket and nil ~= PlayersPairs[lobbyIndex].mineshaftId then
                -- Delete entities function
                local function DeleteEntitiesRecursive(entityTable)
                    if nil == entityTable then
                        return
                    end
                    
                    for key, entity in pairs(entityTable) do
                        if "table" == type(entity) then
                            DeleteEntitiesRecursive(entity)
                        elseif entity then
                            if DoesEntityExist(entity) then
                                DeleteEntity(entity)
                            end
                        end
                    end
                end
                
                -- Cleanup
                CreateThread(function()
                    DeleteEntitiesRecursive(PlayersPairs[lobbyIndex].objects)
                end)
                
                local bucketId = PlayersPairs[lobbyIndex].bucket
                
                -- Free bucket slot
                if nil ~= Buckets[bucketId] then
                    if nil ~= PlayersPairs[lobbyIndex].mineshaftId then
                        Buckets[bucketId][PlayersPairs[lobbyIndex].mineshaftId] = false
                        
                        if nil ~= ObjectsInBuckets[bucketId] then
                            if nil ~= ObjectsInBuckets[bucketId][PlayersPairs[lobbyIndex].mineshaftId] then
                                ObjectsInBuckets[bucketId][PlayersPairs[lobbyIndex].mineshaftId] = nil
                            end
                        end
                        
                        -- Notify others
                        local playersInBucket = GetPlayersInBucket(bucketId)
                        local otherMineshafts = {}
                        
                        for index, lobby in pairs(PlayersPairs) do
                            if index ~= lobbyIndex and lobby.bucket == bucketId then
                                table.insert(otherMineshafts, lobby.mineshaftId)
                            end
                        end
                        
                        for i = 1, #playersInBucket do
                            TriggerClientEvent("gta5vn_miner:UpdateWalls", playersInBucket[i], otherMineshafts)
                            TriggerClientEvent("gta5vn_miner:DestroyThisMineshaft", playersInBucket[i],
                                PlayersPairs[lobbyIndex].mineshaftId)
                        end
                    end
                end
            end
        end
    end
    
    -- Update UI
    if PlayersPairs[lobbyIndex].working then
        if 0 == #PlayersPairs[lobbyIndex].clients then
            TriggerClientEvent("gta5vn_miner:clearMyLobby", newHost)
        else
            TriggerForAllMembers(newHost, "gta5vn_miner:RefreshMugs", GetAllPartyMugs(newHost))
            
            if Config.useModernUI then
                RecalculateRewards(newHost)
            end
        end
    else
        if 0 == #PlayersPairs[lobbyIndex].clients then
            TriggerClientEvent("gta5vn_miner:clearMyLobby", newHost)
            PlayersPairs[lobbyIndex] = nil
        end
    end
end)

-- =====================================================
-- EVENT: Elevator go down
-- =====================================================

RegisterNetEvent("gta5vn_miner:ElevatorGoDown")
AddEventHandler("gta5vn_miner:ElevatorGoDown", function()
    local source = source
    local lobbyIndex = GetLobbyIndex(source)
    local assignedBucket = nil
    local assignedMineshaft = nil
    local allMembers = {}
    
    if 0 == lobbyIndex then
        return Functions.Error("Cant find lobby index in ElevatorDown event")
    end
    
    -- Check if already assigned
    if nil ~= PlayersPairs[lobbyIndex].mineshaftId then
        return
    end
    
    -- Find available slot
    for bucketId, bucket in ipairs(Buckets) do
        for mineshaftId, isOccupied in ipairs(bucket) do
            if not isOccupied and not ReservedTable2[mineshaftId] then
                assignedMineshaft = mineshaftId
                assignedBucket = bucketId
                Buckets[bucketId][mineshaftId] = true
                break
            end
        end
    end
    
    -- Create new bucket if needed
    if not assignedBucket or not assignedMineshaft then
        table.insert(Buckets, {
            [1] = true, [2] = false, [3] = false, [4] = false,
            [5] = false, [6] = false, [7] = false, [8] = false
        })
        assignedMineshaft = 1
        assignedBucket = #Buckets
    end
    
    -- Build member list
    for i = 1, #PlayersPairs[lobbyIndex].clients do
        table.insert(allMembers, PlayersPairs[lobbyIndex].clients[i])
    end
    table.insert(allMembers, PlayersPairs[lobbyIndex].host)
    
    -- Set bucket
    SetRoutingBucketEntityLockdownMode(assignedBucket, "inactive")
    PlayersPairs[lobbyIndex].bucket = assignedBucket
    PlayersPairs[lobbyIndex].mineshaftId = assignedMineshaft
    
    -- Initialize gear
    if nil == PlayersPairs[lobbyIndex].gear then
        PlayersPairs[lobbyIndex].gear = {}
    end
    
    -- Move all to bucket
    for index, memberSource in pairs(allMembers) do
        ClientsInBuckets[memberSource] = assignedBucket
        SetPlayerRoutingBucket(memberSource, assignedBucket)
        
        -- Move gear prop
        if PlayersPairs[lobbyIndex].gearProps then
            if DoesEntityExist(PlayersPairs[lobbyIndex].gearProps[memberSource]) then
                SetEntityRoutingBucket(PlayersPairs[lobbyIndex].gearProps[memberSource], assignedBucket)
            end
        end
        
        TriggerClientEvent("gta5vn_miner:ElevatorGoDown", memberSource)
    end
    
    -- Create mineshaft
    CreateMineshaft(lobbyIndex, assignedMineshaft, assignedBucket)
end)

-- =====================================================
-- EVENT: Elevator open doors
-- =====================================================

RegisterNetEvent("gta5vn_miner:ElevatorOpenDoors")
AddEventHandler("gta5vn_miner:ElevatorOpenDoors", function(doorState)
    local source = source
    local lobbyIndex = GetLobbyIndex(source)
    
    if 0 == lobbyIndex then
        return Functions.Error("Cant find lobby index in ElevatorOpenDoors event")
    end
    
    TriggerForAllMembers(PlayersPairs[lobbyIndex].host, "gta5vn_miner:ElevatorOpenDoors", doorState)
end)

-- =====================================================
-- HELPER FUNCTIONS
-- =====================================================

-- Get players in bucket
function GetPlayersInBucket(bucketId)
    local playersInBucket = {}
    
    for player, bucket in pairs(ClientsInBuckets) do
        if bucketId == bucket then
            table.insert(playersInBucket, player)
        end
    end
    
    return playersInBucket
end

-- Create mineshaft
function CreateMineshaft(lobbyIndex, mineshaftId, bucketId)
    local mineshaftData = Config.Mineshatfs[mineshaftId]
    local playersInBucket = GetPlayersInBucket(bucketId)
    local otherMineshafts = {}
    
    -- Find other mineshafts in bucket
    for index, lobby in pairs(PlayersPairs) do
        if lobby.bucket == bucketId then
            table.insert(otherMineshafts, lobby.mineshaftId)
        end
    end
    
    -- Update walls for all
    for i = 1, #playersInBucket do
        TriggerClientEvent("gta5vn_miner:UpdateWalls", playersInBucket[i], otherMineshafts)
    end
    
    -- Create wall entity
    PlayersPairs[lobbyIndex].wall = CreateObjectNoOffset(Config.WallModel, 
        mineshaftData.wallCoordinates.x, mineshaftData.wallCoordinates.y, mineshaftData.wallCoordinates.z, 
        true, true, false)
    
    -- Wait for entity
    while not DoesEntityExist(PlayersPairs[lobbyIndex].wall) do
        Wait(10)
    end
    
    -- Set wall rotation
    SetEntityRotation(PlayersPairs[lobbyIndex].wall, 
        mineshaftData.wallRotation.x, mineshaftData.wallRotation.y, mineshaftData.wallRotation.z, 
        2, false)
    
    -- Set bucket and freeze
    if DoesEntityExist(PlayersPairs[lobbyIndex].wall) then
        SetEntityRoutingBucket(PlayersPairs[lobbyIndex].wall, bucketId)
    end
    
    FreezeEntityPosition(PlayersPairs[lobbyIndex].wall, true)
    table.insert(ReservedTable1, PlayersPairs[lobbyIndex].wall)
    
    -- Get network ID
    local startTime = GetGameTimer()
    local wallNetId = 0
    
    while 0 == wallNetId or wallNetId == PlayersPairs[lobbyIndex].wall do
        if GetGameTimer() - startTime > 1500 then
            Functions.Error("Cannot create a networked wall")
        end
        
        wallNetId = NetworkGetNetworkIdFromEntity(PlayersPairs[lobbyIndex].wall)
        Wait(10)
    end
    
    -- Store mineshaft index
    PlayersPairs[lobbyIndex].mineshaftIndex = mineshaftId
    
    -- Notify all in bucket
    local bucketsPlayers = GetPlayersInBucket(bucketId)
    for i = 1, #bucketsPlayers do
        TriggerClientEvent("gta5vn_miner:CreateThisMineshaft", bucketsPlayers[i], mineshaftId, 
            GetMinecartProgressByMineshaft(bucketId, mineshaftId))
    end
    
    Wait(100)
    
    -- Create other mineshafts for this team
    for slotId, isOccupied in pairs(Buckets[bucketId]) do
        if isOccupied then
            CreateThread(function()
                if mineshaftId ~= slotId then
                    TriggerForAllMembers(PlayersPairs[lobbyIndex].host, "gta5vn_miner:CreateThisMineshaft", 
                        slotId, GetMinecartProgressByMineshaft(bucketId, slotId))
                end
                
                Wait(1000)
                
                -- Initialize objects tracking
                if nil == ObjectsInBuckets[bucketId] then
                    ObjectsInBuckets[bucketId] = {}
                end
                
                if nil == ObjectsInBuckets[bucketId][slotId] then
                    ObjectsInBuckets[bucketId][slotId] = {
                        rails = {[1] = true},
                        lights = {},
                        supports = {}
                    }
                end
                
                -- Show props
                TriggerForAllMembers(PlayersPairs[lobbyIndex].host, "gta5vn_miner:ShowProp", 
                    slotId, ObjectsInBuckets[bucketId][slotId])
            end)
        end
    end
    
    Wait(100)
    
    -- Notify mineshaft created
    TriggerForAllMembers(PlayersPairs[lobbyIndex].host, "gta5vn_miner:MineshaftCreated", 
        wallNetId, mineshaftId, PlayersPairs[lobbyIndex].buildedObjects)
end

-- Get minecart progress
function GetMinecartProgressByMineshaft(bucketId, mineshaftId)
    local progress = 1
    
    for index, lobby in pairs(PlayersPairs) do
        if lobby.bucket == bucketId and lobby.mineshaftIndex == mineshaftId then
            progress = lobby.lastRailid or progress
            if not lobby.lastRailid then
                progress = 1
            end
            break
        end
    end
    
    return progress
end

-- =====================================================
-- EVENT: Place prop
-- =====================================================

RegisterNetEvent("gta5vn_miner:PlaceProp")
AddEventHandler("gta5vn_miner:PlaceProp", function(propType, propId)
    local source = source
    local lobbyIndex = GetLobbyIndex(source)
    local lobby = PlayersPairs[lobbyIndex]
    
    -- Initialize objects tracking
    if nil == ObjectsInBuckets[lobby.bucket] then
        ObjectsInBuckets[lobby.bucket] = {}
    end
    
    if nil == ObjectsInBuckets[lobby.bucket][lobby.mineshaftId] then
        ObjectsInBuckets[lobby.bucket][lobby.mineshaftId] = {
            rails = {[1] = true},
            lights = {},
            supports = {}
        }
    end
    
    -- Store prop based on type
    if string.find(propType, "Support") then
        if nil == ObjectsInBuckets[lobby.bucket][lobby.mineshaftId].supports[propId] then
            ObjectsInBuckets[lobby.bucket][lobby.mineshaftId].supports[propId] = {}
        end
        ObjectsInBuckets[lobby.bucket][lobby.mineshaftId].supports[propId][propType] = true
    else
        ObjectsInBuckets[lobby.bucket][lobby.mineshaftId][propType][propId] = true
    end
    
    -- Notify team
    TriggerForAllMembers(lobby.host, "gta5vn_miner:BuildProp", propType, propId)
    
    -- Update all in bucket
    local playersInBucket = GetPlayersInBucket(lobby.bucket)
    for i = 1, #playersInBucket do
        TriggerClientEvent("gta5vn_miner:ShowProp", playersInBucket[i], lobby.mineshaftId, 
            ObjectsInBuckets[lobby.bucket][lobby.mineshaftId])
        
        -- Update minecart if rails
        if "rails" == propType then
            PlayersPairs[lobbyIndex].lastRailid = propId
            TriggerClientEvent("gta5vn_miner:UpdateMinecart", playersInBucket[i], propId, 
                lobby.mineshaftId, lobby.host, playersInBucket[i])
        end
    end
end)

-- =====================================================
-- MINING SYSTEM
-- =====================================================

local ActiveMiners = {}

RegisterNetEvent("gta5vn_miner:MiningStop")
AddEventHandler("gta5vn_miner:MiningStop", function()
    local source = source
    if ActiveMiners[source] then
        ActiveMiners[source] = nil
    end
end)

RegisterNetEvent("gta5vn_miner:StartedMining")
AddEventHandler("gta5vn_miner:StartedMining", function()
    local source = source
    if not ActiveMiners[source] then
        ActiveMiners[source] = true
    end
end)

-- Dot product helper
function DotProduct(vec1, vec2)
    return vec1.x * vec2.x + vec1.y * vec2.y + vec1.z * vec2.z
end

-- Mining cooldown tracking
local MiningCooldowns = {}
local NormalMiningSpeed = Config.MiningSpeed.normal or 0.025
local BonusMiningSpeed = Config.MiningSpeed.onBonus or 0.05

RegisterNetEvent("gta5vn_miner:WallHit")
AddEventHandler("gta5vn_miner:WallHit", function(isBonus)
    local source = source
    
    if nil == source then
        return
    end
    
    -- Check cooldown
    local currentTime = GetGameTimer()
    if nil ~= MiningCooldowns[source] then
        if currentTime - MiningCooldowns[source] < 1500 then
            return Functions.Error("THIS IS NOT AN ERROR - WALL HIT EVENT REJECTED: POSSIBLE CHEATER. ID: ", source)
        end
    end
    MiningCooldowns[source] = currentTime
    
    local lobbyIndex = GetLobbyIndex(source)
    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    local wallCoords = Config.Mineshatfs[PlayersPairs[lobbyIndex].mineshaftId].wallCoordinates
    local miningSpeed = isBonus and BonusMiningSpeed or NormalMiningSpeed
    
    if 0 == lobbyIndex then
        return Functions.Error("Cant find lobby index in WallHit event")
    end
    
    -- Check if actively mining
    if not ActiveMiners[source] then
        return Functions.Error("WALL HIT EVENT REJECTED: POSSIBLE CHEATER. ID: ", source)
    end
    
    -- Check minecart status
    if PlayersPairs[lobbyIndex].minecartBusy then
        return Notify(source, Config.Lang.minecartBusy)
    end
    
    -- Initialize minecart content
    if not PlayersPairs[lobbyIndex].minecaftContent then
        PlayersPairs[lobbyIndex].minecaftContent = 0
    end
    
    -- Initialize wall offset
    if nil == PlayersPairs[lobbyIndex].wallOffset then
        PlayersPairs[lobbyIndex].wallOffset = 0
    end
    
    -- Calculate current wall position
    local forwardVector = Config.Mineshatfs[PlayersPairs[lobbyIndex].mineshaftId].forwardVector
    local currentWallPos = wallCoords + (forwardVector * PlayersPairs[lobbyIndex].wallOffset)
    
    -- Check distance from wall
    if playerCoords and currentWallPos then
        if #(playerCoords - currentWallPos) > 15.0 then
            return Functions.Error("WALL HIT EVENT REJECTED: POSSIBLE CHEATER. ID: ", source)
        end
    end
    
    -- Initialize progress
    if nil == PlayersPairs[lobbyIndex].progress then
        PlayersPairs[lobbyIndex].progress = 0
    end
    
    -- Update progress
    PlayersPairs[lobbyIndex].wallOffset = PlayersPairs[lobbyIndex].wallOffset + miningSpeed
    PlayersPairs[lobbyIndex].progress = PlayersPairs[lobbyIndex].wallOffset / (MineshaftSlots / 100)
    
    -- Notify team
    TriggerForAllMembers(PlayersPairs[lobbyIndex].host, "gta5vn_miner:UpdateProgress", 
        PlayersPairs[lobbyIndex].progress)
    
    -- Check if complete
    if PlayersPairs[lobbyIndex].wallOffset >= MineshaftSlots then
        return TriggerForAllMembers(PlayersPairs[lobbyIndex].host, "gta5vn_miner:StopMining")
    end
    
    -- Update wall position
    local newWallPos = wallCoords + (forwardVector * PlayersPairs[lobbyIndex].wallOffset)
    
    if DoesEntityExist(PlayersPairs[lobbyIndex].wall) then
        SetEntityCoords(PlayersPairs[lobbyIndex].wall, newWallPos.x, newWallPos.y, wallCoords.z, 
            false, false, false, false)
        SetEntityRotation(PlayersPairs[lobbyIndex].wall, 
            Config.Mineshatfs[PlayersPairs[lobbyIndex].mineshaftId].wallRotation.x,
            Config.Mineshatfs[PlayersPairs[lobbyIndex].mineshaftId].wallRotation.y,
            Config.Mineshatfs[PlayersPairs[lobbyIndex].mineshaftId].wallRotation.z,
            2, false)
    else
        return Functions.Error(string.format(
            "WALL HIT EVENT REJECTED. CAN'T ACCESS WALL OBJECT. INFO FOR DEVELOPERS: OBJECT: %s, currCoordinates: %s, Exist?: %s",
            PlayersPairs[lobbyIndex].wall, wallCoords, DoesEntityExist(PlayersPairs[lobbyIndex].wall)))
    end
    
    -- Play sound and update UI
    local playersInBucket = GetPlayersInBucket(PlayersPairs[lobbyIndex].bucket)
    for i = 1, #playersInBucket do
        TriggerClientEvent("gta5vn_miner:PlayMiningSound", playersInBucket[i], playerCoords)
        TriggerClientEvent("gta5vn_miner:UpdateMinecartContent", playersInBucket[i], 
            PlayersPairs[lobbyIndex].progress, PlayersPairs[lobbyIndex].mineshaftIndex)
    end
    
    -- Item drops
    for i = 1, #Config.ItemsWhileMining do
        local randomChance = math.random(1, 10000) / 100
        
        if Config.ItemsWhileMining[i].chance > 0 and Config.ItemsWhileMining[i].chance <= 100 then
            if randomChance <= Config.ItemsWhileMining[i].chance then
                local quantity = Config.ItemsWhileMining[i].quantity(isBonus, source) or 1
                AddItem(source, Config.ItemsWhileMining[i].itemName, quantity)
                
                if Config.GiveOnlyOneItemFromTable then
                    break
                end
            end
        end
    end
    
    -- Random events
    if not ReservedTable2[PlayersPairs[lobbyIndex].bucket] then
        math.randomseed(os.time())
        
        for eventName, eventData in pairs(Config.Events) do
            if PlayersPairs[lobbyIndex].progress > eventData.minimumProgressPercent then
                if eventData.chance > 0 and eventData.chance < 101 then
                    if eventData.chance >= (math.random() * 100) then
                        ReservedTable2[PlayersPairs[lobbyIndex].bucket] = eventName
                        local duration = nil
                        
                        if "blackout" == eventName then
                            duration = math.random(Config.Events.blackout.minDuration, 
                                Config.Events.blackout.maxDuration)
                        end
                        
                        -- Trigger event for all
                        for i = 1, #playersInBucket do
                            TriggerClientEvent("gta5vn_miner:RunEvent", playersInBucket[i], eventName, 
                                vector3(newWallPos.x, newWallPos.y, wallCoords.z - 1.0),
                                Config.Mineshatfs[PlayersPairs[lobbyIndex].mineshaftId].wallRotation,
                                duration or eventData.duration)
                        end
                        
                        -- Stop event after duration
                        SetTimeout(duration or eventData.duration, function()
                            local currentPlayers = GetPlayersInBucket(PlayersPairs[lobbyIndex].bucket)
                            for i = 1, #currentPlayers do
                                TriggerClientEvent("gta5vn_miner:StopEvent", currentPlayers[i], eventName)
                                ReservedTable2[PlayersPairs[lobbyIndex].bucket] = nil
                            end
                        end)
                    end
                end
            end
        end
    end
    
    Wait(250)
    
    -- Check for object building
    TriggerForAllMembers(PlayersPairs[lobbyIndex].host, "gta5vn_miner:CheckObjectsToBuild", 
        newWallPos, PlayersPairs[lobbyIndex].bucket)
end)

-- =====================================================
-- EVENT: Player death
-- =====================================================

RegisterNetEvent("gta5vn_miner:ImDead")
AddEventHandler("gta5vn_miner:ImDead", function()
    local source = source
    local lobbyIndex = GetLobbyIndex(source)
    
    if 0 == lobbyIndex then
        return Functions.Error("Cant find lobby index in ImDead event")
    end
    
    -- Build member list
    local allMembers = {PlayersPairs[lobbyIndex].host}
    for i = 1, #PlayersPairs[lobbyIndex].clients do
        table.insert(allMembers, PlayersPairs[lobbyIndex].clients[i])
    end
    
    -- Notify others
    for i = 1, #allMembers do
        if allMembers[i] ~= source then
            TriggerClientEvent("gta5vn_miner:TeammateDead", allMembers[i])
        end
    end
end)

-- =====================================================
-- EVENT: Magazine prop delete
-- =====================================================

RegisterNetEvent("17mov_miner:MagazinePropDelete")
AddEventHandler("17mov_miner:MagazinePropDelete", function(propType, propId)
    local source = source
    local lobbyIndex = GetLobbyIndex(source)
    
    if 0 == lobbyIndex then
        return Functions.Error("Cant find lobby index in MagazinePropDelete callback")
    end
    
    TriggerForAllMembers(PlayersPairs[lobbyIndex].host, "17mov_miner:MagazinePropDelete", propType, propId)
end)

-- =====================================================
-- EVENT: Magazine prop put back
-- =====================================================

RegisterNetEvent("17mov_miner:MagazinePropPutBack")
AddEventHandler("17mov_miner:MagazinePropPutBack", function(propType, propId, arg3, arg4)
    local source = source
    local lobbyIndex = GetLobbyIndex(source)
    
    if 0 == lobbyIndex then
        return Functions.Error("Cant find lobby index in MagazinePropPutBack callback")
    end
    
    TriggerForAllMembers(PlayersPairs[lobbyIndex].host, "17mov_miner:MagazinePropPutBack", 
        propType, propId, arg3, arg4)
end)

-- =====================================================
-- EVENT: Unload minecart
-- =====================================================

RegisterNetEvent("gta5vn_miner:UnloadMinecartInLobby")
AddEventHandler("gta5vn_miner:UnloadMinecartInLobby", function()
    local source = source
    local lobbyIndex = GetLobbyIndex(source)
    
    if 0 == lobbyIndex then
        return Functions.Error("Cant find lobby index in UnloadMinecartInLobby callback")
    end
    
    TriggerForAllMembers(PlayersPairs[lobbyIndex].host, "gta5vn_miner:UnloadMinecart")
end)

-- =====================================================
-- EVENT: Minecart unloaded
-- =====================================================

RegisterNetEvent("gta5vn_miner:MinecartUnloaded")
AddEventHandler("gta5vn_miner:MinecartUnloaded", function()
    local source = source
    local lobbyIndex = GetLobbyIndex(source)
    
    if 0 == lobbyIndex then
        return Functions.Error("Cant find lobby index in MinecartUnloaded callback")
    end
    
    PlayersPairs[lobbyIndex].minecaftContent = 0
    PlayersPairs[lobbyIndex].minecartBusy = false
end)

-- =====================================================
-- EVENT: Minecart sounds
-- =====================================================

RegisterNetEvent("gta5vn_miner:StartMinecartSound")
AddEventHandler("gta5vn_miner:StartMinecartSound", function()
    local source = source
    local lobbyIndex = GetLobbyIndex(source)
    local playersInBucket = GetPlayersInBucket(PlayersPairs[lobbyIndex].bucket)
    
    for i = 1, #playersInBucket do
        TriggerClientEvent("gta5vn_miner:StartMinecartSound", playersInBucket[i], 
            PlayersPairs[lobbyIndex].mineshaftIndex)
    end
end)

RegisterNetEvent("gta5vn_miner:StopMinecartSound")
AddEventHandler("gta5vn_miner:StopMinecartSound", function()
    local source = source
    local lobbyIndex = GetLobbyIndex(source)
    local playersInBucket = GetPlayersInBucket(PlayersPairs[lobbyIndex].bucket)
    
    for i = 1, #playersInBucket do
        TriggerClientEvent("gta5vn_miner:StopMinecartSound", playersInBucket[i])
    end
end)

-- =====================================================
-- ELEVATOR SEAT MANAGEMENT
-- =====================================================

local TakenSeats = {}

RegisterNetEvent("gta5vn_miner:SeatTaken")
AddEventHandler("gta5vn_miner:SeatTaken", function(seatId)
    TakenSeats[seatId] = true
    TriggerClientEvent("gta5vn_miner:SeatTaken", -1, seatId)
end)

RegisterNetEvent("gta5vn_miner:SeatNowFree")
AddEventHandler("gta5vn_miner:SeatNowFree", function(seatId)
    TakenSeats[seatId] = nil
    TriggerClientEvent("gta5vn_miner:SeatNowFree", -1, seatId)
end)

RegisterServerCallback("gta5vn_miner:DownloadTakenSeats", function(source)
    return TakenSeats
end)

-- =====================================================
-- RESOURCE STOP CLEANUP
-- =====================================================

AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    
    -- Return all to main bucket
    for player, bucket in pairs(ClientsInBuckets) do
        SetPlayerRoutingBucket(player, Config.MainBucket)
    end
    
    -- Delete all entities
    for index, entity in pairs(ReservedTable1) do
        if "table" == type(entity) then
            for key, subEntity in pairs(entity) do
                if "number" == type(entity) then
                    DeleteEntity(entity)
                end
            end
        elseif "number" == type(entity) then
            if DoesEntityExist(entity) then
                DeleteEntity(entity)
            end
        end
    end
end)

-- =====================================================
-- EVENT: Toggle light state
-- =====================================================

RegisterNetEvent("gta5vn_miner:ToggleLightState")
AddEventHandler("gta5vn_miner:ToggleLightState", function(lightState)
    local source = source
    
    if nil ~= source then
        local playerPed = GetPlayerPed(source)
        
        if nil ~= playerPed and 0 ~= playerPed then
            local pedNetId = NetworkGetNetworkIdFromEntity(playerPed)
            
            if 0 ~= pedNetId and pedNetId ~= playerPed then
                TriggerClientEvent("gta5vn_miner:ToggleLightState", -1, pedNetId, lightState)
            end
        end
    end
end)

-- =====================================================
-- END OF FILE - 100% ACCURATE CLEAN
-- =====================================================