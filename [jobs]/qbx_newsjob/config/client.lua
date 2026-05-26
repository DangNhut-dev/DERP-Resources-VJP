return {
    useTarget = GetConvar('UseTarget', 'false') == 'true',
    debugPoly = false,
    useBlips = true,
    locations = {
        mainEntrance = {coords = vec4(-1070.78, -246.36, 0.01, 27.74)},
        inside = {coords = vec4(0,0,0,0)},
        outside = {coords = vec4(0,0,0,0)},
        vehicleStorage = {coords = vec4(-1098.14, -256.46, 37.68, 121.369)},
        roofEntrance = {coords = vec4(-1075.28, -253.34, 44.02, 208.71)},
        roofExit = {coords = vec4(-1072.81, -246.74, 54.01, 114.87)},
        helicopterStorage = {coords = vec4(-1065.89, -243.82, 53.73, 99.46)}
    },
    authorizedVehicles = {
        [0] = {newsvan = 'Xe Nhà Báo'},
        [1] = {newsvan = 'Xe Nhà Báo'},
        [2] = {newsvan = 'Xe Nhà Báo'},
        [3] = {newsvan = 'Xe Nhà Báo'},
        [4] = {newsvan = 'Xe Nhà Báo'}
    },
    authorizedhelicopters = {
        [0] = {newsmav = 'Trực Thăng'},
        [1] = {newsmav = 'Trực Thăng'},
        [2] = {newsmav = 'Trực Thăng'},
        [3] = {newsmav = 'Trực Thăng'},
        [4] = {newsmav = 'Trực Thăng'}
    },
    vehicleStickers = {
        -- Sticker cho xe mat dat (newsvan, v.v)
        vehicle = {
            enabled = true,
            mods = {
                { modType = 48, modIndex = 3 },
            }
        },
        -- Sticker cho truc thang
        helicopter = {
            enabled = false,
            mods = {}
        }
    },
}