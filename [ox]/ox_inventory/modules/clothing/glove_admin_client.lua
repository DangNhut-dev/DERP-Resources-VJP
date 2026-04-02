-- modules/clothing/glove_admin_client.lua
local GloveAdminClient = {}

local function openListMenu()
    local entries = lib.callback.await('gloveAdmin:getEntries', false)
    if not entries or #entries == 0 then
        lib.notify({ type = 'info', description = 'Chưa có dữ liệu nào' })
        return
    end

    local options = {}
    for _, entry in ipairs(entries) do
        local e = entry
        options[#options + 1] = {
            title = ('%s — Drawable: %d, Texture: %d'):format(e.citizenid, e.drawable, e.texture),
            icon = 'hand',
            onSelect = function()
                local confirm = lib.alertDialog({
                    header = 'Xác nhận xóa',
                    content = ('Xóa drawable **%d** texture **%d** của **%s**?'):format(e.drawable, e.texture, e.citizenid),
                    centered = true,
                    cancel = true,
                })

                if confirm == 'confirm' then
                    local success = lib.callback.await('gloveAdmin:remove', false, e.citizenid, e.drawable, e.texture)
                    if success then
                        lib.notify({ type = 'success', description = ('Đã xóa drawable %d texture %d của %s'):format(e.drawable, e.texture, e.citizenid) })
                    else
                        lib.notify({ type = 'error', description = 'Xóa thất bại' })
                    end
                end

                openListMenu()
            end,
        }
    end

    lib.registerContext({
        id = 'gloveadmin_list',
        title = ('Danh sách Glove Extras (%d)'):format(#entries),
        menu = 'gloveadmin_main',
        options = options,
    })
    lib.showContext('gloveadmin_list')
end

local function openMainMenu()
    lib.registerContext({
        id = 'gloveadmin_main',
        title = 'Quản lý Găng tay Extras',
        options = {
            {
                title = 'Thêm mới',
                description = 'Thêm drawable cho citizenID',
                icon = 'plus',
                onSelect = function()
                    local input = lib.inputDialog('Thêm Glove Extra', {
                        { type = 'input', label = 'CitizenID', required = true },
                        { type = 'number', label = 'Drawable', required = true, min = 0 },
                        { type = 'number', label = 'Texture', default = 0, min = 0 },
                    })
                    if not input then return openMainMenu() end

                    local citizenid = tostring(input[1]):gsub('%s+', '')
                    local drawable = tonumber(input[2])
                    local texture = tonumber(input[3]) or 0

                    if citizenid == '' or not drawable then
                        lib.notify({ type = 'error', description = 'Dữ liệu không hợp lệ' })
                        return openMainMenu()
                    end

                    local success = lib.callback.await('gloveAdmin:add', false, citizenid, drawable, texture)
                    if success then
                        lib.notify({ type = 'success', description = ('Đã thêm drawable %d texture %d cho %s'):format(drawable, texture, citizenid) })
                    else
                        lib.notify({ type = 'error', description = 'Thêm thất bại (có thể đã tồn tại)' })
                    end

                    openMainMenu()
                end,
            },
            {
                title = 'Xem danh sách',
                description = 'Xem và xóa extras đang có',
                icon = 'list',
                onSelect = openListMenu,
            },
        },
    })
    lib.showContext('gloveadmin_main')
end

RegisterNetEvent('ox_inventory:gloveAdminMenu', function()
    openMainMenu()
end)

RegisterNetEvent('ox_inventory:syncGloveOptions', function(gloveOptions)
    SendNUIMessage({
        action = 'updateGloveOptions',
        data = gloveOptions,
    })
end)

return GloveAdminClient