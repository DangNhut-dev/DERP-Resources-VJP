registerServerCallback("0r_idcard:server:getPlayerData", function(source, cb)
    cb(useIdCard(source))
end)

registerServerCallback("0r_idcard:server:doesPlayerHasLicense", function(_, cb, type, src)
    cb(doesPlayerHasLicense(type, src))
end)