-- modules/clothing/glove_admin.lua
local ClothingConfig = require 'modules.clothing.shared'

local GloveAdmin = {}

-- ── Load citizenIdExtras from DB into shared config cache ──────
function GloveAdmin.LoadFromDB()
    local rows = MySQL.query.await('SELECT citizenid, drawable, texture FROM clothing_glove_extras')
    local extras = {}

    if rows then
        for _, row in ipairs(rows) do
            if not extras[row.citizenid] then
                extras[row.citizenid] = {}
            end
            extras[row.citizenid][#extras[row.citizenid] + 1] = {
                drawable = row.drawable,
                texture = row.texture,
            }
        end
    end

    ClothingConfig.gloveSelector.citizenIdExtras = extras
end

-- ── Add entry to DB + cache ────────────────────────────────────
---@param citizenid string
---@param drawable number
---@param texture number
---@return boolean success
function GloveAdmin.AddEntry(citizenid, drawable, texture)
    local affected = MySQL.insert.await(
        'INSERT IGNORE INTO clothing_glove_extras (citizenid, drawable, texture) VALUES (?, ?, ?)',
        { citizenid, drawable, texture }
    )

    if not affected or affected == 0 then return false end

    local extras = ClothingConfig.gloveSelector.citizenIdExtras
    if not extras[citizenid] then
        extras[citizenid] = {}
    end
    extras[citizenid][#extras[citizenid] + 1] = { drawable = drawable, texture = texture }

    return true
end

-- ── Remove entry from DB + cache ───────────────────────────────
---@param citizenid string
---@param drawable number
---@param texture number
---@return boolean success
function GloveAdmin.RemoveEntry(citizenid, drawable, texture)
    local affected = MySQL.update.await(
        'DELETE FROM clothing_glove_extras WHERE citizenid = ? AND drawable = ? AND texture = ?',
        { citizenid, drawable, texture }
    )

    if not affected or affected == 0 then return false end

    local extras = ClothingConfig.gloveSelector.citizenIdExtras
    if extras[citizenid] then
        for i = #extras[citizenid], 1, -1 do
            local e = extras[citizenid][i]
            if e.drawable == drawable and e.texture == texture then
                table.remove(extras[citizenid], i)
                break
            end
        end
        if #extras[citizenid] == 0 then
            extras[citizenid] = nil
        end
    end

    return true
end

-- ── Sync glove options to online player by citizenid ───────────
---@param citizenid string
function GloveAdmin.SyncOnlinePlayer(citizenid)
    local players = exports.qbx_core:GetQBPlayers()
    for src, player in pairs(players) do
        if player.PlayerData.citizenid == citizenid then
            local job = player.PlayerData.job.name or ''
            local gloveOptions = ClothingConfig.GetGloveOptions(job, citizenid, nil)
            TriggerClientEvent('ox_inventory:syncGloveOptions', src, gloveOptions)
            break
        end
    end
end

-- ── Get all entries for display ────────────────────────────────
---@return table[]
function GloveAdmin.GetAllEntries()
    return MySQL.query.await('SELECT id, citizenid, drawable, texture FROM clothing_glove_extras ORDER BY citizenid, drawable') or {}
end

-- ── Load on resource start ─────────────────────────────────────
MySQL.ready(function()
    GloveAdmin.LoadFromDB()
end)

-- ── Command: gloveadmin ────────────────────────────────────────
lib.addCommand('gloveadmin', {
    help = 'Quản lý găng tay citizenID extras',
    restricted = 'group.admin',
}, function(source)
    TriggerClientEvent('ox_inventory:gloveAdminMenu', source)
end)

-- ── Server callbacks for admin menu ────────────────────────────
lib.callback.register('gloveAdmin:getEntries', function(source)
    return GloveAdmin.GetAllEntries()
end)

lib.callback.register('gloveAdmin:add', function(source, citizenid, drawable, texture)
    if not citizenid or not drawable then return false end
    texture = texture or 0
    local success = GloveAdmin.AddEntry(citizenid, drawable, texture)
    if success then
        GloveAdmin.SyncOnlinePlayer(citizenid)
    end
    return success
end)

lib.callback.register('gloveAdmin:remove', function(source, citizenid, drawable, texture)
    if not citizenid or not drawable then return false end
    texture = texture or 0
    local success = GloveAdmin.RemoveEntry(citizenid, drawable, texture)
    if success then
        GloveAdmin.SyncOnlinePlayer(citizenid)
    end
    return success
end)

return GloveAdmin