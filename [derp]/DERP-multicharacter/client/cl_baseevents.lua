RegisterNetEvent('DERP-multicharacter:Listener:WelcomeScreenStateChanged')
AddEventHandler('DERP-multicharacter:Listener:WelcomeScreenStateChanged', function(state)
    if state then
        --Executed when welcome screen changes state to true
    elseif not state then
        --Executed when welcome screen changes state to false
    end
    --@param state [boolean]
end)

RegisterNetEvent('DERP-multicharacter:Listener:MainInitialized')
AddEventHandler('DERP-multicharacter:Listener:MainInitialized', function()
    --Execute code whenever it's first initialization when NetworkIsPlayerActive() native returns true
end)

RegisterNetEvent('DERP-multicharacter:Listener:MainFinishedWork')
AddEventHandler('DERP-multicharacter:Listener:MainFinishedWork', function()
    --Execute code whenever it's first initialization when NetworkIsPlayerActive() native returns true
    SetCanAttackFriendly(PlayerPedId(), true, false)
    NetworkSetFriendlyFireOption(true)
end)

RegisterNetEvent('DERP-multicharacter:Listener:MulticharacterInitialized')
AddEventHandler('DERP-multicharacter:Listener:MulticharacterInitialized', function(isLogout)
    --Executed code when Multicharacter content switches on
    --@param isLogout [boolean]
    --Specifice if the Multicharacter was initiliazed via logout
end)

RegisterNetEvent('DERP-multicharacter:Listener:MulticharacterFinished')
AddEventHandler('DERP-multicharacter:Listener:MulticharacterFinished', function()
    --Execute code when Multicharacter content switches off
    SetCanAttackFriendly(PlayerPedId(), true, false)
    NetworkSetFriendlyFireOption(true)
end)

RegisterNetEvent('DERP-multicharacter:Listener:SwappedCharacter')
AddEventHandler('DERP-multicharacter:Listener:SwappedCharacter', function(characterData, characterId)
    --Execute code when player will swap the character
    --@param characterID [int]
    --@param characterData [object]
    --characterId is order from the gathered data from sql. First id for the specific WHERE selector to the Last id.
end)

RegisterNetEvent('DERP-multicharacter:Listener:SelectedCharacter')
AddEventHandler('DERP-multicharacter:Listener:SelectedCharacter', function(characterId)
    --Execute code when player will select his character
    --@param characterID [int]
    --characterId is order from the gathered data from sql. First id for the specific WHERE selector to the Last id.
    SetCanAttackFriendly(PlayerPedId(), true, false)
    NetworkSetFriendlyFireOption(true)
end)

RegisterNetEvent('DERP-multicharacter:Listener:CharacterCreated')
AddEventHandler('DERP-multicharacter:Listener:CharacterCreated', function(characterData)
    --Execute code when user character is created
    --@param characterData [OBJECT]
    --Contains firstname, lastname, dateofbirth, height, gender
    SetCanAttackFriendly(PlayerPedId(), true, false)
    NetworkSetFriendlyFireOption(true)
end)

RegisterNetEvent('DERP-multicharacter:Listener:CharacterRemoved')
AddEventHandler('DERP-multicharacter:Listener:CharacterRemoved', function(characterId, characterIdentifier, haveOtherCharacters)
    --Execute code when user character is created
    --@param characterId [INT]
    --@param characterId [STRING]
    --@param haveOtherCharacters [BOOLEAN]
    --characterId is variable containg identifier (number) of the player | cid = QB | char<characterId>:<identifier> = ESX
end)

RegisterNetEvent('DERP-multicharacter:Listener:LocationsInitializing')
AddEventHandler('DERP-multicharacter:Listener:LocationsInitializing', function()
    --Execute code when user will click on Locations button
end)

RegisterNetEvent('DERP-multicharacter:Listener:LocationsDisabled')
AddEventHandler('DERP-multicharacter:Listener:LocationsDisabled', function()
    --Execute code when user will click use Escape to disable Locations
end)

RegisterNetEvent('DERP-multicharacter:Listener:ChangedLocation')
AddEventHandler('DERP-multicharacter:Listener:ChangedLocation', function(locationCoords)
    --Execute the code when user will click enter on specific location
    --@param locationCoords [vector3]
    --Returns location coords for user selected location
end)

RegisterNetEvent('DERP-multicharacter:CreateQBInstance')
AddEventHandler('DERP-multicharacter:CreateQBInstance', function(data)
    local Player = QBCore.Functions.GetPlayerData()
    if GetResourceState('qs-housing') == 'started' then
        local insidehouse = Player.metadata['inside']
        if insidehouse.house ~= nil then
            local houseid = insidehouse.house
            TriggerEvent('qb-houses:client:LastLocationHouse', houseid)
        end
    end

    TriggerServerEvent('qb-multicharacter:server:createCharacter', data)
    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
end)

GetConfigValue = function(key)
    if not key then return false end
    return Config[key]
end

GetUserStorage = function()
    return Storage.Data
end

exports('GetConfigValue', GetConfigValue)
exports('GetUserStorage', GetUserStorage)
exports('CanSwapCoords', World.PreventSwapCoords)
exports('Logout', Logout)
exports('SetLocationsDisabled', Locations.SetLocationsDisabled)

RegisterNetEvent('DERP-multicharacter:LogoutPlayer')
AddEventHandler('DERP-multicharacter:LogoutPlayer', function()
    Logout()
end)

RegisterNetEvent('ZSX_UIV2:Storage:OnColorUpdate')
AddEventHandler('ZSX_UIV2:Storage:OnColorUpdate', function(color)
    NUI.ApplyColor(color)
end)

--[[
    DOCS: https://zsx-development.gitbook.io/docs/multicharacter/baseevents
]]