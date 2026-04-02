if CFG.Framework ~= 'qbox' and CFG.DetectedFramework ~= 'qbox' then return end

TriggerServerCallback = function(name, data)
    return lib.callback.await(name, data)
end
