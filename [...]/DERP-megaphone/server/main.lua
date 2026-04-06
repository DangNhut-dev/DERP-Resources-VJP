-- ────────────────────────────────────────────────────────────
-- ITEM — qbx_core
-- ────────────────────────────────────────────────────────────

exports.qbx_core:CreateUseableItem('megaphone', function(source)
    if exports.qbx_core:GetPlayer(source) then
        TriggerClientEvent('DERP-megaphone:client:usemegaphone', source)
    end
end)

-- ────────────────────────────────────────────────────────────
-- SUBMIX RELAY
-- ────────────────────────────────────────────────────────────

RegisterNetEvent('DERP-megaphone:server:addsubmix', function(srcSrv)
    TriggerClientEvent('DERP-megaphone:client:addsubmix', -1, srcSrv)
end)

RegisterNetEvent('DERP-megaphone:server:removesubmix', function(srcSrv)
    TriggerClientEvent('DERP-megaphone:client:removesubmix', -1, srcSrv)
end)
