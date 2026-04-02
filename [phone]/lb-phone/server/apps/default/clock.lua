-- Clock App Server-side Logic
-- Handles alarm management for the phone clock app

-- Get all alarms for a phone number
BaseCallback("clock:getAlarms", function(source, phoneNumber)
    return MySQL.query.await("SELECT id, hours, minutes, label, enabled FROM phone_clock_alarms WHERE phone_number = ?", {phoneNumber})
end, {})

-- Create a new alarm
BaseCallback("clock:createAlarm", function(source, phoneNumber, label, hours, minutes)
    return MySQL.insert.await("INSERT INTO phone_clock_alarms (phone_number, hours, minutes, label) VALUES (@phoneNumber, @hours, @minutes, @label)", {
        ["@phoneNumber"] = phoneNumber,
        ["@hours"] = hours,
        ["@minutes"] = minutes,
        ["@label"] = label
    })
end)

-- Delete an alarm
BaseCallback("clock:deleteAlarm", function(source, phoneNumber, alarmId)
    local result = MySQL.update.await("DELETE FROM phone_clock_alarms WHERE id = ? AND phone_number = ?", {alarmId, phoneNumber})
    return result > 0
end)

-- Toggle alarm enabled/disabled
BaseCallback("clock:toggleAlarm", function(source, phoneNumber, alarmId, enabled)
    MySQL.update.await("UPDATE phone_clock_alarms SET enabled = ? WHERE id = ? AND phone_number = ?", {
        enabled == true,
        alarmId,
        phoneNumber
    })
    return enabled
end)

-- Update alarm details
BaseCallback("clock:updateAlarm", function(source, phoneNumber, alarmId, label, hours, minutes)
    local result = MySQL.update.await("UPDATE phone_clock_alarms SET label = ?, hours = ?, minutes = ? WHERE id = ? AND phone_number = ?", {
        label,
        hours,
        minutes,
        alarmId,
        phoneNumber
    })
    return result > 0
end)
