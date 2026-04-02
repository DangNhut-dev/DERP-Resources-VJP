if Config.Item.Inventory ~= "ox_inventory" or not Config.Item.Unique or not Config.Item.Require then
    return
end

---Function to check if a player has a phone with a specific number
---@param source any
---@param phoneNumber string
---@return boolean
function HasPhoneNumber(source, phoneNumber)
    debugprint("checking if " .. source .. " has a phone item with number", phoneNumber)
    local phones = exports.ox_inventory:Search(source, "slots", Config.Item.Name)
    if not phones then
        return false
    end

    for i = 1, #phones do
        if phones[i]?.metadata?.lbPhoneNumber == phoneNumber then
            debugprint("they do")
            return true
        end
    end
    return false
end

---Function to set a phone number to a player's empty phone item
---@param source number
---@param phoneNumber string
---@return boolean success
function SetPhoneNumber(source, phoneNumber)
    debugprint("setting phone number to", phoneNumber, "for", source)
    local phones = exports.ox_inventory:Search(source, "slots", Config.Item.Name)
    if not phones then
        return false
    end

    for i = 1, #phones do
        local phone = phones[i]
        if phone?.metadata?.lbPhoneNumber == nil then
            phone.metadata = {
                lbPhoneNumber = phoneNumber,
                lbFormattedNumber = FormatNumber(phoneNumber)
            }
            exports.ox_inventory:SetMetadata(source, phone.slot, phone.metadata)
            debugprint("set phone number to", phoneNumber, "for", source)
            return true
        end
    end

    return false
end

function SetItemName(source, phoneNumber, name)
    local phones = exports.ox_inventory:Search(source, "slots", Config.Item.Name)
    if not phones then
        return false
    end

    for i = 1, #phones do
        local phone = phones[i]
        if phone?.metadata?.lbPhoneNumber == phoneNumber then
            phone.metadata.lbPhoneName = name
            phone.metadata.lbFormattedNumber = FormatNumber(phoneNumber)
            exports.ox_inventory:SetMetadata(source, phone.slot, phone.metadata)
            return true
        end
    end

    return false
end

--- Hook swapItems: update phone_last_phone khi phone doi tay
exports.ox_inventory:registerHook("swapItems", function(payload)
    if payload.fromInventory == payload.toInventory then return true end

    local item = payload.fromSlot
    if not item or item.name ~= Config.Item.Name then return true end

    local phoneNumber = item.metadata?.lbPhoneNumber
    if not phoneNumber then return true end

    local toSource = type(payload.toInventory) == "number" and payload.toInventory or nil
    local fromSource = type(payload.fromInventory) == "number" and payload.fromInventory or nil

    -- Xu ly nguoi nhan: update phone_last_phone ngay trong hook (truoc khi item move)
    if toSource then
        local toCid = GetIdentifier(toSource)
        if toCid then
            MySQL.update("INSERT INTO phone_last_phone (id, phone_number) VALUES (?, ?) ON DUPLICATE KEY UPDATE phone_number = ?", {
                toCid, phoneNumber, phoneNumber
            })
        end
    end

    -- Xu ly nguoi gui: neu phone_last_phone cua ho tro den so nay thi xoa
    if fromSource and fromSource ~= toSource then
        local fromCid = GetIdentifier(fromSource)
        if fromCid then
            MySQL.update("DELETE FROM phone_last_phone WHERE id = ? AND phone_number = ?", { fromCid, phoneNumber })
        end

        -- Delay client events de ox_inventory hoan tat move
        SetTimeout(300, function()
            TriggerClientEvent("lb-phone:itemRemoved", fromSource)
            if toSource then
                TriggerClientEvent("lb-phone:itemAdded", toSource)
            end
        end)
    elseif toSource then
        SetTimeout(300, function()
            TriggerClientEvent("lb-phone:itemAdded", toSource)
        end)
    end

    return true
end, {})