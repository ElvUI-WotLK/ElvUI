local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule("NamePlates")
local LSM = E.Libs.LSM

--Lua functions
local ipairs, next, pairs, rawget, rawset, select, setmetatable, tonumber, type, unpack, tostring = ipairs, next, pairs, rawget, rawset, select, setmetatable, tonumber, type, unpack, tostring
local tinsert, sort, twipe = table.insert, table.sort, table.wipe
local match = string.match
--WoW API / Variables
local GetInstanceInfo = GetInstanceInfo
local GetSpellCooldown = GetSpellCooldown
local GetSpellInfo = GetSpellInfo
local GetTime = GetTime
local UnitAffectingCombat = UnitAffectingCombat
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax

mod.TriggerConditions = {
	raidTargets = {
		STAR = "star",
		CIRCLE = "circle",
		DIAMOND = "diamond",
		TRIANGLE = "triangle",
		MOON = "moon",
		SQUARE = "square",
		CROSS = "cross",
		SKULL = "skull",
	},
	frameTypes = {
		["FRIENDLY_PLAYER"] = "friendlyPlayer",
		["FRIENDLY_NPC"] = "friendlyNPC",
		["ENEMY_PLAYER"] = "enemyPlayer",
		["ENEMY_NPC"] = "enemyNPC",
	},
	roles = {
		["TANK"] = "tank",
		["HEALER"] = "healer",
		["DAMAGER"] = "damager"
	},
	difficulties = {
		-- dungeons
		[1] = "normal",
		[2] = "heroic",
		-- raids
		[14] = "normal",
		[15] = "heroic",
	},
	totems = {},
	uniqueUnits = {}
}

local totemTypes = {
	air = { -- Air Totems
		[8177] = "a1",	-- Grounding Totem
		[10595] = "a2",	-- Nature Resistance Totem I
		[10600] = "a2",	-- Nature Resistance Totem II
		[10601] = "a2",	-- Nature Resistance Totem III
		[25574] = "a2",	-- Nature Resistance Totem IV
		[58746] = "a2",	-- Nature Resistance Totem V
		[58749] = "a2",	-- Nature Resistance Totem VI
		[6495] = "a3",	-- Sentry Totem
		[8512] = "a4",	-- Windfury Totem
		[3738] = "a5",	-- Wrath of Air Totem
	},
	earth = { -- Earth Totems
		[2062] = "e1",	-- Earth Elemental Totem
		[2484] = "e2",	-- Earthbind Totem
		[5730] = "e3",	-- Stoneclaw Totem I
		[6390] = "e3",	-- Stoneclaw Totem II
		[6391] = "e3",	-- Stoneclaw Totem III
		[6392] = "e3",	-- Stoneclaw Totem IV
		[10427] = "e3",	-- Stoneclaw Totem V
		[10428] = "e3",	-- Stoneclaw Totem VI
		[25525] = "e3",	-- Stoneclaw Totem VII
		[58580] = "e3",	-- Stoneclaw Totem VIII
		[58581] = "e3",	-- Stoneclaw Totem IX
		[58582] = "e3",	-- Stoneclaw Totem X
		[8071] = "e4",	-- Stoneskin Totem I -- Faction Champs
		[8154] = "e4",	-- Stoneskin Totem II
		[8155] = "e4",	-- Stoneskin Totem III
		[10406] = "e4",	-- Stoneskin Totem IV
		[10407] = "e4",	-- Stoneskin Totem V
		[10408] = "e4",	-- Stoneskin Totem VI
		[25508] = "e4",	-- Stoneskin Totem VII
		[25509] = "e4",	-- Stoneskin Totem VIII
		[58751] = "e4",	-- Stoneskin Totem IX
		[58753] = "e4",	-- Stoneskin Totem X
		[8075] = "e5",	-- Strength of Earth Totem I -- Faction Champs
		[8160] = "e5",	-- Strength of Earth Totem II
		[8161] = "e5",	-- Strength of Earth Totem III
		[10442] = "e5",	-- Strength of Earth Totem IV
		[25361] = "e5",	-- Strength of Earth Totem V
		[25528] = "e5",	-- Strength of Earth Totem VI
		[57622] = "e5",	-- Strength of Earth Totem VII
		[58643] = "e5",	-- Strength of Earth Totem VIII
		[8143] = "e6",	-- Tremor Totem
	},
	fire = { -- Fire Totems
		[2894] = "f1",	-- Fire Elemental Totem
		[8227] = "f2",	-- Flametongue Totem I -- Faction Champs
		[8249] = "f2",	-- Flametongue Totem II
		[10526] = "f2",	-- Flametongue Totem III
		[16387] = "f2",	-- Flametongue Totem IV
		[25557] = "f2",	-- Flametongue Totem V
		[58649] = "f2",	-- Flametongue Totem VI
		[58652] = "f2",	-- Flametongue Totem VII
		[58656] = "f2",	-- Flametongue Totem VIII
		[8181] = "f3",	-- Frost Resistance Totem I
		[10478] = "f3",	-- Frost Resistance Totem II
		[10479] = "f3",	-- Frost Resistance Totem III
		[25560] = "f3",	-- Frost Resistance Totem IV
		[58741] = "f3",	-- Frost Resistance Totem V
		[58745] = "f3",	-- Frost Resistance Totem VI
		[8190] = "f4",	-- Magma Totem I
		[10585] = "f4",	-- Magma Totem II
		[10586] = "f4",	-- Magma Totem III
		[10587] = "f4",	-- Magma Totem IV
		[25552] = "f4",	-- Magma Totem V
		[58731] = "f4",	-- Magma Totem VI
		[58734] = "f4",	-- Magma Totem VII
		[3599] = "f5",	-- Searing Totem I -- Faction Champs
		[6363] = "f5",	-- Searing Totem II
		[6364] = "f5",	-- Searing Totem III
		[6365] = "f5",	-- Searing Totem IV
		[10437] = "f5",	-- Searing Totem V
		[10438] = "f5",	-- Searing Totem VI
		[25533] = "f5",	-- Searing Totem VII
		[58699] = "f5",	-- Searing Totem VIII
		[58703] = "f5",	-- Searing Totem IX
		[58704] = "f5",	-- Searing Totem X
		[30706] = "f6",	-- Totem of Wrath I
		[57720] = "f6",	-- Totem of Wrath II
		[57721] = "f6",	-- Totem of Wrath III
		[57722] = "f6",	-- Totem of Wrath IV
	},
	water = { -- Water Totems
		[8170] = "w1",	-- Cleansing Totem
		[8184] = "w2",	-- Fire Resistance Totem I
		[10537] = "w2",	-- Fire Resistance Totem II
		[10538] = "w2",	-- Fire Resistance Totem III
		[25563] = "w2",	-- Fire Resistance Totem IV
		[58737] = "w2",	-- Fire Resistance Totem V
		[58739] = "w2",	-- Fire Resistance Totem VI
		[5394] = "w3",	-- Healing Stream Totem I -- Faction Champs
		[6375] = "w3",	-- Healing Stream Totem II
		[6377] = "w3",	-- Healing Stream Totem III
		[10462] = "w3",	-- Healing Stream Totem IV
		[10463] = "w3",	-- Healing Stream Totem V
		[25567] = "w3",	-- Healing Stream Totem VI
		[58755] = "w3",	-- Healing Stream Totem VII
		[58756] = "w3",	-- Healing Stream Totem VIII
		[58757] = "w3",	-- Healing Stream Totem IX
		[5675] = "w4",	-- Mana Spring Totem I
		[10495] = "w4",	-- Mana Spring Totem II
		[10496] = "w4",	-- Mana Spring Totem III
		[10497] = "w4",	-- Mana Spring Totem IV
		[25570] = "w4",	-- Mana Spring Totem V
		[58771] = "w4",	-- Mana Spring Totem VI
		[58773] = "w4",	-- Mana Spring Totem VII
		[58774] = "w4",	-- Mana Spring Totem VIII
		[16190] = "w5" 	-- Mana Tide Totem
	},
	other = {
		[724] = "o1"	-- Lightwell
	}
}

local totemRanks = {
	"",
	" II",
	" III",
	" IV",
	" V",
	" VI",
	" VII",
	" VIII",
	" IX",
	" X"
}

local uniqueUnitTypes = {
	pvp = {
		[34433] = "u1", -- Shadow Fiend
	},
	pve = {
		[72052] = "u2", -- Kinetic Bomb
	}
}

G.nameplates.uniqueUnitTypes = uniqueUnitTypes

for unitType, units in pairs(uniqueUnitTypes) do
	for spellID, unit in pairs(units) do
		local name, _, texture = GetSpellInfo(spellID)
		mod.TriggerConditions.uniqueUnits[unit] = {name, unitType, texture}
		mod.UniqueUnits[name] = unit
	end
end

for totemSchool, totems in pairs(totemTypes) do
	for spellID, totemID in pairs(totems) do
		local totemName, rank, texture = GetSpellInfo(spellID)

		if not mod.TriggerConditions.totems[totemID] then
			mod.TriggerConditions.totems[totemID] = {totemName, totemSchool, texture}
		end

		rank = totemRanks[tonumber(match(rank, ("%d+")))]

		if rank then
			totemName = totemName..rank
		else
			totemName = totemName
		end

		mod.Totems[totemName] = totemID
	end
end

G.nameplates.totemTypes = totemTypes

function mod:StyleFilterAuraCheck(names, icons, mustHaveAll, missing, minTimeLeft, maxTimeLeft)
	local total, count = 0, 0
	for name, value in pairs(names) do
		if value == true then --only if they are turned on
			total = total + 1 --keep track of the names
		end
		for _, icon in ipairs(icons) do
			if icon:IsShown() and (value == true) and ((icon.name and icon.name == name) or (icon.spellID and icon.spellID == tonumber(name)))
				and (not minTimeLeft or (minTimeLeft == 0 or (icon.expirationTime and (icon.expirationTime - GetTime()) > minTimeLeft))) and (not maxTimeLeft or (maxTimeLeft == 0 or (icon.expirationTime and (icon.expirationTime - GetTime()) < maxTimeLeft))) then
				count = count + 1 --keep track of how many matches we have
			end
		end
	end

	if total == 0 then
		return nil --If no auras are checked just pass nil, we dont need to run the filter here.
	else
		return ((mustHaveAll and not missing) and total == count)	-- [x] Check for all [ ] Missing: total needs to match count
		or ((not mustHaveAll and not missing) and count > 0)		-- [ ] Check for all [ ] Missing: count needs to be greater than zero
		or ((not mustHaveAll and missing) and count == 0)			-- [ ] Check for all [x] Missing: count needs to be zero
		or ((mustHaveAll and missing) and total ~= count)			-- [x] Check for all [x] Missing: count must not match total
	end
end

function mod:StyleFilterCooldownCheck(names, mustHaveAll)
	local total, count = 0, 0
	local _, gcd = GetSpellCooldown(61304)

	for name, value in pairs(names) do
		if value == "ONCD" or value == "OFFCD" then --only if they are turned on
			total = total + 1 --keep track of the names

			local _, duration = GetSpellCooldown(name)
			if (duration > gcd and value == "ONCD")
			or (duration <= gcd and value == "OFFCD") then
				count = count + 1
				--print(((duration > gcd and value == "ONCD") and name.."passes because it is on cd.") or ((duration <= gcd and value == "OFFCD") and name.." passes because it is off cd."))
			end
		end
	end

	if total == 0 then
		return nil
	else
		return (mustHaveAll and total == count) or (not mustHaveAll and count > 0)
	end
end

function mod:StyleFilterSetChanges(frame, actions, HealthColorChanged, BorderChanged, FlashingHealth, TextureChanged, ScaleChanged, FrameLevelChanged, AlphaChanged, NameColorChanged, NameOnlyChanged, VisibilityChanged, IconChanged, IconOnlyChanged)
	if VisibilityChanged then
		frame.StyleChanged = true
		frame.VisibilityChanged = true
		frame:Hide()
		return --We hide it. Lets not do other things (no point)
	end
	if FrameLevelChanged then
		frame.StyleChanged = true
		frame.FrameLevelChanged = actions.frameLevel -- we pass this to `ResetNameplateFrameLevel`
	end
	if HealthColorChanged then
		frame.StyleChanged = true
		frame.HealthColorChanged = true
		frame.Health:SetStatusBarColor(actions.color.healthColor.r, actions.color.healthColor.g, actions.color.healthColor.b, actions.color.healthColor.a)
		frame.CutawayHealth:SetStatusBarColor(actions.color.healthColor.r * 1.5, actions.color.healthColor.g * 1.5, actions.color.healthColor.b * 1.5, actions.color.healthColor.a)
	end
	if BorderChanged then --Lets lock this to the values we want (needed for when the media border color changes)
		frame.StyleChanged = true
		frame.BorderChanged = true
		frame.Health.bordertop:SetTexture(actions.color.borderColor.r, actions.color.borderColor.g, actions.color.borderColor.b, actions.color.borderColor.a)
		frame.Health.borderbottom:SetTexture(actions.color.borderColor.r, actions.color.borderColor.g, actions.color.borderColor.b, actions.color.borderColor.a)
		frame.Health.borderleft:SetTexture(actions.color.borderColor.r, actions.color.borderColor.g, actions.color.borderColor.b, actions.color.borderColor.a)
		frame.Health.borderright:SetTexture(actions.color.borderColor.r, actions.color.borderColor.g, actions.color.borderColor.b, actions.color.borderColor.a)
	end
	if FlashingHealth then
		frame.StyleChanged = true
		frame.FlashingHealth = true
		if not TextureChanged then
			frame.FlashTexture:SetTexture(LSM:Fetch("statusbar", mod.db.statusbar))
		end
		frame.FlashTexture:SetVertexColor(actions.flash.color.r, actions.flash.color.g, actions.flash.color.b)
		frame.FlashTexture:SetAlpha(actions.flash.color.a)
		frame.FlashTexture:Show()
		E:Flash(frame.FlashTexture, actions.flash.speed * 0.1, true)
	end
	if TextureChanged then
		frame.StyleChanged = true
		frame.TextureChanged = true
		local tex = LSM:Fetch("statusbar", actions.texture.texture)
		frame.Health.Highlight:SetTexture(tex)
		frame.Health:SetStatusBarTexture(tex)
		if FlashingHealth then
			frame.FlashTexture:SetTexture(tex)
		end
	end
	if ScaleChanged then
		frame.StyleChanged = true
		frame.ScaleChanged = true
		local scale = (frame.ThreatScale or 1)
		frame.ActionScale = actions.scale
		if frame.isTarget and mod.db.useTargetScale then
			scale = scale * mod.db.targetScale
		end
		mod:SetFrameScale(frame, scale * actions.scale)
	end
	if AlphaChanged then
		frame.StyleChanged = true
		frame.AlphaChanged = true
		mod:PlateFade(frame, mod.db.fadeIn and 1 or 0, frame:GetAlpha(), actions.alpha / 100)
	end
	if NameColorChanged then
		frame.StyleChanged = true
		frame.NameColorChanged = true
		local nameText = frame.oldName:GetText()
		if nameText and nameText ~= "" then
			frame.Name:SetTextColor(actions.color.nameColor.r, actions.color.nameColor.g, actions.color.nameColor.b, actions.color.nameColor.a)
			if mod.db.nameColoredGlow then
				frame.Name.NameOnlyGlow:SetVertexColor(actions.color.nameColor.r - 0.1, actions.color.nameColor.g - 0.1, actions.color.nameColor.b - 0.1, 1)
			end
		end
	end
	if NameOnlyChanged then
		frame.StyleChanged = true
		frame.NameOnlyChanged = true
		--hide the bars
		if frame.CastBar:IsShown() then frame.CastBar:Hide() end
		if frame.Health:IsShown() then frame.Health:Hide() end
		--hide the target indicator
		mod:Configure_Glow(frame)
		mod:Update_Glow(frame)
		--position the name and update its color
		frame.Name:ClearAllPoints()
		frame.Name:SetJustifyH("CENTER")
		frame.Name:SetPoint("TOP", frame)
		frame.Level:ClearAllPoints()
		frame.Level:SetPoint("LEFT", frame.Name, "RIGHT")
		frame.Level:SetJustifyH("LEFT")
		if not NameColorChanged then
			mod:Update_Name(frame, true)
		end
	end
	if IconChanged then
		frame.StyleChanged = true
		frame.IconChanged = true
		mod:Configure_IconFrame(frame)
		mod:Update_IconFrame(frame)
	end
	if IconOnlyChanged then
		frame.StyleChanged = true
		frame.IconOnlyChanged = true
		mod:Update_IconFrame(frame, true)
		if frame.Health:IsShown() then frame.Health:Hide() end
		frame.Level:Hide()
		frame.Name:Hide()
		mod:Configure_Glow(frame)
		mod:Update_Glow(frame)
		mod:Update_RaidIcon(frame)
		mod:Configure_IconOnlyGlow(frame)
		mod:Configure_NameOnlyGlow(frame)
	end
end

function mod:StyleFilterClearChanges(frame, HealthColorChanged, BorderChanged, FlashingHealth, TextureChanged, ScaleChanged, FrameLevelChanged, AlphaChanged, NameColorChanged, NameOnlyChanged, VisibilityChanged, IconChanged, IconOnlyChanged)
	frame.StyleChanged = nil
	if VisibilityChanged then
		frame.VisibilityChanged = nil
		mod:PlateFade(frame, mod.db.fadeIn and 1 or 0, 0, 1) -- fade those back in so it looks clean
		frame:Show()
	end
	if FrameLevelChanged then
		frame.FrameLevelChanged = nil
	end
	if HealthColorChanged then
		frame.HealthColorChanged = nil
		frame.Health:SetStatusBarColor(frame.Health.r, frame.Health.g, frame.Health.b)
		frame.CutawayHealth:SetStatusBarColor(frame.Health.r * 1.5, frame.Health.g * 1.5, frame.Health.b * 1.5, 1)
	end
	if BorderChanged then
		frame.BorderChanged = nil
		local r, g, b = unpack(E.media.bordercolor)
		frame.Health.bordertop:SetTexture(r, g, b)
		frame.Health.borderbottom:SetTexture(r, g, b)
		frame.Health.borderleft:SetTexture(r, g, b)
		frame.Health.borderright:SetTexture(r, g, b)
	end
	if FlashingHealth then
		frame.FlashingHealth = nil
		E:StopFlash(frame.FlashTexture)
		frame.FlashTexture:Hide()
	end
	if TextureChanged then
		frame.TextureChanged = nil
		local tex = LSM:Fetch("statusbar", mod.db.statusbar)
		frame.Health.Highlight:SetTexture(tex)
		frame.Health:SetStatusBarTexture(tex)
	end
	if ScaleChanged then
		frame.ScaleChanged = nil
		frame.ActionScale = nil
		local scale = frame.ThreatScale or 1
		if frame.isTarget and mod.db.useTargetScale then
			scale = scale * mod.db.targetScale
		end
		mod:SetFrameScale(frame, scale)
	end
	if AlphaChanged then
		frame.AlphaChanged = nil
		mod:PlateFade(frame, mod.db.fadeIn and 1 or 0, (frame.FadeObject and frame.FadeObject.endAlpha) or 0.5, 1)
	end
	if NameColorChanged then
		frame.NameColorChanged = nil
		frame.Name:SetTextColor(frame.Name.r, frame.Name.g, frame.Name.b)
	end
	if NameOnlyChanged then
		frame.NameOnlyChanged = nil
		frame.TopLevelFrame = nil --We can safely clear this here because it is set upon `UpdateElement_Auras` if needed
		if mod.db.units[frame.UnitType].health.enable or (frame.isTarget and mod.db.alwaysShowTargetHealth) then
			frame.Health:Show()
			mod:Configure_Glow(frame)
			mod:Update_Glow(frame)
		end
		if mod.db.units[frame.UnitType].name.enable then
			frame.Level:Show()
			frame.Name:ClearAllPoints()
			frame.Level:ClearAllPoints()
			mod:Update_Level(frame)
			mod:Update_Name(frame)
		else
			frame.Name:SetText()
		end
	end
	if IconChanged then
		frame.IconChanged = nil
		frame.IconFrame:Hide()
	end
	if IconOnlyChanged then
		frame.IconOnlyChanged = nil
		mod:Update_IconFrame(frame)
		if mod.db.units[frame.UnitType].iconFrame and mod.db.units[frame.UnitType].iconFrame.enable then
			mod:Configure_IconFrame(frame)
		end
		if mod.db.units[frame.UnitType].health.enable or (frame.isTarget and mod.db.alwaysShowTargetHealth) then
			frame.Health:Show()
			mod:Configure_Glow(frame)
			mod:Update_Glow(frame)
		end
		if mod.db.units[frame.UnitType].name.enable then
			frame.Name:Show()
			frame.Level:Show()
			frame.Name:ClearAllPoints()
			frame.Level:ClearAllPoints()
			mod:Update_Level(frame)
			mod:Update_Name(frame)
		else
			frame.Name:SetText()
		end
		mod:Update_RaidIcon(frame)
		mod:Configure_IconOnlyGlow(frame)
		mod:Configure_NameOnlyGlow(frame)
	end
end

function mod:StyleFilterConditionCheck(frame, filter, trigger)
	local passed -- skip StyleFilterPass when triggers are empty

	-- Name
	if trigger.names and next(trigger.names) then
		for _, value in pairs(trigger.names) do
			if value then -- only run if at least one is selected
				local name = trigger.names[frame.UnitName]
				if (not trigger.negativeMatch and name) or (trigger.negativeMatch and not name) then passed = true else return end
				break -- we can execute this once on the first enabled option then kill the loop
			end
		end
	end

	-- Health
	if trigger.healthThreshold then
		local health = (trigger.healthUsePlayer and UnitHealth("player")) or frame.oldHealthBar:GetValue() or 0
		local maxHealth = (trigger.healthUsePlayer and UnitHealthMax("player")) or select(2, frame.oldHealthBar:GetMinMaxValues()) or 0
		local percHealth = (maxHealth and (maxHealth > 0) and health/maxHealth) or 0
		local underHealthThreshold = trigger.underHealthThreshold and (trigger.underHealthThreshold ~= 0) and (trigger.underHealthThreshold > percHealth)
		local overHealthThreshold = trigger.overHealthThreshold and (trigger.overHealthThreshold ~= 0) and (trigger.overHealthThreshold < percHealth)
		if underHealthThreshold or overHealthThreshold then passed = true else return end
	end

	-- Power
	if trigger.powerThreshold then
		local power, maxPower = UnitPower("player"), UnitPowerMax("player")
		local percPower = (maxPower and (maxPower > 0) and power/maxPower) or 0
		local underPowerThreshold = trigger.underPowerThreshold and (trigger.underPowerThreshold ~= 0) and (trigger.underPowerThreshold > percPower)
		local overPowerThreshold = trigger.overPowerThreshold and (trigger.overPowerThreshold ~= 0) and (trigger.overPowerThreshold < percPower)
		if underPowerThreshold or overPowerThreshold then passed = true else return end
	end

	-- Require Target
	if trigger.requireTarget then
		if UnitExists("target") then passed = true else return end
	end

	-- Player Combat
	if trigger.inCombat or trigger.outOfCombat then
		local inCombat = UnitAffectingCombat("player")
		if (trigger.inCombat and inCombat) or (trigger.outOfCombat and not inCombat) then passed = true else return end
	end

	-- Player Target
	if trigger.isTarget or trigger.notTarget then
		if (trigger.isTarget and frame.isTarget) or (trigger.notTarget and not frame.isTarget) then passed = true else return end
	end

	-- Group Role
	if trigger.role.tank or trigger.role.healer or trigger.role.damager then
		if trigger.role[mod.TriggerConditions.roles[E:GetPlayerRole()]] then passed = true else return end
	end

	-- Instance Type
	if trigger.instanceType.none or trigger.instanceType.party or trigger.instanceType.raid or trigger.instanceType.arena or trigger.instanceType.pvp then
		local _, instanceType, difficultyID = GetInstanceInfo()
		if trigger.instanceType[instanceType] then
			passed = true

			-- Instance Difficulty
			if instanceType == "raid" or instanceType == "party" then
				local D = trigger.instanceDifficulty[(instanceType == "party" and "dungeon") or instanceType]
				for _, value in pairs(D) do
					if value and not D[mod.TriggerConditions.difficulties[difficultyID]] then return end
				end
			end
		else return end
	elseif trigger.instanceType.sanctuary then
		if UnitIsPVPSanctuary("player") then passed = true else return end
	end

	-- Level
	if trigger.level then
		local myLevel = E.mylevel
		local level = mod:UnitLevel(frame)
		level = level == "??" and -1 or tonumber(level)
		local curLevel = (trigger.curlevel and trigger.curlevel ~= 0 and (trigger.curlevel == level))
		local minLevel = (trigger.minlevel and trigger.minlevel ~= 0 and (trigger.minlevel <= level))
		local maxLevel = (trigger.maxlevel and trigger.maxlevel ~= 0 and (trigger.maxlevel >= level))
		local matchMyLevel = trigger.mylevel and (level == myLevel)
		if curLevel or minLevel or maxLevel or matchMyLevel then passed = true else return end
	end

	-- Unit Type
	if trigger.nameplateType and trigger.nameplateType.enable then
		if trigger.nameplateType[mod.TriggerConditions.frameTypes[frame.UnitType]] then passed = true else return end
	end

	-- Reaction Type
	if trigger.reactionType and trigger.reactionType.enable then
		local reaction = frame.UnitReaction
		if ((reaction == 1 or reaction == 2 or reaction == 3) and trigger.reactionType.hostile) or (reaction == 4 and trigger.reactionType.neutral) or (reaction == 5 and trigger.reactionType.friendly) then passed = true else return end
	end

	-- Raid Target
	if trigger.raidTarget.star or trigger.raidTarget.circle or trigger.raidTarget.diamond or trigger.raidTarget.triangle or trigger.raidTarget.moon or trigger.raidTarget.square or trigger.raidTarget.cross or trigger.raidTarget.skull then
		if trigger.raidTarget[mod.TriggerConditions.raidTargets[frame.RaidIconType]] then passed = true else return end
	end

	-- Casting
	if trigger.casting then
		local b, c = frame.CastBar, trigger.casting

		-- Spell
		if b.spellName then
			if c.spells and next(c.spells) then
				for _, value in pairs(c.spells) do
					if value then -- only run if at least one is selected
						local _, _, _, _, _, _, spellID = GetSpellInfo(b.spellName)
						local castingSpell = (spellID and c.spells[tostring(spellID)]) or c.spells[b.spellName]
						if (c.notSpell and not castingSpell) or (castingSpell and not c.notSpell) then passed = true else return end
						break -- we can execute this once on the first enabled option then kill the loop
					end
				end
			end
		end

		-- Status
		if c.isCasting or c.isChanneling or c.notCasting or c.notChanneling then
			if (c.isCasting and b.casting) or (c.isChanneling and b.channeling)
			or (c.notCasting and not b.casting) or (c.notChanneling and not b.channeling) then passed = true else return end
		end

		-- Interruptible
		if c.interruptible or c.notInterruptible then
			if (b.casting or b.channeling) and ((c.interruptible and not b.notInterruptible)
			or (c.notInterruptible and b.notInterruptible)) then passed = true else return end
		end
	end

	-- Cooldown
	if trigger.cooldowns and trigger.cooldowns.names and next(trigger.cooldowns.names) then
		local cooldown = mod:StyleFilterCooldownCheck(trigger.cooldowns.names, trigger.cooldowns.mustHaveAll)
		if cooldown ~= nil then -- ignore if none are set to ONCD or OFFCD
			if cooldown then passed = true else return end
		end
	end

	-- Buffs
	if frame.Buffs and trigger.buffs and trigger.buffs.names and next(trigger.buffs.names) then
		local buff = mod:StyleFilterAuraCheck(trigger.buffs.names, frame.Buffs, trigger.buffs.mustHaveAll, trigger.buffs.missing, trigger.buffs.minTimeLeft, trigger.buffs.maxTimeLeft)
		if buff ~= nil then -- ignore if none are selected
			if buff then passed = true else return end
		end
	end

	-- Debuffs
	if frame.Debuffs and trigger.debuffs and trigger.debuffs.names and next(trigger.debuffs.names) then
		local debuff = mod:StyleFilterAuraCheck(trigger.debuffs.names, frame.Debuffs, trigger.debuffs.mustHaveAll, trigger.debuffs.missing, trigger.debuffs.minTimeLeft, trigger.debuffs.maxTimeLeft)
		if debuff ~= nil then -- ignore if none are selected
			if debuff then passed = true else return end
		end
	end

	-- Totems
	if frame.UnitName and trigger.totems.enable then
		local totem = mod.Totems[frame.UnitName]
		if totem then if trigger.totems[totem] then passed = true else return end end
	end

	-- Unique Units
	if frame.UnitName and trigger.uniqueUnits.enable then
		local unit = mod.UniqueUnits[frame.UnitName]
		if unit then if trigger.uniqueUnits[unit] then passed = true else return end end
	end

	-- Plugin Callback
	if mod.StyleFilterCustomChecks then
		for _, customCheck in pairs(mod.StyleFilterCustomChecks) do
			local custom = customCheck(frame, filter, trigger)
			if custom ~= nil then -- ignore if nil return
				if custom then passed = true else return end
			end
		end
	end

	-- Pass it along
	if passed then
		mod:StyleFilterPass(frame, filter.actions)
	end
end

function mod:StyleFilterPass(frame, actions)
	local healthBarEnabled = (frame.UnitType and mod.db.units[frame.UnitType].health.enable) or (frame.isTarget and mod.db.alwaysShowTargetHealth)
	local healthBarShown = healthBarEnabled and frame.Health:IsShown()

	mod:StyleFilterSetChanges(frame, actions,
		(healthBarShown and actions.color and actions.color.health), --HealthColorChanged
		(healthBarShown and actions.color and actions.color.border and frame.Health.backdrop), --BorderChanged
		(healthBarShown and actions.flash and actions.flash.enable and frame.FlashTexture), --FlashingHealth
		(healthBarShown and actions.texture and actions.texture.enable), --TextureChanged
		(healthBarShown and actions.scale and actions.scale ~= 1), --ScaleChanged
		(actions.frameLevel and actions.frameLevel ~= 0), --FrameLevelChanged
		(actions.alpha and actions.alpha ~= -1), --AlphaChanged
		(actions.color and actions.color.name), --NameColorChanged
		(actions.nameOnly), --NameOnlyChanged
		(actions.hide), --VisibilityChanged
		(actions.icon), --IconChanged
		(actions.iconOnly) --IconOnlyChanged
	)
end

function mod:StyleFilterClear(frame)
	if frame and frame.StyleChanged then
		mod:StyleFilterClearChanges(frame, frame.HealthColorChanged, frame.BorderChanged, frame.FlashingHealth, frame.TextureChanged, frame.ScaleChanged, frame.FrameLevelChanged, frame.AlphaChanged, frame.NameColorChanged, frame.NameOnlyChanged, frame.VisibilityChanged, frame.IconChanged, frame.IconOnlyChanged)
	end
end

function mod:StyleFilterSort(place)
	if self[2] and place[2] then
		return self[2] > place[2] --Sort by priority: 1=first, 2=second, 3=third, etc
	end
end

function mod:StyleFilterClearVariables(nameplate)
	nameplate.ActionScale = nil
	nameplate.ThreatScale = nil
end

mod.StyleFilterTriggerList = {}
mod.StyleFilterTriggerEvents = {}
function mod:StyleFilterConfigure()
	twipe(mod.StyleFilterTriggerList)
	twipe(mod.StyleFilterTriggerEvents)

	for filterName, filter in pairs(E.global.nameplates.filters) do
		local t = filter.triggers
		if t and E.db.nameplates and E.db.nameplates.filters then
			if E.db.nameplates.filters[filterName] and E.db.nameplates.filters[filterName].triggers and E.db.nameplates.filters[filterName].triggers.enable then
				tinsert(mod.StyleFilterTriggerList, {filterName, t.priority or 1})

				mod.StyleFilterTriggerEvents.UpdateElement_All = 1
				mod.StyleFilterTriggerEvents.NAME_PLATE_UNIT_ADDED = 1

				if t.casting then
					if next(t.casting.spells) then
						for _, value in pairs(t.casting.spells) do
							if value then
								mod.StyleFilterTriggerEvents.FAKE_Casting = 0
								break
					end end end

					if (t.casting.interruptible or t.casting.notInterruptible)
					or (t.casting.isCasting or t.casting.isChanneling or t.casting.notCasting or t.casting.notChanneling) then
						mod.StyleFilterTriggerEvents.FAKE_Casting = 0
					end
				end

				if t.raidTarget and (t.raidTarget.star or t.raidTarget.circle or t.raidTarget.diamond or t.raidTarget.triangle or t.raidTarget.moon or t.raidTarget.square or t.raidTarget.cross or t.raidTarget.skull) then
					mod.StyleFilterTriggerEvents.RAID_TARGET_UPDATE = 1
				end

				-- real events
				mod.StyleFilterTriggerEvents.PLAYER_TARGET_CHANGED = true

				if t.healthThreshold then
					mod.StyleFilterTriggerEvents.UNIT_HEALTH = 1
					mod.StyleFilterTriggerEvents.UNIT_MAXHEALTH = 1
				end

				if t.powerThreshold then
					mod.StyleFilterTriggerEvents.UNIT_MANA = 1
					mod.StyleFilterTriggerEvents.UNIT_ENERGY = 1
					mod.StyleFilterTriggerEvents.UNIT_FOCUS = 1
					mod.StyleFilterTriggerEvents.UNIT_RAGE = 1
					mod.StyleFilterTriggerEvents.UNIT_RUNIC_POWER = 1
					mod.StyleFilterTriggerEvents.UNIT_DISPLAYPOWER = 1
				end

				if t.names and next(t.names) then
					for _, value in pairs(t.names) do
						if value then
							mod.StyleFilterTriggerEvents.UNIT_NAME_UPDATE = 1
							break
				end end end

				if t.inCombat or t.outOfCombat then
					mod.StyleFilterTriggerEvents.PLAYER_REGEN_DISABLED = true
					mod.StyleFilterTriggerEvents.PLAYER_REGEN_ENABLED = true
				end

				if t.cooldowns and t.cooldowns.names and next(t.cooldowns.names) then
					for _, value in pairs(t.cooldowns.names) do
						if value == "ONCD" or value == "OFFCD" then
							mod.StyleFilterTriggerEvents.SPELL_UPDATE_COOLDOWN = 1
							break
				end end end

				if t.buffs and t.buffs.names and next(t.buffs.names) then
					for _, value in pairs(t.buffs.names) do
						if value then
							mod.StyleFilterTriggerEvents.UNIT_AURA = true
							break
				end end end

				if t.debuffs and t.debuffs.names and next(t.debuffs.names) then
					for _, value in pairs(t.debuffs.names) do
						if value then
							mod.StyleFilterTriggerEvents.UNIT_AURA = true
							break
				end end end
			end
		end
	end

	if next(mod.StyleFilterTriggerList) then
		sort(mod.StyleFilterTriggerList, mod.StyleFilterSort) -- sort by priority
	else
		mod:ForEachPlate("StyleFilterClear")
	end
end

function mod:StyleFilterUpdate(frame, event)
	local hasEvent = mod.StyleFilterTriggerEvents[event]
	if not hasEvent then
		return
	elseif hasEvent == true then -- skip on 1 or 0
		if not frame.StyleFilterWaitTime then
			frame.StyleFilterWaitTime = GetTime()
		elseif GetTime() > (frame.StyleFilterWaitTime + 0.1) then
			frame.StyleFilterWaitTime = nil
		else
			return -- block calls faster than 0.1 second
		end
	end

	mod:StyleFilterClear(frame)

	for filterNum in ipairs(mod.StyleFilterTriggerList) do
		local filter = E.global.nameplates.filters[mod.StyleFilterTriggerList[filterNum][1]]
		if filter then
			mod:StyleFilterConditionCheck(frame, filter, filter.triggers)
		end
	end
end

function mod:StyleFilterAddCustomCheck(name, func)
	if not mod.StyleFilterCustomChecks then
		mod.StyleFilterCustomChecks = {}
	end

	mod.StyleFilterCustomChecks[name] = func
end

function mod:StyleFilterRemoveCustomCheck(name)
	if not mod.StyleFilterCustomChecks then
		return
	end

	mod.StyleFilterCustomChecks[name] = nil
end

-- Shamelessy taken from AceDB-3.0 and stripped down by Simpy
local function copyDefaults(dest, src)
	for k, v in pairs(src) do
		if type(v) == "table" then
			if not rawget(dest, k) then rawset(dest, k, {}) end
			if type(dest[k]) == "table" then copyDefaults(dest[k], v) end
		elseif rawget(dest, k) == nil then
			rawset(dest, k, v)
		end
	end
end

local function removeDefaults(db, defaults)
	setmetatable(db, nil)

	for k, v in pairs(defaults) do
		if type(v) == "table" and type(db[k]) == "table" then
			removeDefaults(db[k], v)
			if next(db[k]) == nil then db[k] = nil end
		elseif db[k] == defaults[k] then
			db[k] = nil
		end
	end
end

function mod:StyleFilterClearDefaults()
	for filterName, filterTable in pairs(E.global.nameplates.filters) do
		if G.nameplates.filters[filterName] then
			local defaultTable = E:CopyTable({}, E.StyleFilterDefaults)
			E:CopyTable(defaultTable, G.nameplates.filters[filterName])
			removeDefaults(filterTable, defaultTable)
		else
			removeDefaults(filterTable, E.StyleFilterDefaults)
		end
	end
end

function mod:StyleFilterCopyDefaults(tbl)
	copyDefaults(tbl, E.StyleFilterDefaults)
end

function mod:StyleFilterInitialize()
	for _, filterTable in pairs(E.global.nameplates.filters) do
		mod:StyleFilterCopyDefaults(filterTable)
	end
end