RegisterNetEvent("tablet:setPlayerUnit", function(job, data)
    SendReactMessage("setUserUnit", {
        job = job,
        unit = data.unit,
        source = data.source
    })
end)

RegisterNetEvent("tablet:unitCreated", function(job, unitName, status)
    SendReactMessage("addUnit", {
        job = job,
        name = unitName,
        status = status
    })
end)

RegisterNetEvent("tablet:unitRemoved", function(job, unit)
    SendReactMessage("removeUnit", {
        job = job,
        unit = unit
    })
end)

RegisterNetEvent("tablet:unitUpdated", function(job, data)
    SendReactMessage("updateUnit", {
        job = job,
        unit = data.unit,
        status = data.status,
        newName = data.newName
    })
end)