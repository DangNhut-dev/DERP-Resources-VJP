NPCs = {
    { id = 1,  name = 'Marcus Johnson',     ped = `a_m_y_hipster_01`,        personality = 'casual' },
    { id = 2,  name = 'Tyler Brooks',       ped = `a_m_y_business_02`,       personality = 'strict' },
    { id = 3,  name = 'Derek Williams',     ped = `a_m_m_hasjew_01`,         personality = 'friendly' },
    { id = 4,  name = 'Jake Sullivan',      ped = `a_m_y_stbla_01`,          personality = 'aggressive' },
    { id = 5,  name = 'Ryan Mitchell',      ped = `a_m_y_skater_01`,         personality = 'casual' },
    { id = 6,  name = 'Chris Thompson',     ped = `a_m_y_genstreet_01`,      personality = 'street' },
    { id = 7,  name = 'Brandon Carter',     ped = `a_m_y_downtown_01`,       personality = 'friendly' },
    { id = 8,  name = 'Kevin Martinez',     ped = `a_m_m_soucent_01`,        personality = 'cautious' },
    { id = 9,  name = 'Ethan Rodriguez',    ped = `a_m_y_hipster_02`,        personality = 'casual' },
    { id = 10, name = 'Austin Walker',      ped = `a_m_y_vinewood_01`,       personality = 'snobby' },
    { id = 11, name = 'Dylan Foster',       ped = `a_m_y_skater_02`,         personality = 'casual' },
    { id = 12, name = 'Logan Reed',         ped = `a_m_y_beach_01`,          personality = 'chill' },
    { id = 13, name = 'Jordan Hayes',       ped = `a_m_y_soucent_01`,        personality = 'street' },
    { id = 14, name = 'Cameron Price',      ped = `a_m_y_hipster_03`,        personality = 'snobby' },
    { id = 15, name = 'Blake Morgan',       ped = `a_m_m_salton_01`,         personality = 'cautious' },
    { id = 16, name = 'Zachary Bennett',    ped = `a_m_m_business_01`,       personality = 'strict' },
    { id = 17, name = 'Hunter Campbell',    ped = `a_m_m_bevhills_01`,       personality = 'snobby' },
    { id = 18, name = 'Nathan Cooper',      ped = `a_m_y_indian_01`,         personality = 'friendly' },
    { id = 19, name = 'Trevor Bailey',      ped = `a_m_y_genstreet_02`,      personality = 'aggressive' },
    { id = 20, name = 'Ian Parker',         ped = `a_m_m_hillbilly_01`,      personality = 'street' },
    { id = 21, name = 'Connor Stewart',     ped = `a_m_y_business_03`,       personality = 'strict' },
    { id = 22, name = 'Elijah Rivera',      ped = `a_m_y_latino_01`,         personality = 'street' },
    { id = 23, name = 'Mason Rogers',       ped = `a_m_y_yoga_01`,           personality = 'chill' },
    { id = 24, name = 'Owen Bryant',        ped = `a_m_m_stlat_02`,          personality = 'cautious' },
    { id = 25, name = 'Caleb Russell',      ped = `a_m_y_hipster_04`,        personality = 'casual' },
    { id = 26, name = 'Aaron Foster',       ped = `a_m_y_surfer_01`,         personality = 'chill' },
    { id = 27, name = 'Lucas Gray',         ped = `a_m_y_business_01`,       personality = 'strict' },
    { id = 28, name = 'Isaac Howard',       ped = `a_m_y_epsilon_01`,        personality = 'snobby' },
    { id = 29, name = 'Wyatt Long',         ped = `a_m_m_fatlatin_01`,       personality = 'friendly' },
    { id = 30, name = 'Gavin Barnes',       ped = `a_m_y_stwhi_01`,          personality = 'casual' }
}

function NPCs.GetById(id)
    id = tonumber(id)
    if not id then return nil end
    for i = 1, #NPCs do
        if NPCs[i].id == id then return NPCs[i] end
    end
    return nil
end

function NPCs.GetAll()
    local list = {}
    for i = 1, #NPCs do
        list[i] = NPCs[i]
    end
    return list
end

function NPCs.Count()
    local c = 0
    for i = 1, #NPCs do
        if NPCs[i].id then c = c + 1 end
    end
    return c
end