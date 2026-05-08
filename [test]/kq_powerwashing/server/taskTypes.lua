-- server/taskTypes.lua
-- Registers powerwashing task types with kq_jobcontracts server side

local jobcontracts = exports.kq_jobcontracts

-- ─────────────────────────────────────────────
--  enter_vehicle task
-- ─────────────────────────────────────────────
jobcontracts:RegisterServerTaskType("enter_vehicle", {
    onStart = function(source, taskData, contractId)
        if Config.debug then
            print(("[kq_powerwashing] Player %d starting enter_vehicle task"):format(source))
        end
    end,

    onFinish = function(source, taskData, contractId)
        if Config.debug then
            print(("[kq_powerwashing] Player %d finished enter_vehicle task"):format(source))
        end
    end,

    onCancel = function(source, taskData, contractId)
        -- Nothing special needed
    end,
})

-- ─────────────────────────────────────────────
--  go_to task
-- ─────────────────────────────────────────────
jobcontracts:RegisterServerTaskType("go_to", {
    onStart = function(source, taskData, contractId)
        if Config.debug then
            print(("[kq_powerwashing] Player %d going to location"):format(source))
        end
    end,

    onFinish = function(source, taskData, contractId)
    end,

    onCancel = function(source, taskData, contractId)
    end,
})

-- ─────────────────────────────────────────────
--  wash task
-- ─────────────────────────────────────────────
jobcontracts:RegisterServerTaskType("wash", {
    onStart = function(source, taskData, contractId)
        if Config.debug then
            print(("[kq_powerwashing] Player %d started wash task for contract %s"):format(source, tostring(contractId)))
        end
    end,

    onFinish = function(source, taskData, contractId)
        if Config.debug then
            print(("[kq_powerwashing] Player %d finished wash task for contract %s"):format(source, tostring(contractId)))
        end
    end,

    onCancel = function(source, taskData, contractId)
    end,
})

-- ─────────────────────────────────────────────
--  return_to_hq task
-- ─────────────────────────────────────────────
jobcontracts:RegisterServerTaskType("return_to_hq", {
    onStart = function(source, taskData, contractId)
    end,

    onFinish = function(source, taskData, contractId)
    end,

    onCancel = function(source, taskData, contractId)
    end,
})

-- ─────────────────────────────────────────────
--  finish_at_npc task
-- ─────────────────────────────────────────────
jobcontracts:RegisterServerTaskType("finish_at_npc", {
    onStart = function(source, taskData, contractId)
    end,

    onFinish = function(source, taskData, contractId)
        -- Contract completion is handled in server.lua via the openJobBoard / finish flow
        if Config.debug then
            print(("[kq_powerwashing] Player %d finished at NPC, contract %s"):format(source, tostring(contractId)))
        end
    end,

    onCancel = function(source, taskData, contractId)
    end,
})
