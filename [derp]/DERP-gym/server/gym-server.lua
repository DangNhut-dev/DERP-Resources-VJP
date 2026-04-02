RESCB("DERP-gym:server:getItem",function(source,cb,item, remove)
	local xPlayer = GETPFI(source)
    if GetItemCount(xPlayer, item) > 0 then
        if remove then
            RemoveItem(xPlayer, item)
        end
        cb(true)
    else
        cb(false)
    end
end)
