-- Voice Memo App Server-side Logic
-- Handles voice recording save, retrieval, deletion, and renaming

-- Save a voice recording
BaseCallback("voiceMemo:saveRecording", function(source, phoneNumber, recordingData)
    -- Validate required data
    if not recordingData.src or not recordingData.duration then
        debugprint("VoiceMemo: no src/duration, not saving")
        return
    end
    
    return MySQL.insert.await("INSERT INTO phone_voice_memos_recordings (phone_number, file_name, file_url, file_length) VALUES (?, ?, ?, ?)", {
        phoneNumber,
        recordingData.title or "Unknown",
        recordingData.src,
        recordingData.duration
    })
end)

-- Get all voice memos for a phone number
BaseCallback("voiceMemo:getMemos", function(source, phoneNumber)
    return MySQL.query.await("SELECT id, file_name AS `title`, file_url AS `src`, file_length AS `duration`, created_at AS `timestamp` FROM phone_voice_memos_recordings WHERE phone_number = ? ORDER BY created_at DESC", {phoneNumber})
end, {})

-- Delete a voice memo
BaseCallback("voiceMemo:deleteMemo", function(source, phoneNumber, memoId)
    local result = MySQL.update.await("DELETE FROM phone_voice_memos_recordings WHERE id = ? AND phone_number = ?", {
        memoId,
        phoneNumber
    })
    return result > 0
end)

-- Rename a voice memo
BaseCallback("renameMemo", function(source, phoneNumber, memoId, newName)
    local result = MySQL.update.await("UPDATE phone_voice_memos_recordings SET file_name = ? WHERE id = ? AND phone_number = ?", {
        newName,
        memoId,
        phoneNumber
    })
    return result > 0
end)
