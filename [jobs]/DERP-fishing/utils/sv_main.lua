lib.locale()
lib.versionCheck('https://github.com/Lunar-Scripts/derp-fishing')

Utils = {}
local resourceName = GetCurrentResourceName()

---@diagnostic disable-next-line: duplicate-set-field
function Utils.getTableSize(t)
    local count = 0

	for _,_ in pairs(t) do
		count = count + 1
	end

	return count
end

---@generic K, V
---@param t table<K, V>
---@return V, K
---@diagnostic disable-next-line: duplicate-set-field
function Utils.randomFromTable(t)
    local index = math.random(1, #t)
    return t[index], index
end

---@param source integer
---@param xPlayer Player 
---@param message string
function Utils.logToDiscord(source, xPlayer, message)
    if SvConfig.Webhook == 'WEBHOOK_HERE' then return end

    local connect = {
        {
            ["color"] = "16768885",
            ["title"] = GetPlayerName(source) .. " (" .. xPlayer:getIdentifier() .. ")",
            ["description"] = message,
            ["footer"] = {
                ["text"] = os.date('%H:%M - %d. %m. %Y', os.time()),
                ["icon_url"] = 'https://cdn.discordapp.com/attachments/793081015433560075/1048643072952647700/lunar.png',
            },
        }
    }
    PerformHttpRequest(SvConfig.Webhook, function(err, text, headers) end,
        'POST', json.encode({ username = resourceName, embeds = connect }), { ['Content-Type'] = 'application/json' })
end

local labels, ready

CreateThread(function()
    while not labels or Utils.getTableSize(labels) == 0 do
        local items = Framework.getItems()
        local temp = {}

        for name, item in pairs(items) do
            temp[item.name or name] = item.label or 'NULL'
        end

        labels = temp

        Wait(100)
    end

    ready = true
end)

lib.callback.register('derp-fishing:getItemLabels', function()
    while not ready do Wait(100) end

    return labels
end)

---@param name string
---@diagnostic disable-next-line: duplicate-set-field
function Utils.getItemLabel(name)
    return labels[name] or labels[name:upper()] or 'ITEM_NOT_FOUND'
end

---@param itemName string
---@param amount number?
---@param mode 'add' | 'remove'?
function Utils.formatItemLog(itemName, amount, mode)
    local label = Utils.getItemLabel(itemName)
    local display = tostring(itemName or '')

    if label and label ~= '' and label ~= display then
        display = ('%s(%s)'):format(display, label)
    end

    local prefix = ''

    if mode == 'add' then
        prefix = '+'
    elseif mode == 'remove' then
        prefix = '-'
    end

    amount = math.floor(tonumber(amount) or 0)

    if amount > 0 then
        return ('%s%s x%s'):format(prefix, display, amount)
    end

    return prefix .. display
end

---@param items { name: string, count: number, mode: 'add' | 'remove' }[]
function Utils.formatItemListLog(items)
    if type(items) ~= 'table' or #items == 0 then
        return nil
    end

    local parts = {}

    for i = 1, #items do
        local item = items[i]

        if type(item) == 'table' and item.name then
            parts[#parts + 1] = Utils.formatItemLog(item.name, item.count, item.mode)
        end
    end

    if #parts == 0 then
        return nil
    end

    return table.concat(parts, ', ')
end

function Utils.isJsRankingStarted()
    return GetResourceState('js_ranking') == 'started'
end

---@param source integer
---@param actionText string
---@param opts table?
function Utils.addActionLog(source, actionText, opts)
    if not Utils.isJsRankingStarted() then return false end
    if type(source) ~= 'number' or source <= 0 then return false end
    if not actionText or actionText == '' then return false end

    local ok = pcall(function()
        exports['js_ranking']:AddActionLog(source, actionText, opts or {})
    end)

    return ok
end

---@param title string
---@param details table?
function Utils.buildActionText(title, details)
    local message = ('[DERP-fishing] | %s'):format(tostring(title or ''))

    if type(details) == 'table' and #details > 0 then
        local parts = {}

        for i = 1, #details do
            local entry = details[i]
            local key = entry and entry[1]
            local value = entry and entry[2]

            if key and value ~= nil and value ~= '' then
                parts[#parts + 1] = ('%s: %s'):format(tostring(key), tostring(value))
            end
        end

        if #parts > 0 then
            message = message .. ' | ' .. table.concat(parts, ' | ')
        end
    end

    return message
end

---@param source integer
---@param title string
---@param details table?
---@param opts table?
function Utils.logAction(source, title, details, opts)
    return Utils.addActionLog(source, Utils.buildActionText(title, details), opts)
end

---@param player Player
---@param accountHint string?
function Utils.captureMoneySnapshot(player, accountHint)
    local snapshot = {}

    local function setMoney(key, value)
        if key == nil then return end

        key = tostring(key)
        if key == '' then return end

        value = tonumber(value) or 0
        snapshot[key] = value

        local lower = key:lower()

        if lower == 'money' then
            snapshot.cash = value
        elseif lower == 'cash' then
            snapshot.money = value
        end
    end

    if player then
        if player.QBPlayer and player.QBPlayer.PlayerData and type(player.QBPlayer.PlayerData.money) == 'table' then
            for key, value in pairs(player.QBPlayer.PlayerData.money) do
                setMoney(key, value)
            end
        elseif player.xPlayer then
            if type(player.xPlayer.accounts) == 'table' then
                for _, account in pairs(player.xPlayer.accounts) do
                    if type(account) == 'table' then
                        setMoney(account.name, account.money)
                    end
                end
            elseif type(player.xPlayer.getAccounts) == 'function' then
                local ok, accounts = pcall(player.xPlayer.getAccounts)

                if ok and type(accounts) == 'table' then
                    for key, account in pairs(accounts) do
                        if type(account) == 'table' then
                            setMoney(account.name or key, account.money)
                        else
                            setMoney(key, account)
                        end
                    end
                end
            end
        end
    end

    if accountHint and player and type(player.getAccountMoney) == 'function' then
        local ok, value = pcall(function()
            return player:getAccountMoney(accountHint)
        end)

        if ok then
            setMoney(accountHint, value)
        end
    end

    return snapshot
end
