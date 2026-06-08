local a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t
version = "1.1.6"
subversion = ""
api_response = {}
a = "1.1.9"
b = false
d = true
registerUsableItems = function()
    for eq_type_name, eq_type_data in pairs(Config.equipments_upgrades) do
        for item_name, item_data in pairs(eq_type_data) do
            local cap_name = item_name
            local cap_type = eq_type_name

            if cap_type == "bait" then
                exports.qbx_core:CreateUseableItem(cap_name, function(src)
                end)
                goto continue
            end

            if item_data.is_scuba then
                exports.qbx_core:CreateUseableItem(cap_name, function(src)
                    TriggerClientEvent("lc_fishing_simulator:toggleswimsuit", src)
                end)

            elseif cap_type == "rod" then
                exports.qbx_core:CreateUseableItem(cap_name, function(src)
                    local ok, err = pcall(function()
                        local user_id = Utils.Framework.getPlayerId(src)
                        if not user_id then return end

                        local rod_config = Config.equipments_upgrades.rod[cap_name]
                        if not rod_config then return end

                        if getPlayerLevel(user_id) < (rod_config.required_level or 0) then
                            TriggerClientEvent("lc_fishing_simulator:Notify", src, "error", Utils.translate("not_enough_level"))
                            return
                        end

                        local slots = exports.ox_inventory:Search(src, 'slots', cap_name)
                        if not slots or #slots == 0 then return end

                        local rod_slot = slots[1].slot
                        local slot_data = exports.ox_inventory:GetSlot(src, rod_slot)
                        if not slot_data then return end

                        local metadata = slot_data.metadata or {}
                        TriggerClientEvent("lc_fishing_simulator:openRodMenu", src, rod_slot, metadata, cap_name)
                    end)
                    if not ok then
                        print("^8[fishing] rod error: " .. tostring(err) .. "^7")
                    end
                end)

            elseif cap_type == "hook" or cap_type == "line" or cap_type == "reel" then
                exports.qbx_core:CreateUseableItem(cap_name, function(src)
                    local ok, err = pcall(function()
                        local user_id = Utils.Framework.getPlayerId(src)
                        if not user_id then return end

                        local eq_config = Config.equipments_upgrades[cap_type][cap_name]
                        if not eq_config then return end

                        if getPlayerLevel(user_id) < (eq_config.required_level or 0) then
                            TriggerClientEvent("lc_fishing_simulator:Notify", src, "error", Utils.translate("not_enough_level"))
                            return
                        end

                        local eq_slots = exports.ox_inventory:Search(src, 'slots', cap_name)
                        if not eq_slots or #eq_slots == 0 then return end
                        local eq_slot = eq_slots[1].slot

                        local rod_list = {}
                        for rod_item_name, _ in pairs(Config.equipments_upgrades.rod or {}) do
                            local rod_slots = exports.ox_inventory:Search(src, 'slots', rod_item_name)
                            if rod_slots and #rod_slots > 0 then
                                for _, rod_slot_data in ipairs(rod_slots) do
                                    local meta = rod_slot_data.metadata or {}
                                   table.insert(rod_list, {
                                        slot  = rod_slot_data.slot,
                                        name  = rod_slot_data.name,
                                        label = rod_slot_data.label or rod_slot_data.name,
                                        current = meta[cap_type],
                                    })
                                end
                            end
                        end

                        if #rod_list == 0 then
                            TriggerClientEvent("lc_fishing_simulator:Notify", src, "error", Utils.translate("missing_equipments.rod"))
                            return
                        end

                        TriggerClientEvent("lc_fishing_simulator:openAttachMenu", src, cap_type, cap_name, eq_slot, rod_list)
                    end)
                    if not ok then
                        print("^8[fishing] equipment error: " .. tostring(err) .. "^7")
                    end
                end)
            end
            ::continue::
            Wait(10)
        end
    end
end
Citizen.CreateThread(
    function()
        local u, v, w, x, y, z, A, B, C
        Wait(2000)
        print(
            "^2[" ..
                GetCurrentResourceName() ..
                    "] Authenticated! Support discord: https://discord.gg/U5YDgbh^7 ^3[v" ..
                        version .. subversion .. "] ^7"
        )
        while not false do
            PerformHttpRequest(
                "http://projetocharmoso.com:3000/api/check-version-v2?script=" .. 12 .. "&version=" .. version,
                function(D, E, F, G)
                    local H, I, J, K, L, M
                    if 200 == D and E then
                        u = true
                        api_response = json.decode(E)
                        if true == api_response.has_update then
                            -- print(
                            --     "^4[" ..
                            --         GetCurrentResourceName() ..
                            --             "] An update is available, download it in your keymaster^7 ^3[v" ..
                            --                 api_response.latest_version .. "]^7"
                            -- )
                            if api_response.update_message then
                                -- print("^4" .. api_response.update_message .. "^7")
                            else
                                -- print(
                                --     "^4[" ..
                                --         GetCurrentResourceName() ..
                                --             "] For the complete changelog, visit our Discord: https://discord.gg/U5YDgbh^7"
                                -- )
                            end
                        end
                    end
                end,
                "GET",
                "",
                {}
            )
            if false == u and 0 + 1 > 5 then
                break
            end
            Wait(10000)
        end
    end
)
e = Utils
if not e then
    e = exports.lc_utils
    e = e.GetUtils(e)
end
Utils = e
e = {}
f = {}
g = {}
h = {}
i = {}
j = nil
k = {}
k[1] = "swamp"
k[2] = "lake"
k[3] = "sea"
k[4] = "river"
l = {}
l[1] = "common"
l[2] = "uncommon"
l[3] = "rare"
l[4] = "legendary"
l[5] = "mythic"
m = {}
n = {}
n[1] = "rod"
n[2] = "hook"
n[3] = "line"
n[4] = "bait"
n[5] = "reel"
AddEventHandler(
    "playerDropped",
    function(N)
        local v, w, x, y, z, A
        v = source
        if g[v] then
            z = {}
            z["@id"] = g[v].id
            Utils.Database.execute(
                "UPDATE `fishing_simulator_available_contracts` SET progress = NULL WHERE id = @id;",
                z
            )
            g[v] = nil
        end
        if h[v] then
            z = {}
            z["@id"] = h[v].id
            Utils.Database.execute("UPDATE `fishing_simulator_available_dives` SET progress = NULL WHERE id = @id;", z)
            h[v] = nil
        end
        f[v] = nil
    end
)
generateFisherAvailableContractsThread = function()
    local u, v
    Citizen.CreateThreadNow(
        function()
            local O, P, Q, R, H, I, J, K, L, M, S, T, U, V, W, X, Y, Z
            while true do
                P = Config.available_contracts.contracts[math.random(1, #Config.available_contracts.contracts)]
                Q = nil
                R = nil
                if P.reward.money_min then
                    Q = math.random(P.reward.money_min, P.reward.money_max)
                else
                    R = json.encode(P.reward)
                end
                if
                    tonumber(
                        Utils.Database.fetchAll(
                            "SELECT COUNT(id) as qtd FROM fishing_simulator_available_contracts",
                            {}
                        )[1].qtd
                    ) >= Config.available_contracts.definitions.max_contracts
                 then
                    T = {}
                    T["@id"] =
                        Utils.Database.fetchAll(
                        "SELECT MIN(id) as min FROM fishing_simulator_available_contracts WHERE progress IS NULL",
                        {}
                    )[1].min
                    Utils.Database.execute("DELETE FROM `fishing_simulator_available_contracts` WHERE id = @id;", T)
                end
                S = {}
                S["@name"] = P.name
                S["@description"] = P.description
                S["@image"] = P.image
                S["@required_items"] = json.encode(P.required_items)
                S["@money_reward"] = Q
                S["@item_reward"] = R
                S["@delivery_location"] =
                    json.encode(Config.delivery_locations[math.random(#Config.delivery_locations)])
                S["@timestamp"] = os.time()
                Utils.Database.execute(
                    "INSERT INTO `fishing_simulator_available_contracts` (name, description, image, required_items, money_reward, item_reward, delivery_location, timestamp) VALUE (@name, @description, @image, @required_items, @money_reward, @item_reward, @delivery_location, @timestamp)",
                    S
                )
                L = Utils.Framework.getPlayers()
                if not L then
                    L = {}
                end
                M, S, T, U = pairs(L)
                for V, W in M, S, T, U do
                    if f[W] then
                        openUI(W, true)
                        Citizen.Wait(100)
                    end
                end
                Wait(60000 * Config.available_contracts.definitions.time_to_new_contracts)
            end
        end
    )
end
generateFisherAvailableDivesThread = function()
    local u, v
    Citizen.CreateThreadNow(
        function()
            local O, P, Q, R, H, I, J, K, L, M, S, T, U, V, W, X, Y, Z
            while true do
                P = Config.available_dives.dives[math.random(1, #Config.available_dives.dives)]
                Q = nil
                R = nil
                if P.reward.money_min then
                    Q = math.random(P.reward.money_min, P.reward.money_max)
                else
                    R = json.encode(P.reward)
                end
                if
                    tonumber(
                        Utils.Database.fetchAll("SELECT COUNT(id) as qtd FROM fishing_simulator_available_dives", {})[1].qtd
                    ) >= Config.available_dives.definitions.max_dives
                 then
                    T = {}
                    T["@id"] =
                        Utils.Database.fetchAll(
                        "SELECT MIN(id) as min FROM fishing_simulator_available_dives WHERE progress IS NULL",
                        {}
                    )[1].min
                    Utils.Database.execute("DELETE FROM `fishing_simulator_available_dives` WHERE id = @id;", T)
                end
                S = {}
                S["@name"] = P.name
                S["@description"] = P.description
                S["@image"] = P.image
                S["@money_reward"] = Q
                S["@item_reward"] = R
                S["@dive_location"] = json.encode(Config.dives_locations[math.random(#Config.dives_locations)])
                S["@timestamp"] = os.time()
                Utils.Database.execute(
                    "INSERT INTO `fishing_simulator_available_dives` (name, description, image, money_reward, item_reward, dive_location, timestamp) VALUE (@name, @description, @image, @money_reward, @item_reward, @dive_location, @timestamp)",
                    S
                )
                L = Utils.Framework.getPlayers()
                if not L then
                    L = {}
                end
                M, S, T, U = pairs(L)
                for V, W in M, S, T, U do
                    if f[W] then
                        openUI(W, true)
                        Citizen.Wait(100)
                    end
                end
                Wait(60000 * Config.available_dives.definitions.time_to_new_dives)
            end
        end
    )
end
processPropertyDegradation = function()
    local u, v
    Citizen.CreateThreadNow(
        function()
            local O, P, Q, R, H, I, J, K, L, M, S, T, U, V, W, X, Y
            while true do
                Q, R, H, I = pairs(Utils.Database.fetchAll("SELECT * FROM `fishing_simulator_properties`"))
                for J, K in Q, R, H, I do
                    if K.property_condition < 1 then
                        T = {}
                        T["@id"] = K.id
                        Utils.Database.execute("DELETE from `fishing_simulator_properties` WHERE id = @id", T)
                    else
                        if K.property_condition < 10 then
                            L = Utils.Framework.getPlayerSource(K.user_id)
                            if L then
                                M = Config.available_items_store.property[K.property]
                                if M then
                                    W = Utils.translate("property_needs_repair")
                                    W, X, Y = W.format(W, M.name)
                                    TriggerClientEvent("lc_fishing_simulator:Notify", L, "error", W, X, Y)
                                end
                            end
                            U = {}
                            U["@id"] = K.id
                            Utils.Database.execute(
                                " UPDATE `fishing_simulator_properties` SET property_condition = property_condition - 1 WHERE id = @id",
                                U
                            )
                        else
                            T = {}
                            T["@id"] = K.id
                            Utils.Database.execute(
                                " UPDATE `fishing_simulator_properties` SET property_condition = property_condition - 1 WHERE id = @id",
                                T
                            )
                        end
                    end
                end
                Wait(60000 * Config.time_degradate_property)
            end
        end
    )
end
updateLoansThread = function()
    local u, v
    Citizen.CreateThreadNow(
        function()
            local O, P, Q, R, H, I, J, K, L, M, S, T, U, V, W, X
            while true do
                R, H, I, J = pairs(Utils.Database.fetchAll("SELECT * FROM fishing_simulator_loans", {}))
                for K, L in R, H, I, J do
                    if L.timer + Config.loans.payment_interval_hours * 3600 < os.time() then
                        M = Utils.Framework.getPlayerSource(L.user_id)
                        if tryGetFisherMoney(L.user_id, L.day_cost) then
                            S = L.remaining_amount - L.taxes_on_day
                            if S > 0 then
                                W = {}
                                W.remaining_amount = S
                                W.timer = os.time()
                                W["@id"] = L.id
                                Utils.Database.execute(
                                    "UPDATE `fishing_simulator_loans` SET remaining_amount = @remaining_amount, timer = @timer WHERE id = @id",
                                    W
                                )
                            else
                                W = {}
                                W["@id"] = L.id
                                Utils.Database.execute("DELETE FROM `fishing_simulator_loans` WHERE id = @id;", W)
                            end
                        elseif M then
                            W, X = Utils.translate("no_loan_money")
                            TriggerClientEvent("lc_fishing_simulator:Notify", M, "info", W, X)
                            deleteAllUserData(L.user_id)
                        else
                            V = {}
                            V["@user_id"] = L.user_id
                            Utils.Database.execute(
                                "UPDATE `fishing_simulator_users` SET loan_notify = 1 WHERE user_id = @user_id",
                                V
                            )
                        end
                        if M then
                            if f[M] then
                                openUI(M, true)
                            end
                        end
                        Citizen.Wait(100)
                    end
                end
                Citizen.Wait(300000)
            end
        end
    )
end
checkTournamentStarts = function()
    local u, v
    Citizen.CreateThreadNow(
        function()
            local O, P, Q, R, H, I, J, K, L, M, S, T, U, V, W, X, Y, Z, _, a0, a1, a2, a3, a4
            while true do
                R = {}
                R["@current_time"] = os.time()
                P =
                    Utils.Database.fetchAll(
                    "SELECT * FROM `fishing_simulator_tournaments` WHERE timestamp <= @current_time AND notified = 0",
                    R
                )[1]
                if P then
                    I = {}
                    I["@tournament_id"] = P.id
                    Utils.Database.execute(
                        "UPDATE `fishing_simulator_tournaments` SET notified = 1 WHERE id = @tournament_id",
                        I
                    )
                    J = {}
                    J["@tournament_id"] = P.id
                    H =
                        Utils.Database.fetchAll(
                        "SELECT user_id FROM `fishing_simulator_tournaments_users` WHERE tournament_id = @tournament_id",
                        J
                    )
                    if Utils.Table.tableLength(H) >= Config.fishing_tournaments.min_participants then
                        I, J, K, L = ipairs(H)
                        for M, S in I, J, K, L do
                            T = Utils.Framework.getPlayerSource(S.user_id)
                            if T then
                                X, Y, Z, _, a0, a1, a2, a3, a4 = json.decode(P.location)
                                TriggerClientEvent(
                                    "lc_fishing_simulator:createTournamentBlip",
                                    T,
                                    X,
                                    Y,
                                    Z,
                                    _,
                                    a0,
                                    a1,
                                    a2,
                                    a3,
                                    a4
                                )
                                Y, Z, _, a0, a1, a2, a3, a4 = Utils.translate("tournament_started")
                                TriggerClientEvent(
                                    "lc_fishing_simulator:Notify",
                                    T,
                                    "success",
                                    Y,
                                    Z,
                                    _,
                                    a0,
                                    a1,
                                    a2,
                                    a3,
                                    a4
                                )
                            end
                        end
                        Wait(60000 * Config.fishing_tournaments.event_duration)
                        L = {}
                        L["@tournament_id"] = P.id
                        K, L, M, S =
                            ipairs(
                            Utils.Database.fetchAll(
                                "SELECT user_id, catches FROM `fishing_simulator_tournaments_users` WHERE tournament_id = @tournament_id order by catches desc",
                                L
                            )
                        )
                        for T, U in K, L, M, S do
                            V = Utils.Framework.getPlayerSource(U.user_id)
                            if V then
                                Z, _, a0, a1, a2, a3, a4 = json.decode(P.location)
                                TriggerClientEvent(
                                    "lc_fishing_simulator:removeTournamentBlip",
                                    V,
                                    Z,
                                    _,
                                    a0,
                                    a1,
                                    a2,
                                    a3,
                                    a4
                                )
                                _, a0, a1, a2, a3, a4 = Utils.translate("tournament_ended")
                                TriggerClientEvent("lc_fishing_simulator:Notify", V, "success", _, a0, a1, a2, a3, a4)
                            end
                            W = Config.fishing_tournaments.prizes[T]
                            if W then
                                X = ""
                                if W.money then
                                    giveFisherMoney(U.user_id, W.money, true)
                                    X = X .. W.money
                                end
                                if W.exp then
                                    giveplayerXp(U.user_id, W.exp)
                                    if "" ~= X then
                                        X = X .. " + "
                                    end
                                    X = X .. W.exp .. " " .. Utils.translate("exp")
                                end
                                if W.item then
                                    if W.item.label then
                                        if W.item.amount and V then
                                            if not Utils.Framework.givePlayerItem(V, W.item.label, W.item.amount) then
                                                a1, a2, a3, a4 = Utils.translate("cant_carry_item")
                                                TriggerClientEvent(
                                                    "lc_fishing_simulator:Notify",
                                                    V,
                                                    "success",
                                                    a1,
                                                    a2,
                                                    a3,
                                                    a4
                                                )
                                            end
                                            if "" ~= X then
                                                X = X .. " + "
                                            end
                                            X = X .. W.item.amount .. "x " .. W.item.display_name
                                        end
                                    end
                                end
                                if V then
                                    a1 = Utils.translate("tournament_prize_received")
                                    a1, a2, a3, a4 = a1.format(a1, T, X)
                                    TriggerClientEvent("lc_fishing_simulator:Notify", V, "success", a1, a2, a3, a4)
                                end
                            elseif V then
                                a0, a1, a2, a3, a4 = Utils.translate("tournament_prize_not_received")
                                TriggerClientEvent("lc_fishing_simulator:Notify", V, "success", a0, a1, a2, a3, a4)
                            end
                        end
                        j = nil
                    else
                        I, J, K, L = ipairs(H)
                        for M, S in I, J, K, L do
                            T = Utils.Framework.getPlayerSource(S.user_id)
                            if T then
                                X, Y, Z, _, a0, a1, a2, a3, a4 = json.decode(P.location)
                                TriggerClientEvent(
                                    "lc_fishing_simulator:removeTournamentBlip",
                                    T,
                                    X,
                                    Y,
                                    Z,
                                    _,
                                    a0,
                                    a1,
                                    a2,
                                    a3,
                                    a4
                                )
                                Y, Z, _, a0, a1, a2, a3, a4 = Utils.translate("tournament_cancelled")
                                TriggerClientEvent(
                                    "lc_fishing_simulator:Notify",
                                    T,
                                    "error",
                                    Y,
                                    Z,
                                    _,
                                    a0,
                                    a1,
                                    a2,
                                    a3,
                                    a4
                                )
                            end
                            giveFisherMoney(S.user_id, Config.fishing_tournaments.entry_fee, true)
                        end
                    end
                end
                Wait(60000)
            end
        end
    )
end
RegisterServerEvent("lc_fishing_simulator:getData")
AddEventHandler(
    "lc_fishing_simulator:getData",
    function(N)
        local v, w, x, y
        v = source
        Wrapper(
            v,
            function(D)
                local P, Q, R
                openUI(v, false)
            end
        )
    end
)
RegisterServerEvent("lc_fishing_simulator:getDataProperty")
AddEventHandler(
    "lc_fishing_simulator:getDataProperty",
    function(N)
        local v, w, x, y
        v = source
        Wrapper(
            v,
            function(D)
                local P, Q, R
                openPropertyUI(v, N)
            end
        )
    end
)
RegisterServerEvent("lc_fishing_simulator:getDataStore")
AddEventHandler(
    "lc_fishing_simulator:getDataStore",
    function(N)
        local v, w, x, y
        v = source
        Wrapper(
            v,
            function(D)
                local P, Q, R
                openFishStoreUI(v, N)
            end
        )
    end
)
RegisterServerEvent("lc_fishing_simulator:closeUI")
AddEventHandler(
    "lc_fishing_simulator:closeUI",
    function()
        local u, v
        f[source] = nil
    end
)
RegisterServerEvent("lc_fishing_simulator:startContract")
AddEventHandler(
    "lc_fishing_simulator:startContract",
    function(N, a5)
        local w, x, y, z
        w = source
        Wrapper(
            w,
            function(D)
                local P, Q, R, H, I, J, K, L, M
                H = {}
                H["@id"] = a5.contract_id
                Q =
                    Utils.Database.fetchAll("SELECT * FROM `fishing_simulator_available_contracts` WHERE id = @id", H)[1]
                if not Q then
                    K, L, M = Utils.translate("contract_invalid")
                    TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", K, L, M)
                    return
                end
                if nil ~= Q.progress then
                    K, L, M = Utils.translate("contract_someone_already_started")
                    TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", K, L, M)
                    return
                end
                if g[w] then
                    K, L, M = Utils.translate("contract_already_started")
                    TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", K, L, M)
                    return
                end
                g[w] = Q
                J = {}
                J["@user_id"] = D
                J["@id"] = g[w].id
                Utils.Database.execute(
                    "UPDATE `fishing_simulator_available_contracts` SET progress = @user_id WHERE id = @id",
                    J
                )
                L, M = Utils.translate("contract_started")
                TriggerClientEvent("lc_fishing_simulator:Notify", w, "success", L, M)
                TriggerClientEvent("lc_fishing_simulator:startContract", w, Q)
            end
        )
    end
)
RegisterServerEvent("lc_fishing_simulator:finishContract")
AddEventHandler(
    "lc_fishing_simulator:finishContract",
    function()
        local u, v, w, x
        u = source
        Wrapper(
            u,
            function(D)
                local P, Q, R, H, I, J, K, L, M, S, T, U, V, W, X, Y, Z, _, a0, a1, a2
                if not g[u] then
                    return
                end
                P = GetPlayerPed(u)
                if not P then
                    print(
                        "^8[" ..
                            GetCurrentResourceName() ..
                                "] Source ped from user " .. D .. " (" .. GetPlayerName(u) .. ") not found.^7"
                    )
                    return
                end
                R = json.decode(g[u].delivery_location)
                J = GetEntityCoords(P)
                if #(J - vector3(R[1], R[2], R[3])) > 20.0 then
                    print(
                        "^8[" ..
                            GetCurrentResourceName() ..
                                "] Money exploit by user: " .. D .. " (" .. GetPlayerName(u) .. ").^7"
                    )
                    S = Utils.translate("logs_exploit")
                    S, T, U, V, W, X, Y, Z, _, a0, a1, a2 =
                        S.format(
                        S,
                        "lc_fishing_simulator:finishContract",
                        json.encode(J),
                        json.encode(g[u]),
                        Utils.Framework.getPlayerIdLog(u) ..
                            os.date(
                                [[

[]] ..
                                    Utils.translate("logs_date") ..
                                        "]: %d/%m/%Y [" .. Utils.translate("logs_hour") .. "]: %H:%M:%S"
                            )
                    )
                    Utils.Webhook.sendWebhookMessage(WebhookURL, S, T, U, V, W, X, Y, Z, _, a0, a1, a2)
                    return
                end
                L = json.decode(g[u].required_items)
                M = ""
                S = false
                T, U, V, W = pairs(L)
                for X, Y in T, U, V, W do
                    if not Utils.Framework.playerHasItem(u, Y.name, Y.amount) then
                        S = true
                        if "" == M then
                            M = Y.amount .. "x " .. Y.display_name
                        else
                            M = M .. ", " .. Y.amount .. "x " .. Y.display_name
                        end
                    end
                end
                if S then
                    X = Utils.translate("contract_not_enough_items")
                    X, Y, Z, _, a0, a1, a2 = X.format(X, M)
                    TriggerClientEvent("lc_fishing_simulator:Notify", u, "error", X, Y, Z, _, a0, a1, a2)
                    return
                end
                T, U, V, W = pairs(L)
                for X, Y in T, U, V, W do
                    Utils.Framework.getPlayerItem(u, Y.name, Y.amount)
                end
                if g[u].money_reward then
                    giveFisherMoney(D, g[u].money_reward, true)
                    X = Utils.translate("contract_received_money")
                    X, Y, Z, _, a0, a1, a2 = X.format(X, g[u].money_reward)
                    TriggerClientEvent("lc_fishing_simulator:Notify", u, "success", X, Y, Z, _, a0, a1, a2)
                else
                    T = json.decode(g[u].item_reward)
                    if Utils.Framework.givePlayerItem(u, T.item, T.amount) then
                        Y = Utils.translate("contract_received_item")
                        Y, Z, _, a0, a1, a2 = Y.format(Y, T.amount, T.display_name)
                        TriggerClientEvent("lc_fishing_simulator:Notify", u, "success", Y, Z, _, a0, a1, a2)
                    else
                        Y = Utils.translate("contract_received_item_error")
                        Y, Z, _, a0, a1, a2 = Y.format(Y, T.amount, T.display_name)
                        TriggerClientEvent("lc_fishing_simulator:Notify", u, "error", Y, Z, _, a0, a1, a2)
                        return
                    end
                end
                W = {}
                W["@user_id"] = D
                Utils.Database.execute(
                    "UPDATE `fishing_simulator_users` SET total_deliveries = total_deliveries + 1 WHERE user_id = @user_id",
                    W
                )
                X = {}
                X["@id"] = g[u].id
                Utils.Database.execute("DELETE FROM `fishing_simulator_available_contracts` WHERE id = @id", X)
                TriggerClientEvent("lc_fishing_simulator:cancelContract", u)
                g[u] = nil
            end
        )
    end
)
RegisterServerEvent("lc_fishing_simulator:cancelContract")
AddEventHandler(
    "lc_fishing_simulator:cancelContract",
    function()
        local u, v, w, x
        u = source
        Wrapper(
            u,
            function(D)
                local P, Q, R, H, I, J, K
                if not g[u] then
                    return
                end
                H = {}
                H["@id"] = g[u].id
                Utils.Database.execute(
                    "UPDATE `fishing_simulator_available_contracts` SET progress = NULL WHERE id = @id",
                    H
                )
                J, K = Utils.translate("contract_cancel")
                TriggerClientEvent("lc_fishing_simulator:Notify", u, "success", J, K)
                TriggerClientEvent("lc_fishing_simulator:cancelContract", u)
                g[u] = nil
                openUI(u, true)
            end
        )
    end
)
RegisterServerEvent("lc_fishing_simulator:startDive")
AddEventHandler(
    "lc_fishing_simulator:startDive",
    function(N, a5)
        local w, x, y, z
        w = source
        Wrapper(
            w,
            function(D)
                local P, Q, R, H, I, J, K, L, M
                H = {}
                H["@id"] = a5.dive_id
                Q = Utils.Database.fetchAll("SELECT * FROM `fishing_simulator_available_dives` WHERE id = @id", H)[1]
                if not Q then
                    K, L, M = Utils.translate("dive_invalid")
                    TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", K, L, M)
                    return
                end
                if nil ~= Q.progress then
                    K, L, M = Utils.translate("dive_someone_already_started")
                    TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", K, L, M)
                    return
                end
                if h[w] then
                    K, L, M = Utils.translate("dive_already_started")
                    TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", K, L, M)
                    return
                end
                h[w] = Q
                J = {}
                J["@user_id"] = D
                J["@id"] = h[w].id
                Utils.Database.execute(
                    "UPDATE `fishing_simulator_available_dives` SET progress = @user_id WHERE id = @id",
                    J
                )
                L, M = Utils.translate("dive_started")
                TriggerClientEvent("lc_fishing_simulator:Notify", w, "success", L, M)
                TriggerClientEvent("lc_fishing_simulator:startDive", w, Q)
            end
        )
    end
)
RegisterServerEvent("lc_fishing_simulator:finishDive")
AddEventHandler(
    "lc_fishing_simulator:finishDive",
    function()
        local u, v, w, x
        u = source
        Wrapper(
            u,
            function(D)
                local P, Q, R, H, I, J, K, L, M, S, T, U, V, W, X, Y, Z, _, a0, a1, a2
                if not h[u] then
                    return
                end
                P = GetPlayerPed(u)
                if not P then
                    print(
                        "^8[" ..
                            GetCurrentResourceName() ..
                                "] Source ped from user " .. D .. " (" .. GetPlayerName(u) .. ") not found.^7"
                    )
                    return
                end
                R = json.decode(h[u].dive_location)
                J = GetEntityCoords(P)
                if #(J - vector3(R[1], R[2], R[3])) > 20.0 then
                    print(
                        "^8[" ..
                            GetCurrentResourceName() ..
                                "] Money exploit by user: " .. D .. " (" .. GetPlayerName(u) .. ").^7"
                    )
                    S = Utils.translate("logs_exploit")
                    S, T, U, V, W, X, Y, Z, _, a0, a1, a2 =
                        S.format(
                        S,
                        "lc_fishing_simulator:finishDive",
                        json.encode(J),
                        json.encode(h[u]),
                        Utils.Framework.getPlayerIdLog(u) ..
                            os.date(
                                [[

[]] ..
                                    Utils.translate("logs_date") ..
                                        "]: %d/%m/%Y [" .. Utils.translate("logs_hour") .. "]: %H:%M:%S"
                            )
                    )
                    Utils.Webhook.sendWebhookMessage(WebhookURL, S, T, U, V, W, X, Y, Z, _, a0, a1, a2)
                    return
                end
                if h[u].money_reward then
                    giveFisherMoney(D, h[u].money_reward, true)
                    U = Utils.translate("dive_received_money")
                    U, V, W, X, Y, Z, _, a0, a1, a2 = U.format(U, h[u].money_reward)
                    TriggerClientEvent("lc_fishing_simulator:Notify", u, "success", U, V, W, X, Y, Z, _, a0, a1, a2)
                else
                    L = json.decode(h[u].item_reward)
                    if Utils.Framework.givePlayerItem(u, L.item, L.amount) then
                        V = Utils.translate("dive_received_item")
                        V, W, X, Y, Z, _, a0, a1, a2 = V.format(V, L.amount, L.display_name)
                        TriggerClientEvent("lc_fishing_simulator:Notify", u, "success", V, W, X, Y, Z, _, a0, a1, a2)
                    else
                        V = Utils.translate("dive_received_item_error")
                        V, W, X, Y, Z, _, a0, a1, a2 = V.format(V, L.amount, L.display_name)
                        TriggerClientEvent("lc_fishing_simulator:Notify", u, "error", V, W, X, Y, Z, _, a0, a1, a2)
                        return
                    end
                end
                T = {}
                T["@user_id"] = D
                Utils.Database.execute(
                    "UPDATE `fishing_simulator_users` SET total_dives = total_dives + 1 WHERE user_id = @user_id",
                    T
                )
                U = {}
                U["@id"] = h[u].id
                Utils.Database.execute("DELETE FROM `fishing_simulator_available_dives` WHERE id = @id", U)
                h[u] = nil
                TriggerClientEvent("lc_fishing_simulator:cancelDive", u)
            end
        )
    end
)
RegisterServerEvent("lc_fishing_simulator:cancelDive")
AddEventHandler(
    "lc_fishing_simulator:cancelDive",
    function()
        local u, v, w, x
        u = source
        Wrapper(
            u,
            function(D)
                local P, Q, R, H, I, J, K
                if not h[u] then
                    return
                end
                H = {}
                H["@id"] = h[u].id
                Utils.Database.execute(
                    "UPDATE `fishing_simulator_available_dives` SET progress = NULL WHERE id = @id",
                    H
                )
                J, K = Utils.translate("dive_cancel")
                TriggerClientEvent("lc_fishing_simulator:Notify", u, "success", J, K)
                TriggerClientEvent("lc_fishing_simulator:cancelDive", u)
                h[u] = nil
                openUI(u, true)
            end
        )
    end
)
RegisterServerEvent("lc_fishing_simulator:buyUpgrade")
AddEventHandler(
    "lc_fishing_simulator:buyUpgrade",
    function(N, a5)
        local w, x, y, z
        w = source
        Wrapper(
            w,
            function(D)
                local P, Q, R, H, I, J, K, L, M, S, T, U
                H = {}
                H["@user_id"] = D
                Q = Utils.Database.fetchAll("SELECT * FROM `fishing_simulator_users` WHERE user_id = @user_id", H)
                R = tonumber(Q[1][a5.upgrade_type .. "_upgrade"])
                if not R then
                    R = 0
                end
                H = R + 1
                I = Config.upgrades[a5.upgrade_type]
                if not I then
                    L = a5.upgrade_type
                    if not L then
                        L = "undefined"
                    end
                    print("lc_fishing_simulator:buyUpgrade: Invalid upgrade type: " .. L)
                    return
                end
                if not I[H] then
                    L = H or L
                    if not H then
                        L = "undefined"
                    end
                    print("lc_fishing_simulator:buyUpgrade: Invalid upgrade level: " .. L .. " - " .. a5.upgrade_type)
                    return
                end
                if Q[1].skill_points >= I[H].points_required then
                    M = {}
                    M["@user_id"] = D
                    M["@level"] = H
                    M["@skill_points"] = I[H].points_required
                    Utils.Database.execute(
                        "UPDATE `fishing_simulator_users` SET " ..
                            a5.upgrade_type ..
                                "_upgrade = @level, skill_points = skill_points - @skill_points WHERE user_id = @user_id",
                        M
                    )
                    T, U = Utils.translate("upgrade_purchased")
                    TriggerClientEvent("lc_fishing_simulator:Notify", w, "success", T, U)
                    openUI(w, true)
                else
                    S, T, U = Utils.translate("insufficient_skill_points")
                    TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", S, T, U)
                end
            end
        )
    end
)
RegisterServerEvent("lc_fishing_simulator:buyEquipment")
AddEventHandler(
    "lc_fishing_simulator:buyEquipment",
    function(N, a5)
        local w, x, y, z
        w = source
        Wrapper(
            w,
            function(D)
                local P, Q, R, H, I, J, K, L, M, S, T
                P = Config.equipments_upgrades[a5.equipment_type]
                if not P then
                    H = a5.equipment_type
                    if not H then
                        H = "undefined"
                    end
                    print("lc_fishing_simulator:buyEquipment: Invalid equipment: " .. H)
                    return
                end
                Q = P[a5.equipment_id]
                if not Q then
                    I = a5.equipment_id
                    if not I then
                        I = "undefined"
                    end
                    print(
                        "lc_fishing_simulator:buyEquipment: Invalid equipment level: " ..
                            I .. " - " .. a5.equipment_type
                    )
                    return
                end
                H = tonumber(a5.amount)
                if not H then
                    H = 0
                end
                a5.amount = math.floor(H)
                if a5.amount then
                    if not (a5.amount < 1) then
                        goto a6
                    end
                end
                K, L, M, S, T = Utils.translate("invalid_value")
                TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", K, L, M, S, T)
                do
                    return
                end
                ::a6::
                R = Q.price * a5.amount
                
                if tryGetFisherMoney(D, R, true) then
                    if Utils.Framework.givePlayerItem(w, a5.equipment_id, a5.amount) then
                        S, T = Utils.translate("equipment_purchased")
                        TriggerClientEvent("lc_fishing_simulator:Notify", w, "success", S, T)
                        openUI(w, true)
                    else
                        local Player = QBCore.Functions.GetPlayer(w)
                        if Player then
                            tryGetFisherMoney(D, -R, true)
                            
                            S, T = Utils.translate("cant_carry_item")
                            TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", S, T)
                        end
                    end
                else
                    S, T = Utils.translate("insufficient_money")
                    TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", S, T)
                end
            end
        )
    end
)
RegisterServerEvent("lc_fishing_simulator:viewLocation")
AddEventHandler(
    "lc_fishing_simulator:viewLocation",
    function(N, a5)
        local w, x, y, z
        w = source
        Wrapper(
            w,
            function(D)
                local P, Q, R, H, I, J, K, L
                H = {}
                H["@id"] = a5.contract_id
                Q =
                    Utils.Database.fetchAll(
                    "SELECT delivery_location FROM `fishing_simulator_available_contracts` WHERE id = @id",
                    H
                )[1]
                if Q then
                    J, K, L = json.decode(Q.delivery_location)
                    TriggerClientEvent("lc_fishing_simulator:viewLocation", w, J, K, L)
                    K, L = Utils.translate("contract_waypoint_set")
                    TriggerClientEvent("lc_fishing_simulator:Notify", w, "success", K, L)
                else
                    K, L = Utils.translate("contract_invalid")
                    TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", K, L)
                end
            end
        )
    end
)
RegisterServerEvent("lc_fishing_simulator:viewPropertyLocation")
AddEventHandler(
    "lc_fishing_simulator:viewPropertyLocation",
    function(N, a5)
        local w, x, y, z
        w = source
        Wrapper(
            w,
            function(D)
                local P, Q, R, H, I, J, K
                P = Config.available_items_store.property[a5.property_id].location
                if P then
                    TriggerClientEvent("lc_fishing_simulator:viewLocation", w, P)
                    J, K = Utils.translate("property_waypoint_set")
                    TriggerClientEvent("lc_fishing_simulator:Notify", w, "success", J, K)
                else
                    J, K = Utils.translate("property_not_found")
                    TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", J, K)
                end
            end
        )
    end
)
RegisterServerEvent("lc_fishing_simulator:buyVehicle")
AddEventHandler(
    "lc_fishing_simulator:buyVehicle",
    function(N, a5)
        local w, x, y, z
        w = source
        Wrapper(
            w,
            function(D)
                local P, Q, R, H, I, J, K, L, M, S, T, U, V, W, X, Y
                if getAmountOfVehicles(D) < getMaxGarageSlots(D) then
                    P = Config.available_items_store[a5.type][a5.vehicle_id].price
                    if beforeBuyVehicle(w, a5.type, a5.vehicle_id, P, D) then
                        if tryGetFisherMoney(D, P, true) then
                            I = {}
                            I["@user_id"] = D
                            I["@vehicle"] = a5.vehicle_id
                            I["@properties"] = json.encode({})
                            I["@type"] = a5.type
                            Utils.Database.execute(
                                "INSERT INTO `fishing_simulator_vehicles` (user_id, vehicle, properties, type) VALUES (@user_id, @vehicle, @properties, @type);",
                                I
                            )
                            K, L, M, S, T, U, V, W, X, Y = Utils.translate("vehicle_purchased")
                            TriggerClientEvent(
                                "lc_fishing_simulator:Notify",
                                w,
                                "success",
                                K,
                                L,
                                M,
                                S,
                                T,
                                U,
                                V,
                                W,
                                X,
                                Y
                            )
                            I = Utils.translate("logs_buy_vehicle")
                            I, J, K, L, M, S, T, U, V, W, X, Y =
                                I.format(
                                I,
                                D,
                                a5.vehicle_id,
                                P,
                                Utils.Framework.getPlayerIdLog(w) ..
                                    os.date(
                                        [[

[]] ..
                                            Utils.translate("logs_date") ..
                                                "]: %d/%m/%Y [" .. Utils.translate("logs_hour") .. "]: %H:%M:%S"
                                    )
                            )
                            Utils.Webhook.sendWebhookMessage(WebhookURL, I, J, K, L, M, S, T, U, V, W, X, Y)
                            openUI(w, true)
                        else
                            J, K, L, M, S, T, U, V, W, X, Y = Utils.translate("insufficient_money")
                            TriggerClientEvent(
                                "lc_fishing_simulator:Notify",
                                w,
                                "error",
                                J,
                                K,
                                L,
                                M,
                                S,
                                T,
                                U,
                                V,
                                W,
                                X,
                                Y
                            )
                        end
                    end
                else
                    I, J, K, L, M, S, T, U, V, W, X, Y = Utils.translate("garage_full")
                    TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", I, J, K, L, M, S, T, U, V, W, X, Y)
                end
            end
        )
    end
)
RegisterServerEvent("lc_fishing_simulator:repairVehicle")
AddEventHandler(
    "lc_fishing_simulator:repairVehicle",
    function(N, a5)
        local w, x, y, z
        w = source
        Wrapper(
            w,
            function(D)
                local P, Q, R, H, I, J, K, L, M, S, T, U
                H = {}
                H["@user_id"] = D
                H["@id"] = a5.vehicle_id
                Q =
                    Utils.Database.fetchAll(
                    "SELECT health, vehicle, type FROM `fishing_simulator_vehicles` WHERE user_id = @user_id AND id = @id",
                    H
                )
                if Q then
                    if Q[1] then
                        if Q[1].health < 900 then
                            if Q[1].health < 0 then
                                Q[1].health = 0
                            end
                            H = Config.available_items_store[Q[1].type][Q[1].vehicle]
                            if H then
                                if tryGetFisherMoney(D, H.repair_price * math.floor((1000 - Q[1].health) / 10), true) then
                                    M = {}
                                    M["@user_id"] = D
                                    M["@id"] = a5.vehicle_id
                                    Utils.Database.execute(
                                        "UPDATE `fishing_simulator_vehicles` SET health = 1000 WHERE user_id = @user_id AND id = @id",
                                        M
                                    )
                                    T, U = Utils.translate("vehicle_repaired")
                                    TriggerClientEvent("lc_fishing_simulator:Notify", w, "success", T, U)
                                    openUI(w, true)
                                else
                                    S, T, U = Utils.translate("insufficient_money")
                                    TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", S, T, U)
                                end
                            else
                                M, S, T, U = Utils.translate("vehicle_not_found")
                                TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", M, S, T, U)
                            end
                        else
                            K, L, M, S, T, U = Utils.translate("vehicle_already_repaired")
                            TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", K, L, M, S, T, U)
                        end
                    end
                else
                    K, L, M, S, T, U = Utils.translate("vehicle_not_found")
                    TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", K, L, M, S, T, U)
                end
            end
        )
    end
)
RegisterServerEvent("lc_fishing_simulator:refuelVehicle")
AddEventHandler(
    "lc_fishing_simulator:refuelVehicle",
    function(N, a5)
        local w, x, y, z
        w = source
        Wrapper(
            w,
            function(D)
                local P, Q, R, H, I, J, K, L, M, S, T, U
                H = {}
                H["@user_id"] = D
                H["@id"] = a5.vehicle_id
                Q =
                    Utils.Database.fetchAll(
                    "SELECT fuel, vehicle, type FROM `fishing_simulator_vehicles` WHERE user_id = @user_id AND id = @id",
                    H
                )
                if Q then
                    if Q[1] then
                        if Q[1].fuel < 90 then
                            if Q[1].fuel < 0 then
                                Q[1].fuel = 0
                            end
                            H = Config.available_items_store[Q[1].type][Q[1].vehicle]
                            if H then
                                if tryGetFisherMoney(D, H.refuel_price * math.floor(100 - Q[1].fuel), true) then
                                    M = {}
                                    M["@user_id"] = D
                                    M["@id"] = a5.vehicle_id
                                    Utils.Database.execute(
                                        "UPDATE `fishing_simulator_vehicles` SET fuel = 100 WHERE user_id = @user_id AND id = @id",
                                        M
                                    )
                                    T, U = Utils.translate("vehicle_refueled")
                                    TriggerClientEvent("lc_fishing_simulator:Notify", w, "success", T, U)
                                    openUI(w, true)
                                else
                                    S, T, U = Utils.translate("insufficient_money")
                                    TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", S, T, U)
                                end
                            else
                                M, S, T, U = Utils.translate("vehicle_not_found")
                                TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", M, S, T, U)
                            end
                        else
                            K, L, M, S, T, U = Utils.translate("vehicle_already_refueled")
                            TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", K, L, M, S, T, U)
                        end
                    end
                else
                    K, L, M, S, T, U = Utils.translate("vehicle_not_found")
                    TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", K, L, M, S, T, U)
                end
            end
        )
    end
)
RegisterServerEvent("lc_fishing_simulator:spawnVehicle")
AddEventHandler(
    "lc_fishing_simulator:spawnVehicle",
    function(N, a5)
        local w, x, y, z
        w = source
        Wrapper(
            w,
            function(D)
                local P, Q, R, H, I, J, K, L, M, S
                H = {}
                H["@user_id"] = D
                H["@id"] = a5.vehicle_id
                Q =
                    Utils.Database.fetchAll(
                    "SELECT * FROM `fishing_simulator_vehicles` WHERE user_id = @user_id AND id = @id",
                    H
                )
                if Q then
                    if Q[1] then
                        if not i[a5.vehicle_id] then
                            if Q[1].health > 200 then
                                if Config.available_items_store[Q[1].type][Q[1].vehicle] then
                                    if "vehicle" == Q[1].type then
                                        TriggerClientEvent(
                                            "lc_fishing_simulator:spawnVehicle",
                                            w,
                                            Q[1],
                                            Config.fishing_locations[N].garage_locations,
                                            nil,
                                            Config.vehicle_blips.vehicle
                                        )
                                    else
                                        TriggerClientEvent(
                                            "lc_fishing_simulator:spawnVehicle",
                                            w,
                                            Q[1],
                                            Config.fishing_locations[N].boat_garage_locations,
                                            Config.fishing_locations[N].boat_teleport_location,
                                            Config.vehicle_blips.boat
                                        )
                                    end
                                else
                                    L, M, S = Utils.translate("vehicle_not_found")
                                    TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", L, M, S)
                                end
                            else
                                K, L, M, S = Utils.translate("vehicle_damaged")
                                TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", K, L, M, S)
                            end
                        else
                            K, L, M, S = Utils.translate("vehicle_already_spawned")
                            TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", K, L, M, S)
                        end
                    end
                else
                    K, L, M, S = Utils.translate("vehicle_not_found")
                    TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", K, L, M, S)
                end
            end
        )
    end
)
RegisterServerEvent("lc_fishing_simulator:setVehicleSpawned")
AddEventHandler(
    "lc_fishing_simulator:setVehicleSpawned",
    function(N, a5)
        local w
        if a5 then
            i[N] = nil
        else
            i[N] = true
        end
    end
)
RegisterServerEvent("lc_fishing_simulator:updateVehicleStatus")
AddEventHandler(
    "lc_fishing_simulator:updateVehicleStatus",
    function(N, a5, a7, a8, a9)
        local z, A, B, C, aa, ab, ac
        if N.id then
            if a9 then
                aa = {}
                aa["@traveled_distance"] = N.traveled_distance
                aa["@health"] = math.floor((a5 + a7) / 2)
                aa["@fuel"] = a8
                aa["@properties"] = json.encode(a9)
                aa["@id"] = N.id
                Utils.Database.execute(
                    "UPDATE `fishing_simulator_vehicles` SET traveled_distance = @traveled_distance, health = @health, fuel = @fuel, properties = @properties WHERE id = @id",
                    aa
                )
            else
                aa = {}
                aa["@traveled_distance"] = N.traveled_distance
                aa["@health"] = math.floor((a5 + a7) / 2)
                aa["@fuel"] = a8
                aa["@id"] = N.id
                Utils.Database.execute(
                    "UPDATE `fishing_simulator_vehicles` SET traveled_distance = @traveled_distance, health = @health, fuel = @fuel WHERE id = @id",
                    aa
                )
            end
        end
    end
)
RegisterServerEvent("lc_fishing_simulator:sellVehicle")
AddEventHandler(
    "lc_fishing_simulator:sellVehicle",
    function(N, a5)
        local w, x, y, z
        w = source
        Wrapper(
            w,
            function(D)
                local P, Q, R, H, I, J, K, L, M, S, T, U
                H = {}
                H["@user_id"] = D
                H["@id"] = a5.vehicle_id
                Q =
                    Utils.Database.fetchAll(
                    "SELECT health, vehicle, type FROM `fishing_simulator_vehicles` WHERE user_id = @user_id AND id = @id",
                    H
                )
                if Q then
                    if Q[1] then
                        if Q[1].health > 900 then
                            R = Config.available_items_store[Q[1].type][Q[1].vehicle]
                            if R then
                                H = Utils.Math.round(R.price * Config.vehicle_sell_price_multiplier, 2)
                                giveFisherMoney(D, H)
                                L = {}
                                L["@user_id"] = D
                                L["@id"] = a5.vehicle_id
                                Utils.Database.execute(
                                    "DELETE FROM `fishing_simulator_vehicles` WHERE user_id = @user_id AND id = @id",
                                    L
                                )
                                S = Utils.translate("vehicle_sold")
                                S, T, U = S.format(S, H)
                                TriggerClientEvent("lc_fishing_simulator:Notify", w, "success", S, T, U)
                                openUI(w, true)
                            else
                                L, M, S, T, U = Utils.translate("vehicle_not_found")
                                TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", L, M, S, T, U)
                            end
                        else
                            K, L, M, S, T, U = Utils.translate("vehicle_damaged")
                            TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", K, L, M, S, T, U)
                        end
                    end
                else
                    K, L, M, S, T, U = Utils.translate("vehicle_not_found")
                    TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", K, L, M, S, T, U)
                end
            end
        )
    end
)
RegisterServerEvent("lc_fishing_simulator:buyProperty")
AddEventHandler(
    "lc_fishing_simulator:buyProperty",
    function(N, a5)
        local w, x, y, z
        w = source
        Wrapper(
            w,
            function(D)
                local P, Q, R, H, I, J, K, L, M, S, T, U, V, W, X, Y
                P = Config.available_items_store[a5.type][a5.property_id].price
                if beforeBuyProperty(w, a5.property_id, P, D) then
                    if tryGetFisherMoney(D, P, true) then
                        I = {}
                        I["@user_id"] = D
                        I["@property"] = a5.property_id
                        I["@stock"] = json.encode({})
                        Utils.Database.execute(
                            "INSERT INTO `fishing_simulator_properties` (user_id, property, stock) VALUES (@user_id, @property, @stock);",
                            I
                        )
                        K, L, M, S, T, U, V, W, X, Y = Utils.translate("property_purchased")
                        TriggerClientEvent("lc_fishing_simulator:Notify", w, "success", K, L, M, S, T, U, V, W, X, Y)
                        I = Utils.translate("logs_buy_property")
                        I, J, K, L, M, S, T, U, V, W, X, Y =
                            I.format(
                            I,
                            D,
                            a5.property_id,
                            P,
                            Utils.Framework.getPlayerIdLog(w) ..
                                os.date(
                                    [[

[]] ..
                                        Utils.translate("logs_date") ..
                                            "]: %d/%m/%Y [" .. Utils.translate("logs_hour") .. "]: %H:%M:%S"
                                )
                        )
                        Utils.Webhook.sendWebhookMessage(WebhookURL, I, J, K, L, M, S, T, U, V, W, X, Y)
                        openUI(w, true)
                    else
                        J, K, L, M, S, T, U, V, W, X, Y = Utils.translate("insufficient_money")
                        TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", J, K, L, M, S, T, U, V, W, X, Y)
                    end
                end
            end
        )
    end
)
RegisterServerEvent("lc_fishing_simulator:repairProperty")
AddEventHandler(
    "lc_fishing_simulator:repairProperty",
    function(N, a5)
        local w, x, y, z
        w = source
        Wrapper(
            w,
            function(D)
                local P, Q, R, H, I, J, K, L, M, S, T, U
                H = {}
                H["@user_id"] = D
                H["@id"] = a5.property_id
                Q =
                    Utils.Database.fetchAll(
                    "SELECT property_condition, property FROM `fishing_simulator_properties` WHERE user_id = @user_id AND id = @id",
                    H
                )
                if Q then
                    if Q[1] then
                        if Q[1].property_condition < 900 then
                            if Q[1].property_condition < 0 then
                                Q[1].property_condition = 0
                            end
                            H = Config.available_items_store.property[Q[1].property]
                            if H then
                                if tryGetFisherMoney(D, H.repair_price * (100 - Q[1].property_condition), true) then
                                    M = {}
                                    M["@user_id"] = D
                                    M["@id"] = a5.property_id
                                    Utils.Database.execute(
                                        "UPDATE `fishing_simulator_properties` SET property_condition = 100 WHERE user_id = @user_id AND id = @id",
                                        M
                                    )
                                    T, U = Utils.translate("property_repaired")
                                    TriggerClientEvent("lc_fishing_simulator:Notify", w, "success", T, U)
                                    openUI(w, true)
                                else
                                    S, T, U = Utils.translate("insufficient_money")
                                    TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", S, T, U)
                                end
                            else
                                M, S, T, U = Utils.translate("property_not_found")
                                TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", M, S, T, U)
                            end
                        else
                            K, L, M, S, T, U = Utils.translate("property_already_repaired")
                            TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", K, L, M, S, T, U)
                        end
                    end
                else
                    K, L, M, S, T, U = Utils.translate("property_not_found")
                    TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", K, L, M, S, T, U)
                end
            end
        )
    end
)
RegisterServerEvent("lc_fishing_simulator:sellProperty")
AddEventHandler(
    "lc_fishing_simulator:sellProperty",
    function(N, a5)
        local w, x, y, z
        w = source
        Wrapper(
            w,
            function(D)
                local P, Q, R, H, I, J, K, L, M, S, T, U
                H = {}
                H["@user_id"] = D
                H["@id"] = a5.property_id
                Q =
                    Utils.Database.fetchAll(
                    "SELECT property FROM `fishing_simulator_properties` WHERE user_id = @user_id AND id = @id",
                    H
                )
                if Q then
                    if Q[1] then
                        R = Config.available_items_store.property[Q[1].property]
                        if R then
                            H = Utils.Math.round(R.price * Config.property_sell_price_multiplier, 2)
                            giveFisherMoney(D, H)
                            L = {}
                            L["@id"] = a5.property_id
                            Utils.Database.execute("DELETE FROM `fishing_simulator_properties` WHERE id = @id;", L)
                            S = Utils.translate("property_sold")
                            S, T, U = S.format(S, H)
                            TriggerClientEvent("lc_fishing_simulator:Notify", w, "success", S, T, U)
                            openUI(w, true)
                        end
                    end
                else
                    K, L, M, S, T, U = Utils.translate("property_not_found")
                    TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", K, L, M, S, T, U)
                end
            end
        )
    end
)
RegisterServerEvent("lc_fishing_simulator:withdrawMoney")
AddEventHandler(
    "lc_fishing_simulator:withdrawMoney",
    function(N, a5)
        local w, x, y, z
        w = source
        Wrapper(
            w,
            function(D)
                local P, Q, R, H, I, J, K, L, M, S, T, U, V, W, X
                H = {}
                H["@user_id"] = D
                Q = Utils.Database.fetchAll("SELECT * FROM `fishing_simulator_loans` WHERE user_id = @user_id", H)[1]
                if Q then
                    if Q.remaining_amount then
                        if not (Q.remaining_amount <= 0) then
                            local K, L, M, S, T, U, V, W, X = Utils.translate("pay_loans")
                            TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", K, L, M, S, T, U, V, W, X)
                            return
                        end
                    end
                end
                H = tonumber(a5.amount)
                if not H then
                    H = 0
                end
                R = Utils.Math.round(H, 2)
                if R and R > 0 then
                    if tryGetFisherMoney(D, R, false) then
                        K, L, M, S, T, U, V, W, X = getAccount()
                        Utils.Framework.giveAccountMoney(w, R, K, L, M, S, T, U, V, W, X)
                        L, M, S, T, U, V, W, X = Utils.translate("money_withdrawn")
                        TriggerClientEvent("lc_fishing_simulator:Notify", w, "success", L, M, S, T, U, V, W, X)
                        J = Utils.translate("logs_withdraw")
                        J, K, L, M, S, T, U, V, W, X =
                            J.format(
                            J,
                            R,
                            Utils.Framework.getPlayerIdLog(w) ..
                                os.date(
                                    [[

[]] ..
                                        Utils.translate("logs_date") ..
                                            "]: %d/%m/%Y [" .. Utils.translate("logs_hour") .. "]: %H:%M:%S"
                                )
                        )
                        Utils.Webhook.sendWebhookMessage(WebhookURL, J, K, L, M, S, T, U, V, W, X)
                        openUI(w, true)
                    end
                else
                    L, M, S, T, U, V, W, X = Utils.translate("insufficient_money")
                    TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", L, M, S, T, U, V, W, X)
                end
            end
        )
    end
)

RegisterServerEvent("lc_fishing_simulator:depositMoney")
AddEventHandler(
    "lc_fishing_simulator:depositMoney",
    function(N, a5)
        local w, x, y, z
        w = source
        Wrapper(
            w,
            function(D)
                local P, Q, R, H, I, J, K, L, M, S, T, U, V
                Q = tonumber(a5.amount)
                if not Q then
                    Q = 0
                end
                P = Utils.Math.round(Q, 2)
                if P and P > 0 then
                    I, J, K, L, M, S, T, U, V = getAccount()
                    if Utils.Framework.tryRemoveAccountMoney(w, P, I, J, K, L, M, S, T, U, V) then
                        giveFisherMoney(D, P)
                        J, K, L, M, S, T, U, V = Utils.translate("money_deposited")
                        TriggerClientEvent("lc_fishing_simulator:Notify", w, "success", J, K, L, M, S, T, U, V)
                        H = Utils.translate("logs_deposit")
                        H, I, J, K, L, M, S, T, U, V =
                            H.format(
                            H,
                            P,
                            Utils.Framework.getPlayerIdLog(w) ..
                                os.date(
                                    [[

[]] ..
                                        Utils.translate("logs_date") ..
                                            "]: %d/%m/%Y [" .. Utils.translate("logs_hour") .. "]: %H:%M:%S"
                                )
                        )
                        Utils.Webhook.sendWebhookMessage(WebhookURL, H, I, J, K, L, M, S, T, U, V)
                        openUI(w, true)
                    else
                        J, K, L, M, S, T, U, V = Utils.translate("insufficient_money")
                        TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", J, K, L, M, S, T, U, V)
                    end
                else
                    J, K, L, M, S, T, U, V = Utils.translate("invalid_value")
                    TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", J, K, L, M, S, T, U, V)
                end
            end
        )
    end
)

RegisterServerEvent("lc_fishing_simulator:loan")
AddEventHandler(
    "lc_fishing_simulator:loan",
    function(N, a5)
        local w, x, y, z
        w = source
        Wrapper(
            w,
            function(D)
                local P, Q, R, H, I, J, K, L, M, S, T, U
                if Config.disable_loans then
                    return
                end
                P = Config.loans.plans[a5.loan_id + 1]
                I = {}
                I["@user_id"] = D
                H = 0
                I, J, K, L =
                    pairs(
                    Utils.Database.fetchAll("SELECT * FROM `fishing_simulator_loans` WHERE user_id = @user_id", I)
                )
                for M, S in I, J, K, L do
                    H = H + tonumber(S.loan)
                end
                I = tonumber(a5.loan_id)
                if not I then
                    I = 0
                end
                a5.loan_id = I
                if H + P.loan_amount <= getMaxLoan(D) then
                    L = {}
                    L["@user_id"] = D
                    L["@loan"] = P.loan_amount
                    L["@remaining_amount"] = P.loan_amount
                    L["@day_cost"] = calculateDailyPayment(P)
                    L["@taxes_on_day"] = math.ceil(P.loan_amount / P.repayment_days)
                    L["@timer"] = os.time()
                    Utils.Database.execute(
                        "INSERT INTO `fishing_simulator_loans` (user_id,loan,remaining_amount,day_cost,taxes_on_day,timer) VALUES (@user_id,@loan,@remaining_amount,@day_cost,@taxes_on_day,@timer);",
                        L
                    )
                    giveFisherMoney(D, P.loan_amount)
                    S, T, U = Utils.translate("loan")
                    TriggerClientEvent("lc_fishing_simulator:Notify", w, "success", S, T, U)
                    openUI(w, true)
                else
                    M, S, T, U = Utils.translate("no_loan")
                    TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", M, S, T, U)
                end
            end
        )
    end
)
calculateDailyPayment = function(N)
    local v, w, x
    return (N.loan_amount + N.loan_amount * N.interest_rate / 100) / N.repayment_days
end
RegisterServerEvent("lc_fishing_simulator:payLoan")
AddEventHandler(
    "lc_fishing_simulator:payLoan",
    function(N, a5)
        local w, x, y, z
        w = source
        Wrapper(
            w,
            function(D)
                local P, Q, R, H, I, J, K, L, M
                H = {}
                H["@id"] = a5.loan_id
                Q = Utils.Database.fetchAll("SELECT * FROM `fishing_simulator_loans` WHERE id = @id", H)[1]
                if not Q then
                    return
                end
                if tryGetFisherMoney(D, Q.remaining_amount) then
                    J = {}
                    J["@id"] = a5.loan_id
                    Utils.Database.execute("DELETE FROM `fishing_simulator_loans` WHERE id = @id;", J)
                    L, M = Utils.translate("loan_paid")
                    TriggerClientEvent("lc_fishing_simulator:Notify", w, "success", L, M)
                    openUI(w, true)
                else
                    K, L, M = Utils.translate("insufficient_money")
                    TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", K, L, M)
                end
            end
        )
    end
)
RegisterServerEvent("lc_fishing_simulator:withdrawItem")
AddEventHandler(
    "lc_fishing_simulator:withdrawItem",
    function(N, a5)
        local w, x, y, z
        w = source
        Wrapper(
            w,
            function(D)
                local P, Q, R, H, I, J, K, L, M, S, T
                H = {}
                H["@property"] = a5.property
                H["@user_id"] = D
                Q =
                    Utils.Database.fetchAll(
                    "SELECT stock FROM `fishing_simulator_properties` WHERE property = @property and user_id = @user_id",
                    H
                )
                if Q then
                    if Q[1] then
                        if Config.fishes_available[a5.item] then
                            I = tonumber(a5.amount)
                            if not I then
                                I = 0
                            end
                            a5.amount = math.floor(I)
                            H = json.decode(Q[1].stock)
                            if a5.amount > 0 then
                                if H[a5.item] then
                                    if H[a5.item] - a5.amount >= 0 then
                                        if Utils.Framework.givePlayerItem(w, a5.item, a5.amount) then
                                            H[a5.item] = H[a5.item] - a5.amount
                                            if 0 == H[a5.item] then
                                                H[a5.item] = nil
                                            end
                                            L = {}
                                            L["@stock"] = json.encode(H)
                                            L["@property"] = a5.property
                                            L["@user_id"] = D
                                            Utils.Database.execute(
                                                "UPDATE `fishing_simulator_properties` SET stock = @stock WHERE property = @property and user_id = @user_id",
                                                L
                                            )
                                            S, T = Utils.translate("stock_item_withdrawn")
                                            TriggerClientEvent("lc_fishing_simulator:Notify", w, "success", S, T)
                                            openPropertyUI(w, a5.property)
                                        else
                                            M, S, T = Utils.translate("cant_carry_item")
                                            TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", M, S, T)
                                        end
                                    end
                                end
                            else
                                M, S, T = Utils.translate("invalid_value")
                                TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", M, S, T)
                            end
                        else
                            L, M, S, T = Utils.translate("stock_cannot_withdraw")
                            TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", L, M, S, T)
                        end
                    end
                end
            end
        )
    end
)
RegisterServerEvent("lc_fishing_simulator:depositItem")
AddEventHandler(
    "lc_fishing_simulator:depositItem",
    function(N, a5)
        local w, x, y, z
        w = source
        Wrapper(
            w,
            function(D)
                local P, Q, R, H, I, J, K, L, M, S, T, U, V, W
                H = {}
                H["@property"] = a5.property
                H["@user_id"] = D
                Q =
                    Utils.Database.fetchAll(
                    "SELECT stock FROM `fishing_simulator_properties` WHERE property = @property and user_id = @user_id",
                    H
                )
                if Q then
                    if Q[1] then
                        H = tonumber(a5.amount)
                        if not H then
                            H = 0
                        end
                        a5.amount = math.floor(H)
                        R = json.decode(Q[1].stock)
                        if a5.amount > 0 then
                            J = Config.fishes_available[a5.item]
                            if J then
                                if getMaxStock(a5.property) >= getStockWeight(R) + a5.amount * J.weight then
                                    if Utils.Framework.getPlayerItem(w, a5.item, a5.amount) then
                                        if not R then
                                            R = {}
                                        end
                                        if not R[a5.item] then
                                            R[a5.item] = 0
                                        end
                                        R[a5.item] = R[a5.item] + a5.amount
                                        S = {}
                                        S["@property"] = a5.property
                                        S["@user_id"] = D
                                        S["@stock"] = json.encode(R)
                                        Utils.Database.execute(
                                            "UPDATE `fishing_simulator_properties` SET stock = @stock , property = @property , user_id = @user_id WHERE property = @property and user_id = @user_id",
                                            S
                                        )
                                        U, V, W = Utils.translate("stock_item_deposited")
                                        TriggerClientEvent("lc_fishing_simulator:Notify", w, "success", U, V, W)
                                        openPropertyUI(w, a5.property)
                                    else
                                        T = Utils.translate("dont_have_item")
                                        T, U, V, W = T.format(T, a5.amount, J.name)
                                        TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", T, U, V, W)
                                    end
                                else
                                    T, U, V, W = Utils.translate("stock_property_full")
                                    TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", T, U, V, W)
                                end
                            end
                        else
                            L, M, S, T, U, V, W = Utils.translate("invalid_value")
                            TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", L, M, S, T, U, V, W)
                        end
                    end
                end
            end
        )
    end
)
RegisterServerEvent("lc_fishing_simulator:sellFish")
AddEventHandler(
    "lc_fishing_simulator:sellFish",
    function(N, a5)
        local w, x, y, z
        w = source
        Wrapper(
            w,
            function(D)
                local P, Q, R, H, I, J, K, L, M, S, T, U, V, W, X, Y, Z, _, a0, a1, a2, a3
                Q = tonumber(a5.amount)
                if not Q then
                    Q = 0
                end
                P = math.floor(Q)
                if P <= 0 then
                    J, K, L, M, S, T, U, V, W, X, Y, Z, _, a0, a1, a2, a3 = Utils.translate("invalid_value")
                    TriggerClientEvent(
                        "lc_fishing_simulator:Notify",
                        w,
                        "error",
                        J,
                        K,
                        L,
                        M,
                        S,
                        T,
                        U,
                        V,
                        W,
                        X,
                        Y,
                        Z,
                        _,
                        a0,
                        a1,
                        a2,
                        a3
                    )
                    return
                end
                Q = Config.fish_stores[N]
                if not Q then
                    return
                end
                R = Config.fishes_available[a5.fish_id]
                if not R then
                    if "others" == a5.area then
                        R = Q.items_to_sell[a5.fish_id]
                        if not R then
                            return
                        end
                    end
                end
                H = GetPlayerPed(w)
                if not H then
                    return
                end
                if #(GetEntityCoords(H) - vector3(Q.menu_location[1], Q.menu_location[2], Q.menu_location[3])) > 10.0 then
                    return
                end
                K = R.sale_value * P
                if Utils.Framework.getPlayerItem(w, a5.fish_id, P) then
                    Utils.Framework.giveAccountMoney(w, K, Q.account)
                    U = Utils.translate("fish_store_sold")
                    U, V, W, X, Y, Z, _, a0, a1, a2, a3 = U.format(U, P, R.name)
                    TriggerClientEvent("lc_fishing_simulator:Notify", w, "success", U, V, W, X, Y, Z, _, a0, a1, a2, a3)
                    T = {}
                    T["@amount"] = K
                    T["@user_id"] = D
                    Utils.Database.execute(
                        "UPDATE `fishing_simulator_users` SET total_money_earned = total_money_earned + @amount WHERE user_id = @user_id",
                        T
                    )
                    T = Utils.translate("logs_fish_sold")
                    T, U, V, W, X, Y, Z, _, a0, a1, a2, a3 =
                        T.format(
                        T,
                        a5.fish_id,
                        P,
                        K,
                        Utils.Framework.getPlayerIdLog(w) ..
                            os.date(
                                [[

[]] ..
                                    Utils.translate("logs_date") ..
                                        "]: %d/%m/%Y [" .. Utils.translate("logs_hour") .. "]: %H:%M:%S"
                            )
                    )
                    Utils.Webhook.sendWebhookMessage(WebhookURL, T, U, V, W, X, Y, Z, _, a0, a1, a2, a3)
                else
                    U = Utils.translate("fish_store_not_enough")
                    U, V, W, X, Y, Z, _, a0, a1, a2, a3 = U.format(U, P, R.name)
                    TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", U, V, W, X, Y, Z, _, a0, a1, a2, a3)
                end
            end
        )
    end
)

RegisterServerEvent("lc_fishing_simulator:sellAllFishes")
AddEventHandler(
    "lc_fishing_simulator:sellAllFishes",
    function(N, a5)
        local w, x, y, z
        w = source
        Wrapper(
            w,
            function(D)
                local P, Q, R, H, I, J, K, L, M, S, T, U, V, W, X, Y, Z, _, a0, a1, a2, a3, a4, af, ag, ah, ai, aj, ak
                P = Config.fish_stores[N]
                if not P then
                    return
                end
                Q = GetPlayerPed(w)
                if not Q then
                    return
                end
                if #(GetEntityCoords(Q) - vector3(P.menu_location[1], P.menu_location[2], P.menu_location[3])) > 10.0 then
                    return
                end
                I = Utils.Framework.getPlayerInventory(w)
                if not I then
                    return
                end
                J = {}
                K, L, M, S = pairs(I)
                for T, U in K, L, M, S do
                    if U.name then
                        if U.amount then
                            if U.amount > 0 then
                                if Config.fishes_available[U.name] then
                                    J[U.name] = tonumber(U.amount)
                                end
                            end
                        end
                    end
                end
                K = 0
                L = {}
                M, S, T, U = pairs(P.fishes_to_sell)
                for V, W in M, S, T, U do
                    X = J[W]
                    if X and X > 0 then
                        if Utils.Framework.getPlayerItem(w, W, X) then
                            Y = Config.fishes_available[W].sale_value * X
                            K = K + Y
                            a0 = {}
                            a0.fish = W
                            a0.amount = X
                            a0.price = Y
                            table.insert(L, a0)
                        end
                    end
                end
                if K > 0 then
                    Utils.Framework.giveAccountMoney(w, K, P.account)
                    V = Utils.translate("fish_store_all_sold")
                    V, W, X, Y, Z, _, a0, a1, a2, a3, a4, af, ag, ah, ai, aj, ak = V.format(V, K)
                    TriggerClientEvent(
                        "lc_fishing_simulator:Notify",
                        w,
                        "success",
                        V,
                        W,
                        X,
                        Y,
                        Z,
                        _,
                        a0,
                        a1,
                        a2,
                        a3,
                        a4,
                        af,
                        ag,
                        ah,
                        ai,
                        aj,
                        ak
                    )
                    U = {}
                    U["@amount"] = K
                    U["@user_id"] = D
                    Utils.Database.execute(
                        "UPDATE `fishing_simulator_users` SET total_money_earned = total_money_earned + @amount WHERE user_id = @user_id",
                        U
                    )
                    S, T, U, V = ipairs(L)
                    for W, X in S, T, U, V do
                        _ = Utils.translate("logs_fish_sold")
                        _, a0, a1, a2, a3, a4, af, ag, ah, ai, aj, ak =
                            _.format(
                            _,
                            X.fish,
                            X.amount,
                            X.price,
                            Utils.Framework.getPlayerIdLog(w) ..
                                os.date(
                                    [[

[]] ..
                                        Utils.translate("logs_date") ..
                                            "]: %d/%m/%Y [" .. Utils.translate("logs_hour") .. "]: %H:%M:%S"
                                )
                        )
                        Utils.Webhook.sendWebhookMessage(WebhookURL, _, a0, a1, a2, a3, a4, af, ag, ah, ai, aj, ak)
                    end
                else
                    V, W, X, Y, Z, _, a0, a1, a2, a3, a4, af, ag, ah, ai, aj, ak =
                        Utils.translate("fish_store_nothing_sold")
                    TriggerClientEvent(
                        "lc_fishing_simulator:Notify",
                        w,
                        "error",
                        V,
                        W,
                        X,
                        Y,
                        Z,
                        _,
                        a0,
                        a1,
                        a2,
                        a3,
                        a4,
                        af,
                        ag,
                        ah,
                        ai,
                        aj,
                        ak
                    )
                end
            end
        )
    end
)
RegisterServerEvent("lc_fishing_simulator:changeTheme")
AddEventHandler(
    "lc_fishing_simulator:changeTheme",
    function(N, a5)
        local w, x, y, z
        w = source
        e[w] = nil
        Wrapper(
            w,
            function(D)
                local P, Q, R, H, I, J, K
                H = {}
                H["@user_id"] = D
                if
                    nil ==
                        Utils.Database.fetchAll("SELECT * FROM `fishing_simulator_users` WHERE user_id = @user_id", H)[1]
                 then
                    J = {}
                    J["@dark_theme"] = a5.dark_theme
                    J["@user_id"] = D
                    Utils.Database.execute(
                        "INSERT INTO `fishing_simulator_users` (user_id,dark_theme) VALUES (@user_id,@dark_theme);",
                        J
                    )
                else
                    J = {}
                    J["@dark_theme"] = a5.dark_theme
                    J["@user_id"] = D
                    Utils.Database.execute(
                        "UPDATE `fishing_simulator_users` SET dark_theme = @dark_theme WHERE user_id = @user_id",
                        J
                    )
                end
            end
        )
    end
)
RegisterServerEvent("lc_fishing_simulator:joinTournament")
AddEventHandler(
    "lc_fishing_simulator:joinTournament",
    function(N, a5)
        local w, x, y, z
        w = source
        Wrapper(
            w,
            function(D)
                local P, Q, R, H, I, J, K, L, M, S, T
                H = {}
                H["@timestamp"] = a5.startTimeUnix
                Q =
                    Utils.Database.fetchAll(
                    "SELECT id, location FROM `fishing_simulator_tournaments` WHERE timestamp = @timestamp",
                    H
                )[1]
                if Q then
                    J = {}
                    J["@user_id"] = D
                    J["@tournament_id"] = Q.id
                    if
                        nil ==
                            Utils.Database.fetchAll(
                                "SELECT * FROM `fishing_simulator_tournaments_users` WHERE user_id = @user_id and tournament_id = @tournament_id",
                                J
                            )[1]
                     then
                        if tryGetFisherMoney(D, Config.fishing_tournaments.entry_fee, true) then
                            L = {}
                            L["@user_id"] = D
                            L["@tournament_id"] = Q.id
                            L["@user_name"] = Utils.Framework.getPlayerName(D)
                            Utils.Database.execute(
                                "INSERT INTO `fishing_simulator_tournaments_users` (user_id,tournament_id,user_name) VALUES (@user_id,@tournament_id,@user_name);",
                                L
                            )
                            S, T = Utils.translate("tournament_joined")
                            TriggerClientEvent("lc_fishing_simulator:Notify", w, "success", S, T)
                            M, S, T = json.decode(Q.location)
                            TriggerClientEvent("lc_fishing_simulator:createTournamentBlip", w, M, S, T)
                            openUI(w, true)
                        else
                            M, S, T = Utils.translate("insufficient_money")
                            TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", M, S, T)
                        end
                    else
                        M, S, T = Utils.translate("tournament_already_in")
                        TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", M, S, T)
                    end
                else
                    K, L, M, S, T = Utils.translate("tournament_not_available")
                    TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", K, L, M, S, T)
                end
            end
        )
    end
)
RegisterServerEvent("lc_fishing_simulator:seeTournamentLocation")
AddEventHandler(
    "lc_fishing_simulator:seeTournamentLocation",
    function(N, a5)
        local w, x, y, z
        w = source
        Wrapper(
            w,
            function(D)
                local P, Q, R, H, I, J, K, L, M, S
                H = {}
                H["@timestamp"] = a5.startTimeUnix
                Q =
                    Utils.Database.fetchAll(
                    "SELECT id, location FROM `fishing_simulator_tournaments` WHERE timestamp = @timestamp",
                    H
                )[1]
                if Q then
                    J = {}
                    J["@user_id"] = D
                    J["@tournament_id"] = Q.id
                    if
                        Utils.Database.fetchAll(
                            "SELECT * FROM `fishing_simulator_tournaments_users` WHERE user_id = @user_id and tournament_id = @tournament_id",
                            J
                        )[1]
                     then
                        M, S = Utils.translate("tournament_waypoint")
                        TriggerClientEvent("lc_fishing_simulator:Notify", w, "success", M, S)
                        L, M, S = json.decode(Q.location)
                        TriggerClientEvent("lc_fishing_simulator:createTournamentBlip", w, L, M, S)
                        TriggerClientEvent("lc_fishing_simulator:closeUI", w)
                    else
                        M, S = Utils.translate("tournament_not_in")
                        TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", M, S)
                    end
                else
                    K, L, M, S = Utils.translate("tournament_not_available")
                    TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", K, L, M, S)
                end
            end
        )
    end
)
Utils.Callback.RegisterServerCallback(
    "fishing_simulator:getTournamentScoreboard",
    function(N, a5, a7)
        local x, y, z
        Wrapper(
            N,
            function(D)
                local P, Q, R, H, I, J, K, L, M
                if not j then
                    I, J, K, L, M = Utils.translate("tournament_not_found")
                    TriggerClientEvent("lc_fishing_simulator:Notify", N, "error", I, J, K, L, M)
                    a5({})
                    return
                end
                P = json.decode(j.location)
                R, H, I, J, K, L, M = GetPlayerPed(N)
                if
                    #(GetEntityCoords(R, H, I, J, K, L, M) - vector3(P[1], P[2], P[3])) >
                        Config.fishing_tournaments.radius
                 then
                    L, M = Utils.translate("tournament_not_found")
                    TriggerClientEvent("lc_fishing_simulator:Notify", N, "error", L, M)
                    a5({})
                    return
                end
                K = {}
                K["@tournament_id"] = j.id
                a5(
                    Utils.Database.fetchAll(
                        "SELECT * FROM `fishing_simulator_tournaments_users` WHERE tournament_id = @tournament_id",
                        K
                    )
                )
            end
        )
    end
)
giveFisherMoney = function(N, a5, a7)
    local x, y, z, A, B
    if a5 and a5 > 0 then
        local src = Utils.Framework.getPlayerSource(N)
        Utils.Framework.giveAccountMoney(src, a5, "bank")
        -- A = {}
        -- A["@amount"] = a5
        -- A["@user_id"] = N
        -- Utils.Database.execute(
        --     "UPDATE `fishing_simulator_users` SET money = money + @amount WHERE user_id = @user_id",
        --     A
        -- )
        if a7 then
            B = {}
            B["@amount"] = a5
            B["@user_id"] = N
            Utils.Database.execute(
                "UPDATE `fishing_simulator_users` SET total_money_earned = total_money_earned + @amount WHERE user_id = @user_id",
                B
            )
        end
    end
end

tryGetFisherMoney = function(N, a5, a7)
    local src = Utils.Framework.getPlayerSource(N)
    -- p["@user_id"] = D
    -- n = Utils.Database.fetchAll("SELECT money FROM `trucker_users` WHERE user_id = @user_id", p)[1]
    if src then
        if Utils.Framework.tryRemoveAccountMoney(src, a5, "bank") then 
            B = {}
            B["@user_id"] = N
            if a7 then
                A = "UPDATE `fishing_simulator_users` SET total_money_spent = total_money_spent + @amount WHERE user_id = @user_id"
                B["@amount"] = a5
            end
            Utils.Database.execute(A, B)
            return true
        else
            return false
        end
    else
        return false
    end
end

-- tryGetFisherMoney = function(N, a5, a7)
--     local x, y, z, A, B, C, aa, ab
--     A = {}
--     A["@user_id"] = N
--     y = Utils.Database.fetchAll("SELECT money FROM `fishing_simulator_users` WHERE user_id = @user_id", A)[1]
--     if a5 > 0 and y then
--         if a5 <= tonumber(y.money) then
--             if Utils.Framework.tryRemoveAccountMoney(src, U, "bank") then 
--                 return true
--             else
--                 return false
--             end
--             B = {}
--             B["@user_id"] = N
--             if a7 then
--                 A = "UPDATE `fishing_simulator_users` SET total_money_spent = total_money_spent + @amount WHERE user_id = @user_id"
--                 B["@amount"] = a5
--             end
--             Utils.Database.execute(A, B)
--             return true
--         end
--     else
--         return false
--     end
-- end
Wrapper = function(N, a5)
    local w, x, y, z, A, B, C, aa, ab
    if d then
        if not b then
            goto al
        end
    end
    if b then
        TriggerClientEvent(
            "lc_fishing_simulator:Notify",
            N,
            "error",
            "The script requires 'lc_utils' in version " ..
                a ..
                    ", but you currently have version " ..
                        Utils.Version ..
                            ". Please update your 'lc_utils' script to the latest version: https://github.com/LeonardoSoares98/lc_utils/releases/latest/download/lc_utils.zip"
        )
    end
    do
        return
    end
    ::al::
    if nil == e[N] then
        e[N] = true
        w = Utils.Framework.getPlayerId(N)
        if w then
            a5(w)
        else
            print("User not found: " .. N)
        end
        SetTimeout(
            100,
            function()
                local O, P
                e[N] = nil
            end
        )
    end
end
getAccount = function()
    local u, v
    if Config.account then
        return Config.account.fisher
    else
        return nil
    end
end
getAmountOfVehicles = function(N)
    local v, w, x, y
    y = {}
    y["@user_id"] = N
    w = Utils.Database.fetchAll("SELECT COUNT(id) as qtd FROM `fishing_simulator_vehicles` WHERE user_id = @user_id", y)
    if w then
        if w[1] then
            return w[1].qtd
        end
    end
    return 0
end
getMaxGarageSlots = function(N)
    local v, w, x, y, z, A
    v = Config.max_garage_slots
    z = {}
    z["@user_id"] = N
    x =
        Utils.Database.fetchAll(
        "SELECT boats_upgrade, vehicles_upgrade FROM `fishing_simulator_users` WHERE user_id = @user_id",
        z
    )
    if x then
        if x[1] then
            y = Config.upgrades.boats[x[1].boats_upgrade]
            z = Config.upgrades.vehicles[x[1].vehicles_upgrade]
            if y then
                v = v + y.level_reward
            end
            if z then
                v = v + z.level_reward
            end
        end
    end
    return v
end
getStockWeight = function(N)
    local v, w, x, y, z, A, B, C, aa, ab, ac, am, an, ao
    if N then
        w, x, y, z = pairs(N)
        for A, B in w, x, y, z do
            C = Config.fishes_available[A]
            if C then
                v = 0 + C.weight * B
            else
                print(
                    "^8[" ..
                        GetCurrentResourceName() ..
                            "]^3 item ^1" ..
                                A ..
                                    "^3 is in a property stock but it is not configured in config, please add it in the config.^7"
                )
            end
        end
        return v
    end
    return 0
end
getStockAmount = function(N)
    local v, w, x, y, z, A, B, C
    v = 0
    w, x, y, z = pairs(N)
    for A, B in w, x, y, z do
        v = v + B
    end
    return v
end
getMaxStock = function(N)
    local v
    return Config.available_items_store.property[N].capacity
end
getMaxLoan = function(N)
    local v, w, x, y, z, A, B, C, aa
    v = 0
    x, y, z, A = pairs(Config.max_loan_per_level)
    for B, C in x, y, z, A do
        if B <= getPlayerLevel(N) then
            v = C
        end
    end
    return v
end
getPlayerLevel = function(N)
    local v, w, x, y, z, A, B, C, aa, ab, ac
    y = {}
    y["@user_id"] = N
    w = Utils.Database.fetchAll("SELECT exp FROM `fishing_simulator_users` WHERE user_id = @user_id", y)[1]
    x = 0
    if w then
        y, z, A, B = pairs(Config.required_xp_to_levelup)
        for C, aa in y, z, A, B do
            if aa <= tonumber(w.exp) then
                x = C
            else
                return x
            end
        end
    end
    return x
end
getNextTournamentData = function()
    local u, v, w, x, y, z, A, B, C, aa, ab, ac, am, an, ao, ap, aq, ar, as, at, au, av, aw, ax
    if false == Config.fishing_tournaments.enabled then
        return nil
    end
    u = os.time()
    v = os.date("*t", u)
    x = {}
    x[1] = "Sunday"
    x[2] = "Monday"
    x[3] = "Tuesday"
    x[4] = "Wednesday"
    x[5] = "Thursday"
    x[6] = "Friday"
    x[7] = "Saturday"
    y = nil
    for C = 0, 6, 1 do
        ab = x[(v.wday + C - 1) % 7 + 1]
        ac = Config.fishing_tournaments.schedule[ab]
        if ac then
            am, an, ao, ap = ipairs(ac)
            for aq, ar in am, an, ao, ap do
                at = u + ar[1] * 3600 + ar[2] * 60 - (v.hour * 3600 + v.min * 60 + v.sec) + C * 86400
                if at - u > 0 then
                    if at - u < Config.fishing_tournaments.alert_time_before_start * 3600 then
                        if nil ~= y then
                            if not (at < y.startTimeUnix) then
                                goto ay
                            end
                        end
                        au = {}
                        au.day = ab
                        au.isToday = 0 == C
                        au.startTime = os.date("%Y-%m-%d %H:%M:%S", at)
                        au.startTimeUnix = at
                        au.entryFee = Config.fishing_tournaments.entry_fee
                        au.duration = Config.fishing_tournaments.event_duration
                        au.prizes = Config.fishing_tournaments.prizes
                        au.fishValues = Config.fishing_tournaments.fish_values
                        y = au
                    end
                end
                ::ay::
            end
        end
    end
    A = 0
    while true do
        if not (false and 60 > A) then
            break
        end
        Wait(10)
    end
    if y then
        ab = {}
        ab["@timestamp"] = y.startTimeUnix
        C =
            Utils.Database.fetchAll(
            "SELECT id, location FROM `fishing_simulator_tournaments` WHERE timestamp = @timestamp",
            ab
        )[1]
        if not C then
            aa = Config.fishing_tournaments.locations[math.random(#Config.fishing_tournaments.locations)]
            an = {}
            an["@location"] = json.encode(aa)
            an["@timestamp"] = y.startTimeUnix
            Utils.Database.fetchAll(
                "INSERT INTO `fishing_simulator_tournaments` (location, timestamp) VALUES (@location, @timestamp);",
                an
            )
            y.location = aa
        else
            y.location = json.decode(C.location)
        end
    end
    return y
end
deleteAllUserData = function(N)
    local v, w, x, y, z, A, B, C
    y = {}
    y["@user_id"] = N
    Utils.Database.execute("DELETE FROM `fishing_simulator_users` WHERE user_id = @user_id;", y)
    z = {}
    z["@user_id"] = N
    Utils.Database.execute("DELETE FROM `fishing_simulator_fishes_caught` WHERE user_id = @user_id;", z)
    A = {}
    A["@user_id"] = N
    Utils.Database.execute("DELETE FROM `fishing_simulator_loans` WHERE user_id = @user_id;", A)
    B = {}
    B["@user_id"] = N
    Utils.Database.execute("DELETE FROM `fishing_simulator_properties` WHERE user_id = @user_id;", B)
    C = {}
    C["@user_id"] = N
    Utils.Database.execute("DELETE FROM `fishing_simulator_vehicles` WHERE user_id = @user_id;", C)
end
hasFisherJob = function(N)
    local v, w, x, y
    if "table" == type(Config.job) then
    end
    if "string" == type(Config.job) then
        x = {}
        x[1] = Config.job
        if Utils.Framework.hasJobs(N, x) then
            goto az
        end
    end
    v = Utils.Framework.hasJobs
    ::az::
    return nil == v or v
end
openUI = function(N, a5)
    local w, x, y, z, A, B, C, aa, ab, ac, am, an, ao, ap, aq, ar, as, at, au
    w = {}
    x = Utils.Framework.getPlayerId(N)
    if not onAccessLocation(N, x) then
        return
    end
    if hasFisherJob(N) then
        B = {}
        B["@user_id"] = x
        w.fishing_simulator_users =
            Utils.Database.fetchAll("SELECT * FROM `fishing_simulator_users` WHERE user_id = @user_id", B)[1]
        if nil == w.fishing_simulator_users then
            if beforeAccessLocation(N, x) then
                C = {}
                C["@user_id"] = x
                Utils.Database.execute("INSERT INTO `fishing_simulator_users` (user_id) VALUES (@user_id);", C)
                aa = {}
                aa["@user_id"] = x
                w.fishing_simulator_users =
                    Utils.Database.fetchAll("SELECT * FROM `fishing_simulator_users` WHERE user_id = @user_id", aa)[1]
            else
                return
            end
        else
            if 1 == w.fishing_simulator_users.loan_notify then
                aa, ab, ac, am, an, ao, ap, aq, ar, as, at, au = Utils.translate("no_loan_money")
                TriggerClientEvent(
                    "lc_fishing_simulator:Notify",
                    N,
                    "info",
                    aa,
                    ab,
                    ac,
                    am,
                    an,
                    ao,
                    ap,
                    aq,
                    ar,
                    as,
                    at,
                    au
                )
                deleteAllUserData(x)
                C = {}
                C["@user_id"] = x
                Utils.Database.execute("INSERT INTO `fishing_simulator_users` (user_id) VALUES (@user_id);", C)
                aa = {}
                aa["@user_id"] = x
                w.fishing_simulator_users =
                    Utils.Database.fetchAll("SELECT * FROM `fishing_simulator_users` WHERE user_id = @user_id", aa)[1]
            end
        end
        C = {}
        C["@user_id"] = x
        w.fishing_simulator_fishes_caught =
            Utils.Database.fetchAll("SELECT * FROM `fishing_simulator_fishes_caught` WHERE user_id = @user_id", C)
        aa = {}
        aa["@user_id"] = x
        w.fishing_simulator_available_contracts =
            Utils.Database.fetchAll(
            "SELECT * FROM `fishing_simulator_available_contracts` WHERE progress IS NULL OR progress = @user_id",
            aa
        )
        ab = {}
        ab["@user_id"] = x
        w.fishing_simulator_available_dives =
            Utils.Database.fetchAll(
            "SELECT * FROM `fishing_simulator_available_dives` WHERE progress IS NULL OR progress = @user_id",
            ab
        )
        ac = {}
        ac["@user_id"] = x
        w.fishing_simulator_loans =
            Utils.Database.fetchAll("SELECT * FROM `fishing_simulator_loans` WHERE user_id = @user_id", ac)
        am = {}
        am["@user_id"] = x
        w.fishing_simulator_vehicles =
            Utils.Database.fetchAll("SELECT * FROM `fishing_simulator_vehicles` WHERE user_id = @user_id", am)
        w.max_garage_slots = getMaxGarageSlots(x)
        an = {}
        an["@user_id"] = x
        w.fishing_simulator_properties =
            Utils.Database.fetchAll("SELECT * FROM `fishing_simulator_properties` WHERE user_id = @user_id", an)
        ac, am, an, ao = pairs(w.fishing_simulator_properties)
        for ap, aq in ac, am, an, ao do
            aq.stock = json.decode(aq.stock)
            if aq.stock then
                if getStockWeight(aq.stock) then
                    goto aA
                end
            end
            ::aA::
            aq.stock_weight = 0
        end
        w.player_inventory = {}
        am, an, ao, ap = pairs(Utils.Framework.getPlayerInventory(N))
        for aq, ar in am, an, ao, ap do
            if Config.fishes_available[ar.name] then
                table.insert(w.player_inventory, ar)
            end
        end
        w.next_tournament = getNextTournamentData()
        if w.next_tournament then
            w.next_tournament.joined = false
            ap = {}
            ap["@timestamp"] = w.next_tournament.startTimeUnix
            an =
                Utils.Database.fetchAll(
                "SELECT id, location FROM `fishing_simulator_tournaments` WHERE timestamp = @timestamp",
                ap
            )[1]
            if an then
                ar = {}
                ar["@user_id"] = x
                ar["@tournament_id"] = an.id
                if
                    Utils.Database.fetchAll(
                        "SELECT * FROM `fishing_simulator_tournaments_users` WHERE user_id = @user_id and tournament_id = @tournament_id",
                        ar
                    )[1]
                 then
                    w.next_tournament.joined = true
                end
            end
        end
        w.top_users = Utils.Framework.getTopFishers()
        ac, am, an, ao, ap, aq, ar, as, at, au = getAccount()
        w.fishing_simulator_users.money = Utils.Framework.getPlayerAccountMoney(N, ac, am, an, ao, ap, aq, ar, as, at, au)
        w.available_money = 0
        w.config = {}
        w.config.required_xp_to_levelup = Utils.Table.deepCopy(Config.required_xp_to_levelup)
        w.config.max_loan_per_level = Utils.Table.deepCopy(Config.max_loan_per_level)
        w.config.loans = Utils.Table.deepCopy(Config.loans)
        w.config.contracts = Utils.Table.deepCopy(Config.available_contracts.definitions)
        w.config.dives = Utils.Table.deepCopy(Config.available_dives.definitions)
        w.config.upgrades = Utils.Table.deepCopy(Config.upgrades)
        w.config.equipments_upgrades = Utils.Table.deepCopy(Config.equipments_upgrades)
        w.config.fishes_available = Utils.Table.deepCopy(Config.fishes_available)
        w.config.disable_loans = Config.disable_loans
        w.config.max_loan = getMaxLoan(x)
        w.config.player_level = getPlayerLevel(x)
        TriggerClientEvent("lc_fishing_simulator:open", N, w, a5)
        f[N] = true
    else
        C, aa, ab, ac, am, an, ao, ap, aq, ar, as, at, au = Utils.translate("no_permission")
        TriggerClientEvent("lc_fishing_simulator:Notify", N, "error", C, aa, ab, ac, am, an, ao, ap, aq, ar, as, at, au)
    end
end
openPropertyUI = function(N, a5)
    local w, x, y, z, A, B, C, aa, ab, ac, am, an, ao, ap, aq
    w = Utils.Framework.getPlayerId(N)
    x = {}
    B = {}
    B["@property"] = a5
    B["@user_id"] = w
    z =
        Utils.Database.fetchAll(
        "SELECT * FROM `fishing_simulator_properties` WHERE property = @property and user_id = @user_id",
        B
    )[1]
    if z then
        aa = {}
        aa["@user_id"] = w
        x.fishing_simulator_users =
            Utils.Database.fetchAll("SELECT * FROM `fishing_simulator_users` WHERE user_id = @user_id", aa)[1]
        if nil == x.fishing_simulator_users then
            return
        end
        x.config = {}
        x.config.player_level = getPlayerLevel(w)
        x.config.available_items_store = Utils.Table.deepCopy(Config.available_items_store)
        x.config.fishes_available = Utils.Table.deepCopy(Config.fishes_available)
        x.player_inventory = {}
        C, aa, ab, ac = pairs(Utils.Framework.getPlayerInventory(N))
        for am, an in C, aa, ab, ac do
            if Config.fishes_available[an.name] then
                table.insert(x.player_inventory, an)
            end
        end
        z.stock = json.decode(z.stock)
        if z.stock then
            if getStockWeight(z.stock) then
                goto aB
            end
        end
        ::aB::
        z.stock_weight = 0
        z.name = Config.available_items_store.property[z.property].name
        TriggerClientEvent("lc_fishing_simulator:openProperty", N, x, z)
    else
        ab, ac, am, an, ao, ap, aq = Utils.translate("property_not_owned")
        TriggerClientEvent("lc_fishing_simulator:Notify", N, "error", ab, ac, am, an, ao, ap, aq)
    end
end
openFishStoreUI = function(N, a5)
    local w, x, y, z, A, B, C, aa, ab, ac, am, an, ao, ap
    w = Utils.Framework.getPlayerId(N)
    x = {}
    B = {}
    B["@user_id"] = w
    x.fishing_simulator_users =
        Utils.Database.fetchAll("SELECT * FROM `fishing_simulator_users` WHERE user_id = @user_id", B)[1]
    if nil == x.fishing_simulator_users then
        if beforeAccessLocation(N, w) then
            C = {}
            C["@user_id"] = w
            Utils.Database.execute("INSERT INTO `fishing_simulator_users` (user_id) VALUES (@user_id);", C)
            aa = {}
            aa["@user_id"] = w
            x.fishing_simulator_users =
                Utils.Database.fetchAll("SELECT * FROM `fishing_simulator_users` WHERE user_id = @user_id", aa)[1]
        else
            return
        end
    end
    x.store_data = Utils.Table.deepCopy(Config.fish_stores[a5])
    x.fishes_available = Utils.Table.deepCopy(Config.fishes_available)
    x.player_level = getPlayerLevel(w)
    B, C, aa, ab, ac, am, an, ao, ap = getAccount()
    x.available_money = Utils.Framework.getPlayerAccountMoney(N, B, C, aa, ab, ac, am, an, ao, ap)
    x.items_in_inventory = {}
    A, B, C, aa = pairs(Utils.Framework.getPlayerInventory(N))
    for ab, ac in A, B, C, aa do
        if ac.name then
            if ac.amount then
                if ac.amount > 0 then
                    if not Config.fishes_available[ac.name] then
                        if not x.store_data.items_to_sell[ac.name] then
                            goto aC
                        end
                    end
                    x.items_in_inventory[ac.name] = tonumber(ac.amount)
                end
            end
        end
        ::aC::
    end
    TriggerClientEvent("lc_fishing_simulator:openStore", N, x)
end
p = {}
q = {}
Utils.Callback.RegisterServerCallback(
    "fishing_simulator:getDataFishing",
    function(N, a5, a7, rod_slot)
        local x = N
        Wrapper(x, function(D)
            if not isAreaValid(a7) then
                print("fishing_simulator:getDataFishing: Invalid area: " .. tostring(a7))
                return
            end
            if not hasFisherJob(x) then
                local msg = Utils.translate("no_permission")
                TriggerClientEvent("lc_fishing_simulator:Notify", x, "error", msg)
                return
            end

            -- Read equipment from rod metadata
            local rod_item = exports.ox_inventory:GetSlot(x, rod_slot)
            if not rod_item then
                TriggerClientEvent("lc_fishing_simulator:Notify", x, "error", Utils.translate("missing_equipments.rod"))
                return
            end

            -- Validate rod is a known rod type
            local rod_eq_config = Config.equipments_upgrades.rod and Config.equipments_upgrades.rod[rod_item.name]
            if not rod_eq_config then
                TriggerClientEvent("lc_fishing_simulator:Notify", x, "error", Utils.translate("missing_equipments.rod"))
                return
            end

            local metadata = rod_item.metadata or {}
            local equipment_types = { "hook", "line", "reel" }

            -- Validate all required equipment slots are filled
            local resolved_equipment = {
                rod = { item = rod_item.name, bonus = rod_eq_config.bonus }
            }

            for _, eq_type in ipairs(equipment_types) do
                local eq_item_name = metadata[eq_type]
                if not eq_item_name then
                    local msg = Utils.translate("missing_equipments." .. eq_type)
                    TriggerClientEvent("lc_fishing_simulator:Notify", x, "error", msg)
                    return
                end
                local eq_config = Config.equipments_upgrades[eq_type] and Config.equipments_upgrades[eq_type][eq_item_name]
                if not eq_config then
                    local msg = Utils.translate("missing_equipments." .. eq_type)
                    TriggerClientEvent("lc_fishing_simulator:Notify", x, "error", msg)
                    return
                end
                resolved_equipment[eq_type] = { item = eq_item_name, bonus = eq_config.bonus }
            end

            -- Validate bait separately (still consumed from inventory)
            local bait_found = false
            local bait_item_name = nil
            for bait_name, bait_data in pairs(Config.equipments_upgrades.bait or {}) do
                if Utils.Framework.playerHasItem(x, bait_name, 1) then
                    bait_found = true
                    bait_item_name = bait_name
                    resolved_equipment.bait = { item = bait_name, bonus = bait_data.bonus }
                    break
                end
            end

            if not bait_found then
                local msg = Utils.translate("missing_equipments.bait")
                TriggerClientEvent("lc_fishing_simulator:Notify", x, "error", msg)
                return
            end

            -- Consume bait
            Utils.Framework.getPlayerItem(x, bait_item_name, 1)

            local time_hook = getTimeToHook(resolved_equipment.hook.item)
            local time_bait = getTimeToBait(resolved_equipment.bait.item)

            p[x] = { time_hook = time_hook, time_bait = time_bait }

            -- Store resolved equipment for generateFish (replaces m[user_id])
            if not m[D] then m[D] = {} end
            m[D] = resolved_equipment

            local fishing_data = {}
            fishing_data.fishing_simulator_user = getDataFishing(D)
            fishing_data.selected_equipments = resolved_equipment
            fishing_data.time_hook = time_hook
            fishing_data.time_bait = time_bait
            a5(fishing_data)
        end)
    end
)
RegisterServerEvent("lc_fishing_simulator:setEquipment")
AddEventHandler("lc_fishing_simulator:setEquipment", function(N, a5, a7, a8)
    if a8 == "rod" then
        local src = source
        local rod_slots = exports.ox_inventory:Search(src, 'slots', a5)
        local rod_slot = nil
        if rod_slots and #rod_slots > 0 then
            for _, slot_data in ipairs(rod_slots) do
                if slot_data.slot == N then
                    rod_slot = slot_data.slot
                    break
                end
            end
            if not rod_slot then
                rod_slot = rod_slots[1].slot
            end
        end
        TriggerClientEvent("lc_fishing_simulator:startFishing", src, rod_slot or N)
    end
end)

RegisterServerEvent("lc_fishing_simulator:useEquipment")
AddEventHandler("lc_fishing_simulator:useEquipment", function(item_name, _unused, eq_type, eq_slot)
    local src = source
    local user_id = Utils.Framework.getPlayerId(src)
    if not user_id then return end

    if not eq_slot then return end

    local eq_config = Config.equipments_upgrades[eq_type] and Config.equipments_upgrades[eq_type][item_name]
    if not eq_config then return end

    if getPlayerLevel(user_id) < (eq_config.required_level or 0) then
        TriggerClientEvent("lc_fishing_simulator:Notify", src, "error", Utils.translate("not_enough_level"))
        return
    end

    local slot_data = exports.ox_inventory:GetSlot(src, eq_slot)
    if not slot_data or slot_data.name ~= item_name then return end

    local rod_list = {}
    for rod_item_name, _ in pairs(Config.equipments_upgrades.rod or {}) do
        local rod_slots = exports.ox_inventory:Search(src, 'slots', rod_item_name)
        if rod_slots and #rod_slots > 0 then
            for _, rod_slot_data in ipairs(rod_slots) do
                local meta = rod_slot_data.metadata or {}
                table.insert(rod_list, {
                    slot    = rod_slot_data.slot,
                    name    = rod_slot_data.name,
                    label   = rod_slot_data.label or rod_slot_data.name,
                    current = meta[eq_type],
                })
            end
        end
    end

    if #rod_list == 0 then
        TriggerClientEvent("lc_fishing_simulator:Notify", src, "error", Utils.translate("missing_equipments.rod"))
        return
    end

    TriggerClientEvent("lc_fishing_simulator:openAttachMenu", src, eq_type, item_name, eq_slot, rod_list)
end)
RegisterServerEvent("lc_fishing_simulator:fishingInitialized")
AddEventHandler(
    "lc_fishing_simulator:fishingInitialized",
    function()
        local u, v, w, x, y
        if not p[source] then
            print(
                "The user (" ..
                    Utils.Framework.getPlayerId(source) ..
                        ") has not started fishing but is initializing fishing minigame. Is this user trying to glitch something?"
            )
            return
        end
        p[source].time_start = os.time()
        p[source].started = true
    end
)
Utils.Callback.RegisterServerCallback(
    "fishing_simulator:generateFish",
    function(N, a5, a7)
        local x, y, z, A, B
        y = N
        Wrapper(
            y,
            function(D)
                local P, Q, R, H, I, J, K, L, M, S

                if not (p[y] and p[y].started) then
                    print(
                        "The user (" ..
                        D ..
                        ") has not started fishing but is generating a fish. Is this user trying to glitch something?"
                    )
                    return
                end

                Q = p[y].time_bait
                H = os.time() - p[y].time_start

                -- if Q > H or H > (Q + p[y].time_hook) * 1.5 then
                --     print(
                --         "The user (" ..
                --         D ..
                --         ") is ending the minigame before he is expected to. Is this user trying to glitch something?"
                --     )
                --     return
                -- end

                p[y] = nil

                if not isAreaValid(a7) then
                    K = a7
                    if not K then
                        K = "undefined"
                    end
                    print("lc_fishing_simulator:generateFish: Invalid area: " .. K)
                    return
                end
                if not hasFisherJob(y) then
                    M, S = Utils.translate("no_permission")
                    TriggerClientEvent("lc_fishing_simulator:Notify", y, "error", M, S)
                    return
                end
                J = generateFishToReceive(getDataFishing(D), a7)
                K = Config.fishes_available[J]
                K.id = J
                q[y] = J
                M = {}
                M.fish_data = K
                a5(M)
            end
        )
    end
)
RegisterServerEvent("lc_fishing_simulator:receiveFish")
AddEventHandler(
    "lc_fishing_simulator:receiveFish",
    function(N, a5)
        local w, x, y, z, A, B, C, aa, ab, ac, am, an, ao, ap, aq, ar, as, at, au
        w = source
        x = Utils.Framework.getPlayerId(w)
        y = q[w]
        if not y then
            B = N
            print(
                "Fish not found in lc_fishing_simulator:receiveFish(" ..
                    B .. ") for user: " .. x .. ". Is this user trying to glitch something?"
            )
            return
        end
        q[w] = nil
        if not isAreaValid(N) then
            B = N or B
            if not N then
                B = "undefined"
            end
            print("lc_fishing_simulator:receiveFish: Invalid area: " .. B)
            return
        end
        if not beforeReceiveFish(w, y, a5) then
            return
        end
        z = Config.fishes_available[y]
        giveplayerXp(x, z.exp)
        aa = {}
        aa["@user_id"] = x
        aa["@fish_rarity"] = z.rarity
        Utils.Database.execute(
            [[
		INSERT INTO `fishing_simulator_fishes_caught` (user_id, fish_rarity, amount)
		VALUES (@user_id, @fish_rarity, 1)
		ON DUPLICATE KEY UPDATE amount = amount + 1
	]],
            aa
        )
        if j then
            if j.id then
                B = json.decode(j.location)
                aa, ab, ac, am, an, ao, ap, aq, ar, as, at, au = GetPlayerPed(w)
                if
                    #(GetEntityCoords(aa, ab, ac, am, an, ao, ap, aq, ar, as, at, au) - vector3(B[1], B[2], B[3])) <
                        Config.fishing_tournaments.radius
                 then
                    an = {}
                    an["@user_id"] = x
                    an["@tournament_id"] = j.id
                    if
                        Utils.Database.fetchAll(
                            "SELECT * FROM `fishing_simulator_tournaments_users` WHERE user_id = @user_id and tournament_id = @tournament_id",
                            an
                        )[1]
                     then
                        am = Config.fishing_tournaments.fish_values[z.rarity]
                        if not am then
                            am = 1
                        end
                        aq = {}
                        aq["@user_id"] = x
                        aq["@tournament_id"] = j.id
                        aq["@catch"] = am
                        Utils.Database.execute(
                            "UPDATE `fishing_simulator_tournaments_users` SET catches = catches + @catch WHERE user_id = @user_id and tournament_id = @tournament_id",
                            aq
                        )
                        as = Utils.translate("tournament_fish_caught")
                        as, at, au = as.format(as, am)
                        TriggerClientEvent("lc_fishing_simulator:Notify", w, "success", as, at, au)
                    end
                end
            end
        end
        if not a5 then
            TriggerClientEvent("lc_fishing_simulator:StopFishingGetFish", w)
            if not userCatchFish(w, y) then
                userCannotCarryFish(w, y, 1)
                ac, am, an, ao, ap, aq, ar, as, at, au = Utils.translate("cant_carry_item")
                TriggerClientEvent("lc_fishing_simulator:Notify", w, "error", ac, am, an, ao, ap, aq, ar, as, at, au)
                return
            end
        end
        afterReceiveFish(w, y, a5)
    end
)
getDataFishing = function(N)
    local v, w, x, y, z, A, B
    y = {}
    y["@user_id"] = N
    w = Utils.Database.fetchAll("SELECT * FROM `fishing_simulator_users` WHERE user_id = @user_id", y)[1]
    if nil == w then
        A = {}
        A["@user_id"] = N
        Utils.Database.execute("INSERT INTO `fishing_simulator_users` (user_id) VALUES (@user_id);", A)
        B = {}
        B["@user_id"] = N
        w = Utils.Database.fetchAll("SELECT * FROM `fishing_simulator_users` WHERE user_id = @user_id", B)[1]
    end
    return w
end
giveplayerXp = function(N, a5)
    local w, x, y, z, A, B, C, aa, ab, ac, am, an
    w = getPlayerLevel(N)
    A = {}
    A["@exp_amount"] = a5
    A["@user_id"] = N
    Utils.Database.execute("UPDATE `fishing_simulator_users` SET exp = exp + @exp_amount WHERE user_id = @user_id", A)
    y = getPlayerLevel(N)
    if w < y then
        C = {}
        C["@skill"] = y - w
        C["@user_id"] = N
        Utils.Database.execute(
            "UPDATE `fishing_simulator_users` SET skill_points = skill_points + @skill WHERE user_id = @user_id",
            C
        )
        A = Utils.Framework.getPlayerSource(N)
        if A then
            ac = Utils.translate("new_level")
            ac, am, an = ac.format(ac, y)
            TriggerClientEvent("lc_fishing_simulator:Notify", A, "success", ac, am, an)
        end
    end
end
generateFishToReceive = function(N, a5)
    local w, x, y, z, A, B, C, aa
    B, C, aa =
        getFishesByAreaAndRarity(
        a5,
        l[
            Utils.Math.weightedRandom(
                Utils.Table.deepCopy(Config.fishing_difficulties.fish_probability_by_level[N[a5 .. "_upgrade"] + 1]),
                Config.equipments_upgrades.rod[m[N.user_id].rod.item].bonus
            )
        ]
    )
    return Utils.Math.getRandomKeyFromTable(B, C, aa)
end
getTimeToHook = function(N)
    local v, w, x
    return getRandomNumber(
        Config.fishing_difficulties.hook_fish_wait.min,
        Config.fishing_difficulties.hook_fish_wait.max
    ) *
        (1 + Config.equipments_upgrades.hook[N].bonus / 100)
end
getTimeToBait = function(N)
    local v, w, x
    return getRandomNumber(
        Config.fishing_difficulties.bait_hook_wait.min,
        Config.fishing_difficulties.bait_hook_wait.max
    ) *
        (1 - Config.equipments_upgrades.bait[N].bonus / 100)
end
getRandomNumber = function(N, a5)
    local w, x, y
    return math.floor(math.random() * (a5 - N + 1) + N)
end
getFishesByAreaAndRarity = function(N, a5)
    local w, x, y, z, A, B, C, aa, ab, ac, am, an, ao, ap
    w = {}
    x, y, z, A = pairs(Config.fishes_available)
    for B, C in x, y, z, A do
        if C.rarity == a5 then
            aa, ab, ac, am = ipairs(C.areas)
            for an, ao in aa, ab, ac, am do
                if ao == N then
                    w[B] = C
                    break
                end
            end
        end
    end
    return w
end
getFishesByArea = function(N)
    local v, w, x, y, z, A, B, C, aa, ab, ac, am, an, ao
    v = {}
    w, x, y, z = pairs(Config.fishes_available)
    for A, B in w, x, y, z do
        C, aa, ab, ac = ipairs(B.areas)
        for am, an in C, aa, ab, ac do
            if an == N then
                v[A] = B
                break
            end
        end
    end
    return v
end
getFishesByRarity = function(N)
    local v, w, x, y, z, A, B, C
    v = {}
    w, x, y, z = pairs(Config.fishes_available)
    for A, B in w, x, y, z do
        if B.rarity == N then
            v[A] = B
        end
    end
    return v
end
isAreaValid = function(N)
    local v, w, x
    return Utils.Table.contains(k, N)
end
Citizen.CreateThread(
    function()
        local u, v, w, x, y, z, A, B, C, aa, ab, ac, am
        Wait(1000)
        while true do
            if d then
                break
            end
            Wait(100)
        end
        assert(
            Config.fishing_locations,
            "^3You have errors in your config file, consider fixing it or redownload the original config.^7"
        )
        assert(
            "started" == GetResourceState("lc_utils"),
            "^3The '^1lc_utils^3' file is missing. Please refer to the documentation for installation instructions: ^7https://docs.lixeirocharmoso.com/fishing_simulator/installation^7"
        )
        if Utils.Math.checkIfCurrentVersionisOutdated(a, Utils.Version) then
            error(
                "^3The script requires 'lc_utils' in version ^1" ..
                    a ..
                        "^3, but you currently have version ^1" ..
                            Utils.Version ..
                                "^3. Please update your 'lc_utils' script to the latest version: https://github.com/LeonardoSoares98/lc_utils/releases/latest/download/lc_utils.zip^7"
            )
        end
        checkIfFrameworkWasLoaded()
        checkScriptName()
        Utils.loadLanguageFile(Lang)
        runCreateTableQueries()
        Utils.Database.execute("UPDATE `fishing_simulator_available_dives` SET progress = NULL", {})
        Utils.Database.execute("UPDATE `fishing_simulator_available_contracts` SET progress = NULL", {})
        u = {}
        v = {}
        w = {}
        w[1] = "fishing_tournaments"
        v.config_path = w
        w = {}
        w.enabled = true
        w.command = "fish_tournament"
        x = {}
        y = {}
        z = {}
        z[1] = 12
        z[2] = 0
        A = {}
        A[1] = 21
        A[2] = 30
        y[1] = z
        y[2] = A
        x.Sunday = y
        y = {}
        z = {}
        z[1] = 12
        z[2] = 0
        A = {}
        A[1] = 21
        A[2] = 30
        y[1] = z
        y[2] = A
        x.Monday = y
        y = {}
        z = {}
        z[1] = 12
        z[2] = 0
        A = {}
        A[1] = 21
        A[2] = 30
        y[1] = z
        y[2] = A
        x.Tuesday = y
        y = {}
        z = {}
        z[1] = 12
        z[2] = 0
        A = {}
        A[1] = 21
        A[2] = 30
        y[1] = z
        y[2] = A
        x.Wednesday = y
        y = {}
        z = {}
        z[1] = 12
        z[2] = 0
        A = {}
        A[1] = 21
        A[2] = 30
        y[1] = z
        y[2] = A
        x.Thursday = y
        y = {}
        z = {}
        z[1] = 12
        z[2] = 0
        A = {}
        A[1] = 21
        A[2] = 30
        y[1] = z
        y[2] = A
        x.Friday = y
        y = {}
        z = {}
        z[1] = 12
        z[2] = 0
        A = {}
        A[1] = 21
        A[2] = 30
        y[1] = z
        y[2] = A
        x.Saturday = y
        w.schedule = x
        w.alert_time_before_start = 8
        w.min_participants = 0
        w.event_duration = 30
        w.entry_fee = 200
        w.radius = 60
        x = {}
        y = {}
        z = {}
        z.label = "gold_medal"
        z.display_name = "Gold Medal"
        z.amount = 1
        y.item = z
        y.money = 1000
        y.exp = 2000
        x[1] = y
        y = {}
        y.item = nil
        y.money = 700
        y.exp = 1500
        x[2] = y
        y = {}
        y.item = nil
        y.money = 600
        y.exp = 1000
        x[3] = y
        w.prizes = x
        x = {}
        x.common = 10
        x.uncommon = 12
        x.rare = 15
        x.legendary = 20
        x.mythic = 30
        w.fish_values = x
        x = {}
        x.id = 68
        x.name = "Fishing Tournament"
        x.color = 5
        x.scale = 0.6
        w.blip = x
        x = {}
        y = {}
        y[1] = -2477.66
        y[2] = 4243.59
        y[3] = 1.39
        z = {}
        z[1] = -1588.18
        z[2] = 5208.35
        z[3] = 4.06
        A = {}
        A[1] = -260.53
        A[2] = 6620.3
        A[3] = 7.41
        B = {}
        B[1] = 714.21
        B[2] = 4146.69
        B[3] = 35.78
        C = {}
        C[1] = -2082.54
        C[2] = 2614.12
        C[3] = 3.08
        aa = {}
        aa[1] = -237.95
        aa[2] = 4262.89
        aa[3] = 30.42
        x[1] = y
        x[2] = z
        x[3] = A
        x[4] = B
        x[5] = C
        x[6] = aa
        w.locations = x
        v.default_value = w
        w = {}
        x = {}
        x[1] = "fishing_tournaments"
        x[2] = "prizes"
        x[3] = 1
        w.config_path = x
        x = {}
        y = {}
        y.label = "gold_medal"
        y.display_name = "Gold Medal"
        y.amount = 1
        x.item = y
        x.money = 1000
        x.exp = 2000
        w.default_value = x
        x = {}
        y = {}
        y[1] = "fishing_tournaments"
        y[2] = "prizes"
        y[3] = 2
        x.config_path = y
        y = {}
        y.item = nil
        y.money = 700
        y.exp = 1500
        x.default_value = y
        y = {}
        z = {}
        z[1] = "fishing_tournaments"
        z[2] = "prizes"
        z[3] = 3
        y.config_path = z
        z = {}
        z.item = nil
        z.money = 600
        z.exp = 1000
        y.default_value = z
        z = {}
        A = {}
        A[1] = "disable_fishing_line"
        z.config_path = A
        z.default_value = false
        u[1] = v
        u[2] = w
        u[3] = x
        u[4] = y
        u[5] = z
        Config = Utils.validateConfig(Config, u)
        Wait(1000)
        Utils.Database.validateTableColumns({}, {}, {})
        y = {}
        y[1] =
            "ALTER TABLE `fishing_simulator_users` CHANGE `user_id` `user_id` VARCHAR(50) CHARACTER SET %s COLLATE %s NOT NULL"
        y[2] =
            "ALTER TABLE `fishing_simulator_fishes_caught` CHANGE `user_id` `user_id` VARCHAR(50) CHARACTER SET %s COLLATE %s NOT NULL"
        Utils.Framework.validateTableCollations("fishing_simulator_users", "user_id", y)
        z = {}
        z[1] = "onAccessLocation"
        z[2] = "userCatchFish"
        Utils.validateFunctions(z, "server_utils.lua")
        searchForErrorsInConfig()
        searchForDataIssuesInDatabase()
        registerUsableItems()
        generateFisherAvailableContractsThread()
        generateFisherAvailableDivesThread()
        processPropertyDegradation()
        updateLoansThread()
        checkTournamentStarts()
    end
)
checkIfFrameworkWasLoaded = function()
    local u, v, w
    assert(
        Utils.Framework.getPlayerId,
        "^3The framework wasn't loaded in the '^1lc_utils^3' resource. Please check if the '^1Config.framework^3' is correctly set to your framework, and make sure there are no errors in your file. For more information, refer to the documentation at '^7https://docs.lixeirocharmoso.com/^3'.^7"
    )
end
checkScriptName = function()
    local u, v, w
    assert(
        "lc_fishing_simulator" == GetCurrentResourceName(),
        "^3The script name does not match the expected resource name. Please ensure that the current resource name is set to '^1lc_fishing_simulator^7'."
    )
end
searchForErrorsInConfig = function()
    local u, v, w, x, y, z, A, B, C, aa, ab, ac, am, an, ao, ap, aq, ar, as, at, au, av, aw, ax
    u = {}
    v = {}
    w, x, y, z = pairs(Config.fishes_available)
    for A, B in w, x, y, z do
        table.insert(v, B)
    end
    table.sort(
        v,
        function(D, E)
            local Q, R
            return D.weight < E.weight
        end
    )
    w, x, y, z = ipairs(v)
    for A, B in w, x, y, z do
        if not u[B.rarity] then
            u[B.rarity] = {}
        end
        C, aa, ab, ac = pairs(B.areas)
        for am, an in C, aa, ab, ac do
            if not u[B.rarity][an] then
                u[B.rarity][an] = {}
            end
            if not B.illegal then
                table.insert(u[B.rarity][an], B.name .. " - " .. B.weight .. "kg - $" .. B.sale_value)
            end
        end
    end
    w, x, y, z = pairs(Config.available_contracts.contracts)
    for A, B in w, x, y, z do
        aa, ab, ac, am = pairs(B.required_items)
        for an, ao in aa, ab, ac, am do
        end
    end
    w = {}
    w[1] = "image"
    w[2] = "name"
    w[3] = "weight"
    w[4] = "sale_value"
    w[5] = "rarity"
    w[6] = "exp"
    w[7] = "areas"
    x, y, z, A = pairs(Config.fishes_available)
    for B, C in x, y, z, A do
        aa = false
        ab, ac, am, an = pairs(C.areas)
        for ao, ap in ab, ac, am, an do
            if not Utils.Table.contains(k, ap) then
                aa = true
                av, aw, ax = table.concat(k, "^3, ^1")
                ar, as, at, au, av, aw, ax =
                    string.format(
                    "^1Error in your config:^3 Fish '^1%s^3' has an invalid area: '^1%s^3'. The valid options are: ^1%s^7",
                    B,
                    ap,
                    av,
                    aw,
                    ax
                )
                print(ar, as, at, au, av, aw, ax)
            end
        end
        if not Utils.Table.contains(l, C.rarity) then
            aa = true
            ap, aq, ar, as, at, au, av, aw, ax = table.concat(l, "^3, ^1")
            ac, am, an, ao, ap, aq, ar, as, at, au, av, aw, ax =
                string.format(
                "^1Error in your config:^3 Fish '^1%s^3' has an invalid rarity: '^1%s^3'. The valid options are: ^1%s^7",
                B,
                C.rarity,
                ap,
                aq,
                ar,
                as,
                at,
                au,
                av,
                aw,
                ax
            )
            print(ac, am, an, ao, ap, aq, ar, as, at, au, av, aw, ax)
        end
        ab, ac, am, an = pairs(w)
        for ao, ap in ab, ac, am, an do
            if not C[ap] then
                aa = true
                ar, as, at, au, av, aw, ax =
                    string.format(
                    "^1Error in your config:^3 Fish '^1%s^3' is missing the required parameter: '^1%s^3'^7",
                    B,
                    ap
                )
                print(ar, as, at, au, av, aw, ax)
            end
        end
        if aa then
            Config.fishes_available[B] = nil
        end
    end
    x, y, z, A = pairs(Config.available_contracts.contracts)
    for B, C in x, y, z, A do
        C.name = Utils.translate(C.name)
        C.description = Utils.translate(C.description)
        aa, ab, ac, am = pairs(C.required_items)
        for an, ao in aa, ab, ac, am do
            if ao.name then
                ap = Config.fishes_available[ao.name]
                if ap then
                    aq = ao.display_name
                    if not aq then
                        aq = ap.name
                    end
                    ao.display_name = aq
                else
                    aq = ao.display_name
                    if not aq then
                        aq = ao.name
                    end
                    ao.display_name = aq
                end
            end
        end
    end
    x, y, z, A = pairs(Config.available_dives.dives)
    for B, C in x, y, z, A do
        C.name = Utils.translate(C.name)
        C.description = Utils.translate(C.description)
    end
    x, y, z, A = pairs(Config.fishes_available)
    for B, C in x, y, z, A do
        aa, ab, ac, am = pairs(l)
        for an, ao in aa, ab, ac, am do
            if ao == C.rarity then
                C.level = an
            end
        end
    end
    if Config.fish_prices.enable then
        x, y, z, A = pairs(Config.fishes_available)
        for B, C in x, y, z, A do
            aa = Config.fish_prices.prices[C.rarity]
            if aa then
                C.sale_value = math.random(aa.min, aa.max)
            end
        end
    end
end
searchForDataIssuesInDatabase = function()
    local u, v, w, x, y, z, A, B, C, aa, ab, ac, am, an, ao, ap, aq, ar, as
    u = {}
    v, w, x, y = pairs(Config.available_items_store.property)
    for z, A in v, w, x, y do
        table.insert(u, z)
    end
    x, y, z, A, B, C, aa, ab, ac, am, an, ao, ap, aq, ar, as = table.concat(u, "','")
    w =
        Utils.Database.fetchAll(
        string.format(
            "SELECT id, property FROM `fishing_simulator_properties` WHERE property NOT IN ('%s')",
            x,
            y,
            z,
            A,
            B,
            C,
            aa,
            ab,
            ac,
            am,
            an,
            ao,
            ap,
            aq,
            ar,
            as
        ),
        {}
    )
    x = {}
    y, z, A, B = pairs(Config.available_items_store.vehicle)
    for C, aa in y, z, A, B do
        table.insert(x, C)
    end
    y, z, A, B = pairs(Config.available_items_store.boat)
    for C, aa in y, z, A, B do
        table.insert(x, C)
    end
    A, B, C, aa, ab, ac, am, an, ao, ap, aq, ar, as = table.concat(x, "','")
    z =
        Utils.Database.fetchAll(
        string.format(
            "SELECT id, vehicle FROM `fishing_simulator_vehicles` WHERE vehicle NOT IN ('%s')",
            A,
            B,
            C,
            aa,
            ab,
            ac,
            am,
            an,
            ao,
            ap,
            aq,
            ar,
            as
        ),
        {}
    )
    A = GetCurrentResourceName()
    if not (#w > 0) then
        if not (#z > 0) then
            goto aG
        end
    end
    print("^8[" .. A .. "] DATABASE ISSUES:^3 The following issues were found in your database:^7")
    ::aG::
    B, C, aa, ab = pairs(w)
    for ac, am in B, C, aa, ab do
        ao, ap, aq, ar, as =
            string.format(
            "^8[%s]^3 Property ^1%s - %s^3 is in your ^1fishing_simulator_properties^3 table but not in your config.^7",
            A,
            am.id,
            am.property
        )
        print(ao, ap, aq, ar, as)
    end
    B, C, aa, ab = pairs(z)
    for ac, am in B, C, aa, ab do
        ao, ap, aq, ar, as =
            string.format(
            "^8[%s]^3 Vehicle ^1%s - %s^3 is in your ^1fishing_simulator_vehicles^3 table but not in your config.^7",
            A,
            am.id,
            am.vehicle
        )
        print(ao, ap, aq, ar, as)
    end
    if not (#w > 0) then
        if not (#z > 0) then
            goto aH
        end
    end
    print(
        "^8[" ..
            A ..
                "] HOW TO RESOLVE ISSUES:^3 You can add missing data to the config or manually remove them from your database.^7"
    )
    ::aH::
end

RegisterServerEvent("lc_fishing_simulator:useRod")
AddEventHandler("lc_fishing_simulator:useRod", function(item_name, _unused, rod_slot)
    local src = source
    local user_id = Utils.Framework.getPlayerId(src)
    if not user_id then return end

    if not rod_slot then return end

    local rod_config = Config.equipments_upgrades.rod and Config.equipments_upgrades.rod[item_name]
    if not rod_config then return end

    if getPlayerLevel(user_id) < (rod_config.required_level or 0) then
        TriggerClientEvent("lc_fishing_simulator:Notify", src, "error", Utils.translate("not_enough_level"))
        return
    end

    local slot_data = exports.ox_inventory:GetSlot(src, rod_slot)
    if not slot_data or slot_data.name ~= item_name then return end

    local metadata = slot_data.metadata or {}
    print("^2[fishing] BEFORE TriggerClientEvent openRodMenu src=" .. tostring(src) .. "^7")
    TriggerClientEvent("lc_fishing_simulator:openRodMenu", src, rod_slot, metadata, cap_name)
    print("^2[fishing] AFTER TriggerClientEvent^7")
end)

local function buildRodDescription(metadata)
    local parts = {}
    if metadata.hook then
        local item_data = exports.ox_inventory:Items(metadata.hook)
        table.insert(parts, "Lưỡi: " .. (item_data and item_data.label or metadata.hook))
    end
    if metadata.line then
        local item_data = exports.ox_inventory:Items(metadata.line)
        table.insert(parts, "Dây: " .. (item_data and item_data.label or metadata.line))
    end
    if metadata.reel then
        local item_data = exports.ox_inventory:Items(metadata.reel)
        table.insert(parts, "Máy: " .. (item_data and item_data.label or metadata.reel))
    end
    return #parts > 0 and table.concat(parts, " | ") or nil
end

RegisterServerEvent("lc_fishing_simulator:attachEquipment")
AddEventHandler("lc_fishing_simulator:attachEquipment", function(data)
    local src = source
    local user_id = Utils.Framework.getPlayerId(src)
    if not user_id then return end

    local equipment_type = data.equipment_type
    local equipment_item = data.equipment_item
    local equipment_slot = data.equipment_slot
    local rod_slot = data.rod_slot

    local valid_types = { hook = true, line = true, reel = true }
    if not valid_types[equipment_type] then return end

    local eq_config = Config.equipments_upgrades[equipment_type] and Config.equipments_upgrades[equipment_type][equipment_item]
    if not eq_config then return end

    if getPlayerLevel(user_id) < (eq_config.required_level or 0) then
        TriggerClientEvent("lc_fishing_simulator:Notify", src, "error", Utils.translate("not_enough_level"))
        return
    end

    local eq_slot_data = exports.ox_inventory:GetSlot(src, equipment_slot)
    if not eq_slot_data or eq_slot_data.name ~= equipment_item then
        TriggerClientEvent("lc_fishing_simulator:Notify", src, "error", Utils.translate("dont_have_item"))
        return
    end

    local rod_slot_data = exports.ox_inventory:GetSlot(src, rod_slot)
    if not rod_slot_data or not (Config.equipments_upgrades.rod and Config.equipments_upgrades.rod[rod_slot_data.name]) then
        TriggerClientEvent("lc_fishing_simulator:Notify", src, "error", Utils.translate("missing_equipments.rod"))
        return
    end

    local metadata = rod_slot_data.metadata or {}
    local old_item = metadata[equipment_type]

    if old_item then
        if not Utils.Framework.givePlayerItem(src, old_item, 1) then
            TriggerClientEvent("lc_fishing_simulator:Notify", src, "error", Utils.translate("cant_carry_item"))
            return
        end
    end

    if not Utils.Framework.getPlayerItem(src, equipment_item, 1) then
        if old_item then
            Utils.Framework.getPlayerItem(src, old_item, 1)
        end
        TriggerClientEvent("lc_fishing_simulator:Notify", src, "error", Utils.translate("dont_have_item"))
        return
    end

    metadata[equipment_type] = equipment_item
    metadata.description = buildRodDescription(metadata)
    exports.ox_inventory:SetMetadata(src, rod_slot, metadata)
    TriggerClientEvent("lc_fishing_simulator:Notify", src, "success", Utils.translate("equipment_equipped"))
end)

RegisterServerEvent("lc_fishing_simulator:detachEquipment")
AddEventHandler("lc_fishing_simulator:detachEquipment", function(data)
    local src = source
    local user_id = Utils.Framework.getPlayerId(src)
    if not user_id then return end

    local equipment_type = data.equipment_type
    local rod_slot = data.rod_slot

    local valid_types = { hook = true, line = true, reel = true }
    if not valid_types[equipment_type] then return end

    local rod_slot_data = exports.ox_inventory:GetSlot(src, rod_slot)
    if not rod_slot_data then
        TriggerClientEvent("lc_fishing_simulator:Notify", src, "error", Utils.translate("item_not_found"))
        return
    end

    local metadata = rod_slot_data.metadata or {}
    local attached_item = metadata[equipment_type]

    if not attached_item then
        TriggerClientEvent("lc_fishing_simulator:Notify", src, "error", Utils.translate("item_not_found"))
        return
    end

    if not Utils.Framework.givePlayerItem(src, attached_item, 1) then
        TriggerClientEvent("lc_fishing_simulator:Notify", src, "error", Utils.translate("cant_carry_item"))
        return
    end

    metadata[equipment_type] = nil
    metadata.description = buildRodDescription(metadata)
    exports.ox_inventory:SetMetadata(src, rod_slot, metadata)
    TriggerClientEvent("lc_fishing_simulator:Notify", src, "success", Utils.translate("equipment_unequipped"))
end)

-- Thay getDataFishing callback
Utils.Callback.RegisterServerCallback(
    "fishing_simulator:getDataFishing",
    function(N, a5, a7, rod_slot)
        local x = N
        Wrapper(x, function(D)
            if not isAreaValid(a7) then
                print("fishing_simulator:getDataFishing: Invalid area: " .. tostring(a7))
                return
            end

            if not hasFisherJob(x) then
                TriggerClientEvent("lc_fishing_simulator:Notify", x, "error", Utils.translate("no_permission"))
                return
            end

            -- Đọc rod từ slot
            local rod_slot_data = exports.ox_inventory:GetSlot(x, rod_slot)
            if not rod_slot_data or not (Config.equipments_upgrades.rod and Config.equipments_upgrades.rod[rod_slot_data.name]) then
                TriggerClientEvent("lc_fishing_simulator:Notify", x, "error", Utils.translate("missing_equipments.rod"))
                return
            end

            local rod_config = Config.equipments_upgrades.rod[rod_slot_data.name]
            local metadata = rod_slot_data.metadata or {}

            -- Validate hook/line/reel trong metadata
            local resolved_equipment = {
                rod = { item = rod_slot_data.name, bonus = rod_config.bonus }
            }

            local required_types = { "hook", "line", "reel" }
            for _, eq_type in ipairs(required_types) do
                local eq_item_name = metadata[eq_type]
                if not eq_item_name then
                    TriggerClientEvent("lc_fishing_simulator:Notify", x, "error", Utils.translate("missing_equipments." .. eq_type))
                    return
                end
                local eq_config = Config.equipments_upgrades[eq_type] and Config.equipments_upgrades[eq_type][eq_item_name]
                if not eq_config then
                    TriggerClientEvent("lc_fishing_simulator:Notify", x, "error", Utils.translate("missing_equipments." .. eq_type))
                    return
                end
                resolved_equipment[eq_type] = { item = eq_item_name, bonus = eq_config.bonus }
            end

            -- Validate và consume bait từ inventory
            local bait_found = false
            local bait_item_name = nil
            for bait_name, bait_data in pairs(Config.equipments_upgrades.bait or {}) do
                if Utils.Framework.playerHasItem(x, bait_name, 1) then
                    bait_found = true
                    bait_item_name = bait_name
                    resolved_equipment.bait = { item = bait_name, bonus = bait_data.bonus }
                    break
                end
            end

            if not bait_found then
                TriggerClientEvent("lc_fishing_simulator:Notify", x, "error", Utils.translate("missing_equipments.bait"))
                return
            end

            Utils.Framework.getPlayerItem(x, bait_item_name, 1)

            local time_hook = getTimeToHook(resolved_equipment.hook.item)
            local time_bait = getTimeToBait(resolved_equipment.bait.item)

            p[x] = { time_hook = time_hook, time_bait = time_bait }
            m[D] = resolved_equipment

            local I = {}
            I.fishing_simulator_user = getDataFishing(D)
            I.selected_equipments = resolved_equipment
            I.time_hook = time_hook
            I.time_bait = time_bait
            a5(I)
        end)
    end
)
runCreateTableQueries = function()
    local u, v
    if false ~= Config.create_table then
        Utils.Database.execute(
            [[
			CREATE TABLE IF NOT EXISTS `fishing_simulator_available_contracts` (
				`id` INT(11) NOT NULL AUTO_INCREMENT,
				`name` VARCHAR(80) NOT NULL COLLATE 'utf8mb4_general_ci',
				`description` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_general_ci',
				`image` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_general_ci',
				`required_items` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_general_ci',
				`money_reward` INT(11) NULL DEFAULT NULL,
				`item_reward` VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
				`delivery_location` VARCHAR(255) NOT NULL DEFAULT '' COLLATE 'utf8mb4_general_ci',
				`progress` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
				`timestamp` INT(11) NOT NULL,
				PRIMARY KEY (`id`) USING BTREE
			)
			COLLATE='utf8mb4_general_ci'
			ENGINE=InnoDB
			;
		]]
        )
        Utils.Database.execute(
            [[
			CREATE TABLE IF NOT EXISTS `fishing_simulator_available_dives` (
				`id` INT(11) NOT NULL AUTO_INCREMENT,
				`name` VARCHAR(80) NOT NULL COLLATE 'utf8mb4_general_ci',
				`description` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_general_ci',
				`image` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_general_ci',
				`money_reward` INT(11) NULL DEFAULT NULL,
				`item_reward` VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
				`dive_location` VARCHAR(255) NOT NULL DEFAULT '' COLLATE 'utf8mb4_general_ci',
				`progress` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
				`timestamp` INT(11) NOT NULL,
				PRIMARY KEY (`id`) USING BTREE
			)
			COLLATE='utf8mb4_general_ci'
			ENGINE=InnoDB
			;
		]]
        )
        Utils.Database.execute(
            [[
			CREATE TABLE IF NOT EXISTS `fishing_simulator_fishes_caught` (
				`user_id` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
				`fish_rarity` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
				`amount` INT(11) NOT NULL DEFAULT '0',
				PRIMARY KEY (`user_id`, `fish_rarity`) USING BTREE
			)
			COLLATE='utf8mb4_general_ci'
			ENGINE=InnoDB
			;
		]]
        )
        Utils.Database.execute(
            [[
			CREATE TABLE IF NOT EXISTS `fishing_simulator_loans` (
				`id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
				`user_id` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
				`loan` INT(10) UNSIGNED NOT NULL DEFAULT '0',
				`remaining_amount` INT(10) UNSIGNED NOT NULL DEFAULT '0',
				`day_cost` INT(10) UNSIGNED NOT NULL DEFAULT '0',
				`taxes_on_day` INT(10) UNSIGNED NOT NULL DEFAULT '0',
				`timer` INT(10) UNSIGNED NOT NULL DEFAULT '0',
				PRIMARY KEY (`id`) USING BTREE
			)
			COLLATE='utf8mb4_general_ci'
			ENGINE=InnoDB
			;
		]]
        )
        Utils.Database.execute(
            [[
			CREATE TABLE IF NOT EXISTS `fishing_simulator_properties` (
				`id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
				`user_id` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
				`property` VARCHAR(80) NOT NULL COLLATE 'utf8mb4_general_ci',
				`stock` LONGTEXT NOT NULL COLLATE 'utf8mb4_general_ci',
				`property_condition` INT(11) UNSIGNED NOT NULL DEFAULT '100',
				PRIMARY KEY (`id`) USING BTREE,
				INDEX `fishing_simulator_vehicle` (`user_id`, `property`) USING BTREE
			)
			COLLATE='utf8mb4_general_ci'
			ENGINE=InnoDB
			;
		]]
        )
        Utils.Database.execute(
            [[
			CREATE TABLE IF NOT EXISTS `fishing_simulator_users` (
				`user_id` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
				`boats_upgrade` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
				`vehicles_upgrade` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
				`properties_upgrade` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
				`sea_upgrade` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
				`lake_upgrade` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
				`river_upgrade` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
				`swamp_upgrade` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
				`money` DOUBLE NOT NULL DEFAULT '0',
				`exp` INT(11) NOT NULL DEFAULT '0',
				`skill_points` INT(11) NOT NULL DEFAULT '0',
				`total_money_earned` DOUBLE UNSIGNED NOT NULL DEFAULT '0',
				`total_money_spent` DOUBLE UNSIGNED NOT NULL DEFAULT '0',
				`total_dives` INT(10) UNSIGNED NOT NULL DEFAULT '0',
				`total_deliveries` INT(10) UNSIGNED NOT NULL DEFAULT '0',
				`loan_notify` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
				`dark_theme` TINYINT(3) UNSIGNED NOT NULL DEFAULT '1',
				PRIMARY KEY (`user_id`) USING BTREE
			)
			COLLATE='utf8mb4_general_ci'
			ENGINE=InnoDB
			;
		]]
        )
        Utils.Database.execute(
            [[
			CREATE TABLE IF NOT EXISTS `fishing_simulator_vehicles` (
				`id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
				`user_id` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
				`vehicle` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
				`properties` LONGTEXT NOT NULL COLLATE 'utf8mb4_general_ci',
				`traveled_distance` INT(11) UNSIGNED NOT NULL DEFAULT '0',
				`health` INT(11) UNSIGNED NOT NULL DEFAULT '1000',
				`fuel` INT(11) UNSIGNED NOT NULL DEFAULT '100',
				`type` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
				PRIMARY KEY (`id`) USING BTREE,
				INDEX `fishing_simulator_vehicle` (`user_id`, `vehicle`) USING BTREE
			)
			COLLATE='utf8mb4_general_ci'
			ENGINE=InnoDB
			;
		]]
        )
        Utils.Database.execute(
            [[
			CREATE TABLE IF NOT EXISTS `fishing_simulator_tournaments_users` (
				`user_id` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
				`tournament_id` INT(11) NOT NULL,
				`catches` INT(11) NOT NULL DEFAULT '0',
				`user_name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
				PRIMARY KEY (`user_id`, `tournament_id`) USING BTREE
			)
			COLLATE='utf8mb4_general_ci'
			ENGINE=InnoDB
			;
		]]
        )
        Utils.Database.execute(
            [[
			CREATE TABLE IF NOT EXISTS `fishing_simulator_tournaments` (
				`id` INT(11) NOT NULL AUTO_INCREMENT,
				`location` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_general_ci',
				`timestamp` INT(11) NOT NULL,
				`notified` TINYINT(4) NOT NULL DEFAULT '0',
				PRIMARY KEY (`id`) USING BTREE,
				UNIQUE INDEX `timestamp` (`timestamp`) USING BTREE
			)
			COLLATE='utf8mb4_general_ci'
			ENGINE=InnoDB
			;
		]]
        )
    end
end
