--[[
	Nameplate Filter

	Add the nameplates name that you do NOT want to see.
]]
local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

G.nameplates.filters = {
	ElvUI_Boss = {
		triggers = {
			level = true,
			curlevel = -1,
			nameplateType = {
				enable = true,
				enemyNPC = true
			}
		},
		actions = {
			scale = 1.15
		}
	},
	ElvUI_Totem = {
		triggers = {
			totems = {
				enable = true
			}
		},
		actions = {
			iconOnly = true
		}
	}
}

E.StyleFilterDefaults = {
	triggers = {
		priority = 1,
		isTarget = false,
		notTarget = false,
		level = false,
		casting = {
			isCasting = false,
			isChanneling = false,
			notCasting = false,
			notChanneling = false,
			interruptible = false,
			notSpell = false,
			spells = {}
		},
		role = {
			tank = false,
			healer = false,
			damager = false
		},
		raidTarget = {
			star = false,
			circle = false,
			diamond = false,
			triangle = false,
			moon = false,
			square = false,
			cross = false,
			skull = false
		},
		curlevel = 0,
		maxlevel = 0,
		minlevel = 0,
		healthThreshold = false,
		healthUsePlayer = false,
		underHealthThreshold = 0,
		overHealthThreshold = 0,
		powerThreshold = false,
		underPowerThreshold = 0,
		overPowerThreshold = 0,
		names = {},
		nameplateType = {
			enable = false,
			friendlyPlayer = false,
			friendlyNPC = false,
			enemyPlayer = false,
			enemyNPC = false
		},
		reactionType = {
			enabled = false,
			hostile = false,
			neutral = false,
			friendly = false
		},
		instanceType = {
			none = false,
			sanctuary = false,
			party = false,
			raid = false,
			arena = false,
			pvp = false
		},
		instanceDifficulty = {
			dungeon = {
				normal = false,
				heroic = false
			},
			raid = {
				normal = false,
				heroic = false
			}
		},
		cooldowns = {
			names = {},
			mustHaveAll = false
		},
		buffs = {
			mustHaveAll = false,
			missing = false,
			names = {},
			minTimeLeft = 0,
			maxTimeLeft = 0
		},
		debuffs = {
			mustHaveAll = false,
			missing = false,
			names = {},
			minTimeLeft = 0,
			maxTimeLeft = 0
		},
		totems = {
			enable = false,
			a1 = true, a2 = true, a3 = true, a4 = true, a5 = true,
			e1 = true, e2 = true, e3 = true, e4 = true, e5 = true, e6 = true,
			f1 = true, f2 = true, f3 = true, f4 = true, f5 = true, f6 = true,
			w1 = true, w2 = true, w3 = true, w4 = true, w5 = true,
			o1 = true
		},
		uniqueUnits = {
			enable = false,
			u1 = true, u2 = true
		},
		inCombat = false,
		outOfCombat = false
	},
	actions = {
		color = {
			health = false,
			border = false,
			name = false,
			healthColor = {r = 1, g = 1, b = 1, a = 1},
			borderColor = {r = 1, g = 1, b = 1, a = 1},
			nameColor = {r = 1, g = 1, b = 1, a = 1}
		},
		texture = {
			enable = false,
			texture = "ElvUI Norm"
		},
		flash = {
			enable = false,
			color = {r = 1, g = 1, b = 1, a = 1},
			speed = 4
		},
		hide = false,
		nameOnly = false,
		icon = false,
		iconOnly = false,
		scale = 1.0,
		alpha = -1
	}
}

G.nameplates.specialFilters = {
	Personal = true,
	nonPersonal = true,
	blockNonPersonal = true,
	blockNoDuration = true
}