HasPermission = false
InTask = false                                                         
function SendNotify(Number)
    notification(Config.Notify[Number][1], Config.Notify[Number][2], Config.Notify[Number][3], Config.Notify[Number][4])
end

Citizen.CreateThread(function()
    for k, v in pairs(Config.Gyms) do
        if v.Blip.Use then
          local GYMBlip = AddBlipForCoord(v.GYMCoords.x, v.GYMCoords.y, v.GYMCoords.z)
          SetBlipSprite(GYMBlip, v.Blip.sprite)
          SetBlipColour(GYMBlip, v.Blip.colour)
          SetBlipScale(GYMBlip, v.Blip.size)
          BeginTextCommandSetBlipName('STRING')
          AddTextComponentSubstringPlayerName(k)
          EndTextCommandSetBlipName(GYMBlip)
          SetBlipAsShortRange(GYMBlip, true)
    end
end

Citizen.Wait(1000)
    while true do
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        sleep = 1000

        for k, v in pairs(Config.Gyms) do
            for _k, _v in pairs(v.Exersices) do
                local distance = #(coords - vector3(_v.x, _v.y, _v.z))
                if distance < Config.Gyms[k]['Distances']['Marker'] then
                    DrawMarker(v.Marker.Sprite, _v.x, _v.y, _v.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.Marker.sizes.x, v.Marker.sizes.y, v.Marker.sizes.z, v.Marker.r, v.Marker.g, v.Marker.b, v.Marker.Brightness, v.Marker.UpAndDown, false, true, v.Marker.Rotation, nil, true)
                    sleep = 1

                    if distance < Config.Gyms[k]['Distances']['Text'] and InTask == false then
                        sleep = 1
                        DrawText3D(_v.x, _v.y, _v.z+0.3, ''.. Config.Text3D[1] ..' '.. Config.Exersices[_v.type]['label'] ..' '.. Config.Text3D[2] ..'')

                        if IsControlJustReleased(0, Config.PressKey) then
                            if not IsPedInAnyVehicle(playerPed, false) then
                                if HasPermission then
                                    workout(_v.type, _v.heading)
                                else
                                    if Config.Gyms[k]['ItemRequired']['Use'] == false then
                                        workout(_v.type, _v.heading)
                                    else
                                        TSCB('DERP-gym:server:getItem', function(HasItem)
                                            if HasItem then
                                                HasPermission = true
                                                CheckDistanceAndTime(k)
                                                workout(_v.type, _v.heading)
                                            else
                                                SendNotify(1)
                                                HasPermission = false
                                            end
                                        end, Config.Gyms[k]['ItemRequired']['Item'], Config.Gyms[k]['ItemRequired']['RemoveItem'])
                                    end
                                end
                            else
                                SendNotify(4)
                            end
                        end
                    end
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)

function workout(exersices, heading)
    Citizen.CreateThread(function()
        InTask = true
        local playerPed = PlayerPedId()
        local player = GetPlayerPed(-1)
        SetEntityHeading(playerPed, heading)
        DisableControls()

        if Config.Exersices[exersices]['anim'] == 'running' then
            FreezeEntityPosition(player, true)
            TaskGoStraightToCoord(playerPed, 0, 0, 0, 1, -1, 100, 2)
        elseif Config.Exersices[exersices]['anim'] == 'pushups' then
            LoadAnim('amb@world_human_push_ups@male@idle_a')
            TaskPlayAnim(playerPed, 'amb@world_human_push_ups@male@idle_a', 'idle_d', 8.0, -8, -1, 1, 0, 0, 0, 0)
        elseif Config.Exersices[exersices]['anim'] == 'situps' then
            LoadAnim('amb@world_human_sit_ups@male@idle_a')
            TaskPlayAnim(playerPed, 'amb@world_human_sit_ups@male@idle_a', 'idle_a', 8.0, -8, -1, 1, 0, 0, 0, 0)
        else
			TaskStartScenarioInPlace(playerPed, Config.Exersices[exersices]['anim'], -1, true)
        end

        ProgressBar(Config.Exersices[exersices]['time']*1000, Config.Exersices[exersices]['label'])
        Wait(Config.Exersices[exersices]['time']*1000)
        AddSkill(Config.Exersices[exersices]['skill'])
        FreezeEntityPosition(player, false)
        ClearPedTasksImmediately(playerPed)
        if exersices == 'weightlifting' then
            ClearAreaOfObjects(GetEntityCoords(playerPed), 1.0, 0)
        end

        InTask = false
    end)
end

function DisableControls()
    Citizen.CreateThread(function()
        while InTask do 
            Citizen.Wait(0)
            for k,v in pairs(Config.DisableControls) do
                DisableControlAction(0,v,true)
                DisableControlAction(2,v,true)
            end
        end
    end)
end

function CheckDistanceAndTime(shop)
    timer = math.floor(Config.Gyms[shop]['ItemRequired']['Time']*60)
    SendNUIMessage({action = "StartTimer", time = timer})
      Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1000*5)
            timer = timer-5
  
            if #(GetEntityCoords(PlayerPedId()) - vector3(Config.Gyms[shop]['GYMCoords']['x'], Config.Gyms[shop]['GYMCoords']['y'], Config.Gyms[shop]['GYMCoords']['z'])) > Config.GYMDistance then
              SendNotify(3)
              HasPermission = false
              SendNUIMessage({action = "StopTimer"})
              break
            end
  
            if timer < 1 then
              SendNotify(2)
              HasPermission = false
              break
            end
        end
    end)
end

RegisterNetEvent('derp_skills:client:PlayExercise')
AddEventHandler('derp_skills:client:PlayExercise', function(type, heading)
    workout(type, heading)
end)

function LoadAnim(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(1)
    end
end

function gymDoExercises()
    return InTask
end