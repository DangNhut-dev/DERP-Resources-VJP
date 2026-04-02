-- Notes App Server-side Logic
-- Handles note creation, editing, deletion, and retrieval

-- Create a new note
BaseCallback("notes:createNote", function(source, phoneNumber, title, content)
    return MySQL.insert.await("INSERT INTO phone_notes (phone_number, title, content) VALUES (?, ?, ?)", {
        phoneNumber,
        title,
        content
    })
end)

-- Save/update an existing note
BaseCallback("notes:saveNote", function(source, phoneNumber, noteId, title, content)
    local result = MySQL.update.await("UPDATE phone_notes SET title = ?, content = ? WHERE id = ? AND phone_number = ?", {
        title,
        content,
        noteId,
        phoneNumber
    })
    return result > 0
end)

-- Delete a note
BaseCallback("notes:removeNote", function(source, phoneNumber, noteId)
    local result = MySQL.update.await("DELETE FROM phone_notes WHERE id = ? AND phone_number = ?", {
        noteId,
        phoneNumber
    })
    return result > 0
end)

-- Get all notes for a phone number
BaseCallback("notes:getNotes", function(source, phoneNumber)
    return MySQL.query.await("SELECT id, title, content, `timestamp` FROM phone_notes WHERE phone_number = ?", {phoneNumber})
end)
