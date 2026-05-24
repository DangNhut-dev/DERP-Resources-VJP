return {
    useTarget = GetConvar('UseTarget', 'false') == 'true',
    debugPoly = false,
    useBlips = true,
    locations = {
        mainEntrance = {coords = vec4(0,0,0,0)},
        inside = {coords = vec4(0,0,0,0)},
        outside = {coords = vec4(0,0,0,0)},
        vehicleStorage = {coords = vec4(-1098.14, -256.46, 37.68, 121.369)},
        roofEntrance = {coords = vec4(-1075.28, -253.34, 44.02, 208.71)},
        roofExit = {coords = vec4(-1072.81, -246.74, 54.01, 114.87)},
        helicopterStorage = {coords = vec4(-1065.89, -243.82, 53.73, 99.46)}
    },
    authorizedVehicles = {
        [0] = {rumpo = 'newsvan'}, -- Grade 0
        [1] = {rumpo = 'newsvan'}, -- Grade 1
        [2] = {rumpo = 'newsvan'}, -- Grade 2
        [3] = {rumpo = 'newsvan'}, -- Grade 3
        [4] = {rumpo = 'newsvan'} -- Grade 4
    },
    authorizedhelicopters = {
        [0] = {frogger = 'newsmav'}, -- Grade 0
        [1] = {frogger = 'newsmav'}, -- Grade 1
        [2] = {frogger = 'newsmav'}, -- Grade 2
        [3] = {frogger = 'newsmav'}, -- Grade 3
        [4] = {frogger = 'newsmav'} -- Grade 4
    }
}