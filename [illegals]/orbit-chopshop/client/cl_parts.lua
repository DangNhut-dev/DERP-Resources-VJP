RegisterNetEvent('orbit-chopshop:StartMenu', function()
    lib.registerContext({
        id = 'chopshop_parts_menu',
        title = 'Rã Nguyên Liệu',
        options = {
            {
                title = 'Cửa Xe',
                icon = 'fas fa-door-open',
                onSelect = function()
                    if GetResourceState('svc_runtime') == 'started' then
                        exports['svc_runtime']:ExecuteServerEvent("orbit-chopshop:server:chopdoor")
                    else
                        TriggerServerEvent("orbit-chopshop:server:chopdoor")
                    end
                end,
            },
            {
                title = 'Bánh Xe',
                icon = 'fas fa-circle',
                onSelect = function()
                    if GetResourceState('svc_runtime') == 'started' then
                        exports['svc_runtime']:ExecuteServerEvent("orbit-chopshop:server:chopwheel")
                    else
                        TriggerServerEvent("orbit-chopshop:server:chopwheel")
                    end
                end,
            },
            {
                title = 'Nắp Capô',
                icon = 'fas fa-car',
                onSelect = function()
                    if GetResourceState('svc_runtime') == 'started' then
                        exports['svc_runtime']:ExecuteServerEvent("orbit-chopshop:server:chophood")
                    else
                        TriggerServerEvent("orbit-chopshop:server:chophood")
                    end
                end,
            },
            {
                title = 'Cốp Xe',
                icon = 'fas fa-box',
                onSelect = function()
                    if GetResourceState('svc_runtime') == 'started' then
                        exports['svc_runtime']:ExecuteServerEvent("orbit-chopshop:server:choptrunk")
                    else
                        TriggerServerEvent("orbit-chopshop:server:choptrunk")
                    end
                end,
            },
        },
    })
    lib.showContext('chopshop_parts_menu')
end)