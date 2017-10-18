--[[
	Nameplate Filter

	Add the nameplates name that you do NOT want to see.
]]
local E, L, V, P, G, _ = unpack(select(2, ...)); --Engine

G["nameplates"]["filters"] = {
	["Boss"] = {
		["triggers"] = {
			["level"] = true,
			["curlevel"] = -1,
			["nameplateType"] = {
				["enable"] = true,
				["enemyNPC"] = true,
			},
		},
		["actions"] = {
			["scale"] = 1.15,
		},
	},
}

E["StyleFilterDefaults"] = {
	["triggers"] = {
		["priority"] = 1,
		["isTarget"] = false,
		["notTarget"] = false,
		["level"] = false,
		["casting"] = {
			["interruptible"] = false,
			["spells"] = {}
		},
		["curlevel"] = 0,
		["maxlevel"] = 0,
		["minlevel"] = 0,
		["healthThreshold"] = false,
		["healthUsePlayer"] = false,
		["underHealthThreshold"] = 0,
		["overHealthThreshold"] = 0,
		["names"] = {},
		["nameplateType"] = {
			["enable"] = false,
			["friendlyPlayer"] = false,
			["friendlyNPC"] = false,
			["enemyPlayer"] = false,
			["enemyNPC"] = false
		},
		["reactionType"] = {
			["enabled"] = false,
			["hostile"] = false,
			["neutral"] = false,
			["friendly"] = false
		},
		["instanceType"] = {
			["none"] = false,
			["party"] = false,
			["raid"] = false,
			["arena"] = false,
			["pvp"] = false
		},
		["instanceDifficulty"] = {
			["dungeon"] = {
				["normal"] = false,
				["heroic"] = false
			},
			["raid"] = {
				["normal"] = false,
				["heroic"] = false
			}
		},
		["cooldowns"] = {
			["names"] = {},
			["mustHaveAll"] = false
		},
		["buffs"] = {
			["mustHaveAll"] = false,
			["missing"] = false,
			["names"] = {},
			["minTimeLeft"] = 0,
			["maxTimeLeft"] = 0
		},
		["debuffs"] = {
			["mustHaveAll"] = false,
			["missing"] = false,
			["names"] = {},
			["minTimeLeft"] = 0,
			["maxTimeLeft"] = 0
		},
		["inCombat"] = false,
		["outOfCombat"] = false,
	},
	["actions"] = {
		["color"] = {
			["health"] = false,
			["border"] = false,
			["name"] = false,
			["healthColor"] = {r=1,g=1,b=1,a=1},
			["borderColor"] = {r=1,g=1,b=1,a=1},
			["nameColor"] = {r=1,g=1,b=1,a=1}
		},
		["texture"] = {
			["enable"] = false,
			["texture"] = "ElvUI Norm"
		},
		["flash"] = {
			["enable"] = false,
			["color"] = {r=1,g=1,b=1,a=1},
			["speed"] = 4
		},
		["hide"] = false,
		["nameOnly"] = false,
		["scale"] = 1.0,
		["alpha"] = -1
	}
}

G.nameplates.specialFilters = {
	["Personal"] = true,
	["nonPersonal"] = true,
	["blockNonPersonal"] = true,
	["blockNoDuration"] = true,
};