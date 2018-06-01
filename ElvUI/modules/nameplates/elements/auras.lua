local E, L, V, P, G = unpack(select(2, ...))
local mod = E:GetModule("NamePlates")
local LSM = LibStub("LibSharedMedia-3.0")
local LAI = LibStub("LibAuraInfo-1.0-ElvUI", true)

local select, unpack, pairs = select, unpack, pairs
local tonumber = tonumber
local band = bit.band
local tinsert, tremove, wipe = table.insert, table.remove, table.wipe

local strlower, strsplit = string.lower, strsplit

local CreateFrame = CreateFrame
local UnitGUID = UnitGUID
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

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

local RaidIconIndex = {
	"STAR",
	"CIRCLE",
	"DIAMOND",
	"TRIANGLE",
	"MOON",
	"SQUARE",
	"CROSS",
	"SKULL"
}

local ByRaidIcon = {}

local auraCache = {}

function mod:UpdateTime(elapsed)
	self.timeLeft = self.timeLeft - elapsed

	if self.nextUpdate > 0 then
		self.nextUpdate = self.nextUpdate - elapsed
		return
	end

	local timeColors, timeThreshold = E.TimeColors, E.db.cooldown.threshold
	if mod.db.cooldown.override and E.TimeColors["nameplates"] then
		timeColors, timeThreshold = E.TimeColors["nameplates"], mod.db.cooldown.threshold
	end
	if not timeThreshold then
		timeThreshold = E.TimeThreshold
	end

	local timerValue, formatID
	timerValue, formatID, self.nextUpdate = E:GetTimeInfo(self.timeLeft, timeThreshold)
	if timerValue <= 0 then
		self:Hide()
		LAI:RemoveAuraFromGUID(self:GetParent():GetParent().guid, self.spellID, nil, self:GetParent().filter)
		mod:UpdateElement_Filters(self:GetParent():GetParent(), "UNIT_AURA")
		return
	end
	self.time:SetFormattedText(format("%s%s|r", timeColors[formatID], E.TimeFormats[formatID][2]), timerValue)
end

function mod:SetAura(aura, index, name, icon, count, duration, expirationTime, spellID)
	aura.icon:SetTexture(icon)
	aura.name = name
	aura.spellID = spellID
	aura.expirationTime = expirationTime
	if count > 1 then
		aura.count:SetText(count)
	else
		aura.count:SetText("")
	end

	if duration == 0 and expirationTime == 0 then
		aura.timeLeft = nil
		aura.time:SetText("")
		aura:SetScript("OnUpdate", nil)
	else
		local timeLeft = expirationTime - GetTime()
		if not aura.timeLeft then
			aura.timeLeft = timeLeft
			aura:SetScript("OnUpdate", self.UpdateTime)
		else
			aura.timeLeft = timeLeft
		end

		aura.nextUpdate = -1
		self.UpdateTime(aura, 0)
	end

	aura:SetID(index)
	aura:Show()
end

function mod:HideAuraIcons(auras)
	for i = 1, #auras.icons do
		auras.icons[i]:Hide()
	end
end

function mod:CheckFilter(name, spellID, isPlayer, allowDuration, noDuration, ...)
	local filterName, filter, filterType, spellList, spell = false, false
	for i = 1, select("#", ...) do
		filterName = select(i, ...)
		if G.nameplates.specialFilters[filterName] or E.global.unitframe.aurafilters[filterName] then
			filter = E.global.unitframe.aurafilters[filterName]
			if filter then
				filterType = filter.type
				spellList = filter.spells
				spell = spellList and (spellList[spellID] or spellList[name])

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

function mod:AuraFilter(frame, frameNum, index, buffType, minDuration, maxDuration, priority, isAura, name, texture, count, dispelType, duration, expiration, caster, spellID)
	if not isAura then return nil end -- checking for an aura that is not there, pass nil to break while loop
	local filterCheck, isPlayer, allowDuration, noDuration = false, false, false, false, false, false

	noDuration = (not duration or duration == 0)
	allowDuration = noDuration or (duration and (duration > 0) and (maxDuration == 0 or duration <= maxDuration) and (minDuration == 0 or duration >= minDuration))

	if priority ~= "" then
		isPlayer = (caster == UnitGUID("player"))
		filterCheck = mod:CheckFilter(name, spellID, isPlayer, allowDuration, noDuration, strsplit(",", priority))
	else
		filterCheck = allowDuration and true -- Allow all auras to be shown when the filter list is empty, while obeying duration sliders
	end

	if filterCheck == true then
		mod:SetAura(frame[buffType].icons[frameNum], index, name, texture, count, duration, expiration, spellID)
		return true
	end

	return false
end

function mod:UpdateElement_Auras(frame)
	if not frame.HealthBar:IsShown() then return end

	local guid = frame.guid

	if not guid then
		if RAID_CLASS_COLORS[frame.UnitClass] then
			local name = frame.UnitName
			guid = self.ByName[name]
		elseif frame.RaidIcon:IsShown() then
			guid = ByRaidIcon[frame.RaidIconType]
		end

		if guid then
			frame.guid = guid
		else
			return
		end
	end

	local hasBuffs, hasDebuffs, showAura = false, false
	local filterType, buffType, buffTypeLower, index, frameNum, maxAuras, minDuration, maxDuration, priority

	for i = 1, 2 do
		filterType = (i == 1 and "HELPFUL" or "HARMFUL")
		buffType = (i == 1 and "Buffs" or "Debuffs")
		frame[buffType].filter = filterType
		buffTypeLower = strlower(buffType)
		index = 1
		frameNum = 1
		maxAuras = #frame[buffType].icons
		minDuration = self.db.units[frame.UnitType][buffTypeLower].filters.minDuration
		maxDuration = self.db.units[frame.UnitType][buffTypeLower].filters.maxDuration
		priority = self.db.units[frame.UnitType][buffTypeLower].filters.priority

		self:HideAuraIcons(frame[buffType])
		if self.db.units[frame.UnitType][buffTypeLower].enable then
			while frameNum <= maxAuras do
				showAura = mod:AuraFilter(frame, frameNum, index, buffType, minDuration, maxDuration, priority, LAI:GUIDAura(guid, index, filterType))
				if showAura == nil then
					break -- used to break the while loop when index is over the limit of auras we have (unitaura name will pass nil)
				elseif showAura == true then -- has aura and passes checks
					if i == 1 then hasBuffs = true else hasDebuffs = true end
					frameNum = frameNum + 1
				end
				index = index + 1
			end
		end
	end

	local TopLevel = frame.HealthBar
	local TopOffset = ((self.db.units[frame.UnitType].showName and select(2, frame.Name:GetFont()) + 5) or 0)
	if hasDebuffs then
		TopOffset = TopOffset + 3
		frame.Debuffs:SetPoint("BOTTOMLEFT", TopLevel, "TOPLEFT", 0, TopOffset)
		frame.Debuffs:SetPoint("BOTTOMRIGHT", TopLevel, "TOPRIGHT", 0, TopOffset)
		TopLevel = frame.Debuffs
		TopOffset = 3
	end

	if hasBuffs then
		if not hasDebuffs then
			TopOffset = TopOffset + 3
		end
		frame.Buffs:SetPoint("BOTTOMLEFT", TopLevel, "TOPLEFT", 0, TopOffset)
		frame.Buffs:SetPoint("BOTTOMRIGHT", TopLevel, "TOPRIGHT", 0, TopOffset)
		TopLevel = frame.Buffs
		TopOffset = 3
	end

	if frame.TopLevelFrame ~= TopLevel then
		frame.TopLevelFrame = TopLevel
		frame.TopOffset = TopOffset
	end

	mod:UpdateElement_Filters(frame, "UNIT_AURA")
end

function mod:UpdateElement_AurasByGUID(guid)
	local destName, destFlags = LAI:GetGUIDInfo(guid)

	if destName then
		destName = strsplit("-", destName)
		self.ByName[destName] = guid
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

		if frame.UnitType == "FRIENDLY_PLAYER" and not frame.UnitClass then
			frame.UnitClass = mod:GetUnitClassByGUID(frame, guid)
			if frame.UnitClass then
				mod:UpdateElement_All(frame, true, true)
			end
		end
		self:UpdateElement_Auras(frame)
	end
end

function mod:LibAuraInfo_AURA_APPLIED(_, destGUID)
	self:UpdateElement_AurasByGUID(destGUID)
end

function mod:LibAuraInfo_AURA_REMOVED(_, destGUID)
	self:UpdateElement_AurasByGUID(destGUID)
end

function mod:LibAuraInfo_AURA_REFRESH(_, destGUID)
	self:LibAuraInfo_AURA_APPLIED(_, destGUID)
end

function mod:LibAuraInfo_AURA_APPLIED_DOSE(_, destGUID)
	self:LibAuraInfo_AURA_APPLIED(_, destGUID)
end

function mod:LibAuraInfo_AURA_CLEAR(_, destGUID)
	self:UpdateElement_AurasByGUID(destGUID)
end

function mod:RemoveAuraFromGUID(_, destGUID)
	self:UpdateElement_AurasByGUID(destGUID)
end

function mod:CreateAuraIcon(parent)
	local aura = CreateFrame("Frame", nil, parent)
	self:StyleFrame(aura, true)

	aura.icon = aura:CreateTexture(nil, "OVERLAY")
	aura.icon:SetAllPoints()
	aura.icon:SetTexCoord(unpack(E.TexCoords))

	aura.time = aura:CreateFontString(nil, "OVERLAY")
	aura.time:SetFont(LSM:Fetch("font", mod.db.durationFont), mod.db.durationFontSize, mod.db.durationFontOutline)
	aura.time:ClearAllPoints()
	if mod.db.durationPosition == "TOPLEFT" then
		aura.time:Point("TOPLEFT", 1, 1)
	elseif mod.db.durationPosition == "BOTTOMLEFT" then
		aura.time:Point("BOTTOMLEFT", 1, 1)
	elseif mod.db.durationPosition == "TOPRIGHT" then
		aura.time:Point("TOPRIGHT", 1, 1)
	else
		aura.time:Point("CENTER", 0, 0)
	end

	aura.count = aura:CreateFontString(nil, "OVERLAY")
	aura.count:SetFont(LSM:Fetch("font", self.db.stackFont), self.db.stackFontSize, self.db.stackFontOutline)
	aura.count:Point("BOTTOMRIGHT", 1, 1)

	return aura
end

function mod:Auras_SizeChanged(width)
	local numAuras = #self.icons
	for i = 1, numAuras do
		self.icons[i]:SetWidth(((width - numAuras) / numAuras) - (E.private.general.pixelPerfect and 0 or 3))
		self.icons[i]:SetHeight((self.db.baseHeight or 18) * (self:GetParent().HealthBar.currentScale or 1))
	end
	self:SetHeight((self.db.baseHeight or 18) * (self:GetParent().HealthBar.currentScale or 1))
end

function mod:UpdateAuraIcons(auras)
	local maxAuras = auras.db.numAuras
	local numCurrentAuras = #auras.icons
	if(numCurrentAuras > maxAuras) then
		for i = maxAuras, numCurrentAuras do
			tinsert(auraCache, auras.icons[i])
			auras.icons[i]:Hide()
			auras.icons[i] = nil
		end
	end

	if(numCurrentAuras ~= maxAuras) then
		self.Auras_SizeChanged(auras, auras:GetWidth(), auras:GetHeight())
	end

	for i = 1, maxAuras do
		auras.icons[i] = auras.icons[i] or tremove(auraCache) or mod:CreateAuraIcon(auras)
		auras.icons[i]:SetParent(auras)
		auras.icons[i]:ClearAllPoints()
		auras.icons[i]:Hide()
		auras.icons[i]:SetHeight(auras.db.baseHeight or 18)

		if auras.icons[i].count then
			auras.icons[i].count:SetFont(LSM:Fetch("font", self.db.stackFont), self.db.stackFontSize, self.db.stackFontOutline)
		end

		if auras.icons[i].time then
			auras.icons[i].time:SetFont(LSM:Fetch("font", mod.db.durationFont), mod.db.durationFontSize, mod.db.durationFontOutline)

			auras.icons[i].time:ClearAllPoints()
			if mod.db.durationPosition == "TOPLEFT" then
				auras.icons[i].time:Point("TOPLEFT", 1, 1)
			elseif mod.db.durationPosition == "BOTTOMLEFT" then
				auras.icons[i].time:Point("BOTTOMLEFT", 1, 1)
			elseif mod.db.durationPosition == "TOPRIGHT" then
				auras.icons[i].time:Point("TOPRIGHT", 1, 1)
			else
				auras.icons[i].time:Point("CENTER", 0, 0)
			end
		end

		if(auras.side == "LEFT") then
			if(i == 1) then
				auras.icons[i]:SetPoint("BOTTOMLEFT", auras, "BOTTOMLEFT")
			else
				auras.icons[i]:SetPoint("LEFT", auras.icons[i-1], "RIGHT", E.Border + E.Spacing*3, 0)
			end
		else
			if(i == 1) then
				auras.icons[i]:SetPoint("BOTTOMRIGHT", auras, "BOTTOMRIGHT")
			else
				auras.icons[i]:SetPoint("RIGHT", auras.icons[i-1], "LEFT", -(E.Border + E.Spacing*3), 0)
			end
		end
	end
end

function mod:ConstructElement_Auras(frame, side)
	local auras = CreateFrame("Frame", nil, frame)

	auras:SetScript("OnSizeChanged", mod.Auras_SizeChanged)
	auras:SetHeight(18) -- this really doesn't matter
	auras.side = side
	auras.icons = {}

	return auras
end