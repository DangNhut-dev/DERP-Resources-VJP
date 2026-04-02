RegisterCommand('clear', function(source)
    TriggerClientEvent('chat:client:ClearChat', source)
end, false)

RegisterCommand('clearall', function(source)
    local permission = exports.qbx_core:GetPermission(source)
    if permission and permission ~= 'user' then
        TriggerClientEvent('chat:client:ClearChat', -1)
    else
        TriggerClientEvent('chat:addMessage', source, {
            template = '<div class="chat-message" style="background-color: rgba(190, 97, 18, 0.85); color: white;"><b>SYSTEM:</b> Access Denied</div>',
            args = {}
        })
    end
end, false)

local function parseEmojis(text)
    return text
        :gsub("%:heart:", "❤️")
        :gsub("%:smile:", "🙂")
        :gsub("%:thinking:", "🤔")
        :gsub("%:check:", "✅")
        :gsub("%:hot:", "🥵")
        :gsub("%:sad:", "😦")
end

local function hasJob(source, jobName, minGrade)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return false end
    local job = player.PlayerData.job
    return job and job.name == jobName and job.grade.level >= minGrade
end

local announcements = {
    {
        command = 'police',
        job = 'police',
        minGrade = 1,
        template = '<div class="chat-message" style="background-color: rgba(15, 55, 255, 0.85);"><b>Police Announcement:</b> {0}</div>'
    },
    {
        command = 'sheriff',
        job = 'police',
        minGrade = 1,
        template = '<div class="chat-message" style="background-color: rgba(184, 118, 53, 0.85);"><b>SDSO Announcement:</b> {0}</div>'
    },
    {
        command = 'cityhall',
        job = 'casino',
        minGrade = 2,
        template = '<div class="chat-message" style="background-color: rgba(58, 151, 113, 0.65);"><b>🏚️ CityHall Announcement:</b> {0}</div>'
    },
    {
        command = 'iec',
        job = 'casino',
        minGrade = 2,
        template = '<div class="chat-message" style="background-color: rgba(205, 133, 0, 0.65);"><b>⚡ Electricity Authority Announcement:</b> {0}</div>'
    },
    {
        command = 'judge',
        job = 'judge',
        minGrade = 2,
        template = '<div class="chat-message" style="background-color: rgba(205, 133, 0, 0.65);"><b>⚖️ Court House Announcement:</b> {0}</div>'
    }
}

for _, cfg in pairs(announcements) do
    RegisterCommand(cfg.command, function(source, args)
        if source == 0 then
            TriggerClientEvent('chat:addMessage', -1, {
                template = cfg.template,
                args = { table.concat(args, ' ') }
            })
            return
        end

        local msg = parseEmojis(table.concat(args, ' '))

        if hasJob(source, cfg.job, cfg.minGrade) then
            TriggerClientEvent('chat:addMessage', -1, {
                template = cfg.template,
                args = { msg }
            })
        else
            TriggerClientEvent('chat:addMessage', source, {
                template = '<div class="chat-message" style="background-color: rgba(190, 97, 18, 0.85); color: white;"><b>SYSTEM:</b> Access Denied</div>',
                args = {}
            })
        end
    end, false)
end

RegisterCommand('group', function(source)
    if source == 0 then return end
    local permission = exports.qbx_core:GetPermission(source)
    TriggerClientEvent('chat:addMessage', source, {
        template = '<div class="chat-message" style="background-color: rgba(190, 97, 18, 0.85); color: white;"><b>SYSTEM:</b> Group User: {0}</div>',
        args = { permission }
    })
end, false)

local function sendToStaff(name, msg)
    local players = exports.qbx_core:GetPlayers()
    for i = 1, #players do
        local permission = exports.qbx_core:GetPermission(players[i])
        if permission and permission ~= 'user' then
            TriggerClientEvent('chat:addMessage', players[i], {
                template = '<div class="chat-message" style="background-color: rgba(37, 103, 113, 0.85);"><b>Staff Chat: [{0}]</b> {1}</div>',
                args = { name, msg }
            })
        end
    end
end

RegisterNetEvent('chatt:adminchatpermmision', function(name, msg)
    local src = source
    local permission = exports.qbx_core:GetPermission(src)
    if permission and permission ~= 'user' then
        sendToStaff(name, msg)
    else
        TriggerClientEvent('chat:addMessage', src, {
            template = '<div class="chat-message" style="background-color: rgba(190, 97, 18, 0.85); color: white;"><b>SYSTEM:</b> You are not a staff member</div>',
            args = {}
        })
    end
end)

RegisterNetEvent('chatt:adminchatsystem', function(name, msg)
    sendToStaff(name, GetPlayerName(source) .. msg)
end)

RegisterCommand('staff', function(source, args)
    if source == 0 then
        TriggerClientEvent('chat:addMessage', -1, {
            template = '<div class="chat-message" style="background-color: rgba(58, 151, 113, 0.85);"><b>🔑 Staff Announcement:</b> {0}</div>',
            args = { table.concat(args, ' ') }
        })
        return
    end

    local msg = parseEmojis(table.concat(args, ' '))
    local permission = exports.qbx_core:GetPermission(source)

    if permission and permission ~= 'user' then
        TriggerClientEvent('chat:addMessage', -1, {
            template = '<div class="chat-message" style="background-color: rgba(58, 151, 113, 0.85);"><b>🔑 Staff Announcement:</b> {0}</div>',
            args = { msg }
        })
    else
        TriggerClientEvent('chat:addMessage', source, {
            template = '<div class="chat-message" style="background-color: rgba(190, 97, 18, 0.85); color: white;"><b>SYSTEM:</b> Access Denied</div>',
            args = {}
        })
    end
end, false)