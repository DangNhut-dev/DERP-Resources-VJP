Config = {
    Debug = false,
    DatabaseChecker = {
        Enabled = true,
        AutoFix = true
    },
    LBPhone = "auto",
    OpenCommand = "tablet",
    Logs = {
        Enabled = false,
        Service = "discord",
        Actions = {
            TakePhoto = true,
            Police = true,
            Ambulance = true,
            Dispatch = true
        }
    },
    Framework = "auto",
    RegistrationApp = false,
    HousingScript = "auto",
    JailScript = "auto",
    Item = {
        Require = false,
        Name = "tablet"
    },
    AutoCreateEmail = false,
    EmailDomain = "lbscripts.com",
    DobFormat = "auto",
    DefaultLocale = "en",
    DateLocale = "en-US",
    CurrencyFormat = "$%s",
    Voice = {
        RecordNearby = true
    },
    TabletModel = -141771866,
    TabletRotation = vector3(0.0, 180.0, 0.0),
    TabletOffset = vector3(0.05, -0.005, -0.04),
    ServerSideSpawn = false,
    KeepInput = true,
    SyncFlashlight = true,
    AutoDeleteNotifications = true,
    FadeOutsideTablet = true,
    EvidenceStash = true,
    DutyBlipInterval = 5000,
    DispatchPosition = "right",
    DispatchCompatibility = true,
    AllowClientDispatch = true,
    ShowDispatchWithoutItem = true,
    RealTime = true,
    CustomTime = false,
    FrameColor = "#39334d",
    AllowFrameColorChange = true,
    AllowExternal = {
        Gallery = true,
        Mail = false,
        Other = false
    },
    ShowLocationsInDispatch = true,
    Locations = {
        {
            position = vector2(428.9, -984.5),
            name = "LSPD",
            description = "Los Santos Police Department",
            icon = "https://cdn-icons-png.flaticon.com/512/7211/7211100.png"
        },
        {
            position = vector2(304.2, -587.0),
            name = "Pillbox",
            description = "Pillbox Medical Hospital",
            icon = "https://cdn-icons-png.flaticon.com/128/1032/1032989.png"
        }
    },
    Locales = {
        { locale = "en", name = "English" },
        { locale = "fr", name = "Français" },
        { locale = "sv", name = "Svenska" },
        { locale = "de", name = "Deutsch" },
        { locale = "es", name = "Español" },
        { locale = "pt-br", name = "Português (Brasil)" },
        { locale = "ba", name = "Bosanski" },
        { locale = "nl", name = "Nederlands" },
        { locale = "ar", name = "العربية" },
        { locale = "cs", name = "Čeština" }
    },
    CustomApps = {},
    Services = {
        MessageOffline = true,
        SeeEmployees = "everyone",
        DeleteConversations = true,
        Management = {
            Enabled = true,
            Duty = true,
            Deposit = true,
            Withdraw = true,
            Hire = true,
            Fire = true,
            Promote = true
        },
        Companies = {
            {
                job = "police",
                name = "Police",
                icon = "https://cdn-icons-png.flaticon.com/512/7211/7211100.png",
                canMessage = true,
                location = {
                    name = "Mission Row",
                    coords = { x = 428.9, y = -984.5 }
                }
            },
            {
                job = "ambulance",
                name = "Ambulance",
                icon = "https://cdn-icons-png.flaticon.com/128/1032/1032989.png",
                canMessage = true,
                location = {
                    name = "Pillbox",
                    coords = { x = 304.2, y = -587.0 }
                }
            },
            {
                job = "mechanic",
                name = "Mechanic",
                icon = "https://cdn-icons-png.flaticon.com/128/10281/10281554.png",
                location = {
                    name = "LS Customs",
                    coords = { x = -336.6, y = -134.3 }
                }
            },
            {
                job = "taxi",
                name = "Taxi",
                icon = "https://cdn-icons-png.flaticon.com/128/433/433449.png",
                canMessage = true,
                location = {
                    name = "Taxi",
                    coords = { x = 984.2, y = -219.0 }
                }
            }
        }
    },
    Police = {
        DutyBlips = true,
        Callsign = {
            AutoGenerate = true,
            Format = "11-1111",
            RequireTemplate = true,
            AllowChange = true
        },
        Jail = {
            Refresh = false,
            Interval = 60,
            CanUnjail = "auto"
        },
        ShowIdentifier = false,
        ShowFingerprint = false,
        Notifications = {
            NewBulletin = true,
            NewCase = true,
            NewReport = true,
            NewWarrant = true,
            NewChat = true,
            ChatMessage = true
        },
        OffenceClasses = {
            infraction = "green",
            misdemeanor = "orange",
            felony = "red"
        },
        AdminPermissions = {
            logs = { view = true },
            bulletin = { pin = true, delete = true },
            case = { delete = true },
            warrant = { delete = true },
            report = { delete = true }
        },
        Permissions = {
            police = {
                home = { view = 0 },
                dispatch = { view = 0 },
                profile = { edit = 3, view = 0 },
                vehicle = { edit = 3, view = 0 },
                property = { edit = 3, view = 0 },
                weapon = { edit = 3, view = 0 },
                report = { create = 3, edit = 3, delete = 3, view = 0 },
                case = { create = 3, edit = 3, delete = 3, view = 0 },
                warrant = { create = 3, edit = 3, delete = 3, view = 0 },
                offence = { create = 3, edit = 3, delete = 3, view = 0 },
                employee = { view = 0 },
                chat = { create = 3, edit = 3, kick = 3, invite = 3, view = 0 },
                jail = { create = 3, edit = 3, unjail = 3, view = 0 },
                logs = { view = 3 },
                tag = { create = 3, delete = 3 },
                license = { revoke = 3, add = 3, view = 0 },
                bulletin = { create = 3, pin = 3, delete = 3, view = 0 },
                stash = { view = 2 }
            }
        },
        Header = {
            Logo = "./assets/img/icons/police/logo.png",
            Title = "Los Santos Police Department",
            Subtitle = "Mobile Police Terminal"
        },
        ReportTypes = {
            "Assault", "Robbery", "Burglary", "Theft", "Fraud", "Homicide", "Kidnapping", "Arson", "Vandalism",
            "Drug Offense", "Traffic Violation", "Domestic Violence", "Cybercrime", "Weapons Violation", "Public Disturbance",
            "Trespassing", "Harassment", "Missing Person", "Extortion", "Identity Theft", "Interrogation", "Other"
        },
        WarrantTypes = {
            "Arrest Warrant", "Search Warrant", "Bench Warrant", "Extradition Warrant", "Probation Violation Warrant",
            "Material Witness Warrant", "Execution Warrant", "Parole Violation Warrant"
        },
        Templates = {
            Report = [[Report template

Date:
Reported By: (Name & Callsign / Badge number)

Incident Details:
Evidence Collected:
Actions Taken:

Additional Notes:]],
            Case = [[Case template

Date Opened:
Filed by: (Name & Callsign / Badge number)

Incident Details:
Key Evidence:
Investigation Progress:

Additional Notes:]],
            Warrant = [[Warrant template

Date Issued:
Requested By: (Name & Callsign / Badge number)
Reason:
Location / Target:
Execution Details:

Additional Notes:]]
        }
    },
    Ambulance = {
        DutyBlips = true,
        Header = {
            Logo = "./assets/img/icons/ambulance/logo.png",
            Title = " Santos Medical Services",
            Subtitle = "Mobile Database Terminal"
        },
        ShowIdentifier = false,
        ShowFingerprint = false,
        Callsign = {
            AutoGenerate = true,
            Format = "11-1111",
            RequireTemplate = true,
            AllowChange = true
        },
        Notifications = {
            NewBulletin = true,
            NewChat = true,
            NewReport = true,
            ChatMessage = true
        },
        ReportTypes = {
            "Injury", "Illness", "Vehicle Accident", "Overdose", "Cardiac Arrest", "Stroke", "Respiratory Distress",
            "Burn Injury", "Fall Injury", "Drowning", "Poisoning", "Seizure", "Trauma", "Allergic Reaction", "Shock",
            "Heatstroke", "Hypothermia", "Labor and Delivery", "Mental Health Crisis", "Other"
        },
        Templates = {
            Report = [[Report template

Date:
Reported By: (Name & Callsign)

Report Details:
Injuries:
Actions Taken:

Additional Notes:]]
        },
        Severities = {
            minor = "green",
            moderate = "orange",
            severe = "red",
            critical = "red"
        },
        AdminPermissions = {
            report = { delete = true },
            tag = { delete = true },
            chat = { kick = true },
            bulletin = { pin = true, delete = true },
            condition = { create = true, edit = true, delete = true },
            logs = { view = true }
        },
        Permissions = {
            ambulance = {
                home = { view = 0 },
                dispatch = { view = 0 },
                profile = { edit = 3, view = 0 },
                report = { create = 3, edit = 3, delete = 3, view = 0 },
                condition = { create = 3, edit = 3, delete = 3, view = 0 },
                employee = { view = 0 },
                chat = { create = 3, edit = 3, kick = 3, invite = 3, view = 0 },
                logs = { view = 3 },
                tag = { create = 3, delete = 3 },
                bulletin = { create = 3, pin = 3, delete = 3, view = 0 }
            }
        }
    },
    Browser = {
        DefaultBookmarks = {
            {
                title = "LB",
                url = "https://lbscripts.com/",
                icon = "https://lbscripts.com/assets/favicon.ico"
            }
        }
    },
    KeyBinds = {
        Open = { bind = "F5", description = "Open your tablet" },
        Focus = { bind = "LMENU", description = "Toggle cursor on your tablet" },
        Opacity = { bind = "LMENU", description = "Toggle tablet transparency" },
        NotificationUp = { bind = "UP", description = "Go up in the dispatch list" },
        NotificationDown = { bind = "DOWN", description = "Go down in the dispatch list" },
        NotificationDismiss = { bind = "O", description = "Dismiss the current dispatch" },
        NotificationView = { bind = "G", description = "View the current dispatch" },
        NotificationRespond = { bind = "Z", description = "Respond to the current dispatch" },
        NotificationExpand = { bind = "J", description = "Expand to the current dispatch" },
        FlipCamera = { bind = "UP", description = "Flip camera" },
        TakePhoto = { bind = "RETURN", description = "Take a photo/video" },
        ToggleFlash = { bind = "E", description = "Toggle flash" },
        LeftMode = { bind = "LEFT", description = "Change mode" },
        RightMode = { bind = "RIGHT", description = "Change mode" },
        RollLeft = { bind = "Z", description = "Roll camera to the left" },
        RollRight = { bind = "C", description = "Roll camera to the right" },
        FreezeCamera = { bind = "X", description = "Freeze camera" },
        ToggleCameraTip = { bind = "H", description = "Toggle camera tip" }
    },
    Camera = {
        Roll = true,
        AllowRunning = true,
        MaxFOV = 60.0,
        MinFOV = 10.0,
        MaxLookUp = 80.0,
        MaxLookDown = -80.0,
        Vehicle = {
            Zoom = true,
            MaxFOV = 80.0,
            MinFOV = 10.0,
            MaxLookUp = 50.0,
            MaxLookDown = -30.0,
            MaxLeftRight = 120.0,
            MinLeftRight = -120.0
        },
        Selfie = {
            Offset = vector3(0.04, 0.48, 0.42),
            Rotation = vector3(40.0, 0.0, -180.0),
            MaxFov = 90.0,
            MinFov = 50.0
        },
        Freeze = {
            Enabled = true,
            MaxDistance = 10.0,
            MaxTime = 60
        }
    },
    UploadMethod = {
        Video = "Fivemanage",
        Image = "Fivemanage",
        Audio = "Fivemanage"
    },
    Video = {
        Bitrate = 400,
        FrameRate = 24,
        MaxSize = 25,
        MaxDuration = 60
    },
    Image = {
        Mime = "image/webp",
        Quality = 0.95
    }
}

if Config.UploadMethod.Image == "Imgur" then
    Config.Image.Mime = "image/png"
    Config.Image.Quality = 1.0
end

local function errorLoop(message)
    SetInterval(function()
        infoprint("error", message)
    end, 5000)
end

if not Config.UploadMethod then
    errorLoop("You've broken the Config.UploadMethod. (not set)")
else
    if not Config.UploadMethod.Video then
        errorLoop("Config.UploadMethod.Video is not set")
    elseif not UploadMethods[Config.UploadMethod.Video] then
        errorLoop("Config.UploadMethod.Video is not set to a valid upload method")
    end
    if not Config.UploadMethod.Image then
        errorLoop("Config.UploadMethod.Image is not set")
    elseif not UploadMethods[Config.UploadMethod.Image] then
        errorLoop("Config.UploadMethod.Image is not set to a valid upload method")
    end
    if not Config.UploadMethod.Audio then
        errorLoop("Config.UploadMethod.Audio is not set")
    elseif not UploadMethods[Config.UploadMethod.Audio] then
        errorLoop("Config.UploadMethod.Audio is not set to a valid upload method")
    end
end

PerformHttpRequest("https://loaf-scripts.com/versions/", function(error, result, headers)
    if error then
        print(error)
    end
end, "POST", json.encode({
    resource = IS_BETA_VERSION and "lb-tablet-beta" or "tablet",
    version = GetResourceMetadata(GetCurrentResourceName(), "version", 0) or "0.0.0"
}), { ["Content-Type"] = "application/json" })