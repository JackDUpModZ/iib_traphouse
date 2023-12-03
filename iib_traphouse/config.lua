Config = {}
Config.Locale = 'en'

Config.Marker = {
	r = 250, g = 0, b = 0, a = 100,  -- red color
	x = 0.5, y = 0.5, z = 0.8,       -- tiny, cylinder formed circle
	DrawDistance = 15.0, Type = 32    -- default circle type, low draw distance due to indoors area
}

Config.PoliceNumberRequired = 2
Config.TimerBeforeNewRob    = 3600 -- The cooldown timer on a Trap after robbery was completed / canceled, in seconds

Config.MaxDistance    = 15   -- max distance from the robbery, going any longer away from it will to cancel the robbery
Config.GiveBlackMoney = true -- give black money? If disabled it will give cash instead

--To leave available 24/7 set start hour to 00 and end hour to 24
Config.StartHour	= 00 -- 9pm
Config.EndHour		= 24 -- 7am

Traps = {
	["nudist"] = {
		position = { x = -1108.763, y = 4938.886, z = 223.0 },
		reward = math.random(100, 200),
		nameOfTrap = "Nudist Camp Trap",
		secondsRemaining = 900, -- seconds
		lastRobbed = 0
	},
	["franklins"] = {
		position = { x = 8.900954, y = 528.1796, z = 170.635 },
		reward = math.random(100, 200),
		nameOfTrap = "Franklins Trap",
		secondsRemaining = 900, -- seconds
		lastRobbed = 0
	},
	["south1"] = {
		position = { x = 336.7777, y = -1978.05, z = 24.4 },
		reward = math.random(100, 200),
		nameOfTrap = "Carson Ave Trap",
		secondsRemaining = 900, -- seconds
		lastRobbed = 0
	},
	["vespucci"] = {
		position = { x = -1156.684, y = -1517.541, z = 10.63273 },
		reward = math.random(100, 200),
		nameOfTrap = "Vespucci Canals Trap",
		secondsRemaining = 900, -- seconds
		lastRobbed = 0
	},
	["yacht"] = {
		position = { x = -2083.8, y = -1018.457, z = 12.7819 },
		reward = math.random(100, 200),
		nameOfTrap = "Yacht Trap",
		secondsRemaining = 900, -- seconds
		lastRobbed = 0
	},
	["cayo"] = {
		position = { x = 5012.951, y = -5756.14, z = 28.90014 },
		reward = math.random(100, 200),
		nameOfTrap = "Cayo Perico Trap",
		secondsRemaining = 900, -- seconds
		lastRobbed = 0
	}
}
