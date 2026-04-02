---- App Store server-side purchase handler
BaseCallback("appstore:purchase", function(source, callback, data)
    local price = data.price
    local phoneNumber = GetEquippedPhoneNumber(source)
    
    if not phoneNumber then
        callback(false)
        return
    end
    
    local success = RemoveMoney(source, price)
    callback(success)
end)
