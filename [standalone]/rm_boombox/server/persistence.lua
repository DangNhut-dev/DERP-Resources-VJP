-- CREATE TABLE IF NOT EXISTS `rm_boombox` (
--     `id` VARCHAR(36) NOT NULL,
--     `owner` VARCHAR(60) NOT NULL,
--     `btype` VARCHAR(60) NOT NULL,
--     `coords` JSON NOT NULL,
--     `heading` FLOAT NOT NULL DEFAULT 0,
--     `queue` LONGTEXT NULL,
--     `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
--     PRIMARY KEY (`id`),
--     INDEX `idx_owner` (`owner`)
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

RmBoomboxPersistence = {}

local oxmysql = exports.oxmysql

local function encodeCoords(coords)
    return json.encode({ x = coords.x, y = coords.y, z = coords.z })
end

local function decodeCoords(jsonStr)
    local ok, data = pcall(json.decode, jsonStr)
    if not ok or not data then return nil end
    return vector3(data.x + 0.0, data.y + 0.0, data.z + 0.0)
end

local function waitForOxmysql()
    while GetResourceState('oxmysql') ~= 'started' do
        Wait(50)
    end
end

function RmBoomboxPersistence.save(boomboxId, owner, bType, coords, heading, queue)
    oxmysql:prepare('INSERT INTO rm_boombox (id, owner, btype, coords, heading, queue) VALUES (?, ?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE queue = VALUES(queue), coords = VALUES(coords), heading = VALUES(heading)', {
        boomboxId,
        owner,
        bType,
        encodeCoords(coords),
        heading or 0.0,
        json.encode(queue or {})
    })
end

function RmBoomboxPersistence.updateQueue(boomboxId, queue)
    oxmysql:prepare('UPDATE rm_boombox SET queue = ? WHERE id = ?', {
        json.encode(queue or {}),
        boomboxId
    })
end

function RmBoomboxPersistence.delete(boomboxId)
    oxmysql:prepare('DELETE FROM rm_boombox WHERE id = ?', { boomboxId })
end

function RmBoomboxPersistence.loadAll()
    waitForOxmysql()
    local rows = oxmysql:query_async('SELECT id, owner, btype, coords, heading, queue FROM rm_boombox')
    if not rows then return {} end
    local result = {}
    for i = 1, #rows do
        local row = rows[i]
        local coords = decodeCoords(row.coords)
        if coords then
            local okQ, queue = pcall(json.decode, row.queue or '[]')
            if not okQ or type(queue) ~= 'table' then queue = {} end
            result[#result + 1] = {
                id = row.id,
                owner = row.owner,
                bType = row.btype,
                coords = coords,
                heading = row.heading + 0.0,
                queue = queue
            }
        end
    end
    return result
end