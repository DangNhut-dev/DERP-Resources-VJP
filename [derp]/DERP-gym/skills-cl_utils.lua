function DefaultSkills() -- Add Skills
    Citizen.CreateThread(function()
        while true do
            local ped = PlayerPedId()
            local vehicle = GetVehiclePedIsUsing(ped)
    
            if IsPedSwimmingUnderWater(ped) then
                TriggerEvent('derp_skills:client:AddSkill', 'Swimming', 1)
            elseif GetEntitySpeed(vehicle) * 3.6 >= 100 and GetPedInVehicleSeat(GetVehiclePedIsIn(ped), -1) == ped then
                TriggerEvent('derp_skills:client:AddSkill', 'Driving', 1)
            end
            Citizen.Wait(30000)
        end
    end)
    Citizen.CreateThread(function()
        while true do
            local ped = PlayerPedId()
            if IsPedShooting(ped) then
                GoodWeapon = true
                for k,v in pairs(Config.ShootWeponsBlackList) do
                    if GetSelectedPedWeapon(ped) == GetHashKey(v) then
                        GoodWeapon = false
                    end
                end

                if GoodWeapon then
                    TriggerEvent('derp_skills:client:AddSkill', 'Shooting', 1)
                end
            end
            Citizen.Wait(200)
        end
    end)
end
