Webhook = Webhook or {}

Webhook.DefaultHook = 'https://discord.com/api/webhooks/1278909795465695242/LEbslhq02wqvlvoAfsBTlsEkKB6YrJk6wPphWQRqc4dTyN0pzdIbKTH6b3xeQ_ZtwBs_' -- Default hook for uploads

Webhook.Username = 'DERP BODYCAM'     -- Bot Username
Webhook.Title = 'Bodycam Records'            -- Message Title

Webhook.DefaultAuthor = {   -- Default author 
    name = "Bodycam",
    icon_url = "https://gunz.vn/img/logo_fiveM.png"
}

Webhook.JobUploads = {  -- Job Speific author
    ['police'] = {
        webhook = 'https://discordapp.com/api/webhooks/1489714061955436684/pnxN9qKEa43rn6zthvmIdmPxG6jNH5ZfjYG-SAG-LIHZ-8bx1kzSyotRtx3YdTOoH4b0',
        author = {
            name = "Police Department",
            icon_url = "https://r2.fivemanage.com/Fb3IsO8ywZvmlyomHJaYJ/AdobeExpress-file.png"
        }
    },
}
