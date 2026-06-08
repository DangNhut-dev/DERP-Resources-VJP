function AddSkill(Skill)
    if Config.MINIGAME then
        finished = exports["taskbarskill"]:taskBar(3700, 1)
        if finished == 100 then 
            TriggerEvent('derp_skills:client:AddSkill', Skill, 1)
        end
    else
        TriggerEvent('derp_skills:client:AddSkill', Skill, 1)
    end
end

function ProgressBar(Time, Label)
    --exports['progressBars']:startUI((Time), Label)
end

function notification(title, text, time, type)
    if Config.BrutalNotify then
        exports['derp_notify']:SendAlert(title, text, time, type)
    else
        SetNotificationTextEntry("STRING")
        AddTextComponentString(text)
        DrawNotification(0,1)
    end
end

function DrawText3D(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.025+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end