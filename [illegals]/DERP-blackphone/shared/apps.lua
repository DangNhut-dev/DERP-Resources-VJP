Apps = {}

Apps.Registered = {
    -- {
    --     id = 'pawnshop',
    --     name = 'Tiệm Cầm',
    --     icon = 'fa-solid fa-coins',
    --     color = '#05f2f2',
    --     enabled = true,
    --     order = 1,
    --     requireJob = nil,
    --     requireItem = nil
    -- }
}

function Apps.GetList()
    local list = {}
    for _, app in ipairs(Apps.Registered) do
        if app.enabled then
            list[#list + 1] = app
        end
    end
    table.sort(list, function(a, b) return (a.order or 99) < (b.order or 99) end)
    return list
end

function Apps.Get(id)
    for _, app in ipairs(Apps.Registered) do
        if app.id == id then return app end
    end
    return nil
end

function Apps.Register(data)
    if not data or not data.id then return false end
    -- Neu da ton tai -> update (cho phep re-register)
    for i, app in ipairs(Apps.Registered) do
        if app.id == data.id then
            Apps.Registered[i] = data
            return true
        end
    end
    Apps.Registered[#Apps.Registered + 1] = data
    return true
end