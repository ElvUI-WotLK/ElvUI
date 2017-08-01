local E, L, V, P, G = unpack(select(2, ...));

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
		["yOffset"] = 0
	},
	["animateConfig"] = true,
	["versionCheck"] = true
};

G["classtimer"] = {};

G["nameplates"] = {};

G["chat"] = {
	["classColorMentionExcludedNames"] = {},
}

G["bags"] = {
	["ignoredItems"] = {}
};

G["unitframe"] = {
	["aurafilters"] = {},
	["buffwatch"] = {},
	["spellRangeCheck"] = {
		["PRIEST"] = {
			["enemySpells"] = {
				[585] = true, -- Smite (30 yards)
			},
			["longEnemySpells"] = {
				[589] = true, -- Shadow Word: Pain (30 yards)
			},
			["friendlySpells"] = {
				[2061] = true, -- Flash Heal (40 yards)
			},
			["resSpells"] = {
				[2006] = true, -- Resurrection (40 yards)
			},
			["petSpells"] = {},
		},
		["DRUID"] = {
			["enemySpells"] = {
				[33786] = true, -- Cyclone
			},
			["longEnemySpells"] = {
				[5176] = true, -- Wrath
			},
			["friendlySpells"] = {
				[774] = true, -- Rejuvenation
			},
			["resSpells"] = {
				[50769] = true, -- Revive
				[20484] = true, -- Rebirth
			},
			["petSpells"] = {},
		},
		["PALADIN"] = {
			["enemySpells"] = {
				[20271] = true, -- Judgement
				[62124] = true, -- Hand of Reckoning
			},
			["longEnemySpells"] = {},
			["friendlySpells"] = {
				[635] = true, -- Holy Light
			},
			["resSpells"] = {
				[7328] = true, -- Redemption
			},
			["petSpells"] = {},
		},
		["SHAMAN"] = {
			["enemySpells"] = {
				[8042] = true, -- Earth Shock
			},
			["longEnemySpells"] = {
				[403] = true, -- Lightning Bolt
			},
			["friendlySpells"] = {
				[8004] = true, -- Healing Surge
			},
			["resSpells"] = {
				[2008] = true, -- Ancestral Spirit
			},
			["petSpells"] = {},
		},
		["WARLOCK"] = {
			["enemySpells"] = {
				[5782] = true, -- Fear
			},
			["longEnemySpells"] = {
				[172] = true, -- Corruption
				[686] = true, -- Shadow Bolt
				[17962] = true, -- Conflagrate
			},
			["friendlySpells"] = {
				[5697] = true, -- Unending Breath
			},
			["resSpells"] = {},
			["petSpells"] = {
				[755] = true, -- Health Funnel
			},
		},
		["MAGE"] = {
			["enemySpells"] = {
				[12826] = true, -- Polymorph
			},
			["longEnemySpells"] = {
				[133] = true, -- Fireball
				[47610] = true, -- Frostfire Bolt
			},
			["friendlySpells"] = {
				[475] = true, -- Remove Curse
			},
			["resSpells"] = {},
			["petSpells"] = {},
		},
		["HUNTER"] = {
			["enemySpells"] = {
				[75] = true, -- Auto Shot
			},
			["longEnemySpells"] = {},
			["friendlySpells"] = {},
			["resSpells"] = {},
			["petSpells"] = {
				[136] = true, -- Mend Pet
			},
		},
		["DEATHKNIGHT"] = {
			["enemySpells"] = {
				[49576] = true, -- Death Grip
			},
			["longEnemySpells"] = {},
			["friendlySpells"] = {
				[47541] = true, -- Death Coil
			},
			["resSpells"] = {
				[61999] = true, -- Raise Ally
			},
			["petSpells"] = {},
		},
		["ROGUE"] = {
			["enemySpells"] = {
				[2094] = true, -- Blind
			},
			["longEnemySpells"] = {
				[1725] = true, -- Distract
			},
			["friendlySpells"] = {
				[57934] = true, -- Tricks of the Trade
			},
			["resSpells"] = {},
			["petSpells"] = {},
		},
		["WARRIOR"] = {
			["enemySpells"] = {
				[5246] = true, -- Intimidating Shout
				[11578] = true, -- Charge
			},
			["longEnemySpells"] = {
				[355] = true, -- Taunt
			},
			["friendlySpells"] = {
				[3411] = true, -- Intervene
			},
			["resSpells"] = {},
			["petSpells"] = {},
		}
	}
}