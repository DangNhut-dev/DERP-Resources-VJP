local isOpen = false
local currentClothType = nil
local currentGender = nil
local currentDrawable = 0
local currentTexture = 0
local maxDrawables = 0
local maxTextures = 0
local assignedItems = {}
local originalAppearance = {}

-- Keybind map: numrow 1-5
local rarityBinds = {}
for _, tier in ipairs(Config.RarityTiers) do
    rarityBinds[tier.bind] = tier.key
end

-- FiveM numrow keys (1=157, 2=158, 3=160, 4=164, 5=165)
local numrowKeys = { [157] = 1, [158] = 2, [160] = 3, [164] = 4, [165] = 5 }
-- E = skip (next), Q = prev
local KEY_SKIP = 38    -- E
local KEY_PREV = 44    -- Q
local KEY_SAVE = 168   -- F7
local KEY_CLOSE = 202  -- Backspace (INPUT_FRONTEND_DELETE)

local function getComponentCount(ped, def)
    if def.componentType == 'props' then
        return GetNumberOfPedPropDrawableVariations(ped, def.componentId)
    else
        return GetNumberOfPedDrawableVariations(ped, def.componentId)
    end
end

local function getTextureCount(ped, def, drawable)
    if def.componentType == 'props' then
        return GetNumberOfPedPropTextureVariations(ped, def.componentId, drawable)
    else
        return GetNumberOfPedTextureVariations(ped, def.componentId, drawable)
    end
end

local function applyPreview(ped, def, drawable, texture)
    if def.componentType == 'props' then
        if drawable >= 0 then
            SetPedPropIndex(ped, def.componentId, drawable, texture, true)
        else
            ClearPedProp(ped, def.componentId)
        end
    else
        SetPedComponentVariation(ped, def.componentId, drawable, texture, 0)
    end
end

local savedComponents = {}

local function saveOriginalAppearance(ped, def)
    if def.componentType == 'props' then
        originalAppearance.drawable = GetPedPropIndex(ped, def.componentId)
        originalAppearance.texture = GetPedPropTextureIndex(ped, def.componentId)
    else
        originalAppearance.drawable = GetPedDrawableVariation(ped, def.componentId)
        originalAppearance.texture = GetPedTextureVariation(ped, def.componentId)
    end
end

local function restoreOriginalAppearance(ped, def)
    applyPreview(ped, def, originalAppearance.drawable or 0, originalAppearance.texture or 0)
end

-- Save all components/props then reset to defaults so target component is not occluded
local function saveAndResetOthers(ped, activeDef, gender)
    savedComponents = {}
    local genderKey = gender == 0 and 'male' or 'female'

    local defaults = {
        male = {
            [1] = { d = 0, t = 0 },   [3] = { d = 15, t = 0 },
            [4] = { d = 18, t = 6 },   [5] = { d = 0, t = 0 },
            [6] = { d = 34, t = 0 },   [7] = { d = 0, t = 0 },
            [8] = { d = 15, t = 0 },   [9] = { d = 0, t = 0 },
            [10] = { d = 0, t = 0 },   [11] = { d = 15, t = 0 },
        },
        female = {
            [1] = { d = 0, t = 0 },   [3] = { d = 15, t = 0 },
            [4] = { d = 10, t = 0 },   [5] = { d = 0, t = 0 },
            [6] = { d = 35, t = 0 },   [7] = { d = 0, t = 0 },
            [8] = { d = 10, t = 0 },   [9] = { d = 0, t = 0 },
            [10] = { d = 0, t = 0 },   [11] = { d = 5, t = 0 },
        },
    }

    local propDefaults = { [0] = -1, [1] = -1, [2] = -1, [6] = -1, [7] = -1 }

    -- Save & reset components
    for compId = 0, 11 do
        if not (activeDef.componentType == 'component' and compId == activeDef.componentId) then
            savedComponents[('c_%d'):format(compId)] = {
                drawable = GetPedDrawableVariation(ped, compId),
                texture = GetPedTextureVariation(ped, compId),
            }
            local def = defaults[genderKey] and defaults[genderKey][compId]
            if def then
                SetPedComponentVariation(ped, compId, def.d, def.t, 0)
            end
        end
    end

    -- Save & reset props
    for _, propId in ipairs({ 0, 1, 2, 6, 7 }) do
        if not (activeDef.componentType == 'props' and propId == activeDef.componentId) then
            savedComponents[('p_%d'):format(propId)] = {
                drawable = GetPedPropIndex(ped, propId),
                texture = GetPedPropTextureIndex(ped, propId),
            }
            ClearPedProp(ped, propId)
        end
    end
end

-- Restore all saved components/props
local function restoreAllOthers(ped)
    for key, data in pairs(savedComponents) do
        local type_, id = key:match('^(%a)_(%d+)$')
        id = tonumber(id)
        if type_ == 'c' then
            SetPedComponentVariation(ped, id, data.drawable, data.texture, 0)
        elseif type_ == 'p' then
            if data.drawable >= 0 then
                SetPedPropIndex(ped, id, data.drawable, data.texture, true)
            else
                ClearPedProp(ped, id)
            end
        end
    end
    savedComponents = {}
end

local function getClothDef(clothName)
    for _, v in ipairs(Config.ClothTypes) do
        if v.name == clothName then return v end
    end
    return nil
end

local function buildItemKey(clothName, drawable, texture, gender)
    return ('%s_%d_%d_%d'):format(clothName, drawable, texture, gender)
end

local function getRarityColor(rarityKey)
    for _, tier in ipairs(Config.RarityTiers) do
        if tier.key == rarityKey then return tier.color end
    end
    return '#ffffff'
end

local function updateNUI()
    local itemKey = buildItemKey(currentClothType, currentDrawable, currentTexture, currentGender)
    local assigned = assignedItems[itemKey]

    SendNUIMessage({
        action = 'updatePreview',
        data = {
            clothType = currentClothType,
            gender = currentGender,
            drawable = currentDrawable,
            texture = currentTexture,
            maxDrawables = maxDrawables,
            maxTextures = maxTextures,
            assignedRarity = assigned or nil,
            totalAssigned = 0,
        }
    })
end

local function countAssigned()
    local c = 0
    for _ in pairs(assignedItems) do c = c + 1 end
    return c
end

local function advanceNext(def)
    local ped = PlayerPedId()
    currentTexture = currentTexture + 1
    if currentTexture >= maxTextures then
        currentTexture = 0
        currentDrawable = currentDrawable + 1
        if currentDrawable >= maxDrawables then
            -- Done all drawables
            SendNUIMessage({
                action = 'showComplete',
                data = { total = countAssigned() }
            })
            SetNuiFocus(true, true)
            return false
        end
        maxTextures = getTextureCount(ped, def, currentDrawable)
        if maxTextures < 1 then maxTextures = 1 end
    end
    applyPreview(ped, def, currentDrawable, currentTexture)
    updateNUI()
    return true
end

local function goBack(def)
    local ped = PlayerPedId()
    currentTexture = currentTexture - 1
    if currentTexture < 0 then
        currentDrawable = currentDrawable - 1
        if currentDrawable < 0 then
            currentDrawable = 0
            currentTexture = 0
            applyPreview(ped, def, currentDrawable, currentTexture)
            updateNUI()
            return
        end
        maxTextures = getTextureCount(ped, def, currentDrawable)
        if maxTextures < 1 then maxTextures = 1 end
        currentTexture = maxTextures - 1
    end
    applyPreview(ped, def, currentDrawable, currentTexture)
    updateNUI()
end

-- Main input loop
local function startInputLoop(def)
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, true)
    TaskStandStill(ped, -1)

    CreateThread(function()
        while isOpen do
            Wait(0)
            -- Disable movement + combat + phone
            DisableControlAction(0, 24, true)  -- attack
            DisableControlAction(0, 25, true)  -- aim
            DisableControlAction(0, 30, true)  -- move LR
            DisableControlAction(0, 31, true)  -- move UD
            DisableControlAction(0, 21, true)  -- sprint
            DisableControlAction(0, 22, true)  -- jump
            DisableControlAction(0, 23, true)  -- enter vehicle
            DisableControlAction(0, 36, true)  -- stealth
            DisableControlAction(0, 37, true)  -- weapon select
            DisableControlAction(0, 44, true)  -- Q (cover) -> we handle manually
            DisableControlAction(0, 38, true)  -- E (pickup) -> we handle manually
            DisableControlAction(0, 47, true)  -- weapon
            DisableControlAction(0, 58, true)  -- weapon
            DisableControlAction(0, 140, true) -- melee
            DisableControlAction(0, 141, true) -- melee
            DisableControlAction(0, 142, true) -- melee
            DisableControlAction(0, 143, true) -- melee
            DisableControlAction(0, 75, true)  -- exit vehicle
            DisableControlAction(0, 202, true) -- backspace -> we handle manually

            -- Numrow 1-5: assign rarity
            for keyCode, num in pairs(numrowKeys) do
                if IsDisabledControlJustPressed(0, keyCode) then
                    local rarityKey = rarityBinds[num]
                    if rarityKey then
                        local itemKey = buildItemKey(currentClothType, currentDrawable, currentTexture, currentGender)
                        assignedItems[itemKey] = rarityKey

                        SendNUIMessage({
                            action = 'flashAssign',
                            data = { rarity = rarityKey, color = getRarityColor(rarityKey) }
                        })

                        Wait(200)
                        if not advanceNext(def) then break end
                    end
                end
            end

            -- E = skip
            if IsDisabledControlJustPressed(0, KEY_SKIP) then
                -- Remove assignment if existed
                local itemKey = buildItemKey(currentClothType, currentDrawable, currentTexture, currentGender)
                assignedItems[itemKey] = nil
                if not advanceNext(def) then break end
            end

            -- Q = go back
            if IsDisabledControlJustPressed(0, KEY_PREV) then
                goBack(def)
            end

            -- F7 = save
            if IsDisabledControlJustPressed(0, KEY_SAVE) then
                SendNUIMessage({ action = 'promptSave' })
                SetNuiFocus(true, true)
            end

            -- Backspace = close without save
            if IsDisabledControlJustPressed(0, KEY_CLOSE) then
                isOpen = false
                local ped = PlayerPedId()
                FreezeEntityPosition(ped, false)
                ClearPedTasks(ped)
                restoreOriginalAppearance(ped, def)
                restoreAllOthers(ped)
                SendNUIMessage({ action = 'closeUI' })
                SetNuiFocus(false, false)
            end
        end

        -- Loop ended (complete / break)
        local ped = PlayerPedId()
        FreezeEntityPosition(ped, false)
        ClearPedTasks(ped)
    end)
end

RegisterNUICallback('startSession', function(data, cb)
    cb('ok')
    SetNuiFocus(false, false)

    local clothName = data.clothType
    local gender = data.gender
    local startDrawable = tonumber(data.startDrawable) or 0

    local def = getClothDef(clothName)
    if not def then return end

    local ped = PlayerPedId()
    local model = GetEntityModel(ped)
    local pedGender = model == `mp_m_freemode_01` and 0 or 1

    if pedGender ~= gender then
        SendNUIMessage({
            action = 'showError',
            data = { message = 'Ped hien tai khong dung gioi tinh da chon. Doi ped truoc.' }
        })
        SetNuiFocus(true, true)
        return
    end

    currentClothType = clothName
    currentGender = gender
    assignedItems = {}

    saveOriginalAppearance(ped, def)
    saveAndResetOthers(ped, def, gender)

    maxDrawables = getComponentCount(ped, def)
    if maxDrawables < 1 then
        restoreAllOthers(ped)
        SendNUIMessage({
            action = 'showError',
            data = { message = 'Khong co drawable nao cho component nay.' }
        })
        SetNuiFocus(true, true)
        return
    end

    if startDrawable >= maxDrawables then startDrawable = 0 end
    currentDrawable = startDrawable
    currentTexture = 0

    maxTextures = getTextureCount(ped, def, currentDrawable)
    if maxTextures < 1 then maxTextures = 1 end

    applyPreview(ped, def, currentDrawable, currentTexture)

    isOpen = true
    SendNUIMessage({
        action = 'showBrowsing',
        data = {
            clothType = clothName,
            gender = gender,
            rarityTiers = Config.RarityTiers,
        }
    })

    updateNUI()
    startInputLoop(def)
end)

RegisterNUICallback('saveOutput', function(data, cb)
    cb('ok')
    SetNuiFocus(false, false)

    if not data.lootboxKey or data.lootboxKey == '' then
        SendNUIMessage({
            action = 'showError',
            data = { message = 'Lootbox key khong duoc de trong.' }
        })
        SetNuiFocus(true, true)
        return
    end

    TriggerServerEvent('DERP-rarity-tool:save', {
        lootboxKey = data.lootboxKey,
        lootboxLabel = data.lootboxLabel or '',
        clothType = currentClothType,
        gender = currentGender,
        items = assignedItems,
    })

    isOpen = false
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, false)
    ClearPedTasks(ped)
    local def = getClothDef(currentClothType)
    if def then
        restoreOriginalAppearance(ped, def)
    end
    restoreAllOthers(ped)

    SendNUIMessage({ action = 'showSaved' })
end)

RegisterNUICallback('cancelSave', function(_, cb)
    cb('ok')
    SetNuiFocus(false, false)
end)

RegisterNUICallback('requestFocus', function(_, cb)
    cb('ok')
    SetNuiFocus(true, true)
end)

RegisterNUICallback('closeUI', function(_, cb)
    cb('ok')
    SetNuiFocus(false, false)
    isOpen = false

    local ped = PlayerPedId()
    FreezeEntityPosition(ped, false)
    ClearPedTasks(ped)
    local def = getClothDef(currentClothType)
    if def then
        restoreOriginalAppearance(ped, def)
    end
    restoreAllOthers(ped)
end)

RegisterCommand('raritytool', function()
    if isOpen then return end
    isOpen = true
    SetNuiFocus(true, true)

    SendNUIMessage({
        action = 'showMenu',
        data = {
            clothTypes = Config.ClothTypes,
            rarityTiers = Config.RarityTiers,
        }
    })
end, false)