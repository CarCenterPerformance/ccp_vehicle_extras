ESX = exports['es_extended']:getSharedObject()

local inMarker = false

-- Marker + Nähe prüfen
CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)

        for _, location in pairs(Config.Locations) do
            local dist = #(coords - location.coords)
            if dist < 15 then
                sleep = 0
                DrawMarker(1, location.coords.x, location.coords.y, location.coords.z - 1.0, 0, 0, 0, 0, 0, 0, 2.0, 2.0, 0.5, 0, 128, 255, 150, false, true, 2, nil, nil, false)
                if dist < 2.0 then
                    inMarker = true
                    ESX.ShowHelpNotification("Drücke ~INPUT_CONTEXT~ um Fahrzeug-Extras zu verwalten")
                    if IsControlJustReleased(0, 38) then
                        openExtrasMenu()
                    end
                else
                    inMarker = false
                end
            end
        end

        Wait(sleep)
    end
end)

function openExtrasMenu()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle == 0 then
        vehicle = getClosestVehicle()
    end

    if not DoesEntityExist(vehicle) then
        lib.notify({ type = 'error', description = 'Kein Fahrzeug gefunden.' })
        return
    end

    ESX.TriggerServerCallback('vehicle_extras:getJob', function(jobName)
        local allowed = false
        for _, loc in pairs(Config.Locations) do
            if #(GetEntityCoords(playerPed) - loc.coords) < 5.0 then
                for _, allowedJob in pairs(loc.jobs) do
                    if jobName == allowedJob then
                        allowed = true
                        break
                    end
                end
            end
        end

        if not allowed then
            lib.notify({ type = 'error', description = 'Du darfst hier nichts tun.' })
            return
        end

        SetEntityAsMissionEntity(vehicle, true, true)

        local options = {}

        for i = 0, 12 do
            if DoesExtraExist(vehicle, i) then
                local enabled = IsVehicleExtraTurnedOn(vehicle, i)
                table.insert(options, {
                    title = ("Extra %s [%s] - %s$"):format(i, enabled and "Aktiv" or "Inaktiv", Config.ExtraPrice),
                    icon = enabled and 'check-square' or 'square',
                    onSelect = function()
                        TriggerServerEvent('vehicle_extras:toggleExtra', i, VehToNet(vehicle))
                    end
                })
            end
        end

        if #options == 0 then
            lib.notify({ type = 'error', description = 'Dieses Fahrzeug hat keine Extras.' })
            return
        end

        lib.registerContext({
            id = 'extras_menu',
            title = 'Fahrzeug Extras',
            options = options
        })

        lib.showContext('extras_menu')
    end)
end

function getClosestVehicle()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local forward = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 5.0, 0.0)
    local rayHandle = StartShapeTestRay(coords.x, coords.y, coords.z, forward.x, forward.y, forward.z, 10, playerPed, 0)
    local _, _, _, _, vehicle = GetShapeTestResult(rayHandle)
    return vehicle
end

-- Client-Handler: Extra aktivieren/deaktivieren
RegisterNetEvent('vehicle_extras:applyExtra', function(extra, netId)
    local vehicle = NetToVeh(netId)
    if not DoesEntityExist(vehicle) then
        lib.notify({ type = 'error', description = 'Fahrzeug nicht gefunden (Client).' })
        return
    end

    local isOn = IsVehicleExtraTurnedOn(vehicle, extra)
    SetVehicleExtra(vehicle, extra, isOn and 1 or 0)

    lib.notify({ type = 'success', description = ("Extra %s %s"):format(extra, isOn and 'deaktiviert' or 'aktiviert') })
end)
