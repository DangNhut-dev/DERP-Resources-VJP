Config = {}

-- Integrations (recommended to leave as "auto")
Config.Framework = "Qbox" -- or "QBCore", "Qbox", "ESX"
Config.Inventory = "ox_inventory" -- or "ox_inventory", "qb-inventory", "esx_inventory", "codem-inventory", "qs-inventory"
Config.Notifications = "default" -- or "default", "ox_lib", "lation_ui", "ps-ui", "okokNotify", "nox_notify"
Config.ProgressBar = "ox-bar" -- or "ox-circle", "ox-bar", "lation_ui", "qb"
Config.SkillCheck = "ox" -- or "ox", "qb", "lation_ui"
Config.DrawText = "ox_lib" -- or "jg-textui", "ox_lib", "okokTextUI", "ps-ui", "lation_ui", "qb"
Config.SocietyBanking = "Renewed-Banking" -- or "okokBanking", "fd_banking", "Renewed-Banking", "tgg-banking", "qb-banking", "qb-management", "esx_addonaccount"
Config.Menus = "ox" -- or "ox", "lation_ui"

-- Localisation
Config.Locale = "en"
Config.NumberAndDateFormat = "en-US"
Config.Currency = "USD"

-- Set to false to use built-in job system
Config.UseFrameworkJobs = true

-- Mechanic Tablet
Config.UseTabletCommand = "tablet" -- set to false to disable command
Config.TabletConnectionMaxDistance = 4.0

-- Shops
Config.Target = "ox_target" -- (shops/stashes only) "qb-target" or "ox_target"
Config.UseSocietyFund = false -- set to false to use player balance
Config.PlayerBalance = "bank" -- or "bank" or "cash"

-- Skill Bars
Config.UseSkillbars = true -- set to false to use progress bars instead of skill bars for installations
Config.ProgressBarDuration = 10000 -- if not using skill bars, this is the progress bar duration in ms (10000 = 10 seconds)
Config.MaximumSkillCheckAttempts = 3 -- How many times the player can attempt a skill check before the skill check fails
Config.SkillCheckDifficulty = { "easy", "easy", "easy", "easy", "easy" } -- for ox only
Config.SkillCheckInputs = { "e"} -- for ox only

-- Servicing
Config.EnableVehicleServicing = false
Config.ServiceRequiredThreshold = 20 -- [%] if any of the servicable parts hit this %, it will flag that the vehicle needs servicing 
Config.ServicingBlacklist = {
  "npolchar",
  "npolvic",
  "clrgtaurus",
  "npolmm",
  "npolchal",
  "npolstang",
  "npolexp",
  "npolvette",
}

-- Nitrous
Config.NitrousScreenEffects = false
Config.NitrousRearLightTrails = false -- Only really visible at night
Config.NitrousPowerIncreaseMult = 2.0
Config.NitrousDefaultKeyMapping = "RMENU"
Config.NitrousMaxBottlesPerVehicle = 3 -- The UI can't really handle more than 7, more than that would be unrealistic anyway
Config.NitrousBottleDuration = 10 -- [in seconds] How long a nitrous tank lasts
Config.NitrousBottleCooldown = 5 -- [in seconds] How long until player can start using the next bottle
Config.NitrousPurgeDrainRate = 0.1 -- purging drains bottle only 10% as fast as actually boosting - set to 1 to drain at the same rate 

-- Stancing
Config.StanceMinSuspensionHeight = -0.3
Config.StanceMaxSuspensionHeight = 0.3
Config.StanceMinCamber = 0.0
Config.StanceMaxCamber = 0.5
Config.StanceMinTrackWidth = 0.5
Config.StanceMaxTrackWidth = 1.25
Config.StanceNearbyVehiclesFreqMs = 500

-- Repairs
Config.AllowFixingAtOwnedMechanicsIfNoOneOnDuty = false
Config.DuctTapeMinimumEngineHealth = 100.0
Config.DuctTapeEngineHealthIncrease = 350.0

-- Tuning
Config.TuningGiveInstalledItemBackOnRemoval = false

-- Locations
Config.UseCarLiftPrompt = "[E] Use car lift"
Config.UseCarLiftKey = 38
Config.CustomiseVehiclePrompt = "[E] Đặt Hàng Độ Xe"
Config.CustomiseVehicleKey = 38

-- Update vehicle props whenever they are changed [probably should not touch]
-- You can set to false to leave saving any usual props vehicle changes such as
-- GTA performance, cosmetic, colours, wheels, etc to the garage or other scripts
-- that persist the props data to the database. Additional data from this script,
-- such as engine swaps, servicing etc is not affected as it's saved differently
Config.UpdatePropsOnChange = true

-- Stops vehicles from immediately going to redline, for a slightly more realistic feel and
-- reduced liklihood of wheelspin. Can make vehicle launch (slightly) slower.
-- No effect on electric vehicles!
-- May not work immediately for all vehicles; see: https://docs.jgscripts.com/mechanic/manual-transmissions-and-smooth-first-gear#smooth-first-gear
Config.SmoothFirstGear = false

-- If using a manual gearbox, show a notification with key binds when high RPMs 
-- have been detected for too long
Config.ManualHighRPMNotifications = true

-- Misc
Config.UniqueBlips = true
Config.ModsPricesAsPercentageOfVehicleValue = true -- Enable pricing tuning items as % of vehicle value - it tries jg-dealerships, then QBShared, then the vehicles meta file automagically for pricing data
Config.AdminsHaveEmployeePermissions = false -- admins can use tablet & interact with mechanics like an owner
Config.MechanicEmployeesCanSelfServiceMods = false -- set to true to allow mechanic employees to bypass the "place order" system at their own mechanic
Config.FullRepairAdminCommand = "vfix"
Config.MechanicAdminCommand = "mechanicadmin"
Config.ChangePlateDuringPreview = "PREVIEW"
Config.RequireManagementForOrderDeletion = true 
Config.UseCustomNamesInTuningMenu = false
Config.DisableNoPaymentOptionForEmployees = false

-- Mechanic Locations
Config.MechanicLocations = {
  -- bennys = {
  --   type = "self-service",
  --   logo = "bennys.png", -- logos go in /logos
  --   locations = {
  --     {
  --       coords = vector3(-211.6, -1324.73, 30.23),
  --       size = 8.0,
  --       showBlip = false,
  --     }
  --   },
  --   blip = {
  --     id = 446,
  --     color = 47,
  --     scale = 0.7
  --   },
  --   mods = {
  --     repair           = { enabled = true, price = 500, percentVehVal = 0.01 },
  --     performance      = { enabled = true, price = 500, percentVehVal = 0.01, priceMult = 0.1 },
  --     cosmetics        = { enabled = true, price = 500, percentVehVal = 0.01, priceMult = 0.1 },
  --     stance           = { enabled = true, price = 500, percentVehVal = 0.01 },
  --     respray          = { enabled = true, price = 500, percentVehVal = 0.01 },
  --     wheels           = { enabled = true, price = 500, percentVehVal = 0.01, priceMult = 0.1 },
  --     neonLights       = { enabled = true, price = 500, percentVehVal = 0.01 },
  --     headlights       = { enabled = true, price = 500, percentVehVal = 0.01 },
  --     tyreSmoke        = { enabled = true, price = 500, percentVehVal = 0.01 },
  --     bulletproofTyres = { enabled = true, price = 500, percentVehVal = 0.01 },
  --     extras           = { enabled = true, price = 500, percentVehVal = 0.01 }
  --   },
  -- },
  -- lscustoms = {
  --   type = "owned",
  --   job = "mechanic",
  --   jobManagementRanks = {4},
  --   logo = "ls_customs.png",
  --   commission = 0, -- %, 10 = 10%
  --   locations = {
  --     {
  --       coords = vector3(-337.25, -137.2, 38.35),
  --       size = 6.5,
  --       showBlip = false,
  --     },
  --     {
  --       coords = vector3(-324.2, -132.0, 38.54),
  --       size = 3.0,
  --       showBlip = false,
  --       employeeOnly = true,
  --     }
  --   },
  --   blip = {
  --     id = 446,
  --     color = 47,
  --     scale = 0.7
  --   },
  --   mods = {
  --     repair           = { enabled = true, price = 500, percentVehVal = 0.01 },
  --     performance      = { enabled = true, price = 500, percentVehVal = 0.01, priceMult = 0.1 },
  --     cosmetics        = { enabled = true, price = 500, percentVehVal = 0.01, priceMult = 0.1 },
  --     stance           = { enabled = true, price = 500, percentVehVal = 0.01 },
  --     respray          = { enabled = true, price = 500, percentVehVal = 0.01 },
  --     wheels           = { enabled = true, price = 500, percentVehVal = 0.01, priceMult = 0.1 },
  --     neonLights       = { enabled = true, price = 500, percentVehVal = 0.01 },
  --     headlights       = { enabled = true, price = 500, percentVehVal = 0.01 },
  --     tyreSmoke        = { enabled = true, price = 500, percentVehVal = 0.01 },
  --     bulletproofTyres = { enabled = true, price = 500, percentVehVal = 0.01 },
  --     extras           = { enabled = true, price = 500, percentVehVal = 0.01 }
  --   },
  --   tuning = {
  --     engineSwaps      = { enabled = true, requiresItem = true },
  --     drivetrains      = { enabled = true, requiresItem = true },
  --     turbocharging    = { enabled = true, requiresItem = true },
  --     tyres            = { enabled = true, requiresItem = true },
  --     brakes           = { enabled = true, requiresItem = true },
  --     driftTuning      = { enabled = true, requiresItem = true },
  --     gearboxes        = { enabled = true, requiresItem = true },
  --   },
  --   carLifts = { -- only usable by employees
  --     vector4(-357.45, -114.17, 38.7, 339.89)
  --   },
  --   shops = {
  --     {
  --       name = "Servicing Supplies",
  --       coords = vector3(-345.54, -131.32, 39.01),
  --       size = 2.0,
  --       usePed = false,
  --       pedModel = "s_m_m_lathandy_01",
  --       marker = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 255, b = 255, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
  --       items = {
  --         { name = "engine_oil", label = "Engine Oil", price = 50 },
  --         { name = "tyre_replacement", label = "Tyre Replacement", price = 2500 },
  --         { name = "clutch_replacement", label = "Clutch Replacement", price = 3000 },
  --         { name = "air_filter", label = "Air Filter", price = 300 },
  --         { name = "spark_plug", label = "Spark Plug", price = 100 },
  --         { name = "suspension_parts", label = "Suspension Parts", price = 2500 },
  --         { name = "brakepad_replacement", label = "Brakepad Replacement", price = 1500 },
  --       },
  --     },
  --     {
  --       name = "Advanced Upgrades",
  --       coords = vector3(-343.79, -139.92, 39.01),
  --       size = 2.0,
  --       usePed = false,
  --       pedModel = "s_m_m_lathandy_01",
  --       marker = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 255, b = 255, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
  --       items = {
  --         { name = "turbocharger", label = "Turbo Charger", price = 25000 },
  --         { name = "v8_engine", label = "V8 Engine Upgrade", price = 40000 },
  --         { name = "ceramic_brakes", label = "Ceramic Brakes", price = 15000 },
  --       },
  --     }
  --   },
  --   stashes = {
  --     {
  --       name = "Parts Bin",
  --       coords = vector3(-339.24, -132.2, 39.01),
  --       size = 2.0,
  --       usePed = false,
  --       pedModel = "s_m_m_lathandy_01",
  --       marker = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 255, b = 255, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
  --       slots = 10,
  --       weight = 50000,
  --     },
  --   }
  -- },
  -- redlinecustom = {
  --   type = "owned",
  --   job = "redlinecustom",
  --   jobManagementRanks = {4},
  --   logo = "ls_customs.png",
  --   commission = 0, -- %, 10 = 10%
  --   locations = {
  --     {
  --       coords = vector3(-578.43, -924.82, 23.28),
  --       size = 25.0,
  --       showBlip = true,
  --     },
  --   },
  --   blip = {
  --     id = 72,
  --     color = 47,
  --     scale = 0.7
  --   },
  --   mods = {
  --     repair           = { enabled = false, price = 2000, percentVehVal = 0.02 },
  --     performance      = { enabled = true, price = 0, percentVehVal = 0.01, priceMult = 0.1 },
  --     cosmetics        = { enabled = true, price = 0, percentVehVal = 0.01, priceMult = 0.1 },
  --     stance           = { enabled = true, price = 0, percentVehVal = 0.01 },
  --     respray          = { enabled = true, price = 0, percentVehVal = 0.01 },
  --     wheels           = { enabled = true, price = 0, percentVehVal = 0.01, priceMult = 0.1 },
  --     neonLights       = { enabled = true, price = 0, percentVehVal = 0.01 },
  --     headlights       = { enabled = true, price = 0, percentVehVal = 0.01 },
  --     tyreSmoke        = { enabled = true, price = 0, percentVehVal = 0.01 },
  --     bulletproofTyres = { enabled = true, price = 0, percentVehVal = 0.01 },
  --     extras           = { enabled = true, price = 0, percentVehVal = 0.01 }
  --   },
  --   tuning = {
  --     engineSwaps      = { enabled = true, requiresItem = true },
  --     drivetrains      = { enabled = true, requiresItem = true },
  --     turbocharging    = { enabled = true, requiresItem = true },
  --     tyres            = { enabled = true, requiresItem = true },
  --     brakes           = { enabled = true, requiresItem = true },
  --     driftTuning      = { enabled = true, requiresItem = true },
  --     gearboxes        = { enabled = true, requiresItem = true },
  --   },
  --   carLifts = {},
  --   shops = {},
  --   stashes = {}
  -- },
  LSMechanic = {
    type = "owned",
    job = "mechanic",
    jobManagementRanks = {3},
    logo = "ls_customs.png",
    commission = 0, 
    
    locations = {
      { 
        coords = vector3(-346.16, -135.92, -10.99),
        size = 8.0,
        showBlip = false,
      }
    },
    
    blip = {
      id = 446, -- Icon cờ lê
      color = 47, -- Màu vàng
      scale = 0.7
    },
    
    mods = {
      repair = { enabled = false, price = 2000, percentVehVal = 0.02 },
      performance      = { enabled = false },
      cosmetics        = { enabled = false },
      stance           = { enabled = false },
      respray          = { enabled = false },
      wheels           = { enabled = false },
      neonLights       = { enabled = false },
      headlights       = { enabled = false },
      tyreSmoke        = { enabled = false },
      bulletproofTyres = { enabled = false },
      extras           = { enabled = false }
    },
    
    tuning = {
      engineSwaps      = { enabled = false },
      drivetrains      = { enabled = false },
      turbocharging    = { enabled = false },
      tyres            = { enabled = false },
      brakes           = { enabled = false },
      driftTuning      = { enabled = false },
      gearboxes        = { enabled = false },
    },
    
    carLifts = {},
    
    shops = {},
    
    stashes = {}
  },
  -- cardealer = {
  --   type = "self-service",
  --   job = "cardealer",
  --   logo = "ls_customs.png",
  --   locations = {
  --     {
  --       coords = vector3(-2152.90, -400.31, 12.64),
  --       -- coords = vector3(-1599.97, -3054.03, 13.94),
  --       size = 8.0,
  --       showBlip = false,
  --       employeeOnly = true,
  --     }
  --   },
  --   blip = {
  --     id = 446,
  --     color = 47,
  --     scale = 0.7
  --   },
  --   mods = {
  --     repair           = { enabled = true, price = 1, percentVehVal = 0.01 },
  --     performance      = { enabled = true, price = 1, percentVehVal = 0.01, priceMult = 0.1 },
  --     cosmetics        = { enabled = true, price = 1, percentVehVal = 0.01, priceMult = 0.1 },
  --     stance           = { enabled = true, price = 1, percentVehVal = 0.01 },
  --     respray          = { enabled = true, price = 1, percentVehVal = 0.01 },
  --     wheels           = { enabled = true, price = 1, percentVehVal = 0.01, priceMult = 0.1 },
  --     neonLights       = { enabled = true, price = 1, percentVehVal = 0.01 },
  --     headlights       = { enabled = true, price = 1, percentVehVal = 0.01 },
  --     tyreSmoke        = { enabled = true, price = 1, percentVehVal = 0.01 },
  --     bulletproofTyres = { enabled = true, price = 1, percentVehVal = 0.01 },
  --     extras           = { enabled = true, price = 1, percentVehVal = 0.01 }
  --   },
  --   tuning = {
  --     engineSwaps      = { enabled = true, requiresItem = false },
  --     drivetrains      = { enabled = true, requiresItem = false },
  --     turbocharging    = { enabled = true, requiresItem = false },
  --     tyres            = { enabled = true, requiresItem = false },
  --     brakes           = { enabled = true, requiresItem = false },
  --     driftTuning      = { enabled = true, requiresItem = false },
  --     gearboxes        = { enabled = true, requiresItem = false },
  --   },
  -- },
  police = {
    type = "self-service",
    job = "police",
    grade = 4,
    logo = "ls_customs.png",
    locations = {
      {
        -- coords = vector3(-82.23, 87.88, 71.72),
        coords = vector3(480.13, -1022.89, 27.53),
        size = 15.0,
        showBlip = false,
        employeeOnly = true,
      }
    },
    blip = {
      id = 446,
      color = 47,
      scale = 0.7
    },
    mods = {
      repair           = { enabled = false, price = 0, percentVehVal = 0.0 },
      performance      = { enabled = false, price = 0, percentVehVal = 0.0},
      cosmetics        = { enabled = true, price = 0, percentVehVal = 0.0},
      stance           = { enabled = false, price = 0, percentVehVal = 0.0 },
      respray          = { enabled = true, price = 0, percentVehVal = 0.0 },
      wheels           = { enabled = false, price = 0, percentVehVal = 0.0},
      neonLights       = { enabled = false, price = 0, percentVehVal = 0.0 },
      headlights       = { enabled = false, price = 0, percentVehVal = 0.0 },
      tyreSmoke        = { enabled = false, price = 0, percentVehVal = 0.0 },
      bulletproofTyres = { enabled = false, price = 0, percentVehVal = 0.0 },
      extras           = { enabled = true, price = 0, percentVehVal = 0.0 }
    },
    tuning = {
      engineSwaps      = { enabled = false, requiresItem = false },
      drivetrains      = { enabled = false, requiresItem = false },
      turbocharging    = { enabled = false, requiresItem = false },
      tyres            = { enabled = false, requiresItem = false },
      brakes           = { enabled = false, requiresItem = false },
      driftTuning      = { enabled = false, requiresItem = false },
      gearboxes        = { enabled = false, requiresItem = false },
    },
  },
  BennyCustom = {
    type = "self-service",
    -- job = "none",
    -- grade = 4,
    logo = "ls_customs.png",
    locations = {
      {
        -- coords = vector3(-82.23, 87.88, 71.72),
        coords = vector3(-217.30, -1328.58, 30.43),
        size = 15.0,
        showBlip = true,
        employeeOnly = false,
      }
    },
    blip = {
      id = 72,
      color = 47,
      scale = 0.7
    },
    mods = {
      repair           = { enabled = false, price = 0, percentVehVal = 0.0 },
      performance      = { enabled = false, price = 0, percentVehVal = 0.0},
      cosmetics        = { enabled = false, price = 0, percentVehVal = 0.0},
      stance           = { enabled = false, price = 0, percentVehVal = 0.0 },
      respray          = { enabled = true, price = 5000, percentVehVal = 0.1 },
      wheels           = { enabled = false, price = 0, percentVehVal = 0.0},
      neonLights       = { enabled = false, price = 0, percentVehVal = 0.0 },
      headlights       = { enabled = false, price = 0, percentVehVal = 0.0 },
      tyreSmoke        = { enabled = false, price = 0, percentVehVal = 0.0 },
      bulletproofTyres = { enabled = false, price = 0, percentVehVal = 0.0 },
      extras           = { enabled = false, price = 0, percentVehVal = 0.0 }
    },
    tuning = {
      engineSwaps      = { enabled = false, requiresItem = false },
      drivetrains      = { enabled = false, requiresItem = false },
      turbocharging    = { enabled = false, requiresItem = false },
      tyres            = { enabled = false, requiresItem = false },
      brakes           = { enabled = false, requiresItem = false },
      driftTuning      = { enabled = false, requiresItem = false },
      gearboxes        = { enabled = false, requiresItem = false },
    },
  },
}

-- Add electric vehicles to disable combustion engine features
-----------------------------------------------------------------------
-- PLEASE NOTE: In b3258 (Bottom Dollar Bounties) and newer, electric
-- vehicles are detected automatically, so this list is not used! 
Config.ElectricVehicles = {
  "Airtug",     "buffalo5",   "caddy",
  "Caddy2",     "caddy3",     "coureur",
  "cyclone",    "cyclone2",   "imorgon",
  "inductor",   "iwagen",     "khamelion",
  "metrotrain", "minitank",   "neon",
  "omnisegt",   "powersurge", "raiden",
  "rcbandito",  "surge",      "tezeract",
  "virtue",     "vivanite",   "voltic",
  "voltic2",
}

-- Nerd options
Config.DisableSound = false
Config.AutoRunSQL = false
Config.Debug = false