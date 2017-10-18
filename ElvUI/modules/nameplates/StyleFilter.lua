local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule("NamePlates");
local LSM = LibStub("LibSharedMedia-3.0");

local ipairs = ipairs
local next = next
local pairs = pairs
local rawget = rawget
local rawset = rawset
local select = select
local setmetatable = setmetatable
local tonumber = tonumber
local type = type
local unpack = unpack

local strsplit = string.split
local tinsert = table.insert
local tsort = table.sort
local twipe = table.wipe
local hooksecurefunc = hooksecurefunc

local FAILED = FAILED
local INTERRUPTED = INTERRUPTED

local GetInstanceInfo = GetInstanceInfo
local GetSpellCharges = GetSpellCharges
local GetSpellCooldown = GetSpellCooldown
local GetSpellInfo = GetSpellInfo
local GetTalentInfo = GetTalentInfo
local GetTime = GetTime
local UnitAffectingCombat = UnitAffectingCombat
local UnitClassification = UnitClassification
local UnitGUID = UnitGUID
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitIsQuestBoss = UnitIsQuestBoss
local UnitIsUnit = UnitIsUnit
local UnitLevel = UnitLevel
local UnitName = UnitName
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitReaction = UnitReaction

function mod:StyleFilterAuraCheck(names, icons, mustHaveAll, missing, minTimeLeft, maxTimeLeft)
	local total, count = 0, 0
	for name, value in pairs(names) do
		if value == true then --only if they are turned on
			total = total + 1 --keep track of the names
		end
		for frameNum, icon in pairs(icons) do
			if icons[frameNum]:IsShown() and (value == true) and ((icon.name and icon.name == name) or (icon.spellID and icon.spellID == tonumber(name)))
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
	local total, count, duration, _ = 0, 0
	local _, gcd = GetSpellCooldown(61304)

	for name, value in pairs(names) do
		if value == "ONCD" or value == "OFFCD" then --only if they are turned on
			total = total + 1 --keep track of the names

			_, duration = GetSpellCooldown(name)

			if (duration > gcd and value == "ONCD")
			or (duration <= gcd and value == "OFFCD") then
				count = count + 1
				--print(((charges and charges == 0 and value == "ONCD") and name.." (charge) passes because it is on cd") or ((charges and charges > 0 and value == "OFFCD") and name.." (charge) passes because it is offcd") or ((charges == nil and (duration > gcd and value == "ONCD")) and name.."passes because it is on cd.") or ((charges == nil and (duration <= gcd and value == "OFFCD")) and name.." passes because it is off cd."))
			end
		end
	end

	if total == 0 then
		return nil
	else
		return (mustHaveAll and total == count) or (not mustHaveAll and count > 0)
	end
end

function mod:StyleFilterSetChanges(frame, actions, HealthColorChanged, BorderChanged, FlashingHealth, TextureChanged, ScaleChanged, AlphaChanged, NameColorChanged, NameOnlyChanged, VisibilityChanged)
	if VisibilityChanged then
		frame.StyleChanged = true
		frame.VisibilityChanged = true
		frame:Hide()
		return --We hide it. Lets not do other things (no point)
	end
	if HealthColorChanged then
		frame.StyleChanged = true
		frame.HealthColorChanged = true
		frame.HealthBar:SetStatusBarColor(actions.color.healthColor.r, actions.color.healthColor.g, actions.color.healthColor.b, actions.color.healthColor.a);
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
			frame.FlashTexture:SetTexture(LSM:Fetch("statusbar", self.db.statusbar))
		end
		frame.FlashTexture:SetVertexColor(actions.flash.color.r, actions.flash.color.g, actions.flash.color.b)
		frame.FlashTexture:SetAlpha(actions.flash.color.a)
		frame.FlashTexture:Show()
		E:Flash(frame.FlashTexture, actions.flash.speed * 0.1, true)
	end
	if TextureChanged then
		frame.StyleChanged = true
		frame.TextureChanged = true
		--frame.Highlight.texture:SetTexture(LSM:Fetch("statusbar", actions.texture.texture))
		frame.HealthBar:SetStatusBarTexture(LSM:Fetch("statusbar", actions.texture.texture))
		if FlashingHealth then
			frame.FlashTexture:SetTexture(LSM:Fetch("statusbar", actions.texture.texture))
		end
	end
	if ScaleChanged then
		frame.StyleChanged = true
		frame.ScaleChanged = true
		local scale = actions.scale
		frame.ActionScale = scale
		if frame.isTarget and self.db.useTargetScale then
			scale = scale * self.db.targetScale
		else
			scale = scale * (frame.ThreatScale or 1)
		end
		self:SetFrameScale(frame, scale)
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
		end
	end
	if NameOnlyChanged then
		frame.StyleChanged = true
		frame.NameOnlyChanged = true
		--hide the bars
		if frame.CastBar:IsShown() then frame.CastBar:Hide() end
		if frame.HealthBar:IsShown() then frame.HealthBar:Hide() end
		--hide the target indicator
		self:UpdateElement_Glow(frame)
		--position the name and update its color
		frame.Name:ClearAllPoints()
		frame.Name:SetJustifyH("CENTER")
		frame.Name:SetPoint("TOP", frame, "CENTER")
		frame.Level:ClearAllPoints()
		frame.Level:SetPoint("LEFT", frame.Name, "RIGHT")
		frame.Level:SetJustifyH("LEFT")
		if not NameColorChanged then
			self:UpdateElement_Name(frame, true)
		end
	end
end

function mod:StyleFilterClearChanges(frame, HealthColorChanged, BorderChanged, FlashingHealth, TextureChanged, ScaleChanged, AlphaChanged, NameColorChanged, NameOnlyChanged, VisibilityChanged)
	frame.StyleChanged = nil
	if VisibilityChanged then
		frame.VisibilityChanged = nil
		frame:Show()
	end
	if HealthColorChanged then
		frame.HealthColorChanged = nil
		frame.HealthBar:SetStatusBarColor(frame.HealthBar.r, frame.HealthBar.g, frame.HealthBar.b);
	end
	if BorderChanged then
		frame.BorderChanged = nil
		frame.HealthBar.bordertop:SetTexture(unpack(E.media.bordercolor))
		frame.HealthBar.borderbottom:SetTexture(unpack(E.media.bordercolor))
		frame.HealthBar.borderleft:SetTexture(unpack(E.media.bordercolor))
		frame.HealthBar.borderright:SetTexture(unpack(E.media.bordercolor))
	end
	if FlashingHealth then
		frame.FlashingHealth = nil
		E:StopFlash(frame.FlashTexture)
		frame.FlashTexture:Hide()
	end
	if TextureChanged then
		frame.TextureChanged = nil
	--	frame.Highlight.texture:SetTexture(LSM:Fetch("statusbar", self.db.statusbar))
		frame.HealthBar:SetStatusBarTexture(LSM:Fetch("statusbar", self.db.statusbar))
	end
	if ScaleChanged then
		frame.ScaleChanged = nil
		frame.ActionScale = nil
		if self.db.useTargetScale then
			if frame.isTarget then
				self:SetFrameScale(frame, (frame.ThreatScale or 1) * self.db.targetScale)
			else
				self:SetFrameScale(frame, frame.ThreatScale or 1)
			end
		end
	end
	if AlphaChanged then
		frame.AlphaChanged = nil
		if frame.isTarget then
			frame:SetAlpha(1)
		else
			frame:SetAlpha(1 - self.db.nonTargetTransparency)
		end
	end
	if NameColorChanged then
		frame.NameColorChanged = nil
		frame.Name:SetTextColor(frame.Name.r, frame.Name.g, frame.Name.b)
	end
	if NameOnlyChanged then
		frame.NameOnlyChanged = nil
		frame.TopLevelFrame = nil --We can safely clear this here because it is set upon `UpdateElement_Auras` if needed
		if self.db.units[frame.UnitType].healthbar.enable then
			frame.HealthBar:Show()
			self:UpdateElement_Glow(frame)
		end
		if self.db.units[frame.UnitType].showName then
			self:ConfigureElement_Level(frame)
			self:ConfigureElement_Name(frame)
			self:UpdateElement_Name(frame)
		else
			frame.Name:SetText()
		end
	end
end

function mod:StyleFilterConditionCheck(frame, filter, trigger, failed)
	local condition, name, inCombat, reaction, spell, classification;
	local talentSelected, talentFunction, talentRows, instanceName, instanceType, instanceDifficulty;
	local level, myLevel, curLevel, minLevel, maxLevel, matchMyLevel, mySpecID;
	local health, maxHealth, percHealth, underHealthThreshold, overHealthThreshold;

	local castbarShown = frame.CastBar:IsShown()
	local castbarTriggered = false --We use this to prevent additional calls to `UpdateElement_All` when the castbar hides
	local matchMyClass = false --Only check spec when we match the class condition

	if not failed and trigger.names and next(trigger.names) then
		condition = 0
		for unitName, value in pairs(trigger.names) do
			if value == true then --only check names that are checked
				condition = 1
				name = frame.UnitName
				if unitName and unitName ~= "" and unitName == name then
					condition = 2
					break
				end
			end
		end
		if condition ~= 0 then
			failed = (condition == 1)
		end
	end

	--Try to match by casting spell name or spell id
	if not failed and (trigger.casting and trigger.casting.spells) and next(trigger.casting.spells) then
		condition = 0
		for name, value in pairs(trigger.casting.spells) do
			if value == true then --only check spell that are checked
				condition = 1
				if castbarShown then
					spell = frame.CastBar.Name:GetText() --Make sure we can check spell name
					if spell and spell ~= "" and spell ~= FAILED and spell ~= INTERRUPTED then
						if tonumber(name) then
							name = GetSpellInfo(name)
						end
						if name and name == spell then
							condition = 2
							break
						end
					end
				end
			end
		end
		if condition ~= 0 then --If we cant check spell name, we ignore this trigger when the castbar is shown
			failed = (condition == 1)
			castbarTriggered = (condition == 2)
		end
	end

	--Try to match by casting interruptible
	if not failed and (trigger.casting and trigger.casting.interruptible) then
		condition = false
		if castbarShown and frame.CastBar.canInterrupt then
			condition = true
			castbarTriggered = true
		end
		failed = not condition
	end

	--Try to match by player health conditions
	if not failed and trigger.healthThreshold then
		condition = false
		health = (trigger.healthUsePlayer and UnitHealth("player")) or frame.oldHealthBar:GetValue() or 0
		maxHealth = (trigger.healthUsePlayer and UnitHealthMax("player")) or select(2, frame.oldHealthBar:GetMinMaxValues()) or 0
		percHealth = (maxHealth and (maxHealth > 0) and health/maxHealth) or 0
		underHealthThreshold = trigger.underHealthThreshold and (trigger.underHealthThreshold ~= 0) and (trigger.underHealthThreshold > percHealth)
		overHealthThreshold = trigger.overHealthThreshold and (trigger.overHealthThreshold ~= 0) and (trigger.overHealthThreshold < percHealth)
		if underHealthThreshold or overHealthThreshold then
			condition = true
		end
		failed = not condition
	end

	--Try to match by player combat conditions
	if not failed and (trigger.inCombat or trigger.outOfCombat) then
		condition = false
		inCombat = UnitAffectingCombat("player")
		if (trigger.inCombat and inCombat) or (trigger.outOfCombat and not inCombat) then
			condition = true
		end
		failed = not condition
	end

	--Try to match by target conditions
	if not failed and (trigger.isTarget or trigger.notTarget) then
		condition = false
		if (trigger.isTarget and frame.isTarget) or (trigger.notTarget and not frame.isTarget) then
			condition = true
		end
		failed = not condition
	end

	--Try to match by instance conditions
	if not failed and (trigger.instanceType.none or trigger.instanceType.scenario or trigger.instanceType.party or trigger.instanceType.raid or trigger.instanceType.arena or trigger.instanceType.pvp) then
		condition = false
		instanceName, instanceType, instanceDifficulty = GetInstanceInfo()
		if instanceType
		and ((trigger.instanceType.none		and instanceType == "none")
		or (trigger.instanceType.party		and instanceType == "party")
		or (trigger.instanceType.raid		and instanceType == "raid")
		or (trigger.instanceType.arena		and instanceType == "arena")
		or (trigger.instanceType.pvp		and instanceType == "pvp")) then
			condition = true
		end
		failed = not condition
	end

	--Try to match by instance difficulty
	if not failed and (trigger.instanceType.party or trigger.instanceType.raid) then
		if trigger.instanceType.party and instanceType == "party" and (trigger.instanceDifficulty.dungeon.normal or trigger.instanceDifficulty.dungeon.heroic) then
			condition = false
			if ((trigger.instanceDifficulty.dungeon.normal		and instanceDifficulty == 1)
			or (trigger.instanceDifficulty.dungeon.heroic		and instanceDifficulty == 2)) then
				condition = true
			end
			failed = not condition
		end

		if trigger.instanceType.raid and instanceType == "raid" and (trigger.instanceDifficulty.raid.normal or trigger.instanceDifficulty.raid.heroic) then
			condition = false;
			if ((trigger.instanceDifficulty.raid.normal		and instanceDifficulty == 14)
			or (trigger.instanceDifficulty.raid.heroic		and instanceDifficulty == 15)) then
				condition = true
			end
			failed = not condition
		end
	end

	--Try to match by level conditions
	if not failed and trigger.level then
		condition = false
		myLevel = UnitLevel("player")
		level = mod:UnitLevel(frame)
		level = level == "??" and -1 or tonumber(level)
		curLevel = (trigger.curlevel and trigger.curlevel ~= 0 and (trigger.curlevel == level))
		minLevel = (trigger.minlevel and trigger.minlevel ~= 0 and (trigger.minlevel <= level))
		maxLevel = (trigger.maxlevel and trigger.maxlevel ~= 0 and (trigger.maxlevel >= level))
		matchMyLevel = trigger.mylevel and (level == myLevel)
		if curLevel or minLevel or maxLevel or matchMyLevel then
			condition = true
		end
		failed = not condition
	end

	--Try to match by unit type
	if not failed and trigger.nameplateType and trigger.nameplateType.enable then
		condition = false

		if (trigger.nameplateType.friendlyPlayer and frame.UnitType=="FRIENDLY_PLAYER")
		or (trigger.nameplateType.friendlyNPC	 and frame.UnitType=="FRIENDLY_NPC")
		or (trigger.nameplateType.enemyPlayer	 and frame.UnitType=="ENEMY_PLAYER")
		or (trigger.nameplateType.enemyNPC		 and frame.UnitType=="ENEMY_NPC") then
			condition = true
		end

		failed = not condition
	end

	--Try to match by Reaction type
	if not failed and trigger.reactionType and trigger.reactionType.enable then
		reaction = frame.UnitReaction
		condition = false

		if ((reaction==1 or reaction==2 or reaction==3) and trigger.reactionType.hostile)
		or (reaction==4 and trigger.reactionType.neutral)
		or (reaction==5 and trigger.reactionType.friendly) then
			condition = true
		end

		failed = not condition
	end

	--Try to match according to cooldown conditions
	if not failed and trigger.cooldowns and trigger.cooldowns.names and next(trigger.cooldowns.names) then
		condition = self:StyleFilterCooldownCheck(trigger.cooldowns.names, trigger.cooldowns.mustHaveAll)
		if condition ~= nil then --Condition will be nil if none are set to ONCD or OFFCD
			failed = not condition
		end
	end

	--Try to match according to buff aura conditions
	if not failed and trigger.buffs and trigger.buffs.names and next(trigger.buffs.names) then
		condition = self:StyleFilterAuraCheck(trigger.buffs.names, frame.Buffs and frame.Buffs.icons, trigger.buffs.mustHaveAll, trigger.buffs.missing, trigger.buffs.minTimeLeft, trigger.buffs.maxTimeLeft)
		if condition ~= nil then --Condition will be nil if none are selected
			failed = not condition
		end
	end

	--Try to match according to debuff aura conditions
	if not failed and trigger.debuffs and trigger.debuffs.names and next(trigger.debuffs.names) then
		condition = self:StyleFilterAuraCheck(trigger.debuffs.names, frame.Debuffs and frame.Debuffs.icons, trigger.debuffs.mustHaveAll, trigger.debuffs.missing, trigger.debuffs.minTimeLeft, trigger.debuffs.maxTimeLeft)
		if condition ~= nil then --Condition will be nil if none are selected
			failed = not condition
		end
	end

	--Callback for Plugins
	if self.CustomStyleConditions then
		failed = self:CustomStyleConditions(frame, filter, trigger, failed)
	end

	--If failed is nil it means the filter is empty so we dont run FilterStyle
	if failed == false then --The conditions didn't fail so pass to FilterStyle
		self:StyleFilterPass(frame, filter.actions, castbarTriggered);
	end
end

function mod:StyleFilterPass(frame, actions, castbarTriggered)
	if castbarTriggered then
		frame.castbarTriggered = castbarTriggered
	end

	local healthBarShown = frame.HealthBar:IsShown()
	self:StyleFilterSetChanges(frame, actions,
		(healthBarShown and actions.color and actions.color.health), --HealthColorChanged
		(healthBarShown and actions.color and actions.color.border and frame.HealthBar.backdrop), --BorderChanged
		(healthBarShown and actions.flash and actions.flash.enable and frame.FlashTexture), --FlashingHealth
		(healthBarShown and actions.texture and actions.texture.enable), --TextureChanged
		(healthBarShown and actions.scale and actions.scale ~= 1), --ScaleChanged
		(actions.alpha and actions.alpha ~= -1), --AlphaChanged
		(actions.color and actions.color.name), --NameColorChanged
		(actions.nameOnly), --NameOnlyChanged
		(actions.hide) --VisibilityChanged
	)
end

function mod:ClearStyledPlate(frame)
	if frame.StyleChanged then
		self:StyleFilterClearChanges(frame, frame.HealthColorChanged, frame.BorderChanged, frame.FlashingHealth, frame.TextureChanged, frame.ScaleChanged, frame.AlphaChanged, frame.NameColorChanged, frame.NameOnlyChanged, frame.VisibilityChanged)
	end
end

function mod:StyleFilterSort(place)
	if self[2] and place[2] then
		return self[2] > place[2] --Sort by priority: 1=first, 2=second, 3=third, etc
	end
end

mod.StyleFilterList = {}
mod.StyleFilterEvents = {}
function mod:StyleFilterConfigureEvents()
	twipe(self.StyleFilterList)
	twipe(self.StyleFilterEvents)

	for filterName, filter in pairs(E.global.nameplates.filters) do
		if filter.triggers and E.db.nameplates and E.db.nameplates.filters then
			if E.db.nameplates.filters[filterName] and E.db.nameplates.filters[filterName].triggers and E.db.nameplates.filters[filterName].triggers.enable then
				tinsert(self.StyleFilterList, {filterName, filter.triggers.priority or 1})

				-- fake events along with "UpdateElement_Cast" (use 1 instead of true to override StyleFilterWaitTime)
				self.StyleFilterEvents["UpdateElement_All"] = true
				self.StyleFilterEvents["NAME_PLATE_UNIT_ADDED"] = 1

				if next(filter.triggers.casting.spells) then
					for name, value in pairs(filter.triggers.casting.spells) do
						if value == true then
							self.StyleFilterEvents["UpdateElement_Cast"] = 1
							break
						end
					end
				end

				if filter.triggers.casting.interruptible then
					self.StyleFilterEvents["UpdateElement_Cast"] = 1
				end

				-- real events
				self.StyleFilterEvents["PLAYER_TARGET_CHANGED"] = true

				if filter.triggers.healthThreshold then
					self.StyleFilterEvents["UNIT_HEALTH"] = true
					self.StyleFilterEvents["UNIT_MAXHEALTH"] = true
					self.StyleFilterEvents["UNIT_HEALTH_FREQUENT"] = true
				end

				if next(filter.triggers.names) then
					for unitName, value in pairs(filter.triggers.names) do
						if value == true then
							self.StyleFilterEvents["UNIT_NAME_UPDATE"] = true
							break
						end
					end
				end

				if filter.triggers.inCombat or filter.triggers.outOfCombat or filter.triggers.inCombatUnit or filter.triggers.outOfCombatUnit then
					self.StyleFilterEvents["UNIT_THREAT_LIST_UPDATE"] = true
				end

				if next(filter.triggers.cooldowns.names) then
					for name, value in pairs(filter.triggers.cooldowns.names) do
						if value == "ONCD" or value == "OFFCD" then
							self.StyleFilterEvents["SPELL_UPDATE_COOLDOWN"] = true
							break
						end
					end
				end

				if next(filter.triggers.buffs.names) then
					for name, value in pairs(filter.triggers.buffs.names) do
						if value == true then
							self.StyleFilterEvents["UNIT_AURA"] = true
							break
						end
					end
				end

				if next(filter.triggers.debuffs.names) then
					for name, value in pairs(filter.triggers.debuffs.names) do
						if value == true then
							self.StyleFilterEvents["UNIT_AURA"] = true
							break
						end
					end
				end
			end
		end
	end

	if next(self.StyleFilterList) then
		tsort(self.StyleFilterList, self.StyleFilterSort) --sort by priority
	else
		self:ForEachPlate("ClearStyledPlate")
	end
end

function mod:UpdateElement_Filters(frame, event)
	if not self.StyleFilterEvents[event] then return end

	--[[if self.StyleFilterEvents[event] == true then
		if not frame.StyleFilterWaitTime then
			frame.StyleFilterWaitTime = GetTime()
		elseif GetTime() > (frame.StyleFilterWaitTime + 0.1) then
			frame.StyleFilterWaitTime = nil
		else
			return --block calls faster than 0.1 second
		end
	end]]

	self:ClearStyledPlate(frame)

	for filterNum, filter in ipairs(self.StyleFilterList) do
		filter = E.global.nameplates.filters[self.StyleFilterList[filterNum][1]];
		if filter then
			self:StyleFilterConditionCheck(frame, filter, filter.triggers, nil)
		end
	end
end

-- Shamelessy taken from AceDB-3.0
local function copyDefaults(dest, src)
	-- this happens if some value in the SV overwrites our default value with a non-table
	--if type(dest) ~= "table" then return end
	for k, v in pairs(src) do
		if k == "*" or k == "**" then
			if type(v) == "table" then
				-- This is a metatable used for table defaults
				local mt = {
					-- This handles the lookup and creation of new subtables
					__index = function(t,k)
							if k == nil then return nil end
							local tbl = {}
							copyDefaults(tbl, v)
							rawset(t, k, tbl)
							return tbl
						end,
				}
				setmetatable(dest, mt)
				-- handle already existing tables in the SV
				for dk, dv in pairs(dest) do
					if not rawget(src, dk) and type(dv) == "table" then
						copyDefaults(dv, v)
					end
				end
			else
				-- Values are not tables, so this is just a simple return
				local mt = {__index = function(t,k) return k~=nil and v or nil end}
				setmetatable(dest, mt)
			end
		elseif type(v) == "table" then
			if not rawget(dest, k) then rawset(dest, k, {}) end
			if type(dest[k]) == "table" then
				copyDefaults(dest[k], v)
				if src['**'] then
					copyDefaults(dest[k], src['**'])
				end
			end
		else
			if rawget(dest, k) == nil then
				rawset(dest, k, v)
			end
		end
	end
end

local function removeDefaults(db, defaults, blocker)
	-- remove all metatables from the db, so we don't accidentally create new sub-tables through them
	setmetatable(db, nil)
	-- loop through the defaults and remove their content
	for k,v in pairs(defaults) do
		if k == "*" or k == "**" then
			if type(v) == "table" then
				-- Loop through all the actual k,v pairs and remove
				for key, value in pairs(db) do
					if type(value) == "table" then
						-- if the key was not explicitly specified in the defaults table, just strip everything from * and ** tables
						if defaults[key] == nil and (not blocker or blocker[key] == nil) then
							removeDefaults(value, v)
							-- if the table is empty afterwards, remove it
							if next(value) == nil then
								db[key] = nil
							end
						-- if it was specified, only strip ** content, but block values which were set in the key table
						elseif k == "**" then
							removeDefaults(value, v, defaults[key])
						end
					end
				end
			elseif k == "*" then
				-- check for non-table default
				for key, value in pairs(db) do
					if defaults[key] == nil and v == value then
						db[key] = nil
					end
				end
			end
		elseif type(v) == "table" and type(db[k]) == "table" then
			-- if a blocker was set, dive into it, to allow multi-level defaults
			removeDefaults(db[k], v, blocker and blocker[k])
			if next(db[k]) == nil then
				db[k] = nil
			end
		else
			-- check if the current value matches the default, and that its not blocked by another defaults table
			if db[k] == defaults[k] and (not blocker or blocker[k] == nil) then
				db[k] = nil
			end
		end
	end
end

function mod:PLAYER_LOGOUT()
	for filterName, filterTable in pairs(E.global.nameplates.filters) do
		if G.nameplates.filters[filterName] then
			local defaultTable = E:CopyTable({}, E.StyleFilterDefaults);
			E:CopyTable(defaultTable, G.nameplates.filters[filterName]);
			removeDefaults(filterTable, defaultTable);
		else
			removeDefaults(filterTable, E.StyleFilterDefaults);
		end
	end
end

function mod:StyleFilterInitializeFilter(tbl)
	copyDefaults(tbl, E.StyleFilterDefaults);
end