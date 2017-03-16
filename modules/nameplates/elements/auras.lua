local E, L, V, P, G = unpack(select(2, ...))
local mod = E:GetModule("NamePlates")
local LSM = LibStub("LibSharedMedia-3.0")

local select, unpack, pairs = select, unpack, pairs
local tonumber = tonumber
local band = bit.band
local gsub = string.gsub
local tinsert, tremove, wipe = table.insert, table.remove, table.wipe

local CreateFrame = CreateFrame
local UnitAura = UnitAura
local UnitGUID = UnitGUID
local GetSpellTexture = GetSpellTexture
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local AURA_TYPE_BUFF = AURA_TYPE_BUFF
local AURA_TYPE_DEBUFF = AURA_TYPE_DEBUFF

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
local ByName = {}

local auraCache = {}
local buffCache = {}
local debuffCache = {}

local auraList = {}
local auraSpellID = {}
local auraName = {}
local auraExpiration = {}
local auraStacks = {}
local auraCaster = {}
local auraDuration = {}
local auraTexture = {}
local auraType = {}
local cachedAuraDurations = {}

local TimeColors = {
	[0] = "|cffeeeeee",
	[1] = "|cffeeeeee",
	[2] = "|cffeeeeee",
	[3] = "|cffFFEE00",
	[4] = "|cfffe0000"
}

local AURA_UPDATE_INTERVAL = 0.1

local PolledHideIn
do
	local Framelist = {}
	local Watcherframe = CreateFrame("Frame")
	local WatcherframeActive = false
	local timeToUpdate = 0

	local function CheckFramelist()
		local curTime = GetTime()
		if curTime < timeToUpdate then return end
		local framecount = 0
		timeToUpdate = curTime + AURA_UPDATE_INTERVAL

		for frame, expiration in pairs(Framelist) do
			if expiration < curTime then
				frame:Hide()
				Framelist[frame] = nil
			else
				if frame.Poll then frame:Poll(expiration) end
				framecount = framecount + 1
			end
		end
		if framecount == 0 then Watcherframe:SetScript("OnUpdate", nil); WatcherframeActive = false end
	end

	function PolledHideIn(frame, expiration)
		if expiration == 0 then
			frame:Hide()
			Framelist[frame] = nil
		else
			Framelist[frame] = expiration
			frame:Show()

			if not WatcherframeActive then
				Watcherframe:SetScript("OnUpdate", CheckFramelist)
				WatcherframeActive = true
			end
		end
	end
end

local function GetSpellDuration(spellID)
	if spellID then return cachedAuraDurations[spellID] end
end

local function SetSpellDuration(spellID, duration)
	if spellID then cachedAuraDurations[spellID] = duration end
end

local function UpdateAuraTime(frame, expiration)
	local timeleft = expiration - GetTime()
	local timervalue, formatid = E:GetTimeInfo(timeleft, 4)
	local timeFormat = E.TimeFormats[3][2]
	if timervalue < 4 then
		timeFormat = E.TimeFormats[4][2]
	end
	frame.timeLeft:SetFormattedText(("%s%s|r"):format(TimeColors[formatid], timeFormat), timervalue)
end

local function RemoveAuraInstance(guid, spellID, caster)
	if guid and spellID and auraList[guid] then
		local instanceID = tostring(guid)..tostring(spellID)..(tostring(caster or "UNKNOWN_CASTER"))
		local auraID = spellID..(tostring(caster or "UNKNOWN_CASTER"))
		if auraList[guid][auraID] then
			auraSpellID[instanceID] = nil
			auraName[instanceID] = nil
			auraExpiration[instanceID] = nil
			auraStacks[instanceID] = nil
			auraCaster[instanceID] = nil
			auraDuration[instanceID] = nil
			auraTexture[instanceID] = nil
			auraType[instanceID] = nil
			auraList[guid][auraID] = nil
		end
	end
end

local function GetAuraList(guid)
	if guid and auraList[guid] then return auraList[guid] end
end

local function GetAuraInstance(guid, auraID)
	if guid and auraID then
		local instanceID = guid..auraID
		local spellID, name, expiration, stacks, caster, duration, texture, type
		spellID = auraSpellID[instanceID]
		name = auraName[instanceID]
		expiration = auraExpiration[instanceID]
		stacks = auraStacks[instanceID]
		caster = auraCaster[instanceID]
		duration = auraDuration[instanceID]
		texture = auraTexture[instanceID]
		type = auraType[instanceID]
		return spellID, name, expiration, stacks, caster, duration, texture, type
	end
end

local function SetAuraInstance(guid, name, spellID, expiration, stacks, caster, duration, texture, type)
	if guid and spellID and caster and texture then
		local auraID = spellID..(tostring(caster or "UNKNOWN_CASTER"))
		local instanceID = guid..auraID
		auraList[guid] = auraList[guid] or {}
		auraList[guid][auraID] = instanceID
		auraSpellID[instanceID] = spellID
		auraName[instanceID] = name
		auraExpiration[instanceID] = expiration
		auraStacks[instanceID] = stacks
		auraCaster[instanceID] = caster
		auraDuration[instanceID] = duration
		auraTexture[instanceID] = texture
		auraType[instanceID] = type
	end
end

local function WipeAuraList(guid)
	if guid and auraList[guid] then
		local unitAuraList = auraList[guid]
		for auraID, instanceID in pairs(unitAuraList) do
			auraSpellID[instanceID] = nil
			auraName[instanceID] = nil
			auraExpiration[instanceID] = nil
			auraStacks[instanceID] = nil
			auraCaster[instanceID] = nil
			auraDuration[instanceID] = nil
			auraTexture[instanceID] = nil
			auraType[instanceID] = nil
			unitAuraList[auraID] = nil
		end
	end
end

function mod:CleanAuraLists()
	local currentTime = GetTime()
	for guid, instanceList in pairs(auraList) do
		local auraCount = 0
		for auraID, instanceID in pairs(instanceList) do
			local expiration = auraExpiration[instanceID]
			if expiration and expiration < currentTime then
				auraList[guid][auraID] = nil
				auraSpellID[instanceID] = nil
				auraName[instanceID] = nil
				auraExpiration[instanceID] = nil
				auraStacks[instanceID] = nil
				auraCaster[instanceID] = nil
				auraDuration[instanceID] = nil
				auraTexture[instanceID] = nil
				auraType[instanceID] = nil
			else
				auraCount = auraCount + 1
			end
		end
		if auraCount == 0 then
			auraList[guid] = nil
		end
	end
end

function mod:SetAura(aura, icon, count, expirationTime)
	aura.icon:SetTexture(icon)
	if count > 1 then
		aura.count:SetText(count)
	else
		aura.count:SetText("")
	end
	aura:Show()
	PolledHideIn(aura, expirationTime)
end

function mod:HideAuraIcons(auras)
	for i = 1, #auras.icons do
		PolledHideIn(auras.icons[i], 0)
	end
end

local currentAura = {}
function mod:UpdateElement_Auras(frame)
	if not frame.HealthBar:IsShown() then return end

	local guid = frame.guid

	if not guid then
		if RAID_CLASS_COLORS[frame.UnitClass] then
			local name = gsub(frame.oldName:GetText(), "%s%(%*%)","")
			guid = ByName[name]
		elseif frame.RaidIcon:IsShown() then
			guid = ByRaidIcon[frame.RaidIconType]
		end

		if guid then
			frame.guid = guid
		else
			return
		end
	end

	local hasDebuffs = false
	local hasBuffs = false

	local numDebuff = 0
	local numBuff = 0

	local aurasOnUnit = GetAuraList(guid)

	debuffCache = wipe(debuffCache)
	buffCache = wipe(buffCache)

	if aurasOnUnit then
		local numAuras = 0
		local aura

		for instanceid in pairs(aurasOnUnit) do
			numAuras = (numDebuff + numBuff) + 1
			aura = wipe(currentAura[numAuras] or {})

			aura.spellID, aura.name, aura.expirationTime, aura.count, aura.caster, aura.duration, aura.icon, aura.type = GetAuraInstance(guid, instanceid)

			local filter = false
			local db = self.db.units[frame.UnitType].buffs.filters
			if aura.type == AURA_TYPE_DEBUFF then
				db = self.db.units[frame.UnitType].debuffs.filters
			end

			if db.personal and aura.caster == UnitGUID("player") then
				filter = true
			end

			local trackFilter = E.global["unitframe"]["aurafilters"][db.filter]
			if db.filter and trackFilter then
				local spell = trackFilter.spells[tonumber(aura.spellID)] or trackFilter.spells[aura.name]
				if trackFilter.type == "Whitelist" then
					if spell and spell.enable then
						filter = true
					end
				elseif trackFilter.type == "Blacklist" and spell and spell.enable then
					filter = false
				end
			end

			if filter ~= true then
				numAuras = numAuras - 1
				RemoveAuraInstance(guid, aura.spellID, aura.caster)
				wipe(aura)
			end

			if tonumber(aura.spellID) then
				aura.unit = frame.unit
				if aura.expirationTime > GetTime() then
					if aura.type == "BUFF" then
						numBuff = numBuff + 1
						buffCache[numBuff] = aura
					else
						numDebuff = numDebuff + 1
						debuffCache[numDebuff] = aura
					end
				end
			end
		end

		wipe(currentAura)
	end

	local frameNum = 1
	local maxAuras = #frame.Debuffs.icons
	local maxDuration = self.db.units[frame.UnitType].debuffs.filters.maxDuration

	self:HideAuraIcons(frame.Debuffs)
	if numDebuff > 0 and self.db.units[frame.UnitType].debuffs.enable then
		for index = 1, #debuffCache do
			if frameNum > maxAuras then break end
			local debuff = debuffCache[index]
			if debuff.spellID and debuff.expirationTime and debuff.duration <= maxDuration then
				self:SetAura(frame.Debuffs.icons[frameNum], debuff.icon, debuff.count, debuff.expirationTime)
				frameNum = frameNum + 1
				hasDebuffs = true
			end
		end
	end

	frameNum = 1
	maxAuras = #frame.Buffs.icons
	maxDuration = self.db.units[frame.UnitType].buffs.filters.maxDuration

	self:HideAuraIcons(frame.Buffs)
	if numBuff > 0 and self.db.units[frame.UnitType].buffs.enable then
		for index = 1, #buffCache do
			if frameNum > maxAuras then break end
			local buff = buffCache[index]
			if buff.spellID and buff.expirationTime and buff.duration <= maxDuration then
				self:SetAura(frame.Buffs.icons[frameNum], buff.icon, buff.count, buff.expirationTime)
				frameNum = frameNum + 1
				hasBuffs = true
			end
		end
	end

	debuffCache = wipe(debuffCache)
	buffCache = wipe(buffCache)

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
end

function mod:UpdateElement_AurasByUnitID(unit)
	local guid = UnitGUID(unit)
	WipeAuraList(guid)

	local index = 1
	local name, _, texture, count, _, duration, expirationTime, unitCaster, _, _, spellID = UnitAura(unit, index, "HARMFUL")
	while name do
		SetSpellDuration(spellID, duration)
		SetAuraInstance(guid, name, spellID, expirationTime, count, UnitGUID(unitCaster or ""), duration, texture, AURA_TYPE_DEBUFF)
		index = index + 1
		name , _, texture, count, _, duration, expirationTime, unitCaster, _, _, spellID = UnitAura(unit, index, "HARMFUL")
	end

	index = 1
	local name, _, texture, count, _, duration, expirationTime, unitCaster, _, _, spellID = UnitAura(unit, index, "HELPFUL")
	while name do
		SetSpellDuration(spellID, duration)
		SetAuraInstance(guid, name, spellID, expirationTime, count, UnitGUID(unitCaster or ""), duration, texture, AURA_TYPE_BUFF)
		index = index + 1
		name, _, texture, count, _, duration, expirationTime, unitCaster, _, _, spellID = UnitAura(unit, index, "HELPFUL")
	end

	local raidIcon, name
	if UnitPlayerControlled(unit) then name = UnitName(unit) end
	raidIcon = RaidIconIndex[GetRaidTargetIndex(unit) or ""]
	if raidIcon then ByRaidIcon[raidIcon] = guid end

	local frame = self:SearchForFrame(guid, raidIcon, name)
	if frame then
		self:UpdateElement_Auras(frame)
	end
end

function mod:COMBAT_LOG_EVENT_UNFILTERED(_, _, event, sourceGUID, _, _, destGUID, destName, destFlags, ...)
	if destGUID == UnitGUID("target") then return end
	--if band(destFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY) ~= 0 then then return
	if not (event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REFRESH" or event == "SPELL_AURA_APPLIED_DOSE" or event == "SPELL_AURA_REMOVED_DOSE" or event == "SPELL_AURA_BROKEN" or event == "SPELL_AURA_BROKEN_SPELL" or event == "SPELL_AURA_REMOVED") then return end

	local spellID, spellName, _, auraType, stackCount = ...

	if event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REFRESH" then
		local duration = GetSpellDuration(spellID)
		local texture = GetSpellTexture(spellID)
		SetAuraInstance(destGUID, spellName, spellID, GetTime() + (duration or 0), 1, sourceGUID, duration, texture, auraType)
	elseif event == "SPELL_AURA_APPLIED_DOSE" or event == "SPELL_AURA_REMOVED_DOSE" then
		local duration = GetSpellDuration(spellID)
		local texture = GetSpellTexture(spellID)
		SetAuraInstance(destGUID, spellName, spellID, GetTime() + (duration or 0), stackCount, sourceGUID, duration, texture, auraType)
	elseif event == "SPELL_AURA_BROKEN" or event == "SPELL_AURA_BROKEN_SPELL" or event == "SPELL_AURA_REMOVED" then
		RemoveAuraInstance(destGUID, spellID, sourceGUID)
	end

	local name, raidIcon
	if band(destFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) > 0 then
		local rawName = strsplit("-", destName)
		ByName[rawName] = destGUID
		name = rawName
	end

	for iconName, bitmask in pairs(RaidIconBit) do
		if band(destFlags, bitmask) > 0 then
			ByRaidIcon[iconName] = destGUID
			raidIcon = iconName

			break
		end
	end

	local frame = self:SearchForFrame(destGUID, raidIcon, name)
	if frame then
		self:UpdateElement_Auras(frame)
	end
end

function mod:CreateAuraIcon(parent)
	local aura = CreateFrame("Frame", nil, parent)
	self:StyleFrame(aura, true)

	aura.icon = aura:CreateTexture(nil, "OVERLAY")
	aura.icon:SetAllPoints()
	aura.icon:SetTexCoord(unpack(E.TexCoords))

	aura.timeLeft = aura:CreateFontString(nil, "OVERLAY")
	aura.timeLeft:SetPoint("TOPLEFT", 2, 2)
	aura.timeLeft:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)

	aura.count = aura:CreateFontString(nil, "OVERLAY")
	aura.count:SetPoint("BOTTOMRIGHT")
	aura.count:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
	aura.Poll = parent.PollFunction

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
	auras:SetHeight(18)
	auras.side = side
	auras.PollFunction = UpdateAuraTime
	auras.icons = {}

	return auras
end