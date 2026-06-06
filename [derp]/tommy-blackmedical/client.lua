local npcHandle = nil
local npcCoords = vector4(2453.55, 4981.19, 51.56, 226.55)
local NPC_MODEL = 'a_f_m_ktown_02'
local isBusy = false

local function spawnNPC()
    local hash = joaat(NPC_MODEL)
    lib.requestModel(hash)

    npcHandle = CreatePed(4, hash, npcCoords.x, npcCoords.y, npcCoords.z - 1.0, npcCoords.w, false, true)
    SetEntityInvincible(npcHandle, true)
    SetBlockingOfNonTemporaryEvents(npcHandle, true)
    FreezeEntityPosition(npcHandle, true)
    SetModelAsNoLongerNeeded(hash)

    exports.ox_target:addLocalEntity(npcHandle, {
        {
            name = 'blackmedical:revive',
            label = 'Chữa trị ($5,000)',
            icon = 'fa-solid fa-kit-medical',
            distance = 2.5,
            canInteract = function()
                return (LocalPlayer.state.isDead or LocalPlayer.state.isDown) and not isBusy
            end,
            onSelect = function()
                if isBusy then return end

                local canPay = lib.callback.await('tommy-blackmedical:server:checkMoney', false)
                if not canPay then return end

                isBusy = true

                local animDict = 'mini@cpr@char_a@cpr_str'
                lib.requestAnimDict(animDict)

                TaskPlayAnim(npcHandle, animDict, 'cpr_pumpchest', 8.0, -8.0, 10000, 1, 0, false, false, false)

                local success = lib.progressBar({
                    duration = 10000,
                    label = 'Đang chữa trị...',
                    useWhileDead = true,
                    canCancel = false,
                    disable = {
                        move = true,
                        car = true,
                        combat = true
                    }
                })

                ClearPedTasks(npcHandle)
                isBusy = false

                if not success then return end

                lib.callback('tommy-blackmedical:server:doRevive', false, function(result, reason)
                    if not result then
                        lib.notify({ title = 'Chữa Trị', description = reason, type = 'error', position = 'top' })
                    end
                end)
            end
        }
    })
end

CreateThread(function()
    Wait(500)
    spawnNPC()
end)