OldSkills   = {}
Skills      = {}
PlayerJob   = ''
NeedToSave  = false
DataArrived = false

RegisterNetEvent(LoadedEvent)
AddEventHandler(LoadedEvent, function()
    Citizen.Wait(10000)
    GetData()
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        GetData()
    end
end)

-- Trả về cap tối đa theo job hiện tại
local function GetMaxCap()
    local mod = Config.JobModifiers[PlayerJob]
    return mod and mod.MaxCap or 100
end

-- Trả về decay multiplier theo job hiện tại
local function GetDecayMultiplier()
    local mod = Config.JobModifiers[PlayerJob]
    return mod and mod.DecayMultiplier or 1
end

-- Cắp toàn bộ skill về cap mới nếu vượt quá
local function ClampSkillsToCap(cap)
    local clamped = false
    for k, v in pairs(Skills) do
        if v > cap then
            Skills[k] = cap
            clamped = true
        end
    end
    if clamped then
        NeedToSave = true
        OldSkills = {}
        for k, v in pairs(Skills) do OldSkills[k] = v end
        TriggerServerEvent('derp_skills:server:UpdateSkill', Skills)
        SetSkills()
    end
end

function GetData()
    TSCB('derp_skills:server:getPlayerData', function(data)
        for k, v in pairs(data) do
            if v ~= nil then
                Skills[k]    = v
                OldSkills[k] = v
            end
        end

        PlayerJob = Core.Functions.GetPlayerData().job.name

        SetSkills()
        DataArrived = true
    end)

    -- Decay Skills — wait động theo job
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1000 * 60 * Config.Skills.RemoveTime * GetDecayMultiplier())
            for k, v in pairs(Skills) do
                if v > 1 then
                    Skills[k] -= 1
                end
            end
        end
    end)

    -- Save Skills
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1000 * 60 * Config.Skills.SaveFrequency)
            for k, v in pairs(OldSkills) do
                if Skills[k] ~= OldSkills[k] then
                    NeedToSave    = true
                    OldSkills[k] = Skills[k]
                end
            end

            if NeedToSave then
                NeedToSave = false
                TriggerServerEvent('derp_skills:server:UpdateSkill', Skills)
            end
        end
    end)

    DefaultSkills()
end

-- Job thay đổi: cập nhật PlayerJob, cắp skill nếu cap mới nhỏ hơn
AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo)
    local newJob = JobInfo.name
    if PlayerJob == newJob then return end

    local oldCap = GetMaxCap()
    PlayerJob    = newJob
    local newCap = GetMaxCap()

    if newCap < oldCap then
        ClampSkillsToCap(newCap)
    end

    SetSkills()
end)

-- Add Skill — cap theo job
RegisterNetEvent('derp_skills:client:AddSkill')
AddEventHandler('derp_skills:client:AddSkill', function(Skill, Value)
    if Config.Skills.SkillTypes[Skill] == nil then return end

    local cap = GetMaxCap()
    if Skills[Skill] + Value <= cap then
        Skills[Skill] += Value
    else
        Skills[Skill] = cap
    end

    SendNUIMessage({
        action     = "Notify",
        skillname  = Skill,
        duration   = Config.Skills.SkillNotifyTime,
        skilltypes = Config.Skills.SkillTypes
    })
    SetSkills()
end)

-- Set Skills — normalize về 0-100 cho GTA stat/multiplier
function SetSkills()
    local player = PlayerId()
    local cap    = GetMaxCap()

    -- Hàm normalize giá trị về 0-100 theo cap
    local function norm(val)
        return math.floor(val / cap * 100)
    end

    if Config.Skills.SkillTypes['Stamina'].Use then
        StatSetInt("MP0_STAMINA", norm(Skills['Stamina']), true)
    end

    if Config.Skills.SkillTypes['Running'].Use then
        local value = 500
        if Config.Skills.SprintSpeedIncrease:upper() == 'FAST' then
            value = 300
        elseif Config.Skills.SprintSpeedIncrease:upper() == 'MEDIUM' then
            value = 400
        end
        SetRunSprintMultiplierForPlayer(player, 1.0 + norm(Skills['Running']) / value)
        StatSetInt('MP0_LUNG_CAPACITY', norm(Skills['Running']), true)
    end

    if Config.Skills.SkillTypes['Driving'].Use then
        StatSetInt('MP0_DRIVING_ABILITY', norm(Skills['Driving']), true)
    end

    if Config.Skills.SkillTypes['Strength'].Use then
        StatSetInt("MP0_STRENGTH", norm(Skills['Strength']), true)
        SetWeaponDamageModifier("WEAPON_UNARMED", 1.0 + norm(Skills['Strength']) / 200)
    end

    if Config.Skills.SkillTypes['Swimming'].Use then
        local value = 500
        if Config.Skills.SwimSpeedIncrease:upper() == 'FAST' then
            value = 300
        elseif Config.Skills.SwimSpeedIncrease:upper() == 'MEDIUM' then
            value = 400
        end
        SetSwimMultiplierForPlayer(player, 1.0 + norm(Skills['Swimming']) / value)
    end

    if Config.Skills.SkillTypes['Shooting'].Use then
        StatSetInt("MP0_SHOOTING_ABILITY", norm(Skills['Shooting']), true)
    end
end

Citizen.CreateThread(function()
    RegisterCommand(Config.Skills.SkillMenu.Command, function()
        if DataArrived then
            Citizen.Wait(10)
            SetNuiFocus(true, true)
            SendNUIMessage({action = "open", skills = Skills, skilltypes = Config.Skills.SkillTypes})
        end
    end)

    RegisterKeyMapping(Config.Skills.SkillMenu.Command, Config.Skills.SkillMenu.Label, "keyboard", Config.Skills.SkillMenu.Control)
    TriggerEvent('chat:addSuggestion', '/' .. Config.Skills.SkillMenu.Command, Config.Skills.SkillMenu.Label)
end)

RegisterNUICallback("UseButton", function(data)
    if data.action == "close" then
        SetNuiFocus(false, false)
    end
end)

lib.addRadialItem({
    id       = 'skill_menu',
    label    = 'Kỹ Năng',
    icon     = 'dumbbell',
    onSelect = function()
        if DataArrived then
            SetNuiFocus(true, true)
            SendNUIMessage({action = "open", skills = Skills, skilltypes = Config.Skills.SkillTypes})
        end
    end
})