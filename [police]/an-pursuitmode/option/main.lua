Option.DefaultKey = 'N'
Option.Notification = "Đã chuyển sang chế độ %s"
Option.AuthorizedJobs = {
    'police',
}

Option.AuthorizedGradeMin = 5

Option.VehicleTiers = {
    S = {
        'npolchar',
        'npolvette',
        'npolstang',
        'npolchal',
    }
}

Option.VehicleModes = { 
    "D",
    "C",
    "A",
    "S"
}

Option.VehicleModifications = {
    ["D"] = {
        Turbo = false,
        Engine = -1,
        Brakes = 0,
        Transmission = -1,
    },
    ["C"] = {
        Turbo = false,
        Engine = 1,
        Brakes = 1,
        Transmission = 1,
    },
    ["A"] = {
        Turbo = true,
        Engine = 2,
        Brakes = 2,
        Transmission = 2,
    },
    ["S"] = {
        Turbo = true,
        Engine = 4,
        Brakes = 3,
        Transmission = 3,
    }
}

Option.TierConfig = {
    ["C"] = {
        ["D"] = {
            ["fDriveInertia"] = 1.000000,
            ["fBrakeForce"] = 0.750,
            ["fInitialDriveMaxFlatVel"] = 135.000000,
            ["fSteeringLock"] = 42.00,
            ["fInitialDriveForce"] = 0.260
        },
        ["C"] = {
            ["fDriveInertia"] = 1.050000,
            ["fBrakeForce"] = 0.800,
            ["fInitialDriveMaxFlatVel"] = 145.000000,
            ["fSteeringLock"] = 40.00,
            ["fInitialDriveForce"] = 0.280
        },
        ["A"] = {
            ["fDriveInertia"] = 1.100000,
            ["fBrakeForce"] = 0.850,
            ["fInitialDriveMaxFlatVel"] = 155.000000,
            ["fSteeringLock"] = 38.00,
            ["fInitialDriveForce"] = 0.300
        },
        ["S"] = {
            ["fDriveInertia"] = 1.150000,
            ["fBrakeForce"] = 0.900,
            ["fInitialDriveMaxFlatVel"] = 165.000000,
            ["fSteeringLock"] = 36.00,
            ["fInitialDriveForce"] = 0.350
        }
    },
    ["B"] = {
        ["D"] = {
            ["fDriveInertia"] = 1.000000,
            ["fBrakeForce"] = 0.800,
            ["fInitialDriveMaxFlatVel"] = 145.000000,
            ["fSteeringLock"] = 40.00,
            ["fInitialDriveForce"] = 0.280
        },
        ["C"] = {
            ["fDriveInertia"] = 1.080000,
            ["fBrakeForce"] = 0.850,
            ["fInitialDriveMaxFlatVel"] = 155.000000,
            ["fSteeringLock"] = 38.00,
            ["fInitialDriveForce"] = 0.310
        },
        ["A"] = {
            ["fDriveInertia"] = 1.130000,
            ["fBrakeForce"] = 0.900,
            ["fInitialDriveMaxFlatVel"] = 165.000000,
            ["fSteeringLock"] = 36.00,
            ["fInitialDriveForce"] = 0.340
        },
        ["S"] = {
            ["fDriveInertia"] = 1.180000,
            ["fBrakeForce"] = 0.950,
            ["fInitialDriveMaxFlatVel"] = 175.000000,
            ["fSteeringLock"] = 34.00,
            ["fInitialDriveForce"] = 0.380
        }
    },
    ["A"] = {
        ["D"] = {
            ["fDriveInertia"] = 1.000000,
            ["fBrakeForce"] = 0.850,
            ["fInitialDriveMaxFlatVel"] = 155.000000,
            ["fSteeringLock"] = 38.00,
            ["fInitialDriveForce"] = 0.300
        },
        ["C"] = {
            ["fDriveInertia"] = 1.100000,
            ["fBrakeForce"] = 0.900,
            ["fInitialDriveMaxFlatVel"] = 165.000000,
            ["fSteeringLock"] = 36.00,
            ["fInitialDriveForce"] = 0.330
        },
        ["A"] = {
            ["fDriveInertia"] = 1.160000,
            ["fBrakeForce"] = 0.950,
            ["fInitialDriveMaxFlatVel"] = 175.000000,
            ["fSteeringLock"] = 34.00,
            ["fInitialDriveForce"] = 0.370
        },
        ["S"] = {
            ["fDriveInertia"] = 1.220000,
            ["fBrakeForce"] = 1.000,
            ["fInitialDriveMaxFlatVel"] = 185.000000,
            ["fSteeringLock"] = 32.00,
            ["fInitialDriveForce"] = 0.420
        }
    },
    ["S"] = {
        ["D"] = {
            ["fDriveInertia"] = 1.000000,
            ["fBrakeForce"] = 0.900,
            ["fInitialDriveMaxFlatVel"] = 165.000000,
            ["fSteeringLock"] = 36.00,
            ["fInitialDriveForce"] = 0.320
        },
        ["C"] = {
            ["fDriveInertia"] = 1.120000,
            ["fBrakeForce"] = 0.950,
            ["fInitialDriveMaxFlatVel"] = 175.000000,
            ["fSteeringLock"] = 34.00,
            ["fInitialDriveForce"] = 0.360
        },
        ["A"] = {
            ["fDriveInertia"] = 1.200000,
            ["fBrakeForce"] = 1.000,
            ["fInitialDriveMaxFlatVel"] = 185.000000,
            ["fSteeringLock"] = 32.00,
            ["fInitialDriveForce"] = 0.410
        },
        ["S"] = {
            ["fDriveInertia"] = 1.280000,
            ["fBrakeForce"] = 1.100,
            ["fInitialDriveMaxFlatVel"] = 195.000000,
            ["fSteeringLock"] = 30.00,
            ["fInitialDriveForce"] = 0.480
        }
    },
}