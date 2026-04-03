Upload = Upload or {}

Upload.ServiceUsed = 'fivemanage'   -- discord | fivemanage | fivemerr
Upload.Token = '46XxRkHypMabQlIon6mq3RNTc7any5fA'      --  fivemanage or fivemerr | [*note - for discord webhook is to be changed below not here]

-- FOR DISCORD LOGS
Upload.DiscordLogs = {
    Enabled = true,
    Username = 'Los Santos Police Department Bodycam',     -- Bot Username
    Title = 'Bodycam Records',            -- Message Title
}

-- Upload Hooks if Upload.ServiceUsed = discord
Upload.DefaultUploads = {   -- Default Upload of log if job not mentioned in Upload.JobUploads. 
    webhook = 'https://discord.com/api/webhooks/1278909795465695242/LEbslhq02wqvlvoAfsBTlsEkKB6YrJk6wPphWQRqc4dTyN0pzdIbKTH6b3xeQ_ZtwBs_',
    author = {
        name = "Los Santos Police Department Bodycam",
        icon_url = "https://i.imgur.com/tMyAdkz.png"
    }
}

Upload.JobUploads = {  -- Job Speific Uploads
    ['police'] = {
        webhook = 'https://discordapp.com/api/webhooks/1489714061955436684/pnxN9qKEa43rn6zthvmIdmPxG6jNH5ZfjYG-SAG-LIHZ-8bx1kzSyotRtx3YdTOoH4b0',
        author = {
            name = "Police Department",
            icon_url = "https://r2.fivemanage.com/Fb3IsO8ywZvmlyomHJaYJ/AdobeExpress-file.png"
        }
    }, -- Add more here
}
