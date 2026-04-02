-- client.lua
local spawnedNpcs = {}

local function SpawnNPC(job, cfg)
    local npcCfg = cfg.npc

    lib.requestModel(npcCfg.model)

    local ped = CreatePed(
        4,
        npcCfg.model,
        npcCfg.coords.x, npcCfg.coords.y, npcCfg.coords.z - 1.0,
        npcCfg.coords.w,
        false, true
    )

    SetEntityAsMissionEntity(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedDiesWhenInjured(ped, false)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    SetPedCanRagdoll(ped, false)
    TaskStartScenarioInPlace(ped, npcCfg.scenario, 0, true)
    SetModelAsNoLongerNeeded(npcCfg.model)

    exports.ox_target:addLocalEntity(ped, {
        {
            name     = 'departmentitems_open_' .. job,
            icon     = 'fa-solid fa-shirt',
            label    = cfg.label .. ' - Trang phục',
            onSelect = function()
                TriggerServerEvent('departmentitems:server:getMenuData')
            end,
        },
    })

    spawnedNpcs[job] = ped
end

RegisterNetEvent('departmentitems:client:openMenu', function(data)
    if not data then return end

    local options = {}

    -- Chọn outfit (chỉ hiện khi không đang giữ đồ)
    if data.canReceive and data.outfits and #data.outfits > 0 then
        options[#options + 1] = { title = '── Chọn đồng phục ──', disabled = true }

        for _, outfit in ipairs(data.outfits) do
            local capturedIndex = outfit.index
            options[#options + 1] = {
                title    = outfit.label,
                icon     = 'fa-solid fa-shirt',
                onSelect = function()
                    TriggerServerEvent('departmentitems:server:receiveOutfit', capturedIndex)
                end,
            }
        end
    elseif not data.canReceive then
        options[#options + 1] = {
            title       = 'Đang giữ đồ ban ngành',
            description = 'Trả hết đồ để có thể chọn đồng phục mới',
            disabled    = true,
            icon        = 'fa-solid fa-circle-info',
            iconColor   = '#f39c12',
        }
    end

    -- Đồ đang giữ + nút trả
    if data.activeRecords and #data.activeRecords > 0 then
        options[#options + 1] = { title = '── Đồ đang giữ ──', disabled = true }

        for _, rec in ipairs(data.activeRecords) do
            options[#options + 1] = {
                title     = rec.label,
                disabled  = true,
                icon      = 'fa-solid fa-circle-check',
                iconColor = '#2ecc71',
            }
        end

        options[#options + 1] = {
            title       = ('Trả tất cả (%d món)'):format(#data.activeRecords),
            description = 'Trả lại toàn bộ đồ ban ngành đang giữ',
            icon        = 'fa-solid fa-rotate-left',
            iconColor   = '#e74c3c',
            onSelect    = function()
                TriggerServerEvent('departmentitems:server:returnAll')
            end,
        }
    end

    -- Boss: quản lý
    if data.isboss then
        options[#options + 1] = { title = '── Quản lý ──', disabled = true }
        options[#options + 1] = {
            title = ('Danh sách nhân viên đang giữ đồ (%d)'):format(
                data.bossData and #data.bossData or 0
            ),
            icon  = 'fa-solid fa-users',
            menu  = 'departmentitems_boss_list',
        }

        if data.bossData then
            for i, person in ipairs(data.bossData) do
                local personCtxId  = 'departmentitems_person_' .. i
                local capturedCid  = person.citizenid
                local capturedName = person.charname
                local personOpts   = {
                    {
                        title    = 'CitizenID: ' .. capturedCid,
                        disabled = true,
                        icon     = 'fa-solid fa-id-card',
                    },
                }

                for _, item in ipairs(person.items) do
                    personOpts[#personOpts + 1] = {
                        title       = item.label,
                        description = ('Grade: %d | Nhận: %s'):format(item.grade, item.received_at),
                        disabled    = true,
                        icon        = 'fa-solid fa-shirt',
                    }
                end

                personOpts[#personOpts + 1] = {
                    title       = 'Phát đồ mới',
                    description = ('Xóa bản ghi cũ, %s có thể tự nhận đồ mới tại NPC'):format(capturedName),
                    icon        = 'fa-solid fa-arrow-rotate-right',
                    iconColor   = '#f39c12',
                    onSelect    = function()
                        TriggerServerEvent('departmentitems:server:bossResetItems', capturedCid)
                    end,
                }

                lib.registerContext({
                    id      = personCtxId,
                    title   = capturedName,
                    menu    = 'departmentitems_boss_list',
                    options = personOpts,
                })
            end
        end

        local bossListOpts = {}
        if data.bossData and #data.bossData > 0 then
            for i, person in ipairs(data.bossData) do
                bossListOpts[#bossListOpts + 1] = {
                    title       = person.charname,
                    description = ('%d món đang giữ'):format(#person.items),
                    icon        = 'fa-solid fa-user',
                    menu        = 'departmentitems_person_' .. i,
                }
            end
        else
            bossListOpts[#bossListOpts + 1] = {
                title    = 'Chưa có nhân viên nào đang giữ đồ',
                disabled = true,
            }
        end

        lib.registerContext({
            id      = 'departmentitems_boss_list',
            title   = data.jobLabel .. ' - Quản lý đồ ban ngành',
            menu    = 'departmentitems_menu',
            options = bossListOpts,
        })
    end

    lib.registerContext({
        id      = 'departmentitems_menu',
        title   = data.jobLabel .. ' - Trang phục ban ngành',
        options = options,
    })

    lib.showContext('departmentitems_menu')
end)

CreateThread(function()
    for job, cfg in pairs(Config.Jobs) do
        SpawnNPC(job, cfg)
    end
end)