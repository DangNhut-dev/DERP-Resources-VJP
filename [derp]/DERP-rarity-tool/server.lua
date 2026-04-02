-- Ensure output folder exists
local resName = GetCurrentResourceName()
local testFile = LoadResourceFile(resName, 'output/.gitkeep')
if not testFile then
    SaveResourceFile(resName, 'output/.gitkeep', '', -1)
end

RegisterNetEvent('DERP-rarity-tool:save', function(data)
    if not data or not data.items or not data.lootboxKey then return end

    local lootboxItems = {}
    local rarityEntries = {}

    for itemKey, rarity in pairs(data.items) do
        lootboxItems[#lootboxItems + 1] = itemKey
        rarityEntries[#rarityEntries + 1] = { key = itemKey, rarity = rarity }
    end

    table.sort(lootboxItems)
    table.sort(rarityEntries, function(a, b) return a.key < b.key end)

    -- Build lootbox config output
    local lootboxLines = {}
    lootboxLines[#lootboxLines + 1] = ("['%s'] = {"):format(data.lootboxKey)
    lootboxLines[#lootboxLines + 1] = ("    label = '%s',"):format(data.lootboxLabel or '')
    lootboxLines[#lootboxLines + 1] = '    items = {'

    for _, itemName in ipairs(lootboxItems) do
        lootboxLines[#lootboxLines + 1] = ("        { name = '%s' },"):format(itemName)
    end

    lootboxLines[#lootboxLines + 1] = '    }'
    lootboxLines[#lootboxLines + 1] = '},'

    local lootboxOutput = table.concat(lootboxLines, '\n')

    -- Build rarity config output
    local rarityLines = {}
    for _, entry in ipairs(rarityEntries) do
        rarityLines[#rarityLines + 1] = ("    ['%s'] = '%s',"):format(entry.key, entry.rarity)
    end

    local rarityOutput = table.concat(rarityLines, '\n')

    -- Timestamp for filename
    local timestamp = os.date('%Y%m%d_%H%M%S')
    local prefix = ('%s_%s_%s'):format(data.clothType or 'unknown', data.gender == 0 and 'nam' or 'nu', timestamp)

    -- Save files
    SaveResourceFile(GetCurrentResourceName(), ('output/lootbox_%s.lua'):format(prefix), lootboxOutput, -1)
    SaveResourceFile(GetCurrentResourceName(), ('output/rarity_%s.lua'):format(prefix), rarityOutput, -1)

    print(('[DERP-rarity-tool] Saved %d items -> output/lootbox_%s.lua & output/rarity_%s.lua'):format(#lootboxItems, prefix, prefix))

    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        description = ('Da luu %d items vao output/'):format(#lootboxItems)
    })
end)