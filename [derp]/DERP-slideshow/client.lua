local board = Config.Board
local tex = Config.Texture
local duiCfg = Config.DUI
local resName = GetCurrentResourceName()

local sfHandle = nil
local duiObj = nil
local currentUrl = nil
local currentType = nil
local boardEntity = nil
local renderActive = false
local urlVersion = 0

local PedId = PlayerPedId
local GetCoords = GetEntityCoords

-- Spawn prop
local function spawnBoard()
    if boardEntity and DoesEntityExist(boardEntity) then return end
    lib.requestModel(board.model)
    boardEntity = CreateObject(board.model, board.coords.x, board.coords.y, board.coords.z, false, false, false)
    SetEntityHeading(boardEntity, board.coords.w)
    FreezeEntityPosition(boardEntity, true)
    SetEntityInvincible(boardEntity, true)
    SetModelAsNoLongerNeeded(board.model)
end

local function deleteBoard()
    if boardEntity and DoesEntityExist(boardEntity) then
        DeleteEntity(boardEntity)
        boardEntity = nil
    end
end

local function loadScaleform()
    local sf = RequestScaleformMovie('generic_texture_renderer')
    while not HasScaleformMovieLoaded(sf) do Wait(0) end
    return sf
end

local function fullCleanup()
    if duiObj then
        DestroyDui(duiObj)
        duiObj = nil
    end
    if sfHandle then
        SetScaleformMovieAsNoLongerNeeded(sfHandle)
        sfHandle = nil
    end
end

-- Tao DUI moi
local function startDUI(url, mediaType)
    fullCleanup()

    sfHandle = loadScaleform()

    local duiUrl = url
    if mediaType == 'video' then
        duiUrl = ('nui://%s/html/player.html?url=nui://%s/%s'):format(resName, resName, url)
    end

    duiObj = CreateDui(duiUrl, duiCfg.width, duiCfg.height)
    Wait(500)

    local dui = GetDuiHandle(duiObj)
    local txdName = 'derp_slide_' .. urlVersion
    local txnName = 'derp_txn_' .. urlVersion
    local txd = CreateRuntimeTxd(txdName)
    CreateRuntimeTextureFromDuiHandle(txd, txnName, dui)
    Wait(0)

    PushScaleformMovieFunction(sfHandle, 'SET_TEXTURE')
    PushScaleformMovieMethodParameterString(txdName)
    PushScaleformMovieMethodParameterString(txnName)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(duiCfg.width)
    PushScaleformMovieFunctionParameterInt(duiCfg.height)
    PopScaleformMovieFunctionVoid()
end

-- Render thread
local function startRenderThread()
    if renderActive then return end
    renderActive = true

    CreateThread(function()
        local myVersion = urlVersion
        local pos = board.coords

        while currentUrl and myVersion == urlVersion do
            local pCoords = GetCoords(PedId())
            local dist = #(pCoords - vector3(pos.x, pos.y, pos.z))

            if dist <= board.renderDistance then
                if not duiObj and myVersion == urlVersion then
                    startDUI(currentUrl, currentType)
                end

                if sfHandle and HasScaleformMovieLoaded(sfHandle) then
                    DrawScaleformMovie_3dNonAdditive(
                        sfHandle,
                        pos.x + tex.offset.x,
                        pos.y + tex.offset.y,
                        pos.z + tex.offset.z,
                        tex.rot.x, tex.rot.y, tex.rot.z,
                        2.0, 2.0, 2.0,
                        tex.scale.x, tex.scale.y, tex.scale.z,
                        2
                    )
                end
                Wait(0)
            else
                fullCleanup()
                Wait(1000)
            end
        end

        fullCleanup()
        renderActive = false

        if currentUrl and myVersion ~= urlVersion then
            startRenderThread()
        end
    end)
end

RegisterNetEvent('DERP-slideshow:client:start', function(url, mediaType)
    fullCleanup()
    urlVersion = urlVersion + 1
    currentUrl = url
    currentType = mediaType
    renderActive = false
    startRenderThread()
end)

RegisterNetEvent('DERP-slideshow:client:stop', function()
    urlVersion = urlVersion + 1
    currentUrl = nil
    currentType = nil
    fullCleanup()
end)

-- Target
local function setupTarget()
    if not boardEntity or not DoesEntityExist(boardEntity) then return end

    exports.ox_target:addLocalEntity(boardEntity, {
        {
            name = 'derp_slideshow_image',
            icon = 'fas fa-image',
            label = 'Chiếu ảnh',
            groups = board.job,
            distance = board.targetDistance,
            onSelect = function()
                local input = lib.inputDialog('Chiếu ảnh', {
                    { type = 'input', label = 'Dán link ảnh', required = true, placeholder = 'https://i.imgur.com/...' },
                })
                if not input or not input[1] or input[1] == '' then return end
                TriggerServerEvent('DERP-slideshow:server:start', 'image', input[1])
            end,
        },
        {
            name = 'derp_slideshow_video',
            icon = 'fas fa-film',
            label = 'Chiếu video',
            groups = board.job,
            distance = board.targetDistance,
            onSelect = function()
                local videos = lib.callback.await('DERP-slideshow:server:getVideos', false)
                if not videos or #videos == 0 then
                    return lib.notify({ title = 'Máy chiếu', description = 'Không có video trong assets/', type = 'error' })
                end
                local input = lib.inputDialog('Chọn video', {
                    { type = 'select', label = 'Video', required = true, options = videos },
                })
                if not input or not input[1] then return end
                TriggerServerEvent('DERP-slideshow:server:start', 'video', input[1])
            end,
        },
        {
            name = 'derp_slideshow_off',
            icon = 'fas fa-power-off',
            label = 'Tắt máy chiếu',
            groups = board.job,
            distance = board.targetDistance,
            onSelect = function()
                TriggerServerEvent('DERP-slideshow:server:stop')
            end,
        },
    })
end

AddEventHandler('onResourceStart', function(res)
    if res ~= resName then return end
    spawnBoard()
    setupTarget()
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    spawnBoard()
    setupTarget()
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= resName then return end
    fullCleanup()
    deleteBoard()
end)