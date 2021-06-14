local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule("DataBars")
local LSM = LibStub("LibSharedMedia-3.0")

--Lua functions
local max, min = math.max, math.min
local format = string.format
--WoW API
local GetNumQuestLogEntries = GetNumQuestLogEntries
local GetQuestLogRewardXP = GetQuestLogRewardXP
local GetQuestLogSelection = GetQuestLogSelection
local GetQuestLogTitle = GetQuestLogTitle
local GetXPExhaustion = GetXPExhaustion
local GetZoneText = GetZoneText
local IsXPUserDisabled = IsXPUserDisabled
local SelectQuestLogEntry = SelectQuestLogEntry
local UnitLevel = UnitLevel
local UnitXP = UnitXP
local UnitXPMax = UnitXPMax

local function getQuestXP(completedOnly, zoneOnly)
	local lastQuestLogID = GetQuestLogSelection()
	local zoneText = GetZoneText()
	local totalExp = 0
	local locationName

	for questIndex = 1, GetNumQuestLogEntries() do
		SelectQuestLogEntry(questIndex)
		local title, _, _, _, isHeader, _, isComplete, _, questID = GetQuestLogTitle(questIndex)

		if isHeader then
			locationName = title
		elseif (not completedOnly or isComplete) and (not zoneOnly or locationName == zoneText) then
			totalExp = totalExp + GetQuestLogRewardXP(questID)
		end
	end

	SelectQuestLogEntry(lastQuestLogID)

	return totalExp
end

function mod:ExperienceBar_QuestXPUpdate(event)
	if event == "ZONE_CHANGED_NEW_AREA" and not self.db.experience.questXP.questCurrentZoneOnly then return end

	self.questTotalXP = getQuestXP(self.db.experience.questXP.questCompletedOnly, self.db.experience.questXP.questCurrentZoneOnly)

	if self.questTotalXP > 0 then
		self.expBar.questBar:SetMinMaxValues(0, self.expBar.maxExp)
		self.expBar.questBar:SetValue(min(self.expBar.curExp + self.questTotalXP, self.expBar.maxExp))
		self.expBar.questBar:Show()
	else
		self.expBar.questBar:Hide()
	end
end

function mod:ExperienceBar_Update(event)
	if not mod.db.experience.enable then return end

	local bar = self.expBar
	local hideBar = (self.playerLevel == self.maxExpansionLevel and self.db.experience.hideAtMaxLevel) or self.expDisabled

	if hideBar or (event == "PLAYER_REGEN_DISABLED" and self.db.experience.hideInCombat) then
		E:DisableMover(bar.mover:GetName())
		bar:Hide()
	elseif not hideBar and (not self.db.experience.hideInCombat or not self.inCombatLockdown) then
		E:EnableMover(bar.mover:GetName())
		bar:Show()

		if self.db.experience.hideInVehicle then
			E:RegisterObjectForVehicleLock(bar, E.UIParent)
		else
			E:UnregisterObjectForVehicleLock(bar)
		end

		local textFormat = self.db.experience.textFormat
		local curExp = UnitXP("player")
		local maxExp = max(1, UnitXPMax("player"))
		local rested = GetXPExhaustion()
		bar.curExp = curExp
		bar.maxExp = maxExp

		bar.statusBar:SetMinMaxValues(min(0, curExp), maxExp)
	--	bar.statusBar:SetValue(curExp - 1 >= 0 and curExp - 1 or 0)
		bar.statusBar:SetValue(curExp)

		if rested and rested > 0 then
			bar.rested:SetMinMaxValues(0, maxExp)
			bar.rested:SetValue(min(curExp + rested, maxExp))

			if textFormat == "PERCENT" then
				bar.text:SetFormattedText("%d%% R:%d%%", curExp / maxExp * 100, rested / maxExp * 100)
			elseif textFormat == "CURMAX" then
				bar.text:SetFormattedText("%s - %s R:%s", E:ShortValue(curExp), E:ShortValue(maxExp), E:ShortValue(rested))
			elseif textFormat == "CURPERC" then
				bar.text:SetFormattedText("%s - %d%% R:%s [%d%%]", E:ShortValue(curExp), curExp / maxExp * 100, E:ShortValue(rested), rested / maxExp * 100)
			elseif textFormat == "CUR" then
				bar.text:SetFormattedText("%s R:%s", E:ShortValue(curExp), E:ShortValue(rested))
			elseif textFormat == "REM" then
				bar.text:SetFormattedText("%s R:%s", E:ShortValue(maxExp - curExp), E:ShortValue(rested))
			elseif textFormat == "CURREM" then
				bar.text:SetFormattedText("%s - %s R:%s", E:ShortValue(curExp), E:ShortValue(maxExp - curExp), E:ShortValue(rested))
			elseif textFormat == "CURPERCREM" then
				bar.text:SetFormattedText("%s - %d%% (%s) R:%s", E:ShortValue(curExp), curExp / maxExp * 100, E:ShortValue(maxExp - curExp), E:ShortValue(rested))
			end
		else
			bar.rested:SetMinMaxValues(0, 1)
			bar.rested:SetValue(0)

			if textFormat == "PERCENT" then
				bar.text:SetFormattedText("%d%%", curExp / maxExp * 100)
			elseif textFormat == "CURMAX" then
				bar.text:SetFormattedText("%s - %s", E:ShortValue(curExp), E:ShortValue(maxExp))
			elseif textFormat == "CURPERC" then
				bar.text:SetFormattedText("%s - %d%%", E:ShortValue(curExp), curExp / maxExp * 100)
			elseif textFormat == "CUR" then
				bar.text:SetFormattedText("%s", E:ShortValue(curExp))
			elseif textFormat == "REM" then
				bar.text:SetFormattedText("%s", E:ShortValue(maxExp - curExp))
			elseif textFormat == "CURREM" then
				bar.text:SetFormattedText("%s - %s", E:ShortValue(curExp), E:ShortValue(maxExp - curExp))
			elseif textFormat == "CURPERCREM" then
				bar.text:SetFormattedText("%s - %d%% (%s)", E:ShortValue(curExp), curExp / maxExp * 100, E:ShortValue(maxExp - curExp))
			end
		end
	end
end

function mod:ExperienceBar_OnEnter()
	if mod.db.experience.mouseover then
		E:UIFrameFadeIn(self, 0.4, self:GetAlpha(), 1)
	end

	local curExp = UnitXP("player")
	local maxExp = max(1, UnitXPMax("player"))
	local rested = GetXPExhaustion()

	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, "ANCHOR_CURSOR", 0, -4)

	GameTooltip:AddLine(L["Experience"])
	GameTooltip:AddLine(" ")

	GameTooltip:AddDoubleLine(L["XP:"], format("%d / %d (%d%%)", curExp, maxExp, curExp / maxExp * 100), 1, 1, 1)
	GameTooltip:AddDoubleLine(L["Remaining:"], format("%d (%d%% - %d %s)", maxExp - curExp, (maxExp - curExp) / maxExp * 100, 20 * (maxExp - curExp) / maxExp, L["Bars"]), 1, 1, 1)

	if rested then
		GameTooltip:AddDoubleLine(L["Rested:"], format("+%d (%d%%)", rested, rested / maxExp * 100), 1, 1, 1)
	end

	if mod.questXPEnabled and mod.db.experience.questXP.tooltip then
		GameTooltip:AddDoubleLine(L["Quest Log XP:"], mod.questTotalXP, 1, 1, 1)
	end

	GameTooltip:Show()
end

function mod:ExperienceBar_OnClick(button)
	if XPRM then -- Warmane exp rates
		if button == "RightButton" then
			ToggleDropDownMenu(1, nil, XPRM, "cursor")
		end
	end
end

function mod:ExperienceBar_UpdateDimensions()
	self.expBar:Size(self.db.experience.width, self.db.experience.height)
	self.expBar:SetAlpha(self.db.experience.mouseover and 0 or 1)

	self.expBar.text:FontTemplate(LSM:Fetch("font", self.db.experience.font), self.db.experience.textSize, self.db.experience.fontOutline)

	self.expBar.statusBar:SetOrientation(self.db.experience.orientation)
	self.expBar.statusBar:SetRotatesTexture(self.db.experience.orientation ~= "HORIZONTAL")

	self.expBar.rested:SetOrientation(self.db.experience.orientation)
	self.expBar.rested:SetRotatesTexture(self.db.experience.orientation ~= "HORIZONTAL")

	self.expBar.questBar:SetOrientation(self.db.experience.orientation)
	self.expBar.questBar:SetRotatesTexture(self.db.experience.orientation ~= "HORIZONTAL")

	local color = self.db.experience.questXP.color
	self.expBar.questBar:SetStatusBarColor(color.r, color.g, color.b, color.a)

	if self.expBar.bubbles then
		self:UpdateBarBubbles(self.expBar, self.db.experience)
	elseif self.db.experience.showBubbles then
		local bubbles = self:CreateBarBubbles(self.expBar)
		bubbles:SetFrameLevel(5)
		self:UpdateBarBubbles(self.expBar, self.db.experience)
	end
end

function mod:ExperienceBar_Toggle()
	if self.db.experience.enable and (self.playerLevel ~= self.maxExpansionLevel or not self.db.experience.hideAtMaxLevel) then
		self.playerLevel = UnitLevel("player")
		self.expDisabled = IsXPUserDisabled()

		self.expBar.eventFrame:RegisterEvent("DISABLE_XP_GAIN")
		self.expBar.eventFrame:RegisterEvent("ENABLE_XP_GAIN")

		if not self.expDisabled then
			self.expBar.eventFrame:RegisterEvent("PLAYER_LEVEL_UP")
			self.expBar.eventFrame:RegisterEvent("PLAYER_XP_UPDATE")
			self.expBar.eventFrame:RegisterEvent("UPDATE_EXHAUSTION")
			self.expBar.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
			self.expBar.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
		end

		self:ExperienceBar_Update()
		self:ExperienceBar_QuestXPToggle()
		E:EnableMover(self.expBar.mover:GetName())
	else
		self.expBar.eventFrame:UnregisterEvent("DISABLE_XP_GAIN")
		self.expBar.eventFrame:UnregisterEvent("ENABLE_XP_GAIN")

		if not self.expDisabled then
			self.expBar.eventFrame:UnregisterEvent("PLAYER_LEVEL_UP")
			self.expBar.eventFrame:UnregisterEvent("PLAYER_XP_UPDATE")
			self.expBar.eventFrame:UnregisterEvent("UPDATE_EXHAUSTION")
			self.expBar.eventFrame:UnregisterEvent("PLAYER_REGEN_DISABLED")
			self.expBar.eventFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
		end

		self:ExperienceBar_QuestXPToggle()
		self.expBar:Hide()
		E:DisableMover(self.expBar.mover:GetName())
	end
end

function mod:ExperienceBar_QuestXPToggle(event)
	if not self.questXPEnabled and not self.expDisabled and self.db.experience.questXP.enable then
		self.questXPEnabled = true

		self.expBar.eventFrame:RegisterEvent("QUEST_LOG_UPDATE")
		self.expBar.eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")

		self:ExperienceBar_QuestXPUpdate(event)
	elseif self.questXPEnabled and (self.expDisabled or not self.db.experience.questXP.enable) then
		self.questXPEnabled = false
		self.expBar.eventFrame:UnregisterEvent("QUEST_LOG_UPDATE")
		self.expBar.eventFrame:UnregisterEvent("ZONE_CHANGED_NEW_AREA")

		self.expBar.questBar:Hide()
	end
end

function mod:ExperienceBar_Load()
	self.expBar = self:CreateBar("ElvUI_ExperienceBar", self.ExperienceBar_OnEnter, self.ExperienceBar_OnClick, "LEFT", LeftChatPanel, "RIGHT", -E.Border + E.Spacing*3, 0)
	self.expBar:RegisterForClicks("RightButtonUp")
	self.expBar.statusBar:SetFrameLevel(4)
	self.expBar.statusBar:SetStatusBarColor(0, 0.4, 1, 0.8)

	self.expBar.rested = CreateFrame("StatusBar", "$parent_Rested", self.expBar)
	self.expBar.rested:SetFrameLevel(3)
	self.expBar.rested:SetInside()
	self.expBar.rested:SetStatusBarTexture(E.media.normTex)
	self.expBar.rested:SetStatusBarColor(1, 0, 1, 0.2)
	E:RegisterStatusBar(self.expBar.rested)

	self.expBar.questBar = CreateFrame("StatusBar", "$parent_Quest", self.expBar)
	self.expBar.questBar:SetFrameLevel(2)
	self.expBar.questBar:SetInside()
	self.expBar.questBar:SetStatusBarTexture(E.media.normTex)
	self.expBar.questBar:Hide()
	E:RegisterStatusBar(self.expBar.questBar)

	self.expBar.eventFrame = CreateFrame("Frame")
	self.expBar.eventFrame:Hide()
	self.expBar.eventFrame:SetScript("OnEvent", function(_, event, arg1)
		if event == "PLAYER_LEVEL_UP" then
			self.playerLevel = arg1
		elseif event == "PLAYER_REGEN_DISABLED" then
			self.inCombatLockdown = true
		elseif event == "PLAYER_REGEN_ENABLED" then
			self.inCombatLockdown = false
		elseif event == "ENABLE_XP_GAIN" then
			self.expDisabled = false

			self.expBar.eventFrame:RegisterEvent("PLAYER_LEVEL_UP")
			self.expBar.eventFrame:RegisterEvent("PLAYER_XP_UPDATE")
			self.expBar.eventFrame:RegisterEvent("UPDATE_EXHAUSTION")
			self.expBar.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
			self.expBar.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

			self:ExperienceBar_Update(event)
			self:ExperienceBar_QuestXPToggle(event)
			return
		elseif event == "DISABLE_XP_GAIN" then
			self.expDisabled = true

			self.expBar.eventFrame:UnregisterEvent("PLAYER_LEVEL_UP")
			self.expBar.eventFrame:UnregisterEvent("PLAYER_XP_UPDATE")
			self.expBar.eventFrame:UnregisterEvent("UPDATE_EXHAUSTION")
			self.expBar.eventFrame:UnregisterEvent("PLAYER_REGEN_DISABLED")
			self.expBar.eventFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")

			self:ExperienceBar_Update(event)
			self:ExperienceBar_QuestXPToggle(event)
			return
		elseif event == "QUEST_LOG_UPDATE"
		or event == "ZONE_CHANGED_NEW_AREA"
		then
			self:ExperienceBar_QuestXPUpdate(event)
			return
		end

		self:ExperienceBar_Update(event)
	end)

	self:ExperienceBar_UpdateDimensions()

	E:CreateMover(self.expBar, "ExperienceBarMover", L["Experience Bar"], nil, nil, nil, nil, nil, "databars,experience")
	self:ExperienceBar_Toggle()
end