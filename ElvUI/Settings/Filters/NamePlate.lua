--[[
	Nameplate Filter

	Add the nameplates name that you do NOT want to see.
]]
local E, L, V, P, G, _ = unpack(select(2, ...)); --Engine

G["nameplates"]["filter"] = {
	--Army of the Dead
	["Army of the Dead Ghoul"] = {
		["enable"] = true,
		["hide"] = true,
		["customColor"] = false,
		["color"] = {r = 104/255, g = 138/255, b = 217/255},
		["customScale"] = 1,
	},

	--Hunter Trap
	["Venomous Snake"] = {
		["enable"] = true,
		["hide"] = true,
		["customColor"] = false,
		["color"] = {r = 104/255, g = 138/255, b = 217/255},
		["customScale"] = 1,
	},

	["Healing Tide Totem"] = {
		enable = true,
		hide = false,
		customColor = true,
		customScale = 1.1,
		color = {r = 104/255, g = 138/255, b = 217/255}
	},
	["Dragonmaw War Banner"] = {
		enable = true,
		hide = false,
		customColor = true,
		customScale = 1.1,
		color = {r = 255/255, g = 140/255, b = 200/255}
	}
}

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
			["spells"] = {},
		},
		["classification"] = {
			["worldboss"] = false,
			["rareelite"] = false,
			["elite"] = false,
			["rare"] = false,
			["normal"] = false,
			["trivial"] = false,
			["minus"] = false,
		},
		["class"] = {}, --this can stay empty we only will accept values that exist
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
			["reputation"] = false,
			["hated"] = false,
			["hostile"] = false,
			["unfriendly"] = false,
			["neutral"] = false,
			["friendly"] = false,
			["honored"] = false,
			["revered"] = false,
			["exalted"] = false
		},
		["instanceType"] = {
			["none"] = false,
			["party"] = false,
			["raid"] = false,
			["arena"] = false,
			["pvp"] = false,
		},
		["instanceDifficulty"] = {
			["dungeon"] = {
				["normal"] = false,
				["heroic"] = false,
			},
			["raid"] = {
				["normal"] = false,
				["heroic"] = false,
			}
		},
		["cooldowns"] = {
			["names"] = {},
			["mustHaveAll"] = false,
		},
		["buffs"] = {
			["mustHaveAll"] = false,
			["missing"] = false,
			["names"] = {},
			["minTimeLeft"] = 0,
			["maxTimeLeft"] = 0,
		},
		["debuffs"] = {
			["mustHaveAll"] = false,
			["missing"] = false,
			["names"] = {},
			["minTimeLeft"] = 0,
			["maxTimeLeft"] = 0,
		},
		["inCombat"] = false,
		["outOfCombat"] = false,
		["inCombatUnit"] = false,
		["outOfCombatUnit"] = false,
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
			["texture"] = "ElvUI Norm",
		},
		["flash"] = {
			["enable"] = false,
			["color"] = {r=1,g=1,b=1,a=1},
			["speed"] = 4,
		},
		["hide"] = false,
		["nameOnly"] = false,
		["scale"] = 1.0,
		["alpha"] = -1,
	},
}

G.nameplates.specialFilters = {
	["Personal"] = true,
	["nonPersonal"] = true,
	["blockNonPersonal"] = true,
	["blockNoDuration"] = true,
};