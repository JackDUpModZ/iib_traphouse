local _U = {
	['trap_robbery'] = 'Trap Robbery',
	['press_to_rob'] = 'Press E to rob ',
	['robbery_timer'] = 'Trap robbery: seconds remaning',
	['recently_robbed'] = 'A trap was recently been robbed. Please wait seconds until you can rob again in ',
	['rob_in_prog'] = 'Yo! Someone is hitting ',
	['started_to_rob'] = 'You started to rob ',
	['alarm_triggered'] = 'These fools called the cops!',
	['robbery_complete'] = 'The robbery has been successful, you stole $%s',
	['robbery_complete_at'] = 'Robbery successful at ',
	['robbery_cancelled'] = 'The robbery has been cancelled! ',
	['robbery_cancelled_at'] = 'The robbery at has been cancelled! ',
	['min_police'] = 'There must be at least cops in town to rob a trap. You need ',
	['robbery_already'] = 'A robbery is already in progress.',
	['no_threat'] = 'The trap house owner laughs at you because you pose no threat!',
}
local rob = false
local robbers = {}
local recentRobTimer = 0

QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent('iib_traphouse:tooFar')
AddEventHandler('iib_traphouse:tooFar', function(currentTrap)
    local _source = source
    local xPlayers = QBCore.Functions.GetPlayers()
    local rob = false

    for i = 1, #xPlayers do
        local xPlayer = QBCore.Functions.GetPlayer(xPlayers[i])
        TriggerClientEvent('QBCore:Notify', xPlayers[i], 'Robbery cancelled at ' .. Traps[currentTrap].nameOfTrap, 'error', 5000)
        TriggerClientEvent('iib_traphouse:killBlip', xPlayers[i])
    end

    if robbers[_source] then
        TriggerClientEvent('iib_traphouse:tooFar', _source)
        robbers[_source] = nil
        TriggerClientEvent('QBCore:Notify', _source, 'Robbery cancelled at ' .. Traps[currentTrap].nameOfTrap, 'error', 5000)
    end
end)

RegisterServerEvent('iib_traphouse:dead')
AddEventHandler('iib_traphouse:dead', function(currentTrap)
	local _source = source
	local xPlayers = QBCore.Functions.GetPlayers()
	rob = false

	if currentTrap == nil then
		return
	end
	
	if currentTrap == '' then
		return
	end
	
	for i=1, #xPlayers, 1 do
		local xPlayer = QBCore.Functions.GetPlayer(xPlayers[i])
		TriggerClientEvent('QBCore:Notify', xPlayers[i], _U['robbery_cancelled_at'] .. Traps[currentTrap].nameOfTrap)
		TriggerClientEvent('iib_traphouse:killBlip', xPlayers[i])
	end

	if robbers[_source] then
		TriggerClientEvent('iib_traphouse:playerDead', _source)
		robbers[_source] = nil
		TriggerClientEvent('QBCore:Notify', _source, _U['robbery_cancelled_at'] .. Traps[currentTrap].nameOfTrap)
	end
end)

RegisterServerEvent('iib_traphouse:robberyStarted')
AddEventHandler('iib_traphouse:robberyStarted', function(currentTrap)
	local _source  = source
	local xPlayer  = QBCore.Functions.GetPlayer(_source)
	local xPlayers = QBCore.Functions.GetPlayers()

	if Traps[currentTrap] then
		local Trap = Traps[currentTrap]

		if (os.time() - recentRobTimer) < Config.TimerBeforeNewRob and recentRobTimer ~= 0 then
			TriggerClientEvent('QBCore:Notify', _source, _U['recently_robbed'] .. Config.TimerBeforeNewRob - (os.time() - recentRobTimer))
			return
		end

        local cops = 0
        for i = 1, #xPlayers do
            local player = QBCore.Functions.GetPlayer(xPlayers[i])
            
            if player and player.PlayerData.job and player.PlayerData.job.name == 'police' then
                cops = cops + 1
            end
        end
		
		if not rob then
			if cops >= Config.PoliceNumberRequired then
				rob = true

				for i=1, #xPlayers, 1 do
					local xPlayer = QBCore.Functions.GetPlayer(xPlayers[i])
						TriggerClientEvent('QBCore:Notify', xPlayers[i], _U['rob_in_prog'] .. Trap.nameOfTrap)
						TriggerClientEvent('iib_traphouse:setBlip', xPlayers[i], Traps[currentTrap].position)
				end

				TriggerClientEvent('QBCore:Notify', _source, _U['started_to_rob'].. Trap.nameOfTrap)
				TriggerClientEvent('QBCore:Notify', _source, _U['alarm_triggered'])

				TriggerClientEvent('iib_traphouse:currentlyRobbing', _source, currentTrap)
				TriggerClientEvent('iib_traphouse:startTimer', _source)

				recentRobTimer = os.time()
				robbers[_source] = currentTrap

				SetTimeout(Trap.secondsRemaining * 1000, function()
					if robbers[_source] then
						rob = false
						if xPlayer then
							TriggerClientEvent('iib_traphouse:robberyComplete', _source, Trap.reward)
							-- Money rewards.
							if Config.GiveBlackMoney then
								xPlayer.Functions.AddItem('dirtymoney', Trap.reward) -- Assuming 'dirtymoney' is the item name
								TriggerClientEvent('inventory:client:ItemBox', _source, QBCore.Shared.Items["dirtymoney"], "add", Trap.reward)

								xPlayer.Functions.AddItem('oxy', math.random(5,10)) -- Assuming 'dirtymoney' is the item name
								TriggerClientEvent('inventory:client:ItemBox', _source, QBCore.Shared.Items["oxy"], "add", math.random(1,5))

								xPlayer.Functions.AddItem('gunpowder', math.random(10,15)) -- Assuming 'dirtymoney' is the item name
								TriggerClientEvent('inventory:client:ItemBox', _source, QBCore.Shared.Items["gunpowder"], "add", math.random(10,15))
								
								xPlayer.Functions.AddMoney('cash', math.random(20000,40000))
							end

							local xPlayers, xPlayer = QBCore.Functions.GetPlayers(), nil
							for i=1, #xPlayers, 1 do
								xPlayer = QBCore.Functions.GetPlayer(xPlayers[i])
									TriggerClientEvent('QBCore:Notify', xPlayers[i], _U['robbery_complete_at'].. Trap.nameOfTrap)
									TriggerClientEvent('iib_traphouse:killBlip', xPlayers[i])
							end
						end
					end
				end)
			else
				TriggerClientEvent('QBCore:Notify', _source, _U['min_police'].. Config.PoliceNumberRequired)
			end
		else
			TriggerClientEvent('QBCore:Notify', _source, _U['robbery_already'])
		end
	end
end)
