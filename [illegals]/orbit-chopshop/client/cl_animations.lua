RegisterNetEvent('orbit-chopshop:wheelanimation', function()
    local ped = PlayerPedId()
    if lib.progressBar({
        duration = 6500,
        label = Config.Locale["Wheel"],
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
        anim = { dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", clip = "machinic_loop_mechandplayer" },
    }) then
        ClearPedTasks(ped)
    else
        ClearPedTasks(ped)
        exports.qbx_core:Notify("Đã hủy", "error")
    end
end)

RegisterNetEvent('orbit-chopshop:dooranimation', function()
    local ped = PlayerPedId()
    if lib.progressBar({
        duration = 4000,
        label = Config.Locale["Door"],
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
        anim = { dict = "amb@world_human_welding@male@base", clip = "base" },
        prop = {
            model = "prop_weld_torch",
            bone = 28422,
            pos = vec3(0.0, 0.0, 0.0),
            rot = vec3(0.0, 0.0, 0.0),
        },
    }) then
        ClearPedTasks(ped)
    else
        ClearPedTasks(ped)
        exports.qbx_core:Notify("Đã hủy", "error")
    end
end)

RegisterNetEvent('orbit-chopshop:trunkanimation', function()
    local ped = PlayerPedId()
    lib.progressBar({
        duration = 4000,
        label = Config.Locale["searching"],
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
        anim = { dict = "mini@repair", clip = "fixing_a_ped" },
    })
    Wait(500)
    if lib.progressBar({
        duration = 5500,
        label = Config.Locale["trunk"],
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
        anim = { dict = "amb@world_human_welding@male@base", clip = "base" },
        prop = {
            model = "prop_weld_torch",
            bone = 28422,
            pos = vec3(0.0, 0.0, 0.0),
            rot = vec3(0.0, 0.0, 0.0),
        },
    }) then
        ClearPedTasks(ped)
    else
        ClearPedTasks(ped)
        exports.qbx_core:Notify("Đã hủy", "error")
    end
end)

RegisterNetEvent('orbit-chopshop:hoodanimation', function()
    local ped = PlayerPedId()
    if lib.progressBar({
        duration = 4000,
        label = Config.Locale["hood"],
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
        anim = { dict = "mini@repair", clip = "fixing_a_player" },
    }) then
        ClearPedTasks(ped)
    else
        ClearPedTasks(ped)
        exports.qbx_core:Notify("Đã hủy", "error")
    end
end)

RegisterNetEvent('orbit-chopshop:wheelchopanim', function()
    local ped = PlayerPedId()
    lib.progressBar({
        duration = 13000,
        label = Config.Locale["chopwheel"],
        useWhileDead = false,
        canCancel = false,
        disable = { move = true, car = true, combat = true },
    })

    lib.requestAnimDict("anim@heists@box_carry@")
    Wait(100)
    local wheelprop = CreateObject(GetHashKey("imp_prop_impexp_tyre_01b"), 0, 0, 0, true, true, true)
    AttachEntityToEntity(wheelprop, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 60309), -0.05, 0.2, 0.35, -145.0, 100.0, 0.0, true, true, false, true, 1, true)
    SetEntityCoords(ped, 472.3670, -1311.3860, 28.2159)
    SetEntityHeading(ped, 124.7478)
    TaskPlayAnim(PlayerPedId(), "anim@heists@box_carry@", "idle", 2.0, 2.0, 1500, 51, 0, false, false, false)
    Wait(1500)
    DeleteEntity(wheelprop)
    DeleteObject(wheelprop)
    local wheeleobj = CreateObject(GetHashKey("imp_prop_impexp_tyre_01b"), 471.8941, -1311.6477, 29.2602, true, true, true)
    PlaceObjectOnGroundProperly(wheeleobj)
    SetEntityHeading(wheeleobj, 290.6089)
    Wait(12000)
    ClearPedTasks(ped)
    DeleteEntity(wheeleobj)
    DeleteObject(wheeleobj)
end)

RegisterNetEvent('orbit-chopshop:doorchopanim', function()
    local ped = PlayerPedId()
    lib.progressBar({
        duration = 13000,
        label = Config.Locale["chopdoor"],
        useWhileDead = false,
        canCancel = false,
        disable = { move = true, car = true, combat = true },
    })

    lib.requestAnimDict("anim@heists@box_carry@")
    Wait(100)
    local doorprop = CreateObject(GetHashKey("imp_prop_impexp_car_door_04a"), 0, 0, 0, true, true, true)
    AttachEntityToEntity(doorprop, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 60309), 0.08, 0.28, 0.90, -115.0, 180.0, 0.0, true, true, false, true, 1, true)
    SetEntityCoords(ped, 472.5670, -1311.3860, 28.2159)
    SetEntityHeading(ped, 124.747)
    TaskPlayAnim(PlayerPedId(), "anim@heists@box_carry@", "idle", 2.0, 2.0, 1500, 51, 0, false, false, false)
    Wait(1500)
    DetachEntity(doorprop, 1, true)
    DeleteEntity(doorprop)
    DeleteObject(doorprop)
    local doorobj = CreateObject(GetHashKey("imp_prop_impexp_car_door_04a"), 471.5941, -1311.3477, 29.2602, true, true, true)
    PlaceObjectOnGroundProperly(doorobj)
    SetEntityHeading(doorobj, 37.1947)
    Wait(12000)
    ClearPedTasks(ped)
    DeleteEntity(doorobj)
    DeleteObject(doorobj)
end)

RegisterNetEvent('orbit-chopshop:hoodchopanim', function()
    local ped = PlayerPedId()
    lib.progressBar({
        duration = 12500,
        label = Config.Locale["chophood"],
        useWhileDead = false,
        canCancel = false,
        disable = { move = true, car = true, combat = true },
    })

    lib.requestAnimDict("anim@heists@box_carry@")
    Wait(100)
    local hoodprop = CreateObject(GetHashKey("imp_prop_impexp_bonnet_02a"), 0, 0, 0, true, true, true)
    AttachEntityToEntity(hoodprop, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 60309), 0.15, -0.05, 0.24, -200.0, 110.0, 0.0, true, true, false, true, 1, true)
    SetEntityCoords(ped, 472.8181, -1311.4249, 28.2183)
    SetEntityHeading(ped, 124.3253)
    TaskPlayAnim(PlayerPedId(), "anim@heists@box_carry@", "idle", 2.0, 2.0, 1000, 51, 0, false, false, false)
    Wait(1000)
    DetachEntity(hoodprop, 1, true)
    DeleteEntity(hoodprop)
    DeleteObject(hoodprop)
    local hoodobj = CreateObject(GetHashKey("imp_prop_impexp_bonnet_02a"), 471.8663, -1311.6914, 29.86, true, true, true)
    SetEntityHeading(hoodobj, 118.1908)
    SetEntityRotation(hoodobj, 0.0, 80.0)
    Wait(12000)
    ClearPedTasks(ped)
    DeleteEntity(hoodobj)
    DeleteObject(hoodobj)
end)

RegisterNetEvent('orbit-chopshop:trunkchopanim', function()
    local ped = PlayerPedId()
    lib.progressBar({
        duration = 12500,
        label = Config.Locale["choptrunk"],
        useWhileDead = false,
        canCancel = false,
        disable = { move = true, car = true, combat = true },
    })

    lib.requestAnimDict("anim@heists@box_carry@")
    Wait(100)
    local trunkprop = CreateObject(GetHashKey("imp_prop_impexp_bonnet_02a"), 0, 0, 0, true, true, true)
    AttachEntityToEntity(trunkprop, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 60309), 0.15, -0.05, 0.24, -200.0, 110.0, 0.0, true, true, false, true, 1, true)
    SetEntityCoords(ped, 472.5044, -1311.2794, 28.2171)
    SetEntityHeading(ped, 122.8519)
    TaskPlayAnim(PlayerPedId(), "anim@heists@box_carry@", "idle", 2.0, 2.0, 1000, 51, 0, false, false, false)
    Wait(1000)
    DetachEntity(trunkprop, 1, true)
    DeleteEntity(trunkprop)
    DeleteObject(trunkprop)
    local trunkobj = CreateObject(GetHashKey("imp_prop_impexp_bonnet_02a"), 471.7178, -1311.6902, 29.82, true, true, true)
    SetEntityHeading(trunkobj, 118.1908)
    SetEntityRotation(trunkobj, 0.0, 250.0)
    Wait(12000)
    ClearPedTasks(ped)
    DeleteEntity(trunkobj)
    DeleteObject(trunkobj)
end)