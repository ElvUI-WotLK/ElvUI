local E, L, V, P, G, _ = unpack(select(2, ...));

local print, unpack = print, unpack;

local GetSpellInfo = GetSpellInfo;

local function SpellName(id)
	local name, _, _, _, _, _, _, _, _ = GetSpellInfo(id);
	if(not name) then
		print("|cff1784d1ElvUI:|r SpellID is not valid: "..id..". Please check for an updated version, if none exists report to ElvUI author.");
		return "Impale";
	else
		return name;
	end
end

local function Defaults(priorityOverride)
	return {["enable"] = true, ["priority"] = priorityOverride or 0, ["stackThreshold"] = 0};
end

G.unitframe.aurafilters = {};

G.unitframe.aurafilters["CCDebuffs"] = {
	["type"] = "Whitelist",
	["spells"] = {
	-- Death Knight
		[47476] = Defaults(), -- Strangulate
		[51209] = Defaults(), -- Hungering Cold
	-- Druid
		[99] = Defaults(), -- Demoralizing Roar
		[339] = Defaults(), -- Entangling Roots
		[2637] = Defaults(), -- Hibernate
		[5211] = Defaults(), -- Bash
		[9005] = Defaults(), -- Pounce
		[22570] = Defaults(), -- Maim
		[33786] = Defaults(), -- Cyclone
		[45334] = Defaults(), -- Feral Charge Effect
	-- Hunter
		[1513] = Defaults(), -- Scare Beast
		[3355] = Defaults(), -- Freezing Trap Effect
		[19386] = Defaults(), -- Wyvern Sting
		[19503] = Defaults(), -- Scatter Shot
		[24394] = Defaults(), -- Intimidation
		[34490] = Defaults(), -- Silencing Shot
		[50245] = Defaults(), -- Pin
		[50519] = Defaults(), -- Sonic Blast
		[50541] = Defaults(), -- Snatch
		[54706] = Defaults(), -- Venom Web Spray
		[56626] = Defaults(), -- Sting
		[60210] = Defaults(), -- Freezing Arrow Effect
		[64803] = Defaults(), -- Entrapment
	-- Mage
		[118] = Defaults(), -- Polymorph (Sheep)
		[122] = Defaults(), -- Frost Nova
		[18469] = Defaults(), -- Silenced - Improved Counterspell (Rank 1)
		[31589] = Defaults(), -- Slow
		[31661] = Defaults(), -- Dragon's Breath
		[33395] = Defaults(), -- Freeze
		[44572] = Defaults(), -- Deep Freeze
		[55080] = Defaults(), -- Shattered Barrier
		[61305] = Defaults(), -- Polymorph (Black Cat)
		[55021] = Defaults(), -- Silenced - Improved Counterspell (Rank 2)
	-- Paladin
		[853] = Defaults(), -- Hammer of Justice
		[10326] = Defaults(), -- Turn Evil
		[20066] = Defaults(), -- Repentance
		[31935] = Defaults(), -- Avenger's Shield
	-- Priest
		[605] = Defaults(), -- Mind Control
		[8122] = Defaults(), -- Psychic Scream
		[9484] = Defaults(), -- Shackle Undead
		[15487] = Defaults(), -- Silence
		[64044] = Defaults(), -- Psychic Horror
	-- Rogue
		[408] = Defaults(), -- Kidney Shot
		[1330] = Defaults(), -- Garrote - Silence
		[1776] = Defaults(), -- Gouge
		[1833] = Defaults(), -- Cheap Shot
		[2094] = Defaults(), -- Blind
		[6770] = Defaults(), -- Sap
		[18425] = Defaults(), -- Silenced - Improved Kick
		[51722] = Defaults(), -- Dismantle
	-- Shaman
		[3600] = Defaults(), -- Earthbind
		[8056] = Defaults(), -- Frost Shock
		[39796] = Defaults(), -- Stoneclaw Stun
		[51514] = Defaults(), -- Hex
		[63685] = Defaults(), -- Freeze
		[64695] = Defaults(), -- Earthgrab
	-- Warlock
		[710] = Defaults(), -- Banish
		[5782] = Defaults(), -- Fear
		[6358] = Defaults(), -- Seduction
		[6789] = Defaults(), -- Death Coil
		[17928] = Defaults(), -- Howl of Terror
		[24259] = Defaults(), -- Spell Lock
		[30283] = Defaults(), -- Shadowfury
	-- Warrior
		[676] = Defaults(), -- Disarm
		[7922] = Defaults(), -- Charge Stun
		[18498] = Defaults(), -- Silenced - Gag Order
		[20511] = Defaults(), -- Intimidating Shout
	-- Racial
		[25046] = Defaults(), -- Arcane Torrent
		[20549] = Defaults(), -- War Stomp
	-- The Lich King
		[73787] = Defaults() -- Necrotic Plague
	}
};

G.unitframe.aurafilters["TurtleBuffs"] = {
	["type"] = "Whitelist",
	["spells"] = {
	-- Mage
		[45438] = Defaults(5), -- Ice Block
	-- Death Knight
		[48707] = Defaults(5), -- Anti-Magic Shell
		[48792] = Defaults(), -- Icebound Fortitude
		[49039] = Defaults(), -- Lichborne
		[50461] = Defaults(), -- Anti-Magic Zone
		[55233] = Defaults(), -- Vampiric Blood
	-- Priest
		[33206] = Defaults(3), -- Pain Suppression
		[47585] = Defaults(5), -- Dispersion
		[47788] = Defaults(), -- Guardian Spirit
	-- Warlock

	-- Druid
		[22812] = Defaults(2), -- Barkskin
		[61336] = Defaults(), -- Survival Instincts
	-- Hunter
		[19263] = Defaults(5), -- Deterrence
		[53480] = Defaults(), -- Roar of Sacrifice
	-- Rogue
		[5277] = Defaults(5), -- Evasion
		[31224] = Defaults(), -- Cloak of Shadows
		[45182] = Defaults(), -- Cheating Death
	-- Shaman
		[30823] = Defaults(), -- Shamanistic Rage
	-- Paladin
		[498] = Defaults(2), -- Divine Protection
		[642] = Defaults(5), -- Divine Shield
		[1022] = Defaults(5), -- Hand of Protection
		[6940] = Defaults(), -- Hand of Sacrifice
		[31821] = Defaults(3), -- Aura Mastery
	-- Warrior
		[871] = Defaults(3), -- Shield Wall
		[55694] = Defaults() -- Enraged Regeneration
	}
};

G.unitframe.aurafilters["PlayerBuffs"] = {
	["type"] = "Whitelist",
	["spells"] = {
	-- Mage
		[12042] = Defaults(), -- Arcane Power
		[12051] = Defaults(), -- Evocation
		[12472] = Defaults(), -- Icy Veins
		[32612] = Defaults(), -- Invisibility
		[45438] = Defaults(), -- Ice Block
	-- Death Knight
		[48707] = Defaults(), -- Anti-Magic Shell
		[48792] = Defaults(), -- Icebound Fortitude
		[49016] = Defaults(), -- Hysteria
		[49039] = Defaults(), -- Lichborne
		[49222] = Defaults(), -- Bone Shield
		[50461] = Defaults(), -- Anti-Magic Zone
		[51271] = Defaults(), -- Unbreakable Armor
		[55233] = Defaults(), -- Vampiric Blood
	-- Priest
		[6346] = Defaults(), -- Fear Ward
		[10060] = Defaults(), -- Power Infusion
		[27827] = Defaults(), -- Spirit of Redemption
		[33206] = Defaults(), -- Pain Suppression
		[47585] = Defaults(), -- Dispersion
		[47788] = Defaults(), -- Guardian Spirit
	-- Warlock

	-- Druid
		[1850] = Defaults(), -- Dash
		[22812] = Defaults(), -- Barkskin
		[52610] = Defaults(), -- Savage Roar
	-- Hunter
		[3045] = Defaults(), -- Rapid Fire
		[5384] = Defaults(), -- Feign Death
		[19263] = Defaults(), -- Deterrence
		[53480] = Defaults(), -- Roar of Sacrifice (Cunning)
		[54216] = Defaults(), -- Master's Call
	-- Rogue
		[2983] = Defaults(), -- Sprint
		[5277] = Defaults(), -- Evasion
		[11327] = Defaults(), -- Vanish
		[13750] = Defaults(), -- Adrenaline Rush
		[31224] = Defaults(), -- Cloak of Shadows
		[45182] = Defaults(), -- Cheating Death
	-- Shaman
		[2825] = Defaults(), -- Bloodlust
		[8178] = Defaults(), -- Grounding Totem Effect
		[16166] = Defaults(), -- Elemental Mastery
		[16188] = Defaults(), -- Nature's Swiftness
		[16191] = Defaults(), -- Mana Tide
		[30823] = Defaults(), -- Shamanistic Rage
		[32182] = Defaults(), -- Heroism
		[58875] = Defaults(), -- Spirit Walk
	-- Paladin
		[498] = Defaults(), -- Divine Protection
		[1022] = Defaults(), -- Hand of Protection
		[1044] = Defaults(), -- Hand of Freedom
		[6940] = Defaults(), -- Hand of Sacrifice
		[31821] = Defaults(), -- Aura Mastery
		[31842] = Defaults(), -- Divine Illumination
		[31850] = Defaults(), -- Ardent Defender
		[31884] = Defaults(), -- Avenging Wrath
		[53563] = Defaults(), -- Beacon of Light
	-- Warrior
		[871] = Defaults(), -- Shield Wall
		[1719] = Defaults(), -- Recklessness
		[3411] = Defaults(), -- Intervene
		[12292] = Defaults(), -- Death Wish
		[12975] = Defaults(), -- Last Stand
		[18499] = Defaults(), -- Berserker Rage
		[23920] = Defaults(), -- Spell Reflection
		[46924] = Defaults(), -- Bladestorm
	-- Racial
		[20594] = Defaults(), -- Stoneform
		[59545] = Defaults(), -- Gift of the Naaru
		[20572] = Defaults(), -- Blood Fury
		[26297] = Defaults() -- Berserking
	}
};

G.unitframe.aurafilters["Blacklist"] = {
	["type"] = "Blacklist",
	["spells"] = {
		[6788] = Defaults(), -- Weakened Soul
		[8326] = Defaults(), -- Ghost
		[15007] = Defaults(), -- Resurrection Sickness
		[23445] = Defaults(), -- Evil Twin
		[24755] = Defaults(), -- Tricked or Treated
		[25771] = Defaults(), -- Forbearance
		[26013] = Defaults(), -- Deserter
		[36032] = Defaults(), -- Arcane Blast
		[36893] = Defaults(), -- Transporter Malfunction
		[36900] = Defaults(), -- Soul Split: Evil!
		[36901] = Defaults(), -- Soul Split: Good
		[41425] = Defaults(), -- Hypothermia
		[55711] = Defaults(), -- Weakened Heart
		[57723] = Defaults(), -- Exhaustion
		[57724] = Defaults(), -- Sated
		[58539] = Defaults(), -- Watcher's Corpse
		[67604] = Defaults(), -- Powering Up
		[69127] = Defaults(), -- Chill of the Throne
		[71041] = Defaults(), -- Dungeon Deserter
	-- Festergut
		[70852] = Defaults(), -- Malleable Goo
		[72144] = Defaults(), -- Orange Blight Residue
		[73034] = Defaults(), -- Blighted Spores
	-- Rotface
		[72145] = Defaults(), -- Green Blight Residue
	-- Professor Putricide
		[72460] = Defaults(), -- Choking Gas
		[72511] = Defaults(), -- Mutated Transformation
	-- Blood Prince Council
		[71911] = Defaults() -- Shadow Resonance
	}
};

G.unitframe.aurafilters["Whitelist"] = {
	["type"] = "Whitelist",
	["spells"] = {
		[1022] = Defaults(), -- Hand of Protection
		[1490] = Defaults(), -- Curse of the Elements
		[2825] = Defaults(), -- Bloodlust
		[12051] = Defaults(), -- Evocation
		[18708] = Defaults(), -- Fel Domination
		[29166] = Defaults(), -- Innervate
		[31821] = Defaults(), -- Aura Mastery
		[32182] = Defaults(), -- Heroism
		[47788] = Defaults(), -- Guardian Spirit
		[54428] = Defaults(), -- Divine Plea
	-- Turtling abilities
		[871] = Defaults(), -- Shield Wall
		[19263] = Defaults(), -- Deterrence
		[22812] = Defaults(), -- Barkskin
		[31224] = Defaults(), -- Cloak of Shadows
		[33206] = Defaults(), -- Pain Suppression
		[48707] = Defaults(), -- Anti-Magic Shell
	-- Immunities
		[642] = Defaults(), -- Divine Shield
		[45438] = Defaults(), -- Ice Block
	-- Offensive
		[12292] = Defaults(), -- Death Wish
		[31884] = Defaults(), -- Avenging Wrath
		[34471] = Defaults() -- The Beast Within
	}
};

G.unitframe.aurafilters["RaidDebuffs"] = {
	["type"] = "Whitelist",
	["spells"] = {
	-- Naxxramas
		-- Kel'Thuzad
		[28410] = Defaults(), -- Chains of Kel'Thuzad
		[27819] = Defaults(), -- Detonate Mana
		[27808] = Defaults(), -- Frost Blast

	-- Ulduar
		-- Ignis the Furnace Master
		[62717] = Defaults(), -- Slag Pot

		-- XT-002
		[63024] = Defaults(), -- Gravity Bomb
		[63018] = Defaults(), -- Light Bomb

		-- The Assembly of Iron
		[61903] = Defaults(), -- Fusion Punch
		[61912] = Defaults(), -- Static Disruption

		-- Kologarn
		[64290] = Defaults(), -- Stone Grip

		-- Thorim
		[62130] = Defaults(), -- Unbalancing Strike

		-- Yogg-Saron
		[63134] = Defaults(), -- Sara's Blessing
		[64157] = Defaults(), -- Curse of Doom

		-- Algalon
		[64412] = Defaults(), -- Phase Punch

	-- Trial of the Crusader
		-- Beast of Northrend
		-- Gormok the Impaler
		[66331] = Defaults(), -- Impale
		[66406] = Defaults(), -- Snowbolled!
		-- Jormungar Behemoth
		[66869] = Defaults(), -- Burning Bile
		[67618] = Defaults(), -- Paralytic Toxin
		-- Icehowl
		[66689] = Defaults(), -- Arctic Breathe

		-- Lord Jaraxxus
		[66237] = Defaults(), -- Incinerate Flesh
		[66197] = Defaults(), -- Legion Flame

		-- Faction Champions
		[65812] = Defaults(), -- Unstable Affliction

		-- The Twin Val'kyr
		[67309] = Defaults(), -- Twin Spike

		-- Anub'arak
		[66013] = Defaults(), -- Penetrating Cold
		[67574] = Defaults(), -- Pursued by Anub'arak
		[67847] = Defaults(), -- Expose Weakness

	-- Icecrown Citadel
		-- Lord Marrowgar
		[69065] = Defaults(), -- Impaled

		-- Lady Deathwhisper
		[72109] = Defaults(), -- Death and Decay
		[71289] = Defaults(), -- Dominate Mind
		[71237] = Defaults(), -- Curse of Torpor

		-- Deathbringer Saurfang
		[72293] = Defaults(), -- Mark of the Fallen Champion
		[72442] = Defaults(), -- Boiling Blood
		[72449] = Defaults(), -- Rune of Blood
		[72769] = Defaults(), -- Scent of Blood

		-- Festergut
		[71218] = Defaults(), -- Vile Gas
		[72219] = Defaults(), -- Gastric Bloat
		[69279] = Defaults(), -- Gas Spore

		-- Rotface
		[71224] = Defaults(), -- Mutated Infection

		-- Professor Putricide
		[71278] = Defaults(), -- Choking Gas Bomb
		[70215] = Defaults(), -- Gaseous Bloat
		[72549] = Defaults(), -- Malleable Goo
		[70953] = Defaults(), -- Plague Sickness
		[72856] = Defaults(), -- Unbound Plague
		[70447] = Defaults(), -- Volatile Ooze Adhesive

		-- Blood Prince Council
		[72796] = Defaults(), -- Glittering Sparks
		[71822] = Defaults(), -- Shadow Resonance

		-- Blood-Queen Lana'thel
		[72265] = Defaults(), -- Delirious Slash
		[71473] = Defaults(), -- Essence of the Blood Queen
		[71474] = Defaults(), -- Frenzied Bloodthirst
		[71340] = Defaults(), -- Pact of the Darkfallen
		[71265] = Defaults(), -- Swarming Shadows
		[70923] = Defaults(), -- Uncontrollable Frenzy

		-- Valithria Dreamwalker
		[71733] = Defaults(), -- Acid Burst
		[71738] = Defaults(), -- Corrosion
		[70873] = Defaults(), -- Emerald Vigor
		[71283] = Defaults(), -- Gut Spray

		-- Sindragosa
		[70106] = Defaults(), -- Chilled to the Bone
		[70126] = Defaults(), -- Frost Beacon
		[70157] = Defaults(), -- Ice Tomb
		[69766] = Defaults(), -- Instability
		[69762] = Defaults(), -- Unchained Magic

		-- The Lich King
		[72762] = Defaults(), -- Defile
		[70541] = Defaults(), -- Infest
		[70337] = Defaults(), -- Necrotic plague
		[72149] = Defaults(), -- Shockwave
		[69409] = Defaults(), -- Soul Reaper
		[69242] = Defaults(), -- Soul Shriek

	-- The Ruby Sanctum
		-- Trash
		-- Baltharus the Warborn
		[75887] = Defaults(), -- Blazing Aura
		[74502] = Defaults(), -- Enervating Brand
		-- General Zarithrian
		[74367] = Defaults(), -- Cleave Armor

		-- Halion
		[74562] = Defaults(), -- Fiery Combustion
		[74567] = Defaults(), -- Mark of Combustion
		[74792] = Defaults(), -- Soul Consumption
		[74795] = Defaults(), -- Mark of Consumption
	}
};

--Spells that we want to show the duration backwards
E.ReverseTimer = {

}

--BuffWatch
--List of personal spells to show on unitframes as icon
local function ClassBuff(id, point, color, anyUnit, onlyShowMissing, style, displayText, decimalThreshold, textColor, textThreshold, xOffset, yOffset, sizeOverride)
	local r, g, b = unpack(color);
	local r2, g2, b2 = 1, 1, 1;
	if(textColor) then
		r2, g2, b2 = unpack(textColor);
	end

	return {["enabled"] = true, ["id"] = id, ["point"] = point, ["color"] = {["r"] = r, ["g"] = g, ["b"] = b},
	["anyUnit"] = anyUnit, ["onlyShowMissing"] = onlyShowMissing, ["style"] = style or "coloredIcon", ["displayText"] = displayText or false, ["decimalThreshold"] = decimalThreshold or 5,
	["textColor"] = {["r"] = r2, ["g"] = g2, ["b"] = b2}, ["textThreshold"] = textThreshold or -1, ["xOffset"] = xOffset or 0, ["yOffset"] = yOffset or 0, ["sizeOverride"] = sizeOverride or 0};
end

G.unitframe.buffwatch = {
	PRIEST = {
		[6788] = ClassBuff(6788, "TOPLEFT", {1, 0, 0}, true), -- Weakened Soul
		[10060] = ClassBuff(10060 , "RIGHT", {227/255, 23/255, 13/255}), -- Power Infusion
		[48066] = ClassBuff(48066, "BOTTOMRIGHT", {0.81, 0.85, 0.1}, true), -- Power Word: Shield
		[48068] = ClassBuff(48068, "BOTTOMLEFT", {0.4, 0.7, 0.2}), -- Renew
		[48111] = ClassBuff(48111, "TOPRIGHT", {0.2, 0.7, 0.2}), -- Prayer of Mending
	},
	DRUID = {
		[48441] = ClassBuff(48441, "TOPRIGHT", {0.8, 0.4, 0.8}), -- Rejuvenation
		[48443] = ClassBuff(48443, "BOTTOMLEFT", {0.2, 0.8, 0.2}), -- Regrowth
		[48451] = ClassBuff(48451, "TOPLEFT", {0.4, 0.8, 0.2}), -- Lifebloom
		[53251] = ClassBuff(53251, "BOTTOMRIGHT", {0.8, 0.4, 0}), -- Wild Growth
	},
	PALADIN = {
		[1038] = ClassBuff(1038, "BOTTOMRIGHT", {238/255, 201/255, 0}, true), -- Hand of Salvation
		[1044] = ClassBuff(1044, "BOTTOMRIGHT", {221/255, 117/255, 0}, true), -- Hand of Freedom
		[6940] = ClassBuff(6940, "BOTTOMRIGHT", {227/255, 23/255, 13/255}, true), -- Hand of Sacrifice
		[10278] = ClassBuff(10278, "BOTTOMRIGHT", {0.2, 0.2, 1}, true), -- Hand of Protection
		[53563] = ClassBuff(53563, "TOPLEFT", {0.7, 0.3, 0.7}), -- Beacon of Light
		[53601] = ClassBuff(53601, "TOPRIGHT", {0.4, 0.7, 0.2}), -- Sacred Shield
	},
	SHAMAN = {
		[16237] = ClassBuff(16237, "BOTTOMLEFT", {0.4, 0.7, 0.2}), -- Ancestral Fortitude
		[49284] = ClassBuff(49284, "TOPRIGHT", {0.2, 0.7, 0.2}), -- Earth Shield
		[52000] = ClassBuff(52000, "BOTTOMRIGHT", {0.7, 0.4, 0}), -- Earthliving
		[61301] = ClassBuff(61301, "TOPLEFT", {0.7, 0.3, 0.7}), -- Riptide
	},
	ROGUE = {
		[57933] = ClassBuff(57933, "TOPRIGHT", {227/255, 23/255, 13/255}), -- Tricks of the Trade
	},
	MAGE = {
		[54646] = ClassBuff(54646, "TOPRIGHT", {0.2, 0.2, 1}), -- Focus Magic
	},
	WARRIOR = {
		[3411] = ClassBuff(3411, "TOPRIGHT", {227/255, 23/255, 13/255}), -- Intervene
		[59665] = ClassBuff(59665, "TOPLEFT", {0.2, 0.2, 1}), -- Vigilance
	},
	DEATHKNIGHT = {
		[49016] = ClassBuff(49016, "TOPRIGHT", {227/255, 23/255, 13/255}) -- Hysteria
	},
	HUNTER = {}
};

P["unitframe"]["filters"] = {
	["buffwatch"] = {}
};

G.unitframe.ChannelTicks = {
	-- Warlock
	[SpellName(1120)] = 5, -- Drain Soul
	[SpellName(689)] = 5, -- Drain Life
	[SpellName(5138)] = 5, -- Drain Mana
	[SpellName(5740)] = 4, -- Rain of Fire
	[SpellName(755)] = 10, -- Health Funnel
	-- Druid
	[SpellName(44203)] = 4, -- Tranquility
	[SpellName(16914)] = 10, -- Hurricane
	-- Priest
	[SpellName(15407)] = 3, -- Mind Flay
	[SpellName(48045)] = 5, -- Mind Sear
	[SpellName(47540)] = 3, -- Penance
	-- Mage
	[SpellName(5143)] = 5, -- Arcane Missiles
	[SpellName(10)] = 8, -- Blizzard
	[SpellName(12051)] = 4 -- Evocation
};

G.unitframe.AuraBarColors = {
	[SpellName(2825)] = {r = 250/255, g = 146/255, b = 27/255},	-- Bloodlust
	[SpellName(32182)] = {r = 250/255, g = 146/255, b = 27/255} -- Heroism
};

G.unitframe.InvalidSpells = {

};

G.unitframe.DebuffHighlightColors = {
	[SpellName(25771)] = {enable = false, style = "FILL", color = {r = 0.85, g = 0, b = 0, a = 0.85}} -- Forbearance
};