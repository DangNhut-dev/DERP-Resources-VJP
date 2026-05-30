Config = {}

Config.ReturnDistance = 5.0
Config.VehicleNearZoneDistance = 10.0
Config.SpawnClearRadius = 3.0
Config.FuelResource = 'cdn-fuel'

Config.NPCs = {
    ['mechanic'] = {
        npc = {
            model = 's_m_m_autoshop_02',
            coords = vector4(-354.58, -118.42, 38.70, 67.56),
        },
        vehicleSpawn = vector4(-358.40, -119.54, 38.67, 70.06),
        deletePoint = vector3(-366.72, -116.34, 38.66),
        vehicles = {
            { label = 'Xe Cẩu', model = 'towtruck', grade = 1 },
        },
    },
    ['police'] = {
        npc = {
            model = 'mp_m_securoguard_01',
            coords = vector4(453.18, -1027.78, 28.53, 8.56),
        },
        vehicleSpawn = vector4(448.17, -1020.55, 28.16, 90.70),
        deletePoint = vector3(448.17, -1020.55, 28.16),
        vehicles = {
            { label = 'Xe Bọc Thép', model = 'bcat', grade = 7 },
        },
    },
}