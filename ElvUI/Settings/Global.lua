local E, L, V, P, G = unpack(select(2, ...))

--Global Settings
G["general"] = {
	["autoScale"] = true,
	["minUiScale"] = 0.64,
	["eyefinity"] = false,
	["smallerWorldMap"] = true,
	["mapAlphaWhenMoving"] = 0.35,
	["WorldMapCoordinates"] = {
		["enable"] = true,
		["position"] = "BOTTOMLEFT",
		["xOffset"] = 0,
		["yOffset"] = 0,
	},
	["animateConfig"] = true,
	["versionCheck"] = true,
}

G["classtimer"] = {}

G["chat"] = {
	["classColorMentionExcludedNames"] = {},
}

G["bags"] = {
	["ignoredItems"] = {},
}

G["nameplates"] = {}

G["unitframe"] = {
	["aurafilters"] = {},
	["buffwatch"] = {},
	["raidDebuffIndicator"] = {
		["instanceFilter"] = "RaidDebuffs",
		["otherFilter"] = "CCDebuffs",
	},
	["spellRangeCheck"] = {
		["PRIEST"] = {
			["enemySpells"] = {
				[585] = true, -- Smite (30 yards)
			},
			["longEnemySpells"] = {
				[589] = true, -- Shadow Word: Pain (30 yards)
			},
			["friendlySpells"] = {
				[2050] = true, -- Lesser Heal (40 yards)
			},
			["resSpells"] = {
				[2006] = true, -- Resurrection (40 yards)
			},
			["petSpells"] = {},
		},
		["DRUID"] = {
			["enemySpells"] = {
				[33786] = true, -- Cyclone (20 yards)
			},
			["longEnemySpells"] = {
				[5176] = true, -- Wrath (30 yards)
			},
			["friendlySpells"] = {
				[5185] = true, -- Healing Touch (40 yards)
			},
			["resSpells"] = {
				[50769] = true, -- Revive (30 yards)
				[20484] = true, -- Rebirth (30 yards)
			},
			["petSpells"] = {},
		},
		["PALADIN"] = {
			["enemySpells"] = {
				[20271] = true, -- Judgement (10 yards)
			},
			["longEnemySpells"] = {
				[879] = true, -- Exorcism (30 yards)
			},
			["friendlySpells"] = {
				[635] = true, -- Holy Light (40 yards)
			},
			["resSpells"] = {
				[7328] = true, -- Redemption (30 yards)
			},
			["petSpells"] = {},
		},
		["SHAMAN"] = {
			["enemySpells"] = {
				[51514] = true, -- Hex (20 yards)
				[8042] = true, -- Earth Shock (25 yards)
			},
			["longEnemySpells"] = {
				[403] = true, -- Lightning Bolt (30 yards)
			},
			["friendlySpells"] = {
				[331] = true, -- Healing Wave (40 yards)
			},
			["resSpells"] = {
				[2008] = true, -- Ancestral Spirit (30 yards)
			},
			["petSpells"] = {},
		},
		["WARLOCK"] = {
			["enemySpells"] = {
				[5782] = true, -- Fear (20 yards)
			},
			["longEnemySpells"] = {
				[686] = true, -- Shadow Bolt (30 yards)
			},
			["friendlySpells"] = {
				[5697] = true, -- Unending Breath (30 yards)
			},
			["resSpells"] = {},
			["petSpells"] = {
				[755] = true, -- Health Funnel (45 yards)
			},
		},
		["MAGE"] = {
			["enemySpells"] = {
				[2136] = true, -- Fire Blast (20 yards)
				[12826] = true, -- Polymorph (30 yards)
			},
			["longEnemySpells"] = {
				[133] = true, -- Fireball (35 yards)
				[44614] = true, -- Frostfire Bolt (40 yards)
			},
			["friendlySpells"] = {
				[475] = true, -- Remove Curse (40 yards)
			},
			["resSpells"] = {},
			["petSpells"] = {},
		},
		["HUNTER"] = {
			["enemySpells"] = {
				[75] = true, -- Auto Shot (35 yards)
			},
			["longEnemySpells"] = {},
			["friendlySpells"] = {},
			["resSpells"] = {},
			["petSpells"] = {
				[136] = true, -- Mend Pet (45 yards)
			},
		},
		["DEATHKNIGHT"] = {
			["enemySpells"] = {
				[49576] = true, -- Death Grip (30 yards)
			},
			["longEnemySpells"] = {},
			["friendlySpells"] = {
				[47541] = true, -- Death Coil (40 yards)
			},
			["resSpells"] = {
				[61999] = true, -- Raise Ally (30 yards)
			},
			["petSpells"] = {},
		},
		["ROGUE"] = {
			["enemySpells"] = {
				[2094] = true, -- Blind (10 yards)
			},
			["longEnemySpells"] = {
				[26679] = true, -- Deadly Throw (30 yards)
			},
			["friendlySpells"] = {
				[57934] = true, -- Tricks of the Trade (20 yards)
			},
			["resSpells"] = {},
			["petSpells"] = {},
		},
		["WARRIOR"] = {
			["enemySpells"] = {
				[5246] = true, -- Intimidating Shout (8 yards)
				[100] = true, -- Charge (25 yards)
			},
			["longEnemySpells"] = {
				[355] = true, -- Taunt (30 yards)
			},
			["friendlySpells"] = {
				[3411] = true, -- Intervene (25 yards)
			},
			["resSpells"] = {},
			["petSpells"] = {},
		}
	}
}