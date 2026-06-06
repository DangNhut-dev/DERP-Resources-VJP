local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local isLoggedIn = false
local menuOpen = false
local allowAutoOpen = false -- Extra safeguard flag
local currentPermissions = nil
local DEBUG_MODE = true
local LAST_DEBUG = ""
local currentEntityType = "job"

-- Debug function
local function DebugPrint(msg)
    if DEBUG_MODE then
        print("^3[DERP-bossmenu Debug]^7 " .. msg)
        LAST_DEBUG = msg
    end
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    isLoggedIn = true
    menuOpen = false
    Wait(2000)
    CreateJobTargetPoints()  
    CreateApplicationPoints() 
end)

RegisterNetEvent('DERP-bossmenu:client:JobChanged', function(jobName)
    if menuOpen and PlayerData.job and PlayerData.job.isboss and PlayerData.job.name == jobName then
        QBCore.Functions.TriggerCallback('DERP-bossmenu:server:GetJobData', function(jobData)
            if jobData then
                SendNUIMessage({
                    action = "refreshData",
                    jobData = jobData
                })
            end
        end, jobName)
    end
end)

RegisterNetEvent('QBCore:Client:OnGangUpdate', function(GangInfo)
    PlayerData.gang = GangInfo
    
    if menuOpen then
        if PlayerData.gang.isboss then
            QBCore.Functions.TriggerCallback('DERP-bossmenu:server:GetJobData', function(gangData)
                if gangData then
                    SendNUIMessage({
                        action = "refreshData",
                        jobData = gangData
                    })
                end
            end, PlayerData.gang.name, "gang")
        else
            SetNuiFocus(false, false)
            SendNUIMessage({ action = "closeUI" })
            menuOpen = false
        end
    end
end)

function UseTargetSystem(action, ...)
    if Config.TargetSystem == "qb-target" then
        return exports['qb-target'][action](...)
    elseif Config.TargetSystem == "ox_target" then
        local oxAction = action:gsub("^%u", string.lower) 
        return exports.ox_target[oxAction](...)
    end
end


function CreateApplicationPoints()    
    if not Config.EnableApplicationSystem then 
        return 
    end
    
    if not Config.ApplicationPoints then
        return
    end
    
    for jobName, location in pairs(Config.ApplicationPoints) do
        if Config.TargetSystem == "qb-target" then
            exports['qb-target']:AddBoxZone("job_application_"..jobName, location.coords, location.length, location.width, {
                name = "job_application_"..jobName,
                heading = location.heading,
                debugPoly = false,
                minZ = location.minZ,
                maxZ = location.maxZ,
            }, {
                options = {
                    {
                        type = "client",
                        event = "DERP-bossmenu:client:OpenApplicationForm",
                        icon = "fas fa-file-alt",
                        label = location.label,
                        job = false, 
                        canInteract = function()
                            return true
                        end,
                        jobData = jobName
                    },
                },
                distance = 2.0
            })
        elseif Config.TargetSystem == "ox_target" then
            exports.ox_target:addBoxZone({
                coords = location.coords,
                size = {location.length, location.width, location.maxZ - location.minZ},
                rotation = location.heading,
                debug = false,
                options = {
                    {
                        name = "job_application_"..jobName,
                        icon = "fas fa-file-alt",
                        label = location.label,
                        onSelect = function()
                            TriggerEvent("DERP-bossmenu:client:OpenApplicationForm", {jobData = jobName})
                        end,
                        distance = 2.0
                    }
                }
            })
        end
    end
end

-- Register event to open application form
RegisterNetEvent('DERP-bossmenu:client:OpenApplicationForm', function(data)
    local jobName = data.jobData
    
    if not jobName then 
        QBCore.Functions.Notify("Invalid application spot", "error")
        return 
    end

    local jobApplication = Config.ApplicationQuestions[jobName]

    if not jobApplication then
        QBCore.Functions.Notify("Invalid application spot", "error")
        return
    end

    QBCore.Functions.TriggerCallback('DERP-bossmenu:server:CheckPendingApplication', function(hasPendingApplication)
        if hasPendingApplication then
           -- QBCore.Functions.Notify("You already have a pending application for this job. Please wait for a response.", "error")
            return
        end
        
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = "openApplicationForm",
            data = {
                job = {
                    name = jobName,
                    label = QBCore.Shared.Jobs[jobName].label
                },
                applicationData = jobApplication
            }
        })
    end, jobName)
end)

RegisterNetEvent('DERP-bossmenu:client:SyncPermissions', function(targetCitizenid, permissions)
    if not PlayerData.job or not PlayerData.job.isboss then return end
    
    if menuOpen and selectedEmployeeForPermissions and selectedEmployeeForPermissions.citizenid == targetCitizenid then
        currentEmployeePermissions = permissions
        
        SendNUIMessage({
            action = "updatePermissionToggles",
            permissions = permissions
        })
    end
end)


RegisterNetEvent('eventName', function()
    SetNuiFocus(true, true)
    
    SendNUIMessage({
        action = "testModal",
        message = "This is a test modal"
    })
end, false)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    isLoggedIn = false
    PlayerData = {}
    menuOpen = false
end)

RegisterNUICallback('getApplications', function(data, cb)
    local jobName = data.jobName
    
    QBCore.Functions.TriggerCallback('DERP-bossmenu:server:GetJobApplications', function(applications)
        cb(applications)
    end, jobName)
end)


RegisterNUICallback('updateApplicationStatus', function(data, cb)
    TriggerServerEvent('DERP-bossmenu:server:UpdateApplicationStatus', data.applicationId, data.status, data.notes)
    cb('ok')
end)
RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    local oldJob = PlayerData.job and PlayerData.job.name or "none"
    PlayerData.job = JobInfo
    
    -- If the menu is open, refresh it
    if menuOpen then
        if PlayerData.job.isboss then
            QBCore.Functions.TriggerCallback('DERP-bossmenu:server:GetJobData', function(jobData)
                if jobData then
                    SendNUIMessage({
                        action = "refreshData",
                        jobData = jobData
                    })
                end
            end, PlayerData.job.name)
        else
            -- If the player is no longer a boss, close the menu
            SetNuiFocus(false, false)
            SendNUIMessage({ action = "closeUI" })
            menuOpen = false
        end
    end
end)

-- Create ONLY interaction points for job management
function CreateJobTargetPoints()
    for jobName, _ in pairs(Config.Locations) do
        if Config.TargetSystem == "qb-target" then
            exports['qb-target']:RemoveZone("jobmanagement_"..jobName)
            
            local i = 1
            while true do
                local zoneExists = exports['qb-target']:RemoveZone("jobmanagement_"..jobName.."_"..i)
                if not zoneExists then
                    break
                end
                i = i + 1
            end
        elseif Config.TargetSystem == "ox_target" then
            exports.ox_target:removeZone("jobmanagement_"..jobName)
            
            local i = 1
            while i <= 10 do 
                exports.ox_target:removeZone("jobmanagement_"..jobName.."_"..i)
                i = i + 1
            end
        end
    end
    
    for jobName, jobData in pairs(Config.Locations) do
        local jobLabel = jobData.label
        local entityType = jobData.type or "job" -- THÊM

        for locationIndex, location in ipairs(jobData.locations) do
            local zoneName = "jobmanagement_"..jobName
            if locationIndex > 1 then
                zoneName = zoneName.."_"..locationIndex
            end

            if Config.TargetSystem == "qb-target" then
                exports['qb-target']:AddBoxZone(zoneName, location.coords, location.length, location.width, {
                    name = zoneName,
                    heading = location.heading,
                    debugPoly = false,
                    minZ = location.minZ,
                    maxZ = location.maxZ,
                }, {
                    options = {
                        {
                            type = "client",
                            event = "DERP-bossmenu:client:TriggerOpenManager",
                            icon = entityType == "gang" and "fas fa-skull" or "fas fa-briefcase",
                            label = "Quản Lý " .. jobLabel,
                            canInteract = function()
                                -- THÊM: phân biệt gang vs job
                                if entityType == "gang" then
                                    return PlayerData.gang and PlayerData.gang.name == jobName
                                else
                                    return PlayerData.job and PlayerData.job.name == jobName
                                end
                            end,
                            jobData = jobName,
                            entityType = entityType 
                        },
                    },
                    distance = 2.0
                })
            elseif Config.TargetSystem == "ox_target" then
                exports.ox_target:addBoxZone({
                    coords = location.coords,
                    size = {location.length, location.width, location.maxZ - location.minZ},
                    rotation = location.heading,
                    debug = false,
                    options = {
                        {
                            name = zoneName,
                            icon = entityType == "gang" and "fas fa-skull" or "fas fa-briefcase",
                            label = "Quản Lý " .. jobLabel,
                            onSelect = function()
                                TriggerEvent("DERP-bossmenu:client:TriggerOpenManager", {
                                    jobData = jobName,
                                    entityType = entityType 
                                })
                            end,
                            canInteract = function()
                                -- THÊM: phân biệt gang vs job
                                if entityType == "gang" then
                                    return PlayerData.gang and PlayerData.gang.name == jobName
                                else
                                    return PlayerData.job and PlayerData.job.name == jobName
                                end
                            end,
                            distance = 2.0
                        }
                    }
                })
            end
        end
    end
end

RegisterNetEvent('DERP-bossmenu:client:TriggerOpenManager', function(data)
    -- print("^3[DERP-DEBUG] TriggerOpenManager called^7")
    -- print("^3[DERP-DEBUG] data.jobData: ^7" .. tostring(data and data.jobData or "NIL"))
    -- print("^3[DERP-DEBUG] data.entityType: ^7" .. tostring(data and data.entityType or "NIL"))
    -- print("^3[DERP-DEBUG] PlayerData.job: ^7" .. tostring(PlayerData.job and PlayerData.job.name or "NIL"))
    -- print("^3[DERP-DEBUG] PlayerData.gang: ^7" .. tostring(PlayerData.gang and PlayerData.gang.name or "NIL"))

    TriggerServerEvent('DERP-bossmenu:server:RequestRefreshJobData')

    if not data or not data.jobData then
        -- print("^1[DERP-DEBUG] data or jobData is nil^7")
        return
    end
    if menuOpen then
        -- print("^1[DERP-DEBUG] Menu already open^7")
        return
    end

    local jobName = data.jobData
    local entityType = data.entityType or "job"

    -- print("^3[DERP-DEBUG] jobName: ^7" .. jobName .. " | entityType: " .. entityType)

    if not isLoggedIn then
        -- print("^1[DERP-DEBUG] Player not logged in^7")
        return
    end

    if entityType == "gang" then
        if not PlayerData.gang or PlayerData.gang.name ~= jobName then
            -- print("^1[DERP-DEBUG] Gang mismatch: ^7" .. tostring(PlayerData.gang and PlayerData.gang.name or "NIL") .. " ~= " .. jobName)
            QBCore.Functions.Notify("You are not part of this gang", "error")
            return
        end
    else
        if not PlayerData.job or PlayerData.job.name ~= jobName then
            -- print("^1[DERP-DEBUG] Job mismatch: ^7" .. tostring(PlayerData.job and PlayerData.job.name or "NIL") .. " ~= " .. jobName)
            QBCore.Functions.Notify("You are not part of this job", "error")
            return
        end
    end

    -- print("^3[DERP-DEBUG] Calling HasJobAccess...^7")
    QBCore.Functions.TriggerCallback('DERP-bossmenu:server:HasJobAccess', function(hasAccess)
        -- print("^3[DERP-DEBUG] HasJobAccess returned: ^7" .. tostring(hasAccess))
        if not hasAccess then
            QBCore.Functions.Notify("You don't have permission to manage this", "error")
            return
        end
        OpenJobManager(jobName, entityType)
    end, jobName, entityType)
end)

-- Register the NUI callback for updateEmployeePermissions
RegisterNUICallback('updateEmployeePermissions', function(data, cb)
    if not data.citizenid or not data.jobName or not data.permissions then
        cb({success = false, message = "Invalid data"})
        return
    end    
    -- Trigger server event to update permissions
    QBCore.Functions.TriggerCallback('DERP-bossmenu:server:UpdateEmployeePermissions', function(result)
        cb(result) 
    end, data.citizenid, data.jobName, data.permissions)
end)

RegisterNUICallback('getEmployeePermissions', function(data, cb)
    local citizenid = data.citizenid
    local jobName = data.jobName
    
    QBCore.Functions.TriggerCallback('DERP-bossmenu:server:GetEmployeePermissions', function(permissions)
        cb(permissions)
    end, citizenid, jobName)
end)

RegisterNetEvent('DERP-bossmenu:client:RefreshPermissions', function(permissions)
    if not PlayerData.job then return end
    
    if permissions then
        -- If permissions were provided directly, update them
        currentPermissions = permissions
        
        -- If menu is open, refresh it with new permissions
        if menuOpen then
            SendNUIMessage({
                action = "updatePermissions",
                permissions = permissions
            })
        end
    else
        -- Otherwise, request current permissions
        QBCore.Functions.TriggerCallback('DERP-bossmenu:server:GetEmployeePermissions', function(newPermissions)
            if newPermissions then
                currentPermissions = newPermissions
                
                -- If menu is open, refresh it with new permissions
                if menuOpen then
                    SendNUIMessage({
                        action = "updatePermissions", 
                        permissions = newPermissions
                    })
                end
            end
        end, PlayerData.citizenid, PlayerData.job.name)
    end
end)

function OpenJobManager(jobName, entityType)
    entityType = entityType or "job" 
    currentEntityType = entityType
    if menuOpen then return end

    QBCore.Functions.TriggerCallback('DERP-bossmenu:server:GetJobData', function(jobData)
        if not jobData then
            QBCore.Functions.Notify("Unable to load data", "error")
            return
        end

        currentPermissions = jobData.permissions

        local entityConfig = Config.Locations[jobName]
        if entityConfig then
            jobData.logoImage = entityConfig.logoImage
            jobData.jobLabel = entityConfig.label
        end

        -- THÊM: fallback label từ Shared
        if not jobData.jobLabel or jobData.jobLabel == "" then
            if entityType == "gang" then
                jobData.jobLabel = QBCore.Shared.Gangs[jobName] and QBCore.Shared.Gangs[jobName].label or jobName
            else
                jobData.jobLabel = QBCore.Shared.Jobs[jobName] and QBCore.Shared.Jobs[jobName].label or jobName
            end
        end

        QBCore.Functions.TriggerCallback('DERP-bossmenu:server:GetSettings', function(settings)
            if not settings then return end

            QBCore.Functions.TriggerCallback('DERP-bossmenu:server:GetSocietyData', function(societyData)
                menuOpen = true
                SetNuiFocus(true, true)
                SendNUIMessage({
                    action = "openUI",
                    jobData = jobData,
                    jobName = jobName,
                    entityType = entityType, -- THÊM: để UI biết là gang hay job
                    playerJob = entityType == "gang" and PlayerData.gang or PlayerData.job,
                    settings = settings,
                    societyData = societyData,
                    permissions = currentPermissions
                })
            end, jobName)
        end)
    end, jobName, entityType) -- THÊM entityType
end

RegisterNUICallback('checkPermission', function(data, cb)
    local permissionType = data.permissionType
    
    -- Check job boss
    if PlayerData.job and PlayerData.job.isboss then
        cb(true)
        return
    end
    
    -- THÊM: Check gang boss
    if PlayerData.gang and PlayerData.gang.isboss then
        cb(true)
        return
    end
    
    if currentPermissions and currentPermissions[permissionType] then
        cb(true)
        return
    end
    
    cb(false)
end)

-- Function to check permissions before certain actions
function HasPermission(permissionType)
    if PlayerData.job and PlayerData.job.isboss then
        return true
    end
    
    -- THÊM: Check gang boss
    if PlayerData.gang and PlayerData.gang.isboss then
        return true
    end
    
    if currentPermissions and currentPermissions[permissionType] then
        return true
    end
    
    return false
end

-- Block the original event to prevent any other scripts from triggering it
RegisterNetEvent('DERP-bossmenu:client:OpenManager', function()
    DebugPrint("Blocked automatic opening from original event")
end)

-- Refresh data event handler
RegisterNetEvent('DERP-bossmenu:client:RefreshData', function()
    if isLoggedIn and PlayerData.job and PlayerData.job.isboss and menuOpen then
        QBCore.Functions.TriggerCallback('DERP-bossmenu:server:GetJobData', function(jobData)
            if jobData then
                SendNUIMessage({
                    action = "refreshData",
                    jobData = jobData
                })
            end
        end, PlayerData.job.name)
    end
end)

-- NUI Callbacks
RegisterNUICallback('closeUI', function(_, cb)
    SetNuiFocus(false, false)
    menuOpen = false
    cb('ok')
end)

RegisterNUICallback('showFireConfirmMenu', function(data, cb)
    local citizenid = data.citizenid
    local employeeName = data.name
    
    ShowFireConfirmationMenu(citizenid, employeeName)
    
    cb('ok')
end)
function ShowCustomFireMenu(citizenid, employeeName)
    SetNuiFocus(true, true)
    
    SendNUIMessage({
        action = "showCustomFireMenu",
        name = employeeName,
        citizenid = citizenid
    })
end

RegisterNUICallback("submitApplication", function(data, cb) 
    SetNuiFocus(false, false)
    TriggerServerEvent("DERP-bossmenu:server:SubmitApplication", data.jobName, data.answers)
end)

function ShowFireConfirmationMenu(citizenid, employeeName)
    SendNUIMessage({
        action = "showCustomFireMenu",
        name = employeeName,
        citizenid = citizenid
    })
end

RegisterNUICallback('fireMenuResponse', function(data, cb)
    SendNUIMessage({
        action = "fireEmployeeResponse",
        confirmed = data.confirmed,
        citizenid = data.citizenid
    })
    cb('ok')
end)

RegisterNetEvent('DERP-bossmenu:client:FireEmployeeConfirmed', function(data)
    SendNUIMessage({
        action = "fireEmployeeResponse",
        confirmed = data.confirmed,
        citizenid = data.citizenid
    })
end)

RegisterNUICallback('updateEmployee', function(data, cb)
    local entityName = currentEntityType == "gang" and PlayerData.gang.name or PlayerData.job.name
    TriggerServerEvent('DERP-bossmenu:server:UpdateEmployee', data.citizenid, entityName, data.grade, currentEntityType)
    cb('ok')
end)

RegisterNUICallback('removeEmployee', function(data, cb)
    local entityName = currentEntityType == "gang" and PlayerData.gang.name or PlayerData.job.name
    TriggerServerEvent('DERP-bossmenu:server:RemoveEmployee', data.citizenid, entityName, currentEntityType)
    cb('ok')
end)

RegisterNUICallback('saveSettings', function(data, cb)
    TriggerServerEvent('DERP-bossmenu:server:SaveSettings', data)
    cb('ok')
end)

-- Refresh data
RegisterNUICallback('refreshData', function(_, cb)
    local entityName = currentEntityType == "gang" and PlayerData.gang.name or PlayerData.job.name
    QBCore.Functions.TriggerCallback('DERP-bossmenu:server:GetJobData', function(jobData)
        if jobData then
            cb(jobData)
        else
            cb(false)
        end
    end, entityName, currentEntityType) 
end)

-- Extra safeguard for resource start/stop
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end    
    Wait(3000)
    
    if Config.TargetSystem ~= "qb-target" and Config.TargetSystem ~= "ox_target" then
        print("^1[DERP-bossmenu]^7 Invalid target system in config: " .. (Config.TargetSystem or "nil") .. ". Defaulting to qb-target.")
        Config.TargetSystem = "qb-target"
    end
    
    if LocalPlayer.state.isLoggedIn then
        PlayerData = QBCore.Functions.GetPlayerData()
        isLoggedIn = true
        CreateJobTargetPoints()
        CreateApplicationPoints()
    end
end)

-- Command to manually trigger the job manager (for testing/emergency)
RegisterCommand('fixjobmanager', function()
    CreateJobTargetPoints()
    QBCore.Functions.Notify("Job Manager target points refreshed", "success")
end, false)

CreateThread(function()
    while true do
        Wait(60000) -- Update every minute
        
        -- Only refresh if menu is open
        if menuOpen then
            TriggerServerEvent('DERP-bossmenu:server:RefreshPlayTime')
        end
        
        Wait(60000) -- Wait another minute before next check
    end
end)

RegisterNUICallback('getSocietyData', function(data, cb)
    if not data.jobName then
        cb(false)
        return
    end
    
    QBCore.Functions.TriggerCallback('DERP-bossmenu:server:GetSocietyData', function(societyData)
        if societyData then
            cb(societyData)
        else
            cb(false)
        end
    end, data.jobName)
end)

RegisterNUICallback('depositMoney', function(data, cb)
    if not data.amount or not data.jobName then
        cb({success = false, message = "Missing required data"})
        return
    end
    
    TriggerServerEvent('DERP-bossmenu:server:DepositMoney', data.amount, data.note, data.jobName)
    cb({success = true})
end)

RegisterNUICallback('withdrawMoney', function(data, cb)
    if not data.amount or not data.jobName then
        cb({success = false, message = "Missing required data"})
        return
    end
    
    TriggerServerEvent('DERP-bossmenu:server:WithdrawMoney', data.amount, data.note, data.jobName)
    cb({success = true})
end)

RegisterNUICallback('transferMoney', function(data, cb)
    if not data.citizenid or not data.amount or not data.jobName then
        cb({success = false, message = "Missing required data"})
        return
    end
    
    TriggerServerEvent('DERP-bossmenu:server:TransferMoney', data.citizenid, data.amount, data.note, data.jobName)
    cb({success = true})
end)

RegisterNUICallback('showNotification', function(data, cb)
    local message = data.message or "Error"
    local type = data.type or "error"
    QBCore.Functions.Notify(message, type)
    
    cb('ok')
end)

RegisterNetEvent('DERP-bossmenu:client:OpenApplicationForm', function(data)
    local jobName = data.jobData
    
    if not jobName then 
        QBCore.Functions.Notify("Invalid application spot", "error")
        return 
    end

    local jobApplication = Config.ApplicationQuestions[jobName]

    if not jobApplication then
        QBCore.Functions.Notify("Invalid application spot", "error")
        return
    end
    
    QBCore.Functions.TriggerCallback('DERP-bossmenu:server:CheckApplicationStatus', function(result)
        if not result.canApply then
            QBCore.Functions.Notify(result.message, "error")
            return
        end
        
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = "openApplicationForm",
            data = {
                job = {
                    name = jobName,
                    label = QBCore.Shared.Jobs[jobName].label
                },
                applicationData = jobApplication
            }
        })
    end, jobName)
end)


-- Register client callback for this new function
RegisterNUICallback('getPlaytimeData', function(data, cb)
    if not data or not data.jobName then
        cb({success = false, message = "Missing job name"})
        return
    end    
    QBCore.Functions.TriggerCallback('DERP-bossmenu:server:GetPlaytimeData', function(playtimeData)
        if playtimeData then
            cb(playtimeData)
        else
            cb({success = false, message = "Failed to get playtime data", employees = {}})
        end
    end, data.jobName)
end)

RegisterNUICallback('hireEmployee', function(data, cb)
    if not data.targetId or not data.jobName or not data.grade then
        cb({ success = false, message = "Missing required data" })
        return
    end
    
    local targetId = tonumber(data.targetId)
    local grade = data.grade
    
    QBCore.Functions.TriggerCallback('DERP-bossmenu:server:HireNewEmployee', function(result)
        cb(result)
    end, targetId, data.jobName, grade, currentEntityType) -- THÊM currentEntityType
end)

RegisterNUICallback('checkPermission', function(data, cb)
    local permissionType = data.permissionType
    
    -- Check job boss
    if PlayerData.job and PlayerData.job.isboss then
        cb(true)
        return
    end
    
    -- THÊM: Check gang boss
    if PlayerData.gang and PlayerData.gang.isboss then
        cb(true)
        return
    end
    
    if currentPermissions and currentPermissions[permissionType] then
        cb(true)
        return
    end
    
    cb(false)
end)


RegisterNUICallback('updateJobGrade', function(data, cb)
    if not data.jobName or not data.gradeLevel or not data.gradeName or not data.gradePayment then
        cb({success = false, message = "Missing required data"})
        return
    end

    QBCore.Functions.TriggerCallback('DERP-bossmenu:server:UpdateJobGrade', function(result)
        cb(result)
    end, data.jobName, data.gradeLevel, data.gradeName, data.gradePayment, data.gradeIsBoss, data.entityType or "job") -- THÊM
end)

RegisterNUICallback('addJobGrade', function(data, cb)
    if not data.jobName or not data.gradeName or not data.gradePayment then
        cb({success = false, message = "Missing required data"})
        return
    end

    QBCore.Functions.TriggerCallback('DERP-bossmenu:server:AddJobGrade', function(result)
        cb(result)
    end, data.jobName, data.gradeName, data.gradePayment, data.gradeIsBoss, data.entityType or "job") -- THÊM
end)

RegisterNUICallback('deleteJobGrade', function(data, cb)
    if not data.jobName or not data.gradeLevel then
        cb({success = false, message = "Missing required data"})
        return
    end

    QBCore.Functions.TriggerCallback('DERP-bossmenu:server:DeleteJobGrade', function(result)
        cb(result)
    end, data.jobName, data.gradeLevel, data.entityType or "job") -- THÊM
end)

RegisterNUICallback('getJobGrades', function(data, cb)
    if not data or not data.jobName then
        cb(false)
        return
    end

    QBCore.Functions.TriggerCallback('DERP-bossmenu:server:GetJobGrades', function(gradesData)
        if gradesData then
            cb(gradesData)
        else
            cb(false)
        end
    end, data.jobName, data.entityType or "job") -- THÊM entityType
end)
