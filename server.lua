ESX = exports['a_extended']:getSharedObject()

local isInheli1v1Queue = {}

function startMatch(player1, player2, arena, s)
    local xPlayer = ESX.GetPlayerFromId(s)
    local arena = 1
    for k, v in pairs(A.Arenas) do
        if not v.active then
            arena = v.id
            break
        end
    end

    -- Teleportiere die Spieler zu ihren jeweiligen Spawns
    TriggerClientEvent("teleportToSpawn", player1, A.Arenas[arena].spawnPoints.team1Spawn)
    TriggerClientEvent("teleportToSpawn", player2, A.Arenas[arena].spawnPoints.team2Spawn)

    TriggerClientEvent("spawnBuzzard", player1, A.Arenas[arena].spawnPoints.buzzardSpawn1)
    TriggerClientEvent("spawnBuzzard", player2, A.Arenas[arena].spawnPoints.buzzardSpawn2)

    if A.Arenas[arena].UseOwnWeapons == false then
        RemoveAllPedWeapons(player1, true)
        RemoveAllPedWeapons(player2, true)
        local weapons = A.Arenas[arena].weapons
        for _, weapon in pairs(weapons) do
            GiveWeaponToPed(player1, GetHashKey(weapon), 999, false, false)
            GiveWeaponToPed(player2, GetHashKey(weapon), 999, false, false)
        end
    else
        -- Kein Code wird ausgeführt, damit die Waffen beibehalten werden
    end
    TriggerClientEvent("resetQueueStatus", player1)
    TriggerClientEvent("resetQueueStatus", player2)
    TriggerEvent("heli1v1:dieheli1v1", isInheli1v1Queue[1], isInheli1v1Queue[2])
    Wait(5000)
    DeleteAllVehicles()
end



healthlimit = 0 

RegisterServerEvent("heli1v1:dieheli1v1")
AddEventHandler("heli1v1:dieheli1v1", function(player1, player2, arena)
    local arena = 1
    for k, v in pairs(A.Arenas) do
        if not v.active then
            arena = v.id
            break
        end
    end
	Citizen.CreateThread(function()
		while true do
			if (GetEntityHealth(GetPlayerPed(player1))<=healthlimit or GetEntityHealth(GetPlayerPed(player2))<=healthlimit) then
				if (GetEntityHealth(GetPlayerPed(player1))<=healthlimit) then
                    TriggerClientEvent("a_notify", player1, "error", "Heli-System", "Du hast verloren!")
                    TriggerClientEvent("a_notify", player2, "success", "Heli-System", "Du hast gewonnen!")
                    TriggerClientEvent('ambulancejob:rartyokpenis', player1)
                    local winner = player1
                    local winnerName = GetPlayerName(winner)
                    local loser = player2
                    local loserName = GetPlayerName(loser)
                    local message1 = string.format("**%s** hat das **Heli1v1** gegen **%s** gewonnen!", loserName, winnerName)
                    dcLogs5(4889599, "A・heli1v1-System", message1)
				elseif (GetEntityHealth(GetPlayerPed(player2))<=healthlimit) then
                    TriggerClientEvent("a_notify", player2, "error", "Heli-System", "Du hast verloren!")
                    TriggerClientEvent("a_notify", player1, "success", "Heli-System", "Du hast gewonnen!")
                    TriggerClientEvent('ambulancejob:rartyokpenis', player2)
                    local winner = player1
                    local winnerName = GetPlayerName(winner)
                    local loser = player2
                    local loserName = GetPlayerName(loser)
                    local message2 = string.format("**%s** hat das **Heli 1v1** gegen **%s** gewonnen!", winnerName, loserName)
                    dcLogs5(4889599, "A・heli1v1-System", message2)
				end
                
                Wait(1000)
                TriggerClientEvent("teleportToSpawn", player1, A.Arenas[arena].spawnPoints.SpawnAtEnd)
                TriggerClientEvent("teleportToSpawn", player2, A.Arenas[arena].spawnPoints.SpawnAtEnd)
                if A.Arenas[arena].UseOwnWeapons == false then
                TriggerClientEvent("heli1v1:endheli1v1", player1)
                TriggerClientEvent("heli1v1:endheli1v1", player2)
                end
				TriggerClientEvent("pvpsystem:cancelCounter", player1)
				TriggerClientEvent("pvpsystem:cancelCounter", player2)
                break
            end
            Citizen.Wait(1)
        end
    end)
end)


RegisterServerEvent("queueForheli1v1")
AddEventHandler("queueForheli1v1", function()
    table.insert(isInheli1v1Queue, source)
    if #isInheli1v1Queue >= 2 then
        startMatch(isInheli1v1Queue[1], isInheli1v1Queue[2])
        table.remove(isInheli1v1Queue, 1)
        table.remove(isInheli1v1Queue, 1)
    end
end)

RegisterServerEvent("queueForheli1v1Not")
AddEventHandler("queueForheli1v1Not", function()
        table.remove(isInheli1v1Queue, 1)
end)

function dcLogs5(color, name, message, author)
    local embed = {
        {
            ["color"] = color,
            ["author"] = author or {
                ["name"] = "Heli 1v1 ・ A Roleplay",
                ["icon_url"] = "https://cdn.discordapp.com/attachments/1378325653392461884/1416414853891096618/agent-black.png?ex=68c6c2a0&is=68c57120&hm=2acd76c1a5bb605b1530d1ba8f2ddd8f3e0b0f8e6cd2e4cb7896ab793c13f928&",
            },
            ["description"] = message,
            ["footer"] = {
                ["text"] = "A Roleplay ・ Heli 1v1-System",
                ["icon_url"] = "https://cdn.discordapp.com/attachments/1378325653392461884/1416414853891096618/agent-black.png?ex=68c6c2a0&is=68c57120&hm=2acd76c1a5bb605b1530d1ba8f2ddd8f3e0b0f8e6cd2e4cb7896ab793c13f928&",
            },
        }
    }
    PerformHttpRequest("DISCORD-WEBHOOK-URL", function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end


function DeleteAllVehicles()
    local vehicles = GetAllVehicles()
    for i = 1, #vehicles do
        local vehicle = vehicles[i]
        local driver = GetPedInVehicleSeat(vehicle, -1)
        if not IsPedAPlayer(driver) then
            DeleteEntity(vehicle)
        end
    end
end


function IsAnyPlayerInsideVehicle(vehicle, playerPeds)
    for i = 1, #playerPeds, 1 do
        local veh = GetVehiclePedIsIn(playerPeds[i], false)

        if (DoesEntityExist(veh) and veh == vehicle) then
            return true
        end
    end

    return false
end
