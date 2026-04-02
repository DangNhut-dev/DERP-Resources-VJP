-- modules/duty.lua
-- Client-side duty state feedback

RegisterNetEvent('DERP-business:dutyToggled', function(onduty, businessLabel)
    lib.notify({
        title       = businessLabel,
        description = onduty and 'Bạn đã bắt đầu ca làm việc' or 'Bạn đã kết thúc ca làm việc',
        type        = onduty and 'success' or 'inform'
    })
end)
