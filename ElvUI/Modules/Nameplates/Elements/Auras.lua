local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule("NamePlates")
local LSM = E.Libs.LSM
local LAI = E.Libs.LAI

--Lua functions
local select, unpack, pairs = select, unpack, pairs
local band = bit.band
local tinsert = table.insert
local floor = math.floor
local find, split = string.find, string.split
--WoW API / Variables
local CreateFrame = CreateFrame
local GetSpellInfo = GetSpellInfo
local GetTime = GetTime
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

local CREATED, VISIBLE, HIDDEN = 2, 1, 0

local positionValues = {
	TOPLEFT = "BOTTOM",
	TOPRIGHT = "BOTTOM",
	BOTTOMLEFT = "TOP",
	BOTTOMRIGHT = "TOP"
}

local positionValues2 = {
	TOPLEFT = "TOP",
	TOPRIGHT = "TOP",
	BOTTOMLEFT = "BOTTOM",
	BOTTOMRIGHT = "BOTTOM"
}


local RaidIconBit = {
	["STAR"] = 0x00100000,
	["CIRCLE"] = 0x00200000,
	["DIAMOND"] = 0x00400000,
	["TRIANGLE"] = 0x00800000,
	["MOON"] = 0x01000000,
	["SQUARE"] = 0x02000000,
	["CROSS"] = 0x04000000,
	["SKULL"] = 0x08000000
}

local ByRaidIcon = {}

function NP:LibAuraInfo_AURA_APPLIED(event, destGUID)
	self:UpdateElement_AurasByGUID(destGUID, event)
end

function NP:LibAuraInfo_AURA_REMOVED(event, destGUID)
	self:UpdateElement_AurasByGUID(destGUID, event)
end

function NP:LibAuraInfo_AURA_REFRESH(event, destGUID)
	self:LibAuraInfo_AURA_APPLIED(event, destGUID)
end

function NP:LibAuraInfo_AURA_APPLIED_DOSE(event, destGUID)
	self:LibAuraInfo_AURA_APPLIED(event, destGUID)
end

function NP:LibAuraInfo_AURA_CLEAR(event, destGUID)
	self:UpdateElement_AurasByGUID(destGUID, event)
end

function NP:LibAuraInfo_UNIT_AURA(event, destGUID)
	self:UpdateElement_AurasByGUID(destGUID, event)
end

function NP:UpdateTime(elapsed)
	self.timeLeft = self.timeLeft - elapsed
	self:SetValue(self.timeLeft)

	if self.nextUpdate > 0 then
		self.nextUpdate = self.nextUpdate - elapsed
		return
	end

	local value, id, nextUpdate, remainder = E:GetTimeInfo(self.timeLeft, self.threshold, self.hhmmThreshold, self.mmssThreshold)
	self.nextUpdate = nextUpdate

	local style = E.TimeFormats[id]
	if style then
		local which = (self.textColors and 2 or 1) + (self.showSeconds and 0 or 2)
		if self.textColors then
			self.text:SetFormattedText(style[which], value, self.textColors[id], remainder)
		else
			self.text:SetFormattedText(style[which], value, remainder)
		end
	end

	local color = self.timeColors[id]
	if color then
		self.text:SetTextColor(color.r, color.g, color.b)
	end
end

local unstableAffliction = GetSpellInfo(30108)
local vampiricTouch = GetSpellInfo(34914)
function NP:SetAura(frame, guid, index, filter, isDebuff, visible)
	local isAura, name, texture, count, debuffType, duration, expiration, caster, spellID, _ = LAI:GUIDAura(guid, index, filter)

	if frame.forceShow or frame.forceCreate then
		spellID = 47540
		name, _, texture = GetSpellInfo(spellID)
		if frame.forceShow then
			isAura, count, debuffType, duration, expiration = true, 5, "Magic", 0, 0
		end
	end

	if isAura then
		local position = visible + 1
		local button = frame[position] or NP:Construct_AuraIcon(frame, position)

		button.caster = caster
		button.filter = filter
		button.isDebuff = isDebuff

		local filterCheck = not frame.forceCreate
		if not (frame.forceShow or frame.forceCreate) then
			filterCheck = NP:AuraFilter(guid, button, name, texture, count, debuffType, duration, expiration, caster, spellID)
		end

		if filterCheck then
			if button.icon then button.icon:SetTexture(texture) end
			if button.count then button.count:SetText(count > 1 and count) end

			if duration > 0 and expiration ~= 0 then
				local timeLeft = expiration - GetTime()
				if timeLeft > 0 then
					button.timeLeft = timeLeft
					button.nextUpdate = 0

					button:SetMinMaxValues(0, duration)
					button:SetValue(timeLeft)

					button:SetScript("OnUpdate", NP.UpdateTime)
--				else
--					return HIDDEN
				end
			else
				button.timeLeft = nil
				button.text:SetText("")
				button:SetScript("OnUpdate", nil)
				button:SetMinMaxValues(0, 1)
				button:SetValue(0)
			end

			button:SetID(index)
			button:Show()

			if isDebuff then
				local color = (debuffType and DebuffTypeColor[debuffType]) or DebuffTypeColor.none
				if button.name and (button.name == unstableAffliction or button.name == vampiricTouch) and E.myclass ~= "WARLOCK" then
					self:StyleFrameColor(button, 0.05, 0.85, 0.94)
				else
					self:StyleFrameColor(button, color.r * 0.6, color.g * 0.6, color.b * 0.6)
				end
			end

			return VISIBLE
		elseif frame.forceCreate then
			button:Hide()

			return CREATED
		else
			return HIDDEN
		end
	end
end

function NP:Update_AurasPosition(frame, db)
	local unitFrame = frame:GetParent()
	local mult = floor(NP.db.units[unitFrame.UnitType].health.width / db.size) < db.numAuras
	frame:Size(NP.db.units[unitFrame.UnitType].health.width, (mult and 2 or 1) * db.size)
	frame:ClearAllPoints()
	frame:Point(positionValues[db.anchorPoint], db.attachTo == "BUFFS" and unitFrame.Buffs or unitFrame, positionValues2[db.anchorPoint], db.xOffset, db.yOffset)

	local size = db.size + db.spacing
	local anchor = E.InversePoints[db.anchorPoint]
	local growthx = (db.growthX == "LEFT" and -1) or 1
	local growthy = (db.growthY == "DOWN" and -1) or 1
	local cols = floor(NP.db.units[unitFrame.UnitType].health.width / size + 0.5)

	for i = frame.anchoredIcons + 1, #frame do
		local button = frame[i]

		if not button then break end
		local col = (i - 1) % cols
		local row = floor((i - 1) / cols)

		button:Size(db.size)
		button:ClearAllPoints()
		button:Point(anchor, frame, anchor, col * size * growthx, row * size * growthy)

		button.count:FontTemplate(LSM:Fetch("font", db.countFont), db.countFontSize, db.countFontOutline)

		button.count:ClearAllPoints()
		local point = db.countPosition
		if point == "CENTER" then
			button.count:Point(point, 1, 0)
		else
			local bottom, right = find(point, "BOTTOM"), find(point, "RIGHT")
			button.count:SetJustifyH(right and "RIGHT" or "LEFT")
			button.count:Point(point, right and -1 or 1, bottom and 1 or -1)
		end

		button.text:FontTemplate(LSM:Fetch("font", db.durationFont), db.durationFontSize, db.durationOutline)

		button.text:ClearAllPoints()
		point = db.durationPosition
		if point == "CENTER" then
			button.text:Point(point, 1, 0)
		else
			local bottom, right = find(point, "BOTTOM"), find(point, "RIGHT")
			button.text:Point(point, right and -1 or 1, bottom and 1 or -1)
		end

		button:SetOrientation(db.cooldownOrientation)

		button.bg:ClearAllPoints()
		if db.cooldownOrientation == "VERTICAL" then
			button.bg:SetPoint("TOPLEFT", button)
			button.bg:SetPoint("BOTTOMRIGHT", button:GetStatusBarTexture(), "TOPRIGHT")
		else
			button.bg:SetPoint("TOPRIGHT", button)
			button.bg:SetPoint("BOTTOMLEFT", button:GetStatusBarTexture(), "BOTTOMRIGHT")
		end

		if db.reverseCooldown then
			button:SetStatusBarColor(0, 0, 0, 0.5)
			button.bg:SetTexture(0, 0, 0, 0)
		else
			button:SetStatusBarColor(0, 0, 0, 0)
			button.bg:SetTexture(0, 0, 0, 0.5)
		end
	end
end

function NP:UpdateElement_AuraIcons(frame, guid, filter, limit, isDebuff)
	local index, visible, hidden, created = 1, 0, 0, 0

	while visible < limit do
		local result = NP:SetAura(frame, guid, index, filter, isDebuff, visible)
		if not result then
			break
		elseif result == HIDDEN then
			hidden = hidden + 1
		elseif result == VISIBLE then
			visible = visible + 1
		elseif result == CREATED then
			visible = visible + 1
			created = created + 1
		end
		index = index + 1
	end

	visible = visible - created

	for i = visible + 1, #frame do
		frame[i].timeLeft = nil
		frame[i]:Hide()
	end
	return visible
end

function NP:UpdateElement_Auras(frame)
	if not frame.Health:IsShown() then return end

	local guid = frame.guid

	if not guid then
		if RAID_CLASS_COLORS[frame.UnitClass] then
			local name = frame.UnitName
			guid = self.GUIDByName[name]
		elseif frame.RaidIcon:IsShown() then
			guid = ByRaidIcon[frame.RaidIconType]
		end

		if guid then
			frame.guid = guid
		elseif not frame.Buffs.forceShow and not frame.Debuffs.forceShow then
			return
		end
	end

	local db = NP.db.units[frame.UnitType].buffs
	if db.enable then
		local buffs = frame.Buffs
		buffs.visibleBuffs = NP:UpdateElement_AuraIcons(buffs, guid, buffs.filter or "HELPFUL", db.numAuras)

		if #buffs > buffs.anchoredIcons then
			self:Update_AurasPosition(buffs, db)

			buffs.anchoredIcons = #buffs
		end
	end

	db = NP.db.units[frame.UnitType].debuffs
	if db.enable then
		local debuffs = frame.Debuffs
		debuffs.visibleDebuffs = NP:UpdateElement_AuraIcons(debuffs, guid, debuffs.filter or "HARMFUL", db.numAuras, true)

		if #debuffs > debuffs.anchoredIcons then
			self:Update_AurasPosition(debuffs, db)

			debuffs.anchoredIcons = #debuffs
		end
	end

	self:StyleFilterUpdate(frame, "UNIT_AURA")
end

function NP:UpdateElement_AurasByGUID(guid, event)
	local destName, destFlags = LAI:GetGUIDInfo(guid)

	if destName then
		destName = split("-", destName)
	end

	local raidIcon
	if destFlags then
		for iconName, bitmask in pairs(RaidIconBit) do
			if band(destFlags, bitmask) > 0 then
				ByRaidIcon[iconName] = guid
				raidIcon = iconName
				break
			end
		end
	end

	local frame = self:SearchForFrame(guid, raidIcon, destName)
	if frame then
		frame.guid = guid
		self.GUIDByName[destName] = guid
		self:UpdateElement_Auras(frame)
	end
end

function NP:Construct_AuraIcon(parent, index)
	local db = NP.db.units[parent:GetParent().UnitType][parent.type]

	local button = CreateFrame("StatusBar", "$parentButton"..index, parent)
	NP:StyleFrame(button, true)

	button:SetStatusBarTexture(E.media.blankTex)
	button:SetStatusBarColor(0, 0, 0, 0)
	button:SetOrientation("VERTICAL")

	button.bg = button:CreateTexture()
	button.bg:SetTexture(0, 0, 0, 0.5)

	button.bg:SetPoint("TOPLEFT", button)
	button.bg:SetPoint("BOTTOMRIGHT", button:GetStatusBarTexture(), "TOPRIGHT")

	button.icon = button:CreateTexture(nil, "BORDER")
	button.icon:SetTexCoord(unpack(E.TexCoords))
	button.icon:SetAllPoints()

	button.count = button:CreateFontString(nil, "OVERLAY")
	button.count:ClearAllPoints()
	button.count:Point("BOTTOMRIGHT", 1, 1)
	button.count:SetJustifyH("RIGHT")
	button.count:FontTemplate(LSM:Fetch("font", db.countFont), db.countFontSize, db.countFontOutline)

	button.text = button:CreateFontString(nil, "OVERLAY")
	button.text:Point("TOP", button, "BOTTOM", 1, 0)

	-- support cooldown override
	if not button.isRegisteredCooldown then
		button.CooldownOverride = "nameplates"
		button.isRegisteredCooldown = true
		button.forceEnabled = true

		if not E.RegisteredCooldowns.nameplates then E.RegisteredCooldowns.nameplates = {} end
		tinsert(E.RegisteredCooldowns.nameplates, button)
	end

	button.text:FontTemplate(LSM:Fetch("font", db.durationFont), db.durationFontSize, db.durationOutline)

	NP:Update_CooldownOptions(button)

	tinsert(parent, button)

	return button
end

function NP:Update_CooldownOptions(button)
	E:Cooldown_Options(button, self.db.cooldown, button)
end

function NP:ConstructElement_Auras(frame, auraType)
	local auras = CreateFrame("Frame", "$parent"..auraType, frame)
	auras:Show()
	auras:Size(150, 27)
	auras:Point("TOP", 0, 22)
	auras.anchoredIcons = 0
	auras.type = string.lower(auraType)

	return auras
end

function NP:CheckFilter(name, spellID, isPlayer, allowDuration, noDuration, ...)
	for i = 1, select("#", ...) do
		local filterName = select(i, ...)
		if not filterName then return true end
		if G.nameplates.specialFilters[filterName] or E.global.unitframe.aurafilters[filterName] then
			local filter = E.global.unitframe.aurafilters[filterName]
			if filter then
				local filterType = filter.type
				local spellList = filter.spells
				local spell = spellList and (spellList[spellID] or spellList[name])

				if filterType and (filterType == "Whitelist") and (spell and spell.enable) and allowDuration then
					return true
				elseif filterType and (filterType == "Blacklist") and (spell and spell.enable) then
					return false
				end
			elseif filterName == "Personal" and isPlayer and allowDuration then
				return true
			elseif filterName == "nonPersonal" and (not isPlayer) and allowDuration then
				return true
			elseif filterName == "blockNoDuration" and noDuration then
				return false
			elseif filterName == "blockNonPersonal" and (not isPlayer) then
				return false
			end
		end
	end
end

function NP:AuraFilter(guid, button, name, texture, count, debuffType, duration, expiration, caster, spellID)
	local parent = button:GetParent()
	local parentType = parent.type
	local db = NP.db.units[parent:GetParent().UnitType][parentType]
	if not db then return true end

	local isPlayer = caster == E.myguid

	-- keep these same as in `UF:AuraFilter`
	button.isPlayer = isPlayer
	button.dtype = debuffType
	button.duration = duration
	button.expiration = expiration
	button.stackCount = count
	button.name = name
	button.spellID = spellID
	button.spell = name
	button.priority = 0

	if not db.filters then return true end

	local priority = db.filters.priority
	local noDuration = (not duration or duration == 0)
	local allowDuration = noDuration or (duration and (duration > 0) and db.filters.maxDuration == 0 or duration <= db.filters.maxDuration) and (db.filters.minDuration == 0 or duration >= db.filters.minDuration)
	local filterCheck

	if priority ~= "" then
		filterCheck = NP:CheckFilter(name, spellID, isPlayer, allowDuration, noDuration, split(",", priority))
	else
		filterCheck = allowDuration and true -- Allow all auras to be shown when the filter list is empty, while obeying duration sliders
	end

	return filterCheck
end