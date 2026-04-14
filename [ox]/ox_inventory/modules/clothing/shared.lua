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
        defaultCount = 16,

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
    local genderKey = gender == 0 and 'male' or 'female'

    for i = 0, cfg.defaultCount - 1 do
        options[#options + 1] = { drawable = i, texture = 0 }
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