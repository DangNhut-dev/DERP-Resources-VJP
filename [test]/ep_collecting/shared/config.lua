Config = {}
Config.Debug = false
Config.Zones = {
    {
        name = 'Collector Zone 1',
        coords = vector4(2657.6025390625,4198.7592773438,42.093650817871,293.74404907227),
        size = vector3(20,20,5),
        maxItems = 15, -- Max number of items that can be populated in this zone
        items = {
            {
                model = `xm_prop_x17_chest_closed`,
                name = 'Open Chest',
                onSelect = function()
                    --Add your looting logic here
                    print('Chest selected')
                end,
            },
            {
                model = `ep_wheat_03`,
                name = 'Collect Wheat',
                onSelect = function()
                    --Add your looting logic here
                    print('Wheat selected')
                end,
            },
            {
                model = `ep_watermelon_03`,
                name = 'Collect Watermelon',
                onSelect = function()
                    --Add your looting logic here
                    print('Watermelon selected')
                end,
            },
        },
    }
}