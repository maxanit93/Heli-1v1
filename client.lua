
            local isInheli1v1Queue = false
            local playerWeapons = {} -- Table zum Speichern der Waffen

            local arena = nil
                for k, v in pairs(A.Arenas) do
                if not v.active then
                arena = v.id
            break
        end
    end

            
    RegisterCommand(A.Arenas[1].queueCommand, function(source, args, rawCommand)
        if not isInheli1v1Queue and not isInheli1v1Match then
            isInheli1v1Queue = true
            TriggerServerEvent("queueForheli1v1")
            TriggerEvent("a_notify", "success", "Heli-System", "Du hast die Heli 1v1 Queue betreten!")
        elseif isInheli1v1Queue and not isInheli1v1Match then
            TriggerEvent("a_notify", "error", "Heli-System", "Du hast die Heli 1v1 Queue verlassen!")
            TriggerServerEvent("queueForheli1v1Not")
            isInheli1v1Queue = false
        end
    end)


    local buzzardModel = "buzzard2" -- Hier den Modellname des Buzzard angeben

    RegisterNetEvent("spawnBuzzard")
    AddEventHandler("spawnBuzzard", function(coords)
        RequestModel(buzzardModel)
        while not HasModelLoaded(buzzardModel) do
            Citizen.Wait(0)
        end
        local buzzard = CreateVehicle(buzzardModel, coords.x, coords.y, coords.z, 0.0, true, false)
        SetVehicleOnGroundProperly(buzzard)
        SetVehicleNumberPlateText(buzzard, "BUZZARD")
        local playerPed = GetPlayerPed(-1)
        SetPedIntoVehicle(playerPed, buzzard, -1)
        SetVehicleEngineOn(buzzard, true, true)
        TriggerClientEvent("teleportIntoBuzzard", playerPed, coords)
    end)
    
    function spawnBuzzard(coords)
        TriggerServerEvent("spawnBuzzard", coords)
    end
    
    function teleportIntoBuzzard(coords)
        local playerPed = GetPlayerPed(-1)
        local vehicle = GetVehiclePedIsUsing(playerPed)
        local seat = GetPedInVehicleSeat(vehicle, -1)
        if IsVehicleModel(vehicle, "buzzard2") and seat == -1 then
            SetEntityCoords(playerPed, coords.x, coords.y, coords.z)
            SetPedIntoVehicle(playerPed, vehicle, 0)
            SetVehicleEngineOn(vehicle, true, true)
        end
    end

            RegisterNetEvent("resetQueueStatus")
                AddEventHandler("resetQueueStatus", function()
                isInheli1v1Queue = false
                isIn2v2Queue = false
            end)

            RegisterNetEvent("setPlayerStats")
            AddEventHandler("setPlayerStats", function()
                local playerPed = GetPlayerPed(-1)
                SetPedArmour(playerPed, 100)
                SetEntityHealth(playerPed, 100)
                TriggerServerEvent("playerStatsSet")
            end)

            RegisterNetEvent("teleportToSpawn")
            AddEventHandler("teleportToSpawn", function(spawnPoint)
                local playerPed = PlayerPedId()
                SetEntityCoords(playerPed, spawnPoint.x, spawnPoint.y, spawnPoint.z, false, false, false, false)
            end)
            
            -- Freeze die Spieler
            RegisterNetEvent("freezePlayers")
            AddEventHandler("freezePlayers", function()
                local playerPed = GetPlayerPed(-1)
                FreezeEntityPosition(playerPed, true)
            end)
            
            -- Entfreeze die Spieler
            RegisterNetEvent("unfreezePlayers")
            AddEventHandler("unfreezePlayers", function()
                local playerPed = GetPlayerPed(-1)
                FreezeEntityPosition(playerPed, false)
            end)
        
            
            RegisterNetEvent('heli1v1:endheli1v1')
            AddEventHandler('heli1v1:endheli1v1', function()
                isInheli1v1Queue = false
                RemoveAllPedWeapons(player1, true)
                RemoveAllPedWeapons(player2, true)
                TriggerEvent('esx:restoreLoadout')
            end)
