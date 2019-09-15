local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local THREAT = E:GetModule("Threat")
local DT = E:GetModule("DataTexts")

--Lua functions
local pairs, select = pairs, select
local wipe = table.wipe
--WoW API / Variables
local GetNumPartyMembers = GetNumPartyMembers
local GetNumRaidMembers = GetNumRaidMembers
local GetThreatStatusColor = GetThreatStatusColor
local UnitClass = UnitClass
local UnitDetailedThreatSituation = UnitDetailedThreatSituation
local UnitExists = UnitExists
local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit
local UnitName = UnitName
local UnitReaction = UnitReaction

local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local UNKNOWN = UNKNOWN

local partyUnits, raidUnits = {}, {}
for i = 1, 4 do partyUnits[i] = "party"..i end
for i = 1, 40 do raidUnits[i] = "raid"..i end

function THREAT:UpdatePosition()
	if self.db.position == "RIGHTCHAT" then
		self.bar:SetInside(RightChatDataPanel)
		self.bar:SetParent(RightChatDataPanel)
	else
		self.bar:SetInside(LeftChatDataPanel)
		self.bar:SetParent(LeftChatDataPanel)
	end

	self.bar.text:FontTemplate(nil, self.db.textSize)
	self.bar:SetFrameStrata("MEDIUM")
end

function THREAT:GetLargestThreatOnList(percent)
	local largestValue, largestUnit = 0
	for unit, threatPercent in pairs(self.list) do
		if threatPercent > largestValue then
			largestValue = threatPercent
			largestUnit = unit
		end
	end

	return (percent - largestValue), largestUnit
end

function THREAT:GetColor(unit)
	if UnitIsPlayer(unit) then
		local _, unitClass = UnitClass(unit)
		local class = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[unitClass] or RAID_CLASS_COLORS[unitClass]
		if not class then
			return 194, 194, 194
		end

		return class.r*255, class.g*255, class.b*255
	end

	local unitReaction = UnitReaction(unit, "player")
	if unitReaction then
		local reaction = ElvUF.colors.reaction[unitReaction]
		return reaction[1]*255, reaction[2]*255, reaction[3]*255
	else
		return 194, 194, 194
	end
end

function THREAT:Update()
	if not UnitExists("target") or (DT and DT.ShowingBGStats) then
		if self.bar:IsShown() then
			self.bar:Hide()
		end

		return
	end

	local _, status, percent = UnitDetailedThreatSituation("player", "target")
	local petExists = HasPetUI()

	if percent and percent > 0 and (GetNumPartyMembers() > 0 or petExists == 1) then
		local name = UnitName("target")
		self.bar:Show()

		if percent == 100 then
			if petExists == 1 then
				self.list.pet = select(3, UnitDetailedThreatSituation("pet", "target"))
			end

			if GetNumRaidMembers() > 0 then
				for i = 1, 40 do
					if UnitExists(raidUnits[i]) and not UnitIsUnit(raidUnits[i], "player") then
						self.list[raidUnits[i]] = select(3, UnitDetailedThreatSituation(raidUnits[i], "target"))
					end
				end
			else
				for i = 1, 4 do
					if UnitExists(partyUnits[i]) then
						self.list[partyUnits[i]] = select(3, UnitDetailedThreatSituation(partyUnits[i], "target"))
					end
				end
			end

			local leadPercent, largestUnit = self:GetLargestThreatOnList(percent)
			if leadPercent > 0 and largestUnit then
				local r, g, b = self:GetColor(largestUnit)
				self.bar.text:SetFormattedText(L["ABOVE_THREAT_FORMAT"], name, percent, leadPercent, r, g, b, UnitName(largestUnit) or UNKNOWN)

				if E.Role == "Tank" then
					self.bar:SetStatusBarColor(0, 0.839, 0)
					self.bar:SetValue(leadPercent)
				else
					self.bar:SetStatusBarColor(GetThreatStatusColor(status))
					self.bar:SetValue(percent)
				end
			else
				self.bar:SetStatusBarColor(GetThreatStatusColor(status))
				self.bar:SetValue(percent)
				self.bar.text:SetFormattedText("%s: %.0f%%", name, percent)
			end
		else
			self.bar:SetStatusBarColor(GetThreatStatusColor(status))
			self.bar:SetValue(percent)
			self.bar.text:SetFormattedText("%s: %.0f%%", name, percent)
		end
	else
		self.bar:Hide()
	end

	wipe(self.list)
end

function THREAT:ToggleEnable()
	if self.db.enable then
		self:RegisterEvent("PLAYER_TARGET_CHANGED", "Update")
		self:RegisterEvent("UNIT_THREAT_LIST_UPDATE", "Update")
		self:RegisterEvent("PARTY_MEMBERS_CHANGED", "Update")
		self:RegisterEvent("RAID_ROSTER_UPDATE", "Update")
		self:RegisterEvent("UNIT_PET", "Update")
		self:Update()
	else
		self.bar:Hide()
		self:UnregisterEvent("PLAYER_TARGET_CHANGED")
		self:UnregisterEvent("UNIT_THREAT_LIST_UPDATE")
		self:UnregisterEvent("PARTY_MEMBERS_CHANGED")
		self:UnregisterEvent("RAID_ROSTER_UPDATE")
		self:UnregisterEvent("UNIT_PET")
	end
end

function THREAT:Initialize()
	self.db = E.db.general.threat

	self.bar = CreateFrame("StatusBar", "ElvUI_ThreatBar", E.UIParent)
	self.bar:CreateBackdrop("Default")
	self.bar:SetMinMaxValues(0, 100)
	self.bar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(self.bar)

	self.bar.text = self.bar:CreateFontString(nil, "OVERLAY")
	self.bar.text:FontTemplate(nil, self.db.textSize)
	self.bar.text:Point("CENTER", self.bar, "CENTER")

	self.list = {}

	self:UpdatePosition()
	self:ToggleEnable()

	self.Initialized = true
end

local function InitializeCallback()
	THREAT:Initialize()
end

E:RegisterModule(THREAT:GetName(), InitializeCallback)