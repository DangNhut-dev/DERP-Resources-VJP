QBCore = exports['qb-core']:GetCoreObject()

for jobName, jobData in pairs(Config.DutyJobs) do
    for i, location in ipairs(jobData.locations) do
        exports.ox_target:addSphereZone({
            coords  = location.coords,
            radius  = 1.5,
            options = {
                {
                    name    = 'duty_' .. jobName .. '_' .. i,
                    label   = 'Vào/Ra Ca - ' .. jobData.label,
                    icon    = 'fa-solid fa-briefcase',
                    job     = jobName,  -- Chỉ hiện với đúng job
                    onSelect = function()
                        TriggerServerEvent('duty:toggle')
                    end
                }
            }
        })
    end
end