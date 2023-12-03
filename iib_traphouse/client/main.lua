local _U = {
	['trap_robbery'] = 'Trap Robbery',
	['press_to_rob'] = 'Press E to rob ',
	['robbery_timer'] = 'Trap robbery: seconds remaning ',
	['recently_robbed'] = 'This trap was recently been robbed. Please wait seconds until you can rob again ',
	['rob_in_prog'] = 'Yo! Someone is hitting ',
	['started_to_rob'] = 'You started to rob ',
	['alarm_triggered'] = 'These fools called the cops!',
	['robbery_complete'] = 'The robbery has been successful, you stole $%s',
	['robbery_complete_at'] = 'Robbery successful at ',
	['robbery_cancelled'] = 'The robbery has been cancelled! ',
	['robbery_cancelled_at'] = 'The robbery at  has been cancelled! ',
	['min_police'] = 'There must be at least  cops in town to rob a trap. You need ',
	['robbery_already'] = 'A robbery is already in progress.',
	['no_threat'] = 'The trap house owner laughs at you because you pose no threat!',
}
  
local drawingText = false
local holdingUp = false
local Trap = ""
local blipTraphouse = nil
local isDead = false
QBCore = exports['qb-core']:GetCoreObject()

local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

Citizen.CreateThread(function()
	while true do
		Wait(500)
		local playerPed = GetPlayerPed(-1)
		if IsEntityDead(playerPed) then
			TriggerServerEvent('iib_traphouse:dead', Trap)
		end
	end
end)

AddEventHandler('playerSpawned', function(spawn)
    IsDead = false
end)

function drawTxt(x,y, width, height, scale, text, r,g,b,a, outline)
	SetTextFont(0)
	SetTextScale(scale, scale)
	SetTextColour(r, g, b, a)
	SetTextDropshadow(0, 0, 0, 0,255)
	SetTextDropShadow()
	if outline then SetTextOutline() end

	BeginTextCommandDisplayText('STRING')
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayText(x - width/2, y - height/2 + 0.005)
end

RegisterNetEvent('iib_traphouse:currentlyRobbing')
AddEventHandler('iib_traphouse:currentlyRobbing', function(currentTrap)
	holdingUp, Trap = true, currentTrap
end)

RegisterNetEvent('iib_traphouse:killBlip')
AddEventHandler('iib_traphouse:killBlip', function()
	RemoveBlip(blipTraphouse)
end)

RegisterNetEvent('iib_traphouse:setBlip')
AddEventHandler('iib_traphouse:setBlip', function(position)
	blipTraphouse = AddBlipForCoord(position.x, position.y, position.z)

	SetBlipSprite(blipTraphouse, 161)
	SetBlipScale(blipTraphouse, 2.0)

	PulseBlip(blipTraphouse)
end)

RegisterNetEvent('iib_traphouse:tooFar')
AddEventHandler('iib_traphouse:tooFar', function()
	holdingUp, Trap = false, ''
	QBCore.Functions.Notify(_U['robbery_cancelled'])
end)

RegisterNetEvent('iib_traphouse:playerDead')
AddEventHandler('iib_traphouse:playerDead', function()
	holdingUp, Trap = false, ''
	QBCore.Functions.Notify(_U['robbery_cancelled'])
end)

RegisterNetEvent('iib_traphouse:robberyComplete')
AddEventHandler('iib_traphouse:robberyComplete', function(award)
    local playerData = QBCore.Functions.GetPlayerData()
    
    -- Check if the 'lambraraidcamps' metadata exists and is a number
    if playerData.metadata and type(playerData.metadata["lambraraidcamps"]) == "number" then
        local currentXP = playerData.metadata["lambraraidcamps"]
        
        -- Add 15 XP to the current value
        local newXP = currentXP + 15
        
        -- Update the 'lambraraidcamps' metadata with the new value
        playerData.metadata["lambraraidcamps"] = newXP
        
        -- Notify the player about the update
		holdingUp, Trap = false, ''
		QBCore.Functions.Notify(_U['robbery_complete'], award)
    end
end)


RegisterNetEvent('iib_traphouse:startTimer')
AddEventHandler('iib_traphouse:startTimer', function()
	exports['ps-dispatch']:TrapRobbery()
	local timer = Traps[Trap].secondsRemaining

	Citizen.CreateThread(function()
		while timer > 0 and holdingUp do
			Citizen.Wait(1000)

			if timer > 0 then
				timer = timer - 1
			end
		end
	end)

	Citizen.CreateThread(function()
		while holdingUp do
			Citizen.Wait(0)
			drawTxt(0.85, 1.44, 1.0, 1.0, 0.4, _U['robbery_timer'].. timer, 255, 255, 255, 255)
		end
	end)
end)

Citizen.CreateThread(function()
	for k,v in pairs(Traps) do
		local blip = AddBlipForCoord(v.position.x, v.position.y, v.position.z)
		SetBlipSprite(blip, 514)
		SetBlipScale(blip, 0.8)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(_U['trap_robbery'])
		EndTextCommandSetBlipName(blip)
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		local playerPos = GetEntityCoords(PlayerPedId(), true)
		hour = GetClockHours()
		if (hour >= Config.StartHour and hour <= 24) or  (hour <= Config.EndHour and hour >= 00) then
			for k,v in pairs(Traps) do
				local TrapPos = v.position
				local distance = Vdist(playerPos.x, playerPos.y, playerPos.z, TrapPos.x, TrapPos.y, TrapPos.z)

				if distance < Config.Marker.DrawDistance then
					if not holdingUp then
						DrawMarker(Config.Marker.Type, TrapPos.x, TrapPos.y, TrapPos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.x, Config.Marker.y, Config.Marker.z, Config.Marker.r, Config.Marker.g, Config.Marker.b, Config.Marker.a, true, false, 2, true, false, false, false)

						if distance < 0.5 then
							exports['qb-core']:DrawText(_U['press_to_rob'] .. v.nameOfTrap, 'left')
							drawingText = true

							if IsControlJustReleased(0, Keys['E']) then
								if IsPedArmed(PlayerPedId(), 4) then
									exports['qb-core']:HideText()
									TriggerServerEvent('iib_traphouse:robberyStarted', k)
								else
									QBCore.Functions.Notify(_U['no_threat'])
								end
							end
						else
							if drawingText == true then
								exports['qb-core']:HideText()
								drawingText = false
							end
						end
					end
				end
			end
		end
		
		if holdingUp then
			local TrapPos = Traps[Trap].position
			if Vdist(playerPos.x, playerPos.y, playerPos.z, TrapPos.x, TrapPos.y, TrapPos.z) > Config.MaxDistance then
				TriggerServerEvent('iib_traphouse:tooFar', Trap)
			end
		end
	end
end)
