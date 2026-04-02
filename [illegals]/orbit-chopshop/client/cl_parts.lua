RegisterNetEvent('orbit-chopshop:StartMenu', function()
    lib.registerContext({
        id = 'chopshop_parts_menu',
        title = 'Rã Nguyên Liệu',
        options = {
            {
                title = 'Cửa Xe',
                icon = 'fas fa-door-open',
                onSelect = function()
                    TriggerServerEvent("orbit-chopshop:server:chopdoor")
                end,
            },
            {
                title = 'Bánh Xe',
                icon = 'fas fa-circle',
                onSelect = function()
                    TriggerServerEvent("orbit-chopshop:server:chopwheel")
                end,
            },
            {
                title = 'Nắp Capô',
                icon = 'fas fa-car',
                onSelect = function()
                    TriggerServerEvent("orbit-chopshop:server:chophood")
                end,
            },
            {
                title = 'Cốp Xe',
                icon = 'fas fa-box',
                onSelect = function()
                    TriggerServerEvent("orbit-chopshop:server:choptrunk")
                end,
            },
        },
    })
    lib.showContext('chopshop_parts_menu')
end)