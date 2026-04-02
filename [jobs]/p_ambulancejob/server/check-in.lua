-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--		Cleaned By Said Ak Using Claude Sonnet 4.5
-- =====================================================





lib.callback.register('p_ambulancejob/server/checkIn/canUse', function(source, hospital, payment)
    local _source = source
    if payment == 'none' then
        return true
    end
    
    local checkInPoint = Config.CheckIn.points[hospital]
    if not checkInPoint then return false end
    local paymentPrice = checkInPoint.price[payment]
    if not paymentPrice then return false end

    if Editable.medicsCount > checkInPoint.maxDutyMedics then
        Bridge.Notify.showNotify(_source, locale('medics_on_duty'), 'error')
        return false
    end

    if payment == 'insurance' then
        local identifier = Bridge.Framework.getUniqueId(_source)
        if not identifier then return false end

        local insurance = GetResourceState('envi-prescriptions') == 'started' and exports['envi-prescriptions']:HasMedicalInsurance(_source) or Insurance.active[identifier]
        if not insurance then
            Bridge.Notify.showNotify(_source, locale('no_insurance'), 'error')
            return false
        end

        if GetResourceState('envi-prescriptions') ~= 'started' and os.time() > insurance.duration then
            Bridge.Notify.showNotify(_source, locale('insurance_expired'), 'error')
            return false
        end

        return true
    else
        local plyMoney = Bridge.Framework.getMoney(_source)
        if plyMoney[payment] >= paymentPrice then
            Bridge.Framework.removeMoney(_source, payment, paymentPrice)
            if Config.CheckIn.moneyIntoSociety and Bridge.Society then
                Citizen.CreateThread(function()
                    local hospitalJobs = Config.Hospitals[hospital]?.jobs or {}
                    for _, jobName in pairs(hospitalJobs) do
                        Bridge.Society.addMoney(playerId, jobName, paymentPrice)
                    end
                end)
            end
            return true
        else
            Bridge.Notify.showNotify(_source, locale('not_enough_money'), 'error')
            return false
        end
    end
end)

RegisterNetEvent('p_ambulancejob/server/checkIn/payForOther', function(targetId, hospital, payment)
    local _source = source
    if not Config.CheckIn.canPayForOther then return end
    local checkInPoint = Config.CheckIn.points[hospital]
    if not checkInPoint then return end
    local paymentPrice = checkInPoint.price[payment]
    if not paymentPrice then return end

    local enoughDistance = Utils:checkDistance(_source, targetId)
    if not enoughDistance then
        return
    end

    local plyMoney = Bridge.Framework.getMoney(_source)
    if plyMoney[payment] >= paymentPrice then
        Bridge.Framework.removeMoney(_source, payment, paymentPrice)
        TriggerClientEvent('p_ambulancejob/client/checkIn/startCheckIn', targetId, hospital)
        Bridge.Notify.showNotify(_source, locale('paid_checkin_for_other'), 'success')
        if Config.CheckIn.moneyIntoSociety and Bridge.Society then
            Citizen.CreateThread(function()
                local hospitalJobs = Config.Hospitals[hospital]?.jobs or {}
                for _, jobName in pairs(hospitalJobs) do
                    Bridge.Society.addMoney(playerId, jobName, paymentPrice)
                end
            end)
        end
    else
        Bridge.Notify.showNotify(_source, locale('not_enough_money'), 'error')
    end
end)