Config = {
    Framework = "qb", -- qb, esx
    ProgressBarType = "ox_progressbar", -- qb_progressbar, ox_progressbar, custom_progressbar
    BorrowOfVehicle = true, -- Can a player take a ped's vehicle with player work ID Card
    Locale = "en",
    MySQL = "oxmysql", -- oxmysql, mysql-async, ghmattimysql

    IdCard = "id_card", -- Item name for ID Card
    JobCard = "job_card", -- Item name for Job Card
    FakeIdCard = "fake_id_card", -- Item name for Fake Id Card
    FakeJobCard = "fake_job_card", -- Item name for Fake Job Card
    DriverLicense = "driver_license", -- Item name for Driver License
    WeaponLicense = "weapon_license", -- Item name for Weapon License

    UseQbLicense = true,
    UseESXLicense = false,
    UseDatabaseForDriverLicense = false, -- If true, player will need to have driver license item to drive a vehicle
    UseDatabaseForWeaponLicense = false, -- If true, player will need to have weapon license item to use a weapon

    BoardHeader = "Dominion Entropy Roleplay", -- Header of the card
    TargetLoc = vector3(473.01, -1012.57, 26.27),
    MugShotCoords = vector3(402.84, -996.38, -100.0),
    MugShotHeading = 179.03,
    CameraPos = {
        pos = vector3(402.81, -999.87, -98.5),
        rotation = vector3(0.0,  0.0, 358.04),
    },

    FakeCardPrice = 1000,

    BadgeAnimation = {
        dict = "paper_1_rcm_alt1-9",
        anim = "player_one_dual-9",
        prop = "prop_fib_badge",
    },

    HeadshotPed = {
        model = "s_m_y_cop_01",
        coords = vector4(442.71, -981.94, 30.69, 94.21),
    },

    FakeCardPed = {
        model = "s_m_y_cop_01",
        coords = vector4(453.06, -984.75, -123.10, 265.74),
    },

    BorrowWhitelist = {
        ["police"] = true,
    },

    GiveVehicleKey = function(plate)
        if Config.Framework == "qb" then
            TriggerEvent("vehiclekeys:client:SetOwner", plate)
        elseif Config.Framework == "esx" then
            TriggerServerEvent("esx_vehicleshop:giveVehicleKeys", plate)
        end
    end,

    CoreExport = function()
        if Config.Framework == "qb" then
            return exports["qb-core"]:GetCoreObject()
        elseif Config.Framework == "esx" then
            return exports["es_extended"]:getSharedObject()
        end
    end,

    Notify = function(message, type)
        if Config.Framework == "qb" then
            TriggerEvent('QBCore:Notify', message, type, 5000)
        else
            Framework.ShowNotification(message)
        end
    end,
    
    -- These are the card types that will be shown depend on the grade.
    CardTypes = {
        ["citizen"] = { -- This will be selected if player has non of the jobs below.
            job = "citizen", -- dont change this
            grades = {
                [0] = {
                    cardType = "one",
                    textColor = "#555555",
                    text = "Citizen Card",
                },
            }
        },
        ["driver"] = {
            job = "driver", -- dont change this
            grades = {
                [0] = {
                    cardType = "one",
                    textColor = "#555555",
                    text = "Drivers License",
                },
            }
        },
        ["weapon"] = {
            job = "weapon", -- dont change this
            grades = {
                [0] = {
                    cardType = "one",
                    textColor = "#FFFFFF",
                    text = "Weapon License",
                },
            }
        },
        ["police"] = {
            job = "police",
            grades = {
                [0] = {
                    cardType = "one",
                    textColor = "#FFFFFF",
                    text = "Police Cadet Card",
                },
                [1] = {
                    cardType = "one",
                    textColor = "#FFFFFF",
                    text = "Police Solo Cadet Card",
                },
                [2] = {
                    cardType = "one",
                    textColor = "#FFFFFF",
                    text = "Police Officer Card",
                },
                [3] = {
                    cardType = "one",
                    textColor = "#FFFFFF",
                    text = "Police Senior Officer Card",
                },
                [4] = {
                    cardType = "two",
                    textColor = "#FFFFFF",
                    text = "Police Corporal Card",
                },
                [5] = {
                    cardType = "two",
                    textColor = "#FFFFFF",
                    text = "Police Sergeant Card",
                },
                [6] = {
                    cardType = "two",
                    textColor = "#FFFFFF",
                    text = "Police Lieutenant Card",
                },
                [7] = {
                    cardType = "three",
                    textColor = "#FFFFFF",
                    text = "Police Captain Card",
                },
                [8] = {
                    cardType = "three",
                    textColor = "#FFFFFF",
                    text = "Police Commander Card",
                },
                [9] = {
                    cardType = "three",
                    textColor = "#FFFFFF",
                    text = "Police Deputy Chief Card",
                },
                [10] = {
                    cardType = "three",
                    textColor = "#FFFFFF",
                    text = "Police Assistant Chief Card",
                },
                [11] = {
                    cardType = "three",
                    textColor = "#FFFFFF",
                    text = "Police Chief Card",
                },
            }
        },
        ["ambulance"] = {
            job = "ambulance",
            grades = {
                [0] = {
                    cardType = "one",
                    textColor = "#FFFFFF",
                    text = "Doctor Card",
                },
                [1] = {
                    cardType = "one",
                    textColor = "#FFFFFF",
                    text = "Doctor Card",
                },
                [2] = {
                    cardType = "two",
                    textColor = "#FFFFFF",
                    text = "Doctor Card",
                },
                [3] = {
                    cardType = "two",
                    textColor = "#FFFFFF",
                    text = "Doctor Card",
                },
                [4] = {
                    cardType = "three",
                    textColor = "#FFFFFF",
                    text = "Doctor Card",
                },
                [5] = {
                    cardType = "three",
                    textColor = "#FFFFFF",
                    text = "Doctor Card",
                },
                [6] = {
                    cardType = "four",
                    textColor = "#FFFFFF",
                    text = "Doctor Card",
                },
            }
        },
        ["sheriff"] = {
            job = "sheriff",
            grades = {
                [0] = {
                    cardType = "one",
                    textColor = "#FFFFFF",
                    text = "Sheriff Card",
                },
                [1] = {
                    cardType = "one",
                    textColor = "#FFFFFF",
                    text = "Sheriff Card",
                },
                [2] = {
                    cardType = "two",
                    textColor = "#FFFFFF",
                    text = "Sheriff Card",
                },
                [3] = {
                    cardType = "two",
                    textColor = "#FFFFFF",
                    text = "Sheriff Card",
                },
                [4] = {
                    cardType = "three",
                    textColor = "#FFFFFF",
                    text = "Sheriff Card",
                },
                [5] = {
                    cardType = "three",
                    textColor = "#FFFFFF",
                    text = "Sheriff Card",
                },
                [6] = {
                    cardType = "three",
                    textColor = "#FFFFFF",
                    text = "Sheriff Card",
                },
            }
        },
        ["lsnews"] = {
            job = "lsnews",
            grades = {
                [0] = {
                    cardType = "one",
                    textColor = "#FFFFFF",
                    text = "LS News Card",
                },
                [1] = {
                    cardType = "one",
                    textColor = "#FFFFFF",
                    text = "LS News Card",
                },
                [2] = {
                    cardType = "two",
                    textColor = "#FFFFFF",
                    text = "LS News Card",
                },
                [3] = {
                    cardType = "two",
                    textColor = "#FFFFFF",
                    text = "LS News Card",
                },
                [4] = {
                    cardType = "three",
                    textColor = "#FFFFFF",
                    text = "LS News Card",
                },
            }
        },
        ["justice"] = {
            job = "justice",
            grades = {
                [0] = {
                    cardType = "one",
                    textColor = "#FFFFFF",
                    text = "Justice Card",
                },
                [1] = {
                    cardType = "one",
                    textColor = "#FFFFFF",
                    text = "Justice Card",
                },
                [2] = {
                    cardType = "two",
                    textColor = "#FFFFFF",
                    text = "Justice Card",
                },
                [3] = {
                    cardType = "two",
                    textColor = "#FFFFFF",
                    text = "Justice Card",
                },
                [4] = {
                    cardType = "three",
                    textColor = "#FFFFFF",
                    text = "Justice Card",
                },
                [5] = {
                    cardType = "three",
                    textColor = "#FFFFFF",
                    text = "Justice Card",
                },
                [6] = {
                    cardType = "three",
                    textColor = "#FFFFFF",
                    text = "Justice Card",
                },
            }
        },
        ["fib"] = {
            job = "fib",
            grades = {
                [0] = {
                    cardType = "one",
                    textColor = "#FFFFFF",
                    text = "F.I.B Card",
                },
                [1] = {
                    cardType = "one",
                    textColor = "#FFFFFF",
                    text = "F.I.B Card",
                },
                [2] = {
                    cardType = "two",
                    textColor = "#FFFFFF",
                    text = "F.I.B Card",
                },
                [3] = {
                    cardType = "two",
                    textColor = "#FFFFFF",
                    text = "F.I.B Card",
                },
                [4] = {
                    cardType = "three",
                    textColor = "#FFFFFF",
                    text = "F.I.B Card",
                },
                [5] = {
                    cardType = "three",
                    textColor = "#FFFFFF",
                    text = "F.I.B Card",
                },
                [6] = {
                    cardType = "three",
                    textColor = "#FFFFFF",
                    text = "F.I.B Card",
                },
            }
        },
    }
}