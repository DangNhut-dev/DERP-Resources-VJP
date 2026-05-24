-- modules/clothing/shared.lua
local ClothingConfig = {
    items = {
        mu          = { slot = 1,  slotType = 'hat',        label = 'Mũ',          componentId = 0,  componentType = 'props' },
        matna       = { slot = 2,  slotType = 'mask',       label = 'Mặt nạ',      componentId = 1,  componentType = 'component' },
        aokhoac     = { slot = 3,  slotType = 'jacket',     label = 'Áo khoác',    componentId = 11, componentType = 'component' },
        aotrong     = { slot = 4,  slotType = 'undershirt', label = 'Áo trong',     componentId = 8,  componentType = 'component' },
        tay         = { slot = 5,  slotType = 'gloves',     label = 'Găng tay',     componentId = 3,  componentType = 'component', selectorMode = true },
        quan        = { slot = 6,  slotType = 'pants',      label = 'Quần',         componentId = 4,  componentType = 'component' },
        giay        = { slot = 7,  slotType = 'shoes',      label = 'Giày',         componentId = 6,  componentType = 'component' },
        kinh        = { slot = 8,  slotType = 'glasses',    label = 'Kính',         componentId = 1,  componentType = 'props' },
        khuyentai   = { slot = 9,  slotType = 'ear',        label = 'Khuyên tai',   componentId = 2,  componentType = 'props' },
        daychuyen   = { slot = 10, slotType = 'necklace',   label = 'Dây chuyền',   componentId = 7,  componentType = 'component' },
        balo        = { slot = 11, slotType = 'backpack',   label = 'Ba lô',        componentId = 5,  componentType = 'component' },
        giap        = { slot = 12, slotType = 'vest',       label = 'Giáp',         componentId = 9,  componentType = 'component' },
        dongho      = { slot = 13, slotType = 'watch',      label = 'Đồng hồ',      componentId = 6,  componentType = 'props' },
        vongtay     = { slot = 14, slotType = 'bracelet',   label = 'Vòng tay',     componentId = 7,  componentType = 'props' },
        huyhieu     = { slot = 15, slotType = 'decal',      label = 'Huy hiệu',    componentId = 10, componentType = 'component' },
    },
    slotToItem = {},

    -- ── Decal slot whitelist ───────────────────────────────────
    decalJobs = {
        ['police'] = true,
        ['bcso'] = true,
    },

    -- ── Glove Selector Config ──────────────────────────────────
    gloveSelector = {
        -- Default drawables per gender
        defaultDrawables = {
            male = {
                { drawable = 0,  texture = 0 },
                { drawable = 1,  texture = 0 },
                { drawable = 2,  texture = 0 },
                { drawable = 3,  texture = 0 },
                { drawable = 4,  texture = 0 },
                { drawable = 5,  texture = 0 },
                { drawable = 6,  texture = 0 },
                { drawable = 7,  texture = 0 },
                { drawable = 8,  texture = 0 },
                { drawable = 9,  texture = 0 },
                { drawable = 10, texture = 0 },
                { drawable = 11, texture = 0 },
                { drawable = 12, texture = 0 },
                { drawable = 13, texture = 0 },
                { drawable = 14, texture = 0 },
                { drawable = 15, texture = 0 },
            },
            female = {
                { drawable = 0,   texture = 0 },
                { drawable = 1,   texture = 0 },
                { drawable = 2,   texture = 0 },
                { drawable = 3,   texture = 0 },
                { drawable = 4,   texture = 0 },
                { drawable = 5,   texture = 0 },
                { drawable = 6,   texture = 0 },
                { drawable = 7,   texture = 0 },
                { drawable = 8,   texture = 0 },
                { drawable = 9,   texture = 0 },
                { drawable = 10,  texture = 0 },
                { drawable = 11,  texture = 0 },
                { drawable = 12,  texture = 0 },
                { drawable = 13,  texture = 0 },
                { drawable = 14,  texture = 0 },
                { drawable = 15,  texture = 0 },
                { drawable = 248, texture = 0 },
                { drawable = 248, texture = 1 },
                { drawable = 248, texture = 2 },
                { drawable = 248, texture = 3 },
                { drawable = 248, texture = 4 },
                { drawable = 248, texture = 5 },
                { drawable = 248, texture = 6 },
                { drawable = 249, texture = 0 },
                { drawable = 249, texture = 1 },
                { drawable = 249, texture = 2 },
                { drawable = 249, texture = 3 },
                { drawable = 249, texture = 4 },
                { drawable = 249, texture = 5 },
                { drawable = 249, texture = 6 },
                { drawable = 250, texture = 0 },
                { drawable = 250, texture = 1 },
                { drawable = 250, texture = 2 },
                { drawable = 250, texture = 3 },
                { drawable = 250, texture = 4 },
                { drawable = 250, texture = 5 },
                { drawable = 250, texture = 6 },
                { drawable = 251, texture = 0 },
                { drawable = 251, texture = 1 },
                { drawable = 251, texture = 2 },
                { drawable = 251, texture = 3 },
                { drawable = 251, texture = 4 },
                { drawable = 251, texture = 5 },
                { drawable = 251, texture = 6 },
                { drawable = 252, texture = 0 },
                { drawable = 252, texture = 1 },
                { drawable = 252, texture = 2 },
                { drawable = 252, texture = 3 },
                { drawable = 252, texture = 4 },
                { drawable = 252, texture = 5 },
                { drawable = 252, texture = 6 },
                { drawable = 253, texture = 0 },
                { drawable = 253, texture = 1 },
                { drawable = 253, texture = 2 },
                { drawable = 253, texture = 3 },
                { drawable = 253, texture = 4 },
                { drawable = 253, texture = 5 },
                { drawable = 253, texture = 6 },
                { drawable = 254, texture = 0 },
                { drawable = 254, texture = 1 },
                { drawable = 254, texture = 2 },
                { drawable = 254, texture = 3 },
                { drawable = 254, texture = 4 },
                { drawable = 254, texture = 5 },
                { drawable = 254, texture = 6 },
                { drawable = 255, texture = 0 },
                { drawable = 255, texture = 1 },
                { drawable = 255, texture = 2 },
                { drawable = 255, texture = 3 },
                { drawable = 255, texture = 4 },
                { drawable = 255, texture = 5 },
                { drawable = 255, texture = 6 },
            },
        },

        -- Extra drawables theo job, phân biệt gender
        jobExtras = {
            police = {
                male = {
                    { drawable = 33, texture = 0 },
                    { drawable = 37, texture = 0 },
                },
                female = {
                    { drawable = 36, texture = 0 },
                    { drawable = 41, texture = 0 },
                }
            },
            ambulance = {
                male = {
                    { drawable = 88, texture = 0 },
                    { drawable = 85, texture = 0 },
                },
                female = {
                    { drawable = 101, texture = 0 },
                    { drawable = 100, texture = 0 },
                },
            },
        },

        -- Runtime cache, loaded from DB on server start
        citizenIdExtras = {},
    },

    defaults = {
        male = {
            [0] = { drawable = -1, texture = 0 }, [1] = { drawable = 0, texture = 0 },
            [3] = { drawable = 15, texture = 0 }, [4] = { drawable = 18, texture = 6 },
            [5] = { drawable = 0, texture = 0 },  [6] = { drawable = 34, texture = 0 },
            [7] = { drawable = 0, texture = 0 },  [8] = { drawable = 15, texture = 0 },
            [9] = { drawable = 0, texture = 0 },  [10] = { drawable = 0, texture = 0 },
            [11] = { drawable = 15, texture = 0 },
        },
        female = {
            [0] = { drawable = -1, texture = 0 }, [1] = { drawable = 0, texture = 0 },
            [3] = { drawable = 15, texture = 0 }, [4] = { drawable = 15, texture = 3 },
            [5] = { drawable = 0, texture = 0 },  [6] = { drawable = 35, texture = 0 },
            [7] = { drawable = 0, texture = 0 },  [8] = { drawable = 10, texture = 0 },
            [9] = { drawable = 0, texture = 0 },  [10] = { drawable = 0, texture = 0 },
            [11] = { drawable = 5, texture = 0 },
        },
        props = { [0] = -1, [1] = -1, [2] = -1, [6] = -1, [7] = -1 }
    }
}

for itemName, def in pairs(ClothingConfig.items) do
    ClothingConfig.slotToItem[def.slot] = itemName
end

function ClothingConfig.GetDef(itemName) return ClothingConfig.items[itemName] end
function ClothingConfig.GetItemBySlot(slot) return ClothingConfig.slotToItem[slot] end
function ClothingConfig.IsClothing(itemName) return ClothingConfig.items[itemName] ~= nil end

---@param job string
---@return boolean
function ClothingConfig.HasDecalAccess(job)
    return ClothingConfig.decalJobs[job] == true
end

---@param job string
---@param citizenId string
---@param gender number 0=male, 1=female
---@return table[]
function ClothingConfig.GetGloveOptions(job, citizenId, gender)
    local options = {}
    local cfg = ClothingConfig.gloveSelector
    local genderKey = gender == 1 and 'female' or 'male'

    local defaults = cfg.defaultDrawables[genderKey]
    if defaults then
        for _, entry in ipairs(defaults) do
            options[#options + 1] = { drawable = entry.drawable, texture = entry.texture }
        end
    end

    if job and cfg.jobExtras[job] then
        local jobGender = cfg.jobExtras[job][genderKey]
        if jobGender then
            for _, entry in ipairs(jobGender) do
                options[#options + 1] = { drawable = entry.drawable, texture = entry.texture }
            end
        end
    end

    if citizenId and cfg.citizenIdExtras[citizenId] then
        for _, entry in ipairs(cfg.citizenIdExtras[citizenId]) do
            options[#options + 1] = { drawable = entry.drawable, texture = entry.texture }
        end
    end

    return options
end

return ClothingConfig