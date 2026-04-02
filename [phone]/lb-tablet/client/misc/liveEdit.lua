ReactCallback("LiveEdit", function(data)
    local action = data.action
    local docId = data.docId

    if action == "getDocument" then
        return AwaitCallback("liveEdit:getDocument", docId, data.clientId)
    elseif action == "leaveDocument" then
        TriggerServerEvent("liveEdit:leaveDocument")
    elseif action == "refreshAwareness" then
        TriggerServerEvent("liveEdit:refreshAwareness", docId)
    elseif action == "crdtUpdate" then
        return AwaitCallback("liveEdit:crdtUpdate", docId, data.update)
    elseif action == "awarenessUpdate" then
        TriggerServerEvent("liveEdit:updateAwareness", docId, data.originClientId, data.state)
        return "ok"
    elseif action == "saveFullDocState" then
        TriggerServerEvent("liveEdit:saveFullDocState", docId, data.fullState)
        return "ok"
    end
end)

RegisterNetEvent("liveEdit:crdtBroadcast", function(docId, update)
    SendReactMessage("liveEdit:crdtBroadcast", { docId = docId, update = update })
end)

RegisterNetEvent("liveEdit:awarenessUpdate", function(docId, clientId, state)
    debugprint("awarenessUpdate", docId, clientId, state)
    SendReactMessage("liveEdit:awarenessUpdate", { docId = docId, clientId = clientId, state = state })
end)