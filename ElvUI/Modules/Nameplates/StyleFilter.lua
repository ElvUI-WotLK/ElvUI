local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule("NamePlates")
local LSM = E.Libs.LSM

--Lua functions
local ipairs, next, pairs, rawget, rawset, select, setmetatable, tonumber, type, unpack, tostring = ipairs, next, pairs, rawget, rawset, select, setmetatable, tonumber, type, unpack, tostring
local tinsert, sort, twipe = table.insert, table.sort, table.wipe
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
	}
}

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

function mod:StyleFilterSetChanges(frame, actions, HealthColorChanged, BorderChanged, FlashingHealth, TextureChanged, ScaleChanged, FrameLevelChanged, AlphaChanged, NameColorChanged, NameOnlyChanged, VisibilityChanged)
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
		frame.HealthBar:SetStatusBarColor(actions.color.healthColor.r, actions.color.healthColor.g, actions.color.healthColor.b, actions.color.healthColor.a)
		frame.CutawayHealth:SetStatusBarColor(actions.color.healthColor.r * 1.5, actions.color.healthColor.g * 1.5, actions.color.healthColor.b * 1.5, actions.color.healthColor.a)
	end
	if BorderChanged then --Lets lock this to the values we want (needed for when the media border color changes)
		frame.StyleChanged = true
		frame.BorderChanged = true
		frame.HealthBar.bordertop:SetTexture(actions.color.borderColor.r, actions.color.borderColor.g, actions.color.borderColor.b, actions.color.borderColor.a)
		frame.HealthBar.borderbottom:SetTexture(actions.color.borderColor.r, actions.color.borderColor.g, actions.color.borderColor.b, actions.color.borderColor.a)
		frame.HealthBar.borderleft:SetTexture(actions.color.borderColor.r, actions.color.borderColor.g, actions.color.borderColor.b, actions.color.borderColor.a)
		frame.HealthBar.borderright:SetTexture(actions.color.borderColor.r, actions.color.borderColor.g, actions.color.borderColor.b, actions.color.borderColor.a)
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
		frame.HealthBar.Highlight:SetTexture(tex)
		frame.HealthBar:SetStatusBarTexture(tex)
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
		frame:SetAlpha(actions.alpha / 100)
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
		if frame.HealthBar:IsShown() then frame.HealthBar:Hide() end
		--hide the target indicator
		mod:UpdateElement_Glow(frame)
		--position the name and update its color
		frame.Name:ClearAllPoints()
		frame.Name:SetJustifyH("CENTER")
		frame.Name:SetPoint("TOP", frame, "CENTER")
		frame.Level:ClearAllPoints()
		frame.Level:SetPoint("LEFT", frame.Name, "RIGHT")
		frame.Level:SetJustifyH("LEFT")
		if not NameColorChanged then
			mod:UpdateElement_Name(frame, true)
		end
	end
end

function mod:StyleFilterClearChanges(frame, HealthColorChanged, BorderChanged, FlashingHealth, TextureChanged, ScaleChanged, FrameLevelChanged, AlphaChanged, NameColorChanged, NameOnlyChanged, VisibilityChanged)
	frame.StyleChanged = nil
	if VisibilityChanged then
		frame.VisibilityChanged = nil
		frame:Show()
	end
	if FrameLevelChanged then
		frame.FrameLevelChanged = nil
	end
	if HealthColorChanged then
		frame.HealthColorChanged = nil
		frame.HealthBar:SetStatusBarColor(frame.HealthBar.r, frame.HealthBar.g, frame.HealthBar.b)
		frame.CutawayHealth:SetStatusBarColor(frame.HealthBar.r * 1.5, frame.HealthBar.g * 1.5, frame.HealthBar.b * 1.5, 1)
	end
	if BorderChanged then
		frame.BorderChanged = nil
		local r, g, b = unpack(E.media.bordercolor)
		frame.HealthBar.bordertop:SetTexture(r, g, b)
		frame.HealthBar.borderbottom:SetTexture(r, g, b)
		frame.HealthBar.borderleft:SetTexture(r, g, b)
		frame.HealthBar.borderright:SetTexture(r, g, b)
	end
	if FlashingHealth then
		frame.FlashingHealth = nil
		E:StopFlash(frame.FlashTexture)
		frame.FlashTexture:Hide()
	end
	if TextureChanged then
		frame.TextureChanged = nil
		local tex = LSM:Fetch("statusbar", mod.db.statusbar)
		frame.HealthBar.Highlight:SetTexture(tex)
		frame.HealthBar:SetStatusBarTexture(tex)
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
		if frame.isTarget then
			frame:SetAlpha(1)
		else
			frame:SetAlpha(1 - mod.db.nonTargetTransparency)
		end
	end
	if NameColorChanged then
		frame.NameColorChanged = nil
		frame.Name:SetTextColor(frame.Name.r, frame.Name.g, frame.Name.b)
	end
	if NameOnlyChanged then
		frame.NameOnlyChanged = nil
		frame.TopLevelFrame = nil --We can safely clear this here because it is set upon `UpdateElement_Auras` if needed
		if mod.db.units[frame.UnitType].healthbar.enable or (frame.isTarget and mod.db.alwaysShowTargetHealth) then
			frame.HealthBar:Show()
			mod:UpdateElement_Glow(frame)
		end
		if mod.db.units[frame.UnitType].showName then
			mod:ConfigureElement_Level(frame)
			mod:ConfigureElement_Name(frame)
			mod:UpdateElement_Name(frame)
		else
			frame.Name:SetText()
		end
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

	-- Unit Combat
	if trigger.inCombatUnit or trigger.outOfCombatUnit then
		local inCombat = UnitAffectingCombat("player")
		if (trigger.inCombatUnit and inCombat) or (trigger.outOfCombatUnit and not inCombat) then passed = true else return end
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
	local healthBarEnabled = (frame.UnitType and mod.db.units[frame.UnitType].healthbar.enable) or (frame.isTarget and mod.db.alwaysShowTargetHealth)
	local healthBarShown = healthBarEnabled and frame.HealthBar:IsShown()

	mod:StyleFilterSetChanges(frame, actions,
		(healthBarShown and actions.color and actions.color.health), --HealthColorChanged
		(healthBarShown and actions.color and actions.color.border and frame.HealthBar.backdrop), --BorderChanged
		(healthBarShown and actions.flash and actions.flash.enable and frame.FlashTexture), --FlashingHealth
		(healthBarShown and actions.texture and actions.texture.enable), --TextureChanged
		(healthBarShown and actions.scale and actions.scale ~= 1), --ScaleChanged
		(actions.frameLevel and actions.frameLevel ~= 0), --FrameLevelChanged
		(actions.alpha and actions.alpha ~= -1), --AlphaChanged
		(actions.color and actions.color.name), --NameColorChanged
		(actions.nameOnly), --NameOnlyChanged
		(actions.hide) --VisibilityChanged
	)
end

function mod:StyleFilterClear(frame)
	if frame and frame.StyleChanged then
		mod:StyleFilterClearChanges(frame, frame.HealthColorChanged, frame.BorderChanged, frame.FlashingHealth, frame.TextureChanged, frame.ScaleChanged, frame.FrameLevelChanged, frame.AlphaChanged, frame.NameColorChanged, frame.NameOnlyChanged, frame.VisibilityChanged)
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

				-- real events
				mod.StyleFilterTriggerEvents.PLAYER_TARGET_CHANGED = 1

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

				if t.inCombat or t.outOfCombat or t.inCombatUnit or t.outOfCombatUnit then
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

function mod:UpdateElement_Filters(frame, event)
	if not mod.StyleFilterTriggerEvents[event] then return end

	--[[if mod.StyleFilterTriggerEvents[event] == true then
		if not frame.StyleFilterWaitTime then
			frame.StyleFilterWaitTime = GetTime()
		elseif GetTime() > (frame.StyleFilterWaitTime + 0.1) then
			frame.StyleFilterWaitTime = nil
		else
			return --block calls faster than 0.1 second
		end
	end]]

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