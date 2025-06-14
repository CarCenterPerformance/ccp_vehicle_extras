ESX = exports['es_extended']:getSharedObject()

-- Job-Callback
ESX.RegisterServerCallback('vehicle_extras:getJob', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        cb(xPlayer.job.name)
    else
        cb(nil)
    end
end)

-- Extra-Toggle Event (Geld abziehen & an Client weitergeben)
RegisterNetEvent('vehicle_extras:toggleExtra', function(extra, netId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then
        print('[vehicle_extras] FEHLER: Kein xPlayer für source ' .. tostring(src))
        return
    end

    if xPlayer.getMoney() < Config.ExtraPrice then
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = 'Nicht genug Geld.'
        })
        return
    end

    xPlayer.removeMoney(Config.ExtraPrice)

    -- Client ausführen lassen
    TriggerClientEvent('vehicle_extras:applyExtra', src, extra, netId)
end)
