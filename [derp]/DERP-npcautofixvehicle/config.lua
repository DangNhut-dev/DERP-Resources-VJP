Config = {}

-- Job name được tính là "mechanic on duty" -> ẩn toàn bộ NPC
Config.MechanicJob = 'mechanic'

-- GlobalState key để broadcast trạng thái mechanic on duty
Config.MechanicOnDutyStateKey = 'DERO_npcautofix_mechOnduty'

-- Danh sách NPC sửa xe
-- repairType: 'engine' = chỉ sửa động cơ | 'full' = sửa toàn bộ xe (không rửa bẩn)
-- allowedJobs: nil = ai cũng gọi được | table = chỉ job/grade đủ điều kiện
-- zone: coords trung tâm ô đậu xe + radius
Config.NPCs = {
    {
        id            = 'engine',
        coords        = vec4(-356.96, -126.65, 38.70, 69.96),
        model         = 's_m_m_autoshop_02',
        targetLabel   = 'Gọi Sửa Xe 250$',
        price         = 250,
        targetDistance = 2.0,
        repairType    = 'full',
        allowedJobs   = nil,
        zone = {
            coords = vec3(-360.21, -128.09, 38.13),
            radius = 10.0,  
        },
    },
    {
        id            = 'police_full',
        coords        = vec4(428.09, -972.97, 25.70, 190.96),
        model         = 's_m_y_cop_01',
        targetLabel   = 'Gọi Sửa Xe 250$',
        price         = 250,
        targetDistance = 2.0,
        repairType    = 'full',
        allowedJobs   = { police = 0 },
        zone = {
            coords = vec3(426.02, -976.19, 25.70),
            radius = 8.0,
        },
    },
}
