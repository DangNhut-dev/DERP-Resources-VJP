if Config.Core:upper() == 'ESX' then                                                     
    Core = exports['es_extended']:getSharedObject()
    LoadedEvent = 'esx:playerLoaded'
    ReviveEvent = 'esx_ambulancejob:revive'
    TSCB = Core.TriggerServerCallback

elseif Config.Core:upper() == 'QBCORE' then

    Core = exports['qb-core']:GetCoreObject()
    LoadedEvent = 'QBCore:Client:OnPlayerLoaded'
    ReviveEvent = 'hospital:client:Revive'
    TSCB = Core.Functions.TriggerCallback

end