local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

--Lua functions
local print, unpack = print, unpack
--WoW API / Variables
local GetSpellInfo = GetSpellInfo

local function SpellName(id)
	local name = GetSpellInfo(id)
	if not name then
		print("|cff1784d1ElvUI:|r SpellID is not valid: "..id..". Please check for an updated version, if none exists report to ElvUI author.")
		return "Impale"
	else
		return name
	end
end

local function Defaults(priorityOverride)
	return {
		enable = true,
		priority = priorityOverride or 0,
		stackThreshold = 0
	}
end

G.unitframe.aurafilters = {}

-- These are debuffs that are some form of CC
G.unitframe.aurafilters.CCDebuffs = {
	type = "Whitelist",
	spells = {
	-- Death Knight
		[SpellName(47476)] = Defaults(), -- Strangulate
		[SpellName(51209)] = Defaults(), -- Hungering Cold
	-- Druid
		[SpellName(99)] = Defaults(), -- Demoralizing Roar
		[SpellName(339)] = Defaults(), -- Entangling Roots
		[SpellName(2637)] = Defaults(), -- Hibernate
		[SpellName(5211)] = Defaults(), -- Bash
		[SpellName(9005)] = Defaults(), -- Pounce
		[SpellName(22570)] = Defaults(), -- Maim
		[SpellName(33786)] = Defaults(), -- Cyclone
		[SpellName(45334)] = Defaults(), -- Feral Charge Effect
	-- Hunter
		[SpellName(1513)] = Defaults(), -- Scare Beast
		[SpellName(3355)] = Defaults(), -- Freezing Trap Effect
		[SpellName(19386)] = Defaults(), -- Wyvern Sting
		[SpellName(19503)] = Defaults(), -- Scatter Shot
		[SpellName(24394)] = Defaults(), -- Intimidation
		[SpellName(34490)] = Defaults(), -- Silencing Shot
		[SpellName(50245)] = Defaults(), -- Pin
		[SpellName(50519)] = Defaults(), -- Sonic Blast
		[SpellName(50541)] = Defaults(), -- Snatch
		[SpellName(54706)] = Defaults(), -- Venom Web Spray
		[SpellName(56626)] = Defaults(), -- Sting
		[SpellName(60210)] = Defaults(), -- Freezing Arrow Effect
		[SpellName(64803)] = Defaults(), -- Entrapment
	-- Mage
		[SpellName(118)] = Defaults(), -- Polymorph (Sheep)
		[SpellName(122)] = Defaults(), -- Frost Nova
		[SpellName(18469)] = Defaults(), -- Silenced - Improved Counterspell (Rank 1)
		[SpellName(31589)] = Defaults(), -- Slow
		[SpellName(31661)] = Defaults(), -- Dragon's Breath
		[SpellName(33395)] = Defaults(), -- Freeze
		[SpellName(44572)] = Defaults(), -- Deep Freeze
		[SpellName(55080)] = Defaults(), -- Shattered Barrier
		[SpellName(61305)] = Defaults(), -- Polymorph (Black Cat)
		[SpellName(55021)] = Defaults(), -- Silenced - Improved Counterspell (Rank 2)
	-- Paladin
		[SpellName(853)] = Defaults(), -- Hammer of Justice
		[SpellName(10326)] = Defaults(), -- Turn Evil
		[SpellName(20066)] = Defaults(), -- Repentance
		[SpellName(31935)] = Defaults(), -- Avenger's Shield
	-- Priest
		[SpellName(605)] = Defaults(), -- Mind Control
		[SpellName(8122)] = Defaults(), -- Psychic Scream
		[SpellName(9484)] = Defaults(), -- Shackle Undead
		[SpellName(15487)] = Defaults(), -- Silence
		[SpellName(64044)] = Defaults(), -- Psychic Horror
	-- Rogue
		[SpellName(408)] = Defaults(), -- Kidney Shot
		[SpellName(1330)] = Defaults(), -- Garrote - Silence
		[SpellName(1776)] = Defaults(), -- Gouge
		[SpellName(1833)] = Defaults(), -- Cheap Shot
		[SpellName(2094)] = Defaults(), -- Blind
		[SpellName(6770)] = Defaults(), -- Sap
		[SpellName(18425)] = Defaults(), -- Silenced - Improved Kick
		[SpellName(51722)] = Defaults(), -- Dismantle
	-- Shaman
		[SpellName(3600)] = Defaults(), -- Earthbind
		[SpellName(8056)] = Defaults(), -- Frost Shock
		[SpellName(39796)] = Defaults(), -- Stoneclaw Stun
		[SpellName(51514)] = Defaults(), -- Hex
		[SpellName(63685)] = Defaults(), -- Freeze
		[SpellName(64695)] = Defaults(), -- Earthgrab
	-- Warlock
		[SpellName(710)] = Defaults(), -- Banish
		[SpellName(5782)] = Defaults(), -- Fear
		[SpellName(6358)] = Defaults(), -- Seduction
		[SpellName(6789)] = Defaults(), -- Death Coil
		[SpellName(17928)] = Defaults(), -- Howl of Terror
		[SpellName(24259)] = Defaults(), -- Spell Lock
		[SpellName(30283)] = Defaults(), -- Shadowfury
	-- Warrior
		[SpellName(676)] = Defaults(), -- Disarm
		[SpellName(7922)] = Defaults(), -- Charge Stun
		[SpellName(18498)] = Defaults(), -- Silenced - Gag Order
		[SpellName(20511)] = Defaults(), -- Intimidating Shout
	-- Racial
		[SpellName(25046)] = Defaults(), -- Arcane Torrent
		[SpellName(20549)] = Defaults(), -- War Stomp
	-- The Lich King
		[SpellName(73787)] = Defaults(), -- Necrotic Plague
	}
}

G.unitframe.aurafilters.TurtleBuffs = {
	type = "Whitelist",
	spells = {
	-- Mage
		[SpellName(45438)] = Defaults(5), -- Ice Block
	-- Death Knight
		[SpellName(48707)] = Defaults(5), -- Anti-Magic Shell
		[SpellName(48792)] = Defaults(), -- Icebound Fortitude
		[SpellName(49039)] = Defaults(), -- Lichborne
		[SpellName(50461)] = Defaults(), -- Anti-Magic Zone
		[SpellName(55233)] = Defaults(), -- Vampiric Blood
	-- Priest
		[SpellName(33206)] = Defaults(3), -- Pain Suppression
		[SpellName(47585)] = Defaults(5), -- Dispersion
		[SpellName(47788)] = Defaults(), -- Guardian Spirit
	-- Warlock

	-- Druid
		[SpellName(22812)] = Defaults(2), -- Barkskin
		[SpellName(61336)] = Defaults(), -- Survival Instincts
	-- Hunter
		[SpellName(19263)] = Defaults(5), -- Deterrence
		[SpellName(53480)] = Defaults(), -- Roar of Sacrifice
	-- Rogue
		[SpellName(5277)] = Defaults(5), -- Evasion
		[SpellName(31224)] = Defaults(), -- Cloak of Shadows
		[SpellName(45182)] = Defaults(), -- Cheating Death
	-- Shaman
		[SpellName(30823)] = Defaults(), -- Shamanistic Rage
	-- Paladin
		[SpellName(498)] = Defaults(2), -- Divine Protection
		[SpellName(642)] = Defaults(5), -- Divine Shield
		[SpellName(1022)] = Defaults(5), -- Hand of Protection
		[SpellName(6940)] = Defaults(), -- Hand of Sacrifice
		[SpellName(31821)] = Defaults(3), -- Aura Mastery
	-- Warrior
		[SpellName(871)] = Defaults(3), -- Shield Wall
		[SpellName(55694)] = Defaults(), -- Enraged Regeneration
	}
}

G.unitframe.aurafilters.PlayerBuffs = {
	type = "Whitelist",
	spells = {
	-- Mage
		[SpellName(12042)] = Defaults(), -- Arcane Power
		[SpellName(12051)] = Defaults(), -- Evocation
		[SpellName(12472)] = Defaults(), -- Icy Veins
		[SpellName(32612)] = Defaults(), -- Invisibility
		[SpellName(45438)] = Defaults(), -- Ice Block
	-- Death Knight
		[SpellName(48707)] = Defaults(), -- Anti-Magic Shell
		[SpellName(48792)] = Defaults(), -- Icebound Fortitude
		[SpellName(49016)] = Defaults(), -- Hysteria
		[SpellName(49039)] = Defaults(), -- Lichborne
		[SpellName(49222)] = Defaults(), -- Bone Shield
		[SpellName(50461)] = Defaults(), -- Anti-Magic Zone
		[SpellName(51271)] = Defaults(), -- Unbreakable Armor
		[SpellName(55233)] = Defaults(), -- Vampiric Blood
	-- Priest
		[SpellName(6346)] = Defaults(), -- Fear Ward
		[SpellName(10060)] = Defaults(), -- Power Infusion
		[SpellName(27827)] = Defaults(), -- Spirit of Redemption
		[SpellName(33206)] = Defaults(), -- Pain Suppression
		[SpellName(47585)] = Defaults(), -- Dispersion
		[SpellName(47788)] = Defaults(), -- Guardian Spirit
	-- Warlock

	-- Druid
		[SpellName(1850)] = Defaults(), -- Dash
		[SpellName(22812)] = Defaults(), -- Barkskin
		[SpellName(52610)] = Defaults(), -- Savage Roar
	-- Hunter
		[SpellName(3045)] = Defaults(), -- Rapid Fire
		[SpellName(5384)] = Defaults(), -- Feign Death
		[SpellName(19263)] = Defaults(), -- Deterrence
		[SpellName(53480)] = Defaults(), -- Roar of Sacrifice (Cunning)
		[SpellName(54216)] = Defaults(), -- Master's Call
	-- Rogue
		[SpellName(2983)] = Defaults(), -- Sprint
		[SpellName(5277)] = Defaults(), -- Evasion
		[SpellName(11327)] = Defaults(), -- Vanish
		[SpellName(13750)] = Defaults(), -- Adrenaline Rush
		[SpellName(31224)] = Defaults(), -- Cloak of Shadows
		[SpellName(45182)] = Defaults(), -- Cheating Death
	-- Shaman
		[SpellName(2825)] = Defaults(), -- Bloodlust
		[SpellName(8178)] = Defaults(), -- Grounding Totem Effect
		[SpellName(16166)] = Defaults(), -- Elemental Mastery
		[SpellName(16188)] = Defaults(), -- Nature's Swiftness
		[SpellName(16191)] = Defaults(), -- Mana Tide
		[SpellName(30823)] = Defaults(), -- Shamanistic Rage
		[SpellName(32182)] = Defaults(), -- Heroism
		[SpellName(58875)] = Defaults(), -- Spirit Walk
	-- Paladin
		[SpellName(498)] = Defaults(), -- Divine Protection
		[SpellName(1022)] = Defaults(), -- Hand of Protection
		[SpellName(1044)] = Defaults(), -- Hand of Freedom
		[SpellName(6940)] = Defaults(), -- Hand of Sacrifice
		[SpellName(31821)] = Defaults(), -- Aura Mastery
		[SpellName(31842)] = Defaults(), -- Divine Illumination
		[SpellName(31850)] = Defaults(), -- Ardent Defender
		[SpellName(31884)] = Defaults(), -- Avenging Wrath
		[SpellName(53563)] = Defaults(), -- Beacon of Light
	-- Warrior
		[SpellName(871)] = Defaults(), -- Shield Wall
		[SpellName(1719)] = Defaults(), -- Recklessness
		[SpellName(3411)] = Defaults(), -- Intervene
		[SpellName(12292)] = Defaults(), -- Death Wish
		[SpellName(12975)] = Defaults(), -- Last Stand
		[SpellName(18499)] = Defaults(), -- Berserker Rage
		[SpellName(23920)] = Defaults(), -- Spell Reflection
		[SpellName(46924)] = Defaults(), -- Bladestorm
	-- Racial
		[SpellName(20594)] = Defaults(), -- Stoneform
		[SpellName(59545)] = Defaults(), -- Gift of the Naaru
		[SpellName(20572)] = Defaults(), -- Blood Fury
		[SpellName(26297)] = Defaults(), -- Berserking
	}
}

-- Buffs that really we dont need to see
G.unitframe.aurafilters.Blacklist = {
	type = "Blacklist",
	spells = {
		[6788] = Defaults(), -- Weakened Soul
		[SpellName(8326)] = Defaults(), -- Ghost
		[15007] = Defaults(), -- Resurrection Sickness
		[23445] = Defaults(), -- Evil Twin
		[24755] = Defaults(), -- Tricked or Treated
		[25771] = Defaults(), -- Forbearance
		[26013] = Defaults(), -- Deserter
		[SpellName(36032)] = Defaults(), -- Arcane Blast
		[SpellName(36893)] = Defaults(), -- Transporter Malfunction
		[36900] = Defaults(), -- Soul Split: Evil!
		[36901] = Defaults(), -- Soul Split: Good
		[41425] = Defaults(), -- Hypothermia
		[55711] = Defaults(), -- Weakened Heart
		[57723] = Defaults(), -- Exhaustion
		[57724] = Defaults(), -- Sated
		[58539] = Defaults(), -- Watcher's Corpse
		[SpellName(67604)] = Defaults(), -- Powering Up
		[69127] = Defaults(), -- Chill of the Throne
		[71041] = Defaults(), -- Dungeon Deserter
	-- Festergut
		[SpellName(70852)] = Defaults(), -- Malleable Goo
		[72144] = Defaults(), -- Orange Blight Residue
		[SpellName(73034)] = Defaults(), -- Blighted Spores
	-- Rotface
		[72145] = Defaults(), -- Green Blight Residue
	-- Professor Putricide
		[SpellName(72460)] = Defaults(), -- Choking Gas
		[SpellName(72511)] = Defaults(), -- Mutated Transformation
	-- Blood Prince Council
		[SpellName(71911)] = Defaults(), -- Shadow Resonance
	},
}

--[[
	This should be a list of important buffs that we always want to see when they are active
	bloodlust, paladin hand spells, raid cooldowns, etc..
]]
G.unitframe.aurafilters.Whitelist = {
	type = "Whitelist",
	spells = {
		[SpellName(1022)] = Defaults(), -- Hand of Protection
		[SpellName(1490)] = Defaults(), -- Curse of the Elements
		[SpellName(2825)] = Defaults(), -- Bloodlust
		[SpellName(12051)] = Defaults(), -- Evocation
		[SpellName(18708)] = Defaults(), -- Fel Domination
		[SpellName(29166)] = Defaults(), -- Innervate
		[SpellName(31821)] = Defaults(), -- Aura Mastery
		[SpellName(32182)] = Defaults(), -- Heroism
		[SpellName(47788)] = Defaults(), -- Guardian Spirit
		[SpellName(54428)] = Defaults(), -- Divine Plea
	-- Turtling abilities
		[SpellName(871)] = Defaults(), -- Shield Wall
		[SpellName(19263)] = Defaults(), -- Deterrence
		[SpellName(22812)] = Defaults(), -- Barkskin
		[SpellName(31224)] = Defaults(), -- Cloak of Shadows
		[SpellName(33206)] = Defaults(), -- Pain Suppression
		[SpellName(48707)] = Defaults(), -- Anti-Magic Shell
	-- Immunities
		[SpellName(642)] = Defaults(), -- Divine Shield
		[SpellName(45438)] = Defaults(), -- Ice Block
	-- Offensive
		[SpellName(12292)] = Defaults(), -- Death Wish
		[SpellName(31884)] = Defaults(), -- Avenging Wrath
		[SpellName(34471)] = Defaults(), -- The Beast Within
	}
}

-- RAID DEBUFFS: This should be pretty self explainitory
G.unitframe.aurafilters.RaidDebuffs = {
	type = "Whitelist",
	spells = {
	-- Naxxramas
		-- Anub'Rekhan
		[SpellName(54022)] = Defaults(), -- Locust Swarm
		-- Grand Widow Faerlina
		[SpellName(54098)] = Defaults(), -- Poison Bolt Volley
		-- Maexxna
		[SpellName(54121)] = Defaults(), -- Necrotic Poison
		[SpellName(54125)] = Defaults(), -- Web Spray
		-- Gluth
		[SpellName(29306)] = Defaults(), -- Infected Wound
		[SpellName(54378)] = Defaults(), -- Mortal Wound
		-- Gothik the Harvester
		[SpellName(27825)] = Defaults(), -- Shadow Mark
		[SpellName(28679)] = Defaults(), -- Harvest Soul
		[SpellName(55645)] = Defaults(), -- Death Plague
		-- The Four Horsemem
		[SpellName(28832)] = Defaults(), -- Mark of Korth'azz
		[SpellName(28833)] = Defaults(), -- Mark of Blaumeux
		[SpellName(28834)] = Defaults(), -- Mark of Rivendare
		[SpellName(28835)] = Defaults(), -- Mark of Zeliek
		[SpellName(57369)] = Defaults(), -- Unholy Shadow
		-- Noth the Plaguebringer
		[SpellName(29212)] = Defaults(), -- Cripple
		[SpellName(29213)] = Defaults(), -- Curse of the Plaguebringer
		[SpellName(29214)] = Defaults(), -- Wrath of the Plaguebringer
		-- Heigan the Unclean
		[SpellName(29310)] = Defaults(), -- Spell Disruption
		[SpellName(29998)] = Defaults(), -- Decrepit Fever
		-- Loatheb
		[SpellName(55052)] = Defaults(), -- Inevitable Doom
		[SpellName(55053)] = Defaults(), -- Deathbloom
		-- Sapphiron
		[SpellName(28522)] = Defaults(), -- Icebolt
		[SpellName(55665)] = Defaults(), -- Life Drain
		[SpellName(55699)] = Defaults(), -- Chill
		-- Kel'Thuzad
		[SpellName(28410)] = Defaults(), -- Chains of Kel'Thuzad
		[SpellName(27819)] = Defaults(), -- Detonate Mana
		[SpellName(27808)] = Defaults(), -- Frost Blast

	-- Ulduar
		-- Ignis the Furnace Master
		[SpellName(62717)] = Defaults(), -- Slag Pot

		-- XT-002
		[SpellName(63024)] = Defaults(), -- Gravity Bomb
		[SpellName(63018)] = Defaults(), -- Light Bomb

		-- The Assembly of Iron
		[SpellName(61903)] = Defaults(), -- Fusion Punch
		[SpellName(61912)] = Defaults(), -- Static Disruption

		-- Kologarn
		[SpellName(64290)] = Defaults(), -- Stone Grip

		-- Thorim
		[SpellName(62130)] = Defaults(), -- Unbalancing Strike

		-- Yogg-Saron
		[SpellName(63134)] = Defaults(), -- Sara's Blessing
		[SpellName(64157)] = Defaults(), -- Curse of Doom

		-- Algalon
		[SpellName(64412)] = Defaults(), -- Phase Punch

	-- Trial of the Crusader
		-- Beast of Northrend
		-- Gormok the Impaler
		[SpellName(66331)] = Defaults(), -- Impale
		[SpellName(66406)] = Defaults(), -- Snowbolled!
		-- Jormungar Behemoth
		[SpellName(66869)] = Defaults(), -- Burning Bile
		[SpellName(67618)] = Defaults(), -- Paralytic Toxin
		-- Icehowl
		[SpellName(66689)] = Defaults(), -- Arctic Breathe

		-- Lord Jaraxxus
		[SpellName(66237)] = Defaults(), -- Incinerate Flesh
		[SpellName(66197)] = Defaults(), -- Legion Flame

		-- Faction Champions
		[SpellName(65812)] = Defaults(), -- Unstable Affliction

		-- The Twin Val'kyr
		[SpellName(67309)] = Defaults(), -- Twin Spike

		-- Anub'arak
		[SpellName(66013)] = Defaults(), -- Penetrating Cold
		[SpellName(67574)] = Defaults(), -- Pursued by Anub'arak
		[SpellName(67847)] = Defaults(), -- Expose Weakness

	-- Icecrown Citadel
		-- Lord Marrowgar
		[SpellName(69065)] = Defaults(), -- Impaled

		-- Lady Deathwhisper
		[SpellName(72109)] = Defaults(), -- Death and Decay
		[SpellName(71289)] = Defaults(), -- Dominate Mind
		[SpellName(71237)] = Defaults(), -- Curse of Torpor

		-- Deathbringer Saurfang
		[SpellName(72293)] = Defaults(), -- Mark of the Fallen Champion
		[SpellName(72442)] = Defaults(), -- Boiling Blood
		[SpellName(72449)] = Defaults(), -- Rune of Blood
		[SpellName(72769)] = Defaults(), -- Scent of Blood

		-- Festergut
		[SpellName(71218)] = Defaults(), -- Vile Gas
		[SpellName(72219)] = Defaults(), -- Gastric Bloat
		[SpellName(69279)] = Defaults(), -- Gas Spore

		-- Rotface
		[SpellName(71224)] = Defaults(), -- Mutated Infection

		-- Professor Putricide
		[SpellName(71278)] = Defaults(), -- Choking Gas Bomb
		[SpellName(70215)] = Defaults(), -- Gaseous Bloat
		[SpellName(72549)] = Defaults(), -- Malleable Goo
		[SpellName(70953)] = Defaults(), -- Plague Sickness
		[SpellName(72856)] = Defaults(), -- Unbound Plague
		[SpellName(70447)] = Defaults(), -- Volatile Ooze Adhesive

		-- Blood Prince Council
		[SpellName(72796)] = Defaults(), -- Glittering Sparks
		[SpellName(71822)] = Defaults(), -- Shadow Resonance

		-- Blood-Queen Lana'thel
		[SpellName(72265)] = Defaults(), -- Delirious Slash
		[SpellName(71473)] = Defaults(), -- Essence of the Blood Queen
		[SpellName(71474)] = Defaults(), -- Frenzied Bloodthirst
		[SpellName(71340)] = Defaults(), -- Pact of the Darkfallen
		[SpellName(71265)] = Defaults(), -- Swarming Shadows
		[SpellName(70923)] = Defaults(), -- Uncontrollable Frenzy

		-- Valithria Dreamwalker
		[SpellName(71733)] = Defaults(), -- Acid Burst
		[SpellName(71738)] = Defaults(), -- Corrosion
		[SpellName(70873)] = Defaults(), -- Emerald Vigor
		[SpellName(71283)] = Defaults(), -- Gut Spray

		-- Sindragosa
		[SpellName(70106)] = Defaults(), -- Chilled to the Bone
		[SpellName(70126)] = Defaults(), -- Frost Beacon
		[SpellName(70157)] = Defaults(), -- Ice Tomb
		[SpellName(69766)] = Defaults(), -- Instability
		[SpellName(69762)] = Defaults(), -- Unchained Magic

		-- The Lich King
		[SpellName(72762)] = Defaults(), -- Defile
		[SpellName(70541)] = Defaults(), -- Infest
		[SpellName(70337)] = Defaults(), -- Necrotic plague
		[SpellName(72149)] = Defaults(), -- Shockwave
		[SpellName(69409)] = Defaults(), -- Soul Reaper
		[SpellName(69242)] = Defaults(), -- Soul Shriek

	-- The Ruby Sanctum
		-- Trash
		-- Baltharus the Warborn
		[SpellName(75887)] = Defaults(), -- Blazing Aura
		[SpellName(74502)] = Defaults(), -- Enervating Brand
		-- General Zarithrian
		[SpellName(74367)] = Defaults(), -- Cleave Armor

		-- Halion
		[SpellName(74562)] = Defaults(), -- Fiery Combustion
		[SpellName(74567)] = Defaults(), -- Mark of Combustion
		[SpellName(74792)] = Defaults(), -- Soul Consumption
		[SpellName(74795)] = Defaults(), -- Mark of Consumption
	},
}

--Spells that we want to show the duration backwards
E.ReverseTimer = {

}

-- BuffWatch: List of personal spells to show on unitframes as icon
local function ClassBuff(id, point, color, anyUnit, onlyShowMissing, style, displayText, decimalThreshold, textColor, textThreshold, xOffset, yOffset, sizeOverride)
	local r, g, b = unpack(color)

	local r2, g2, b2 = 1, 1, 1
	if textColor then
		r2, g2, b2 = unpack(textColor)
	end

	return {
		enabled = true,
		id = id,
		point = point,
		color = {r = r, g = g, b = b},
		anyUnit = anyUnit,
		onlyShowMissing = onlyShowMissing,
		style = style or "coloredIcon",
		displayText = displayText or false,
		decimalThreshold = decimalThreshold or 5,
		textColor = {r = r2, g = g2, b = b2},
		textThreshold = textThreshold or -1,
		xOffset = xOffset or 0,
		yOffset = yOffset or 0,
		sizeOverride = sizeOverride or 0
	}
end

G.unitframe.buffwatch = {
	PRIEST = {
		[6788] = ClassBuff(6788, "TOPLEFT", {1, 0, 0}, true),				-- Weakened Soul
		[10060] = ClassBuff(10060, "RIGHT", {0.89, 0.09, 0.05}),			-- Power Infusion
		[48066] = ClassBuff(48066, "BOTTOMRIGHT", {0.81, 0.85, 0.1}, true), -- Power Word: Shield
		[48068] = ClassBuff(48068, "BOTTOMLEFT", {0.4, 0.7, 0.2}),			-- Renew
		[48111] = ClassBuff(48111, "TOPRIGHT", {0.2, 0.7, 0.2}),			-- Prayer of Mending
	},
	DRUID = {
		[48441] = ClassBuff(48441, "TOPRIGHT", {0.8, 0.4, 0.8}),			-- Rejuvenation
		[48443] = ClassBuff(48443, "BOTTOMLEFT", {0.2, 0.8, 0.2}),			-- Regrowth
		[48451] = ClassBuff(48451, "TOPLEFT", {0.4, 0.8, 0.2}),				-- Lifebloom
		[53251] = ClassBuff(53251, "BOTTOMRIGHT", {0.8, 0.4, 0}),			-- Wild Growth
	},
	PALADIN = {
		[1038] = ClassBuff(1038, "BOTTOMRIGHT", {0.9, 0.78, 0}, true),		-- Hand of Salvation
		[1044] = ClassBuff(1044, "BOTTOMRIGHT", {0.86, 0.45, 0}, true),		-- Hand of Freedom
		[6940] = ClassBuff(6940, "BOTTOMRIGHT", {0.89, 0.09, 0.05}, true),	-- Hand of Sacrifice
		[10278] = ClassBuff(10278, "BOTTOMRIGHT", {0.2, 0.2, 1}, true),		-- Hand of Protection
		[53563] = ClassBuff(53563, "TOPLEFT", {0.7, 0.3, 0.7}),				-- Beacon of Light
		[53601] = ClassBuff(53601, "TOPRIGHT", {0.4, 0.7, 0.2}),			-- Sacred Shield
	},
	SHAMAN = {
		[16237] = ClassBuff(16237, "BOTTOMLEFT", {0.4, 0.7, 0.2}),			-- Ancestral Fortitude
		[49284] = ClassBuff(49284, "TOPRIGHT", {0.2, 0.7, 0.2}),			-- Earth Shield
		[52000] = ClassBuff(52000, "BOTTOMRIGHT", {0.7, 0.4, 0}),			-- Earthliving
		[61301] = ClassBuff(61301, "TOPLEFT", {0.7, 0.3, 0.7}),				-- Riptide
	},
	ROGUE = {
		[57933] = ClassBuff(57933, "TOPRIGHT", {0.89, 0.09, 0.05}),			-- Tricks of the Trade
	},
	MAGE = {
		[54646] = ClassBuff(54646, "TOPRIGHT", {0.2, 0.2, 1}),				-- Focus Magic
	},
	WARRIOR = {
		[3411] = ClassBuff(3411, "TOPRIGHT", {0.89, 0.09, 0.05}),			-- Intervene
		[59665] = ClassBuff(59665, "TOPLEFT", {0.2, 0.2, 1}),				-- Vigilance
	},
	DEATHKNIGHT = {
		[49016] = ClassBuff(49016, "TOPRIGHT", {0.89, 0.09, 0.05})			-- Hysteria
	},
	PET = {
		[1539] = ClassBuff(1539, "TOPLEFT", {0.81, 0.85, 0.1}, true),		-- Feed Pet
		[48990] = ClassBuff(48990, "TOPRIGHT", {0.2, 0.8, 0.2}, true)		-- Mend Pet
	},
	HUNTER = {},
	WARLOCK = {},
}

-- Profile specific BuffIndicator
P.unitframe.filters = {
	buffwatch = {}
}

-- Ticks
G.unitframe.ChannelTicks = {
	-- Warlock
	[SpellName(1120)] = 5,	-- Drain Soul
	[SpellName(689)] = 5,	-- Drain Life
	[SpellName(5138)] = 5,	-- Drain Mana
	[SpellName(5740)] = 4,	-- Rain of Fire
	[SpellName(755)] = 10,	-- Health Funnel
	[SpellName(1949)] = 15,	-- Hellfire
	-- Druid
	[SpellName(44203)] = 4,	-- Tranquility
	[SpellName(16914)] = 10, -- Hurricane
	-- Priest
	[SpellName(15407)] = 3,	-- Mind Flay
	[SpellName(48045)] = 5,	-- Mind Sear
	[SpellName(47540)] = 3,	-- Penance
	[SpellName(64843)] = 4,	-- Divine Hymn
	[SpellName(64901)] = 4,	-- Hymn of Hope
	-- Mage
	[SpellName(5143)] = 5,	-- Arcane Missiles
	[SpellName(10)] = 8,	-- Blizzard
	[SpellName(12051)] = 4,	-- Evocation
	-- Hunter
	[SpellName(58434)] = 6,	-- Volley
	-- Death Knight
	[SpellName(42650)] = 8,	-- Army of the Dead
}

-- This should probably be the same as the whitelist filter + any personal class ones that may be important to watch
G.unitframe.AuraBarColors = {
	[SpellName(2825)] = {r = 0.98, g = 0.57, b = 0.10},		-- Bloodlust
	[SpellName(32182)] = {r = 0.98, g = 0.57, b = 0.10},	-- Heroism
}

G.unitframe.DebuffHighlightColors = {
	[25771] = {enable = false, style = "FILL", color = {r = 0.85, g = 0, b = 0, a = 0.85}}, -- Forbearance
}

G.unitframe.specialFilters = {
	-- Whitelists
	Personal = true,
	nonPersonal = true,
	CastByUnit = true,
	notCastByUnit = true,
	Dispellable = true,
	notDispellable = true,

	-- Blacklists
	blockNonPersonal = true,
	blockNoDuration = true,
	blockDispellable = true,
	blockNotDispellable = true,
}