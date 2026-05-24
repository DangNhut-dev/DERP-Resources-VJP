-- =============================================
-- ONE-TIME MIGRATION: Import farms.json into DB
-- Run this ONCE after updating to DB-backed persistence
-- =============================================
-- This script reads farms.json and inserts data into the `farms` table.
-- After running, farms.json is no longer used for persistence.

CreateThread(function()
    Wait(2000) -- Wait for DB to be ready

    local data = LoadResourceFile(GetCurrentResourceName(), 'farms.json')
    if not data or data == '' then
        print('^3[Renewed-Farming MIGRATION] No farms.json found, skipping migration.^0')
        return
    end

    -- Strip UTF-8 BOM if present
    if string.byte(data, 1) == 239 and string.byte(data, 2) == 187 and string.byte(data, 3) == 191 then
        data = string.sub(data, 4)
    end

    local success, decoded = pcall(json.decode, data)
    if not success or type(decoded) ~= 'table' then
        print('^1[Renewed-Farming MIGRATION] Failed to parse farms.json!^0')
        return
    end

    -- Check if DB already has farms
    local existing = MySQL.query.await('SELECT COUNT(*) as cnt FROM `farms`')
    if existing and existing[1] and existing[1].cnt > 0 then
        print('^3[Renewed-Farming MIGRATION] Database already has ' .. existing[1].cnt .. ' farms. Skipping migration.^0')
        print('^3[Renewed-Farming MIGRATION] If you want to re-import, clear the farms table first.^0')
        return
    end

    local count = 0
    for idStr, v in pairs(decoded) do
        local x = v.x or 0
        local y = v.y or 0
        local z = v.z or 0
        local heading = v.heading or 0
        local spots = v.spots or {}

        MySQL.prepare.await(
            'INSERT INTO `farms` (`id`, `x`, `y`, `z`, `heading`, `spots`) VALUES (?, ?, ?, ?, ?, ?)',
            { tonumber(idStr), x, y, z, heading, json.encode(spots) }
        )
        count = count + 1
    end

    print('^2[Renewed-Farming MIGRATION] Successfully migrated ' .. count .. ' farms from farms.json to database!^0')
    print('^2[Renewed-Farming MIGRATION] You can now safely remove farms.json and this migration script.^0')
end)
