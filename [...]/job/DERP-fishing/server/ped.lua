---@param source integer
---@param fishName string
---@param amount integer
lib.callback.register('derp-fishing:sellFish', function(source, fishName, amount)
    local item = Config.fish[fishName]

    if not item or amount <= 0 then return end

    local price = type(item.price) == 'number' and item.price or math.random(item.price.min, item.price.max)

    ---@cast price number

    local player = Framework.getPlayerFromId(source)
    
    if not player then return end
    
    if player:getItemCount(fishName) >= amount then
        SetTimeout(3000, function()
            if player:getItemCount(fishName) < amount then return end

            local beforeMoney = Utils.captureMoneySnapshot(player, Config.ped.sellAccount)
            local totalPrice = price * amount

            player:removeItem(fishName, amount)
            player:addAccountMoney(Config.ped.sellAccount, totalPrice)

            local afterMoney = Utils.captureMoneySnapshot(player, Config.ped.sellAccount)

            Utils.logAction(source, 'Bán cá', {
                { 'danh sách', Utils.formatItemListLog({
                    { name = fishName, count = amount, mode = 'remove' }
                }) },
                { 'cá', Utils.formatItemLog(fishName, amount, 'remove') },
                { 'đơn giá', tostring(price) },
                { 'tổng', tostring(totalPrice) },
                { 'tiền', tostring(Config.ped.sellAccount) },
            }, {
                beforeMoney = beforeMoney,
                afterMoney = afterMoney
            })
        end)

        return true
    end

    return false
end)

---@param source integer
---@param amount integer
lib.callback.register('derp-fishing:buy', function(source, data, amount)
    local type, index = data.type, data.index

    if type ~= 'fishingRods' and type ~= 'baits' then return end

    local item = Config[type][index]

    if not item or amount <= 0 then return end

    local price = item.price * amount
    local player = Framework.getPlayerFromId(source)

    if not player
    or GetPlayerLevel(player) < item.minLevel then return end

    if player:getAccountMoney(Config.ped.buyAccount) >= price then
        SetTimeout(3000, function()
            if player:getAccountMoney(Config.ped.buyAccount) < price then return end

            local beforeMoney = Utils.captureMoneySnapshot(player, Config.ped.buyAccount)

            player:removeAccountMoney(Config.ped.buyAccount, price)
            player:addItem(item.name, amount)

            local afterMoney = Utils.captureMoneySnapshot(player, Config.ped.buyAccount)

            Utils.logAction(source, 'Mua vật phẩm câu cá', {
                { 'shop', tostring(Config.ped.blip and Config.ped.blip.name or 'Cửa Hàng Câu') },
                { 'danh sách', Utils.formatItemListLog({
                    { name = item.name, count = amount, mode = 'add' }
                }) },
                { 'item', Utils.formatItemLog(item.name, amount, 'add') },
                { 'đơn giá', tostring(item.price) },
                { 'tổng', tostring(price) },
                { 'tiền', tostring(Config.ped.buyAccount) },
            }, {
                beforeMoney = beforeMoney,
                afterMoney = afterMoney
            })
        end)
        
        return true
    end

    return false
end)
