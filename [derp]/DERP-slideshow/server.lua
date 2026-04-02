local allowedJob = Config.Board.job
local resName = GetCurrentResourceName()

-- Scan assets/ folder cho .mp4
local function getVideoFiles()
    local files = {}
    local resPath = GetResourcePath(resName) .. '/assets'
    local handle, name = FindFirstFile(resPath .. '/*.mp4')
    if not handle then return files end

    repeat
        if name and name:match('%.mp4$') then
            local label = name:gsub('%.mp4$', '')
            files[#files + 1] = { value = 'assets/' .. name, label = label }
        end
        name = FindNextFile(handle)
    until not name
    FindClose(handle)

    return files
end

-- Validate URL
local function isValidUrl(url)
    if type(url) ~= 'string' then return false end
    if #url > 500 or #url < 5 then return false end
    if not url:match('^https?://') then return false end
    return true
end

-- Kiem tra job
local function hasAccess(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return false end
    return player.PlayerData.job.name == allowedJob
end

-- Client request danh sach video
lib.callback.register('DERP-slideshow:server:getVideos', function(source)
    if not hasAccess(source) then return {} end
    return getVideoFiles()
end)

RegisterNetEvent('DERP-slideshow:server:start', function(mediaType, value)
    local src = source
    if not hasAccess(src) then return end
    if type(mediaType) ~= 'string' or type(value) ~= 'string' then return end

    if mediaType == 'image' then
        if not isValidUrl(value) then
            return lib.notify(src, { title = 'Máy chiếu', description = 'Link không hợp lệ', type = 'error' })
        end
        TriggerClientEvent('DERP-slideshow:client:start', -1, value, 'image')

    elseif mediaType == 'video' then
        if not value:match('^assets/.*%.mp4$') then return end
        local content = LoadResourceFile(resName, value)
        if not content then return end
        TriggerClientEvent('DERP-slideshow:client:start', -1, value, 'video')
    end
end)

RegisterNetEvent('DERP-slideshow:server:stop', function()
    local src = source
    if not hasAccess(src) then return end
    TriggerClientEvent('DERP-slideshow:client:stop', -1)
end)