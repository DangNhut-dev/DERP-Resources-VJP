-- Music app server-side functionality
-- Handles music playlists, songs, and playlist management

-- Callback to create a new playlist
BaseCallback("music:createPlaylist", function(source, phoneNumber, playlistName)
    -- Insert new playlist into database
    local playlistId = MySQL.insert.await("INSERT INTO phone_music_playlists (`name`, phone_number) VALUES (?, ?)", {
        playlistName,
        phoneNumber
    })
    
    if not playlistId then
        return false
    end
    
    -- Automatically save the playlist for the creator
    MySQL.update.await("INSERT INTO phone_music_saved_playlists (playlist_id, phone_number) VALUES (?, ?)", {
        playlistId,
        phoneNumber
    })
    
    return playlistId
end)

-- Callback to edit playlist details
BaseCallback("music:editPlaylist", function(source, phoneNumber, playlistId, newName, newCover)
    local updated = MySQL.update.await("UPDATE phone_music_playlists SET `name` = ?, cover = ? WHERE id = ? AND phone_number = ?", {
        newName,
        newCover,
        playlistId,
        phoneNumber
    })
    
    return updated > 0
end)

-- Callback to get all playlists for a user
BaseCallback("music:getPlaylists", function(source, phoneNumber)
    return MySQL.query.await([[
        SELECT s.song_id, p.id, p.`name`, p.cover, p.phone_number
        FROM phone_music_playlists p
        LEFT JOIN phone_music_saved_playlists p2 ON p2.playlist_id = p.id
        LEFT JOIN phone_music_songs s ON s.playlist_id = p.id

        WHERE p2.phone_number = ?

        ORDER BY p.`name` ASC
    ]], {
        phoneNumber
    })
end)

-- Callback to delete a playlist (only owner can delete)
BaseCallback("music:deletePlaylist", function(source, phoneNumber, playlistId)
    local deleted = MySQL.update.await("DELETE FROM phone_music_playlists WHERE id = ? AND phone_number = ?", {
        playlistId,
        phoneNumber
    })
    
    return deleted > 0
end)

-- Callback to save/follow a playlist
BaseCallback("music:savePlaylist", function(source, phoneNumber, playlistId)
    local saved = MySQL.update.await("INSERT INTO phone_music_saved_playlists (playlist_id, phone_number) VALUES (?, ?) ON DUPLICATE KEY UPDATE phone_number = phone_number", {
        playlistId,
        phoneNumber
    })
    
    return saved > 0
end)

-- Callback to add a song to a playlist
BaseCallback("music:addSong", function(source, phoneNumber, playlistId, songId)
    -- Verify user owns the playlist
    local ownsPlaylist = MySQL.scalar.await("SELECT 1 FROM phone_music_playlists WHERE id = ? AND phone_number = ?", {
        playlistId,
        phoneNumber
    })
    
    if not ownsPlaylist then
        return false
    end
    
    -- Add song to playlist (ignore duplicates)
    local added = MySQL.update.await("INSERT INTO phone_music_songs (playlist_id, song_id) VALUES (?, ?) ON DUPLICATE KEY UPDATE song_id = song_id", {
        playlistId,
        songId
    })
    
    return added > 0
end)

-- Callback to remove a song from a playlist
BaseCallback("music:removeSong", function(source, phoneNumber, playlistId, songId)
    -- Verify user owns the playlist
    local ownsPlaylist = MySQL.scalar.await("SELECT 1 FROM phone_music_playlists WHERE id = ? AND phone_number = ?", {
        playlistId,
        phoneNumber
    })
    
    if not ownsPlaylist then
        return false
    end
    
    -- Remove song from playlist
    local removed = MySQL.update.await("DELETE FROM phone_music_songs WHERE playlist_id = ? AND song_id = ?", {
        playlistId,
        songId
    })
    
    return removed > 0
end)
