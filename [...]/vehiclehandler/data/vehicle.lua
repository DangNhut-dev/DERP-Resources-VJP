return {
    units = 'kmh',
    breaktire = false,
    threshold = {
        health = 70.0,          -- Body damage cần thiết để rụng bánh (cao hơn = khó rụng hơn)
        speed  = 60.0,          -- Giảm tốc đột ngột cần thiết để rụng bánh
        heavy  = 160.0,         -- Giảm tốc cần thiết để chết máy tức thì (cao = khó chết tức thì)
    },
    globalmultiplier = 1.5,     -- 1.0 = vanilla GTA, 2.5 = hư rõ ràng nhưng không quá nhanh
    classmultiplier = {
        [0] =   1.0,            -- 0: Compacts
                0.95,           -- 1: Sedans
                0.85,           -- 2: SUVs (khung gầm cao, chịu va tốt hơn)
                0.95,           -- 3: Coupes
                0.90,           -- 4: Muscle (xe nặng, chịu va khá)
                0.95,           -- 5: Sports Classics
                1.05,           -- 6: Sports (nhẹ, hư nhanh hơn chút)
                1.10,           -- 7: Super (siêu xe nhẹ, engine nhạy cảm)
                0.50,           -- 8: Motorcycles
                0.65,           -- 9: Off-road (thiết kế chịu va)
                0.25,           -- 10: Industrial
                0.35,           -- 11: Utility
                0.80,           -- 12: Vans
                1.0,            -- 13: Bicycles
                0.4,            -- 14: Boats
                0.7,            -- 15: Helicopters
                0.7,            -- 16: Planes
                0.70,           -- 17: Service
                0.45,           -- 18: Emergency (xe công vụ bền hơn)
                0.30,           -- 19: Military
                0.40,           -- 20: Commercial
                0.1,            -- 21: Trains
                1.10,           -- 22: Open Wheel (rất nhạy cảm)
    },
    regulated = {
        [0] =   true,           -- 0: Compacts
                true,           -- 1: Sedans
                true,           -- 2: SUVs
                true,           -- 3: Coupes
                true,           -- 4: Muscle
                true,           -- 5: Sports Classics
                true,           -- 6: Sports
                true,           -- 7: Super
                false,          -- 8: Motorcycles
                true,           -- 9: Off-road
                true,           -- 10: Industrial
                true,           -- 11: Utility
                true,           -- 12: Vans
                false,          -- 13: Bicycles
                false,          -- 14: Boats
                false,          -- 15: Helicopters
                false,          -- 16: Planes
                true,           -- 17: Service
                true,           -- 18: Emergency
                false,          -- 19: Military
                true,           -- 20: Commercial
                false,          -- 21: Trains
                true,           -- 22: Open Wheel
    },
    exclusions = {
        [`deluxo`] = true,
        [`scramjet`] = true,
        [`vigilante`] = true,
    },
    backengine = {
        [`ninef`] = true,
        [`adder`] = true,
        [`vagner`] = true,
        [`t20`] = true,
        [`infernus`] = true,
        [`zentorno`] = true,
        [`reaper`] = true,
        [`comet2`] = true,
        [`jester`] = true,
        [`jester2`] = true,
        [`cheetah`] = true,
        [`cheetah2`] = true,
        [`prototipo`] = true,
        [`turismor`] = true,
        [`pfister811`] = true,
        [`ardent`] = true,
        [`nero`] = true,
        [`nero2`] = true,
        [`tempesta`] = true,
        [`vacca`] = true,
        [`bullet`] = true,
        [`osiris`] = true,
        [`entityxf`] = true,
        [`turismo2`] = true,
        [`fmj`] = true,
        [`re7b`] = true,
        [`tyrus`] = true,
        [`italigtb`] = true,
        [`penetrator`] = true,
        [`monroe`] = true,
        [`ninef2`] = true,
        [`stingergt`] = true,
        [`surfer`] = true,
        [`surfer2`] = true,
        [`comet3`] = true,
    }
}