
lib.locale()

CreateThread(function()
    TriggerServerEvent("prp-pettycrime:server:startup")
end)

lib.callback.register("prp-pettycrime:client:inputDialog", function(header, rows)
    return bridge.fw.inputDialog(header, rows)
end)

