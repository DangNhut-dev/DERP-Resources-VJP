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
}