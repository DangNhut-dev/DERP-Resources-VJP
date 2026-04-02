CAS = {
    allowedJob = { 'police', 'sheriff' },
    webhook = "https://discord.com/api/webhooks/1470350503786578103/QLRjGFut_1SzOtwkwVDVF1LHiB4GQ4JM216un9sX_6nKoT6eBizGotehcAnXGBOKLltQ",
    Framework = "qbx",
    Footer = "You can see the records of bodycam in this page.",
    Header = "LOS SANTOS POLICE DEPARTMENT BODYCAM RECORDS",
    recordDesc = "Police Department Bodycam Record",
    recordName = "Police Bodycam Record",
    -- Event name for player loaded (framework-specific)
    playerLoaded = "qb-core:client:playerLoaded",

    Commands = {
        [1] = {
            command = "records",
            action = "recordmenu",
            desc = "Records Menu",
        },
        [2] = {
            command = "bodycam",
            action = "bodycam",
            desc = "Turn On/Off Bodycam"
        },
    }
}
