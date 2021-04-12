local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule("DataBars")
local LSM = LibStub("LibSharedMedia-3.0")

--Lua functions
local min = math.min
local format = string.format
--WoW API / Variables
local GetExpansionLevel = GetExpansionLevel
local GetPetExperience = GetPetExperience
local GetXPExhaustion = GetXPExhaustion
local InCombatLockdown = InCombatLockdown
local IsXPUserDisabled = IsXPUserDisabled
local UnitLevel = UnitLevel
local UnitXP = UnitXP
local UnitXPMax = UnitXPMax
local MAX_PLAYER_LEVEL_TABLE = MAX_PLAYER_LEVEL_TABLE

function mod:GetXP(unit)
	if unit == "pet" then
		return GetPetExperience()
	else
		return UnitXP(unit), UnitXPMax(unit)
	end
end

function mod:ExperienceBar_Update(event)
	if not mod.db.experience.enable then return end

	local bar = self.expBar
	local hideXP = ((UnitLevel("player") == MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()] and self.db.experience.hideAtMaxLevel) or IsXPUserDisabled())

	if hideXP or (event == "PLAYER_REGEN_DISABLED" and self.db.experience.hideInCombat) then
		E:DisableMover(self.expBar.mover:GetName())
		bar:Hide()
	elseif not hideXP and (not self.db.experience.hideInCombat or not InCombatLockdown()) then
		E:EnableMover(self.expBar.mover:GetName())
		bar:Show()

		if self.db.experience.hideInVehicle then
			E:RegisterObjectForVehicleLock(bar, E.UIParent)
		else
			E:UnregisterObjectForVehicleLock(bar)
		end

		local cur, max = self:GetXP("player")
		local total = self:ExperienceBar_QuestXP()
		if max <= 0 then max = 1 end

		bar.statusBar:SetMinMaxValues(0, max)
		bar.statusBar:SetValue(cur - 1 >= 0 and cur - 1 or 0)
		bar.statusBar:SetValue(cur)

		bar.questBar:SetMinMaxValues(0, max)
		bar.questBar:SetValue(min(cur + total, max))

		if cur + total >= max then
			bar.questBar:SetStatusBarColor(0/255, 255/255, 0/255, 0.5)
		else
			local color = self.db.experience.questXP.color
			bar.questBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
		end

		bar.bubbles:SetWidth(bar:GetWidth() - 4)
		bar.bubbles:SetHeight(bar:GetHeight() - 8)

		if self.db.experience.questXP.showBubbles then
			bar.bubbles:Show()
		else
			bar.bubbles:Hide()
		end

		local rested = GetXPExhaustion()
		local text = ""
		local textFormat = self.db.experience.textFormat

		if rested and rested > 0 then
			bar.rested:SetMinMaxValues(0, max)
			bar.rested:SetValue(min(cur + rested, max))

			if textFormat == "PERCENT" then
				text = format("%d%% R:%d%%", cur / max * 100, rested / max * 100)
			elseif textFormat == "CURMAX" then
				text = format("%s - %s R:%s", E:ShortValue(cur), E:ShortValue(max), E:ShortValue(rested))
			elseif textFormat == "CURPERC" then
				text = format("%s - %d%% R:%s [%d%%]", E:ShortValue(cur), cur / max * 100, E:ShortValue(rested), rested / max * 100)
			elseif textFormat == "CUR" then
				text = format("%s R:%s", E:ShortValue(cur), E:ShortValue(rested))
			elseif textFormat == "REM" then
				text = format("%s R:%s", E:ShortValue(max - cur), E:ShortValue(rested))
			elseif textFormat == "CURREM" then
				text = format("%s - %s R:%s", E:ShortValue(cur), E:ShortValue(max - cur), E:ShortValue(rested))
			elseif textFormat == "CURPERCREM" then
				text = format("%s - %d%% (%s) R:%s", E:ShortValue(cur), cur / max * 100, E:ShortValue(max - cur), E:ShortValue(rested))
			end
		else
			bar.rested:SetMinMaxValues(0, 1)
			bar.rested:SetValue(0)

			if textFormat == "PERCENT" then
				text = format("%d%%", cur / max * 100)
			elseif textFormat == "CURMAX" then
				text = format("%s - %s", E:ShortValue(cur), E:ShortValue(max))
			elseif textFormat == "CURPERC" then
				text = format("%s - %d%%", E:ShortValue(cur), cur / max * 100)
			elseif textFormat == "CUR" then
				text = format("%s", E:ShortValue(cur))
			elseif textFormat == "REM" then
				text = format("%s", E:ShortValue(max - cur))
			elseif textFormat == "CURREM" then
				text = format("%s - %s", E:ShortValue(cur), E:ShortValue(max - cur))
			elseif textFormat == "CURPERCREM" then
				text = format("%s - %d%% (%s)", E:ShortValue(cur), cur / max * 100, E:ShortValue(max - cur))
			end
		end

		bar.text:SetText(text)
	end
end

function mod:ExperienceBar_QuestXP()
	local lastQuestLogID = GetQuestLogSelection()
	local completedOnly = self.db.experience.questXP.questCompletedOnly
	local zoneOnly = self.db.experience.questXP.questCurrentZoneOnly
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

function mod:ExperienceBar_OnEnter()
	if mod.db.experience.mouseover then
		E:UIFrameFadeIn(self, 0.4, self:GetAlpha(), 1)
	end
	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, "ANCHOR_CURSOR", 0, -4)

	local cur, max = mod:GetXP("player")
	local rested = GetXPExhaustion()
	GameTooltip:AddLine(L["Experience"])
	GameTooltip:AddLine(" ")

	GameTooltip:AddDoubleLine(L["XP:"], format(" %d / %d (%d%%)", cur, max, cur/max * 100), 1, 1, 1)
	GameTooltip:AddDoubleLine(L["Remaining:"], format(" %d (%d%% - %d "..L["Bars"]..")", max - cur, (max - cur) / max * 100, 20 * (max - cur) / max), 1, 1, 1)

	if rested then
		GameTooltip:AddDoubleLine(L["Rested:"], format("+%d (%d%%)", rested, rested / max * 100), 1, 1, 1)
	end

	if mod.db.experience.questXP.tooltip then
		GameTooltip:AddDoubleLine("Quest Log XP:", mod:ExperienceBar_QuestXP(), 1, 1, 1)
	end

	GameTooltip:Show()
end

function mod:ExperienceBar_OnClick(button)
	if not XPRM then return end
	if button == "RightButton" then
		ToggleDropDownMenu(1, nil, XPRM, "cursor")
	end
end

function mod:ExperienceBar_UpdateDimensions()
	local bar = self.expBar
	bar:Width(self.db.experience.width)
	bar:Height(self.db.experience.height)

	bar.text:FontTemplate(LSM:Fetch("font", self.db.experience.font), self.db.experience.textSize, self.db.experience.fontOutline)
	bar.rested:SetOrientation(self.db.experience.orientation)

	bar.statusBar:SetOrientation(self.db.experience.orientation)

	bar.questBar:SetOrientation(E.db.databars.experience.orientation)

	if self.db.experience.mouseover then
		bar:SetAlpha(0)
	else
		bar:SetAlpha(1)
	end
end

function mod:ExperienceBar_Toggle()
	local maxLevel = MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()]
	if (UnitLevel("player") ~= maxLevel or not self.db.experience.hideAtMaxLevel) and self.db.experience.enable then
		self:RegisterEvent("PLAYER_XP_UPDATE", "ExperienceBar_Update")
		self:RegisterEvent("DISABLE_XP_GAIN", "ExperienceBar_Update")
		self:RegisterEvent("ENABLE_XP_GAIN", "ExperienceBar_Update")
		self:RegisterEvent("UPDATE_EXHAUSTION", "ExperienceBar_Update")
		self:RegisterEvent("QUEST_LOG_UPDATE", "ExperienceBar_QuestXP")
		self:RegisterEvent("ZONE_CHANGED", "ExperienceBar_QuestXP")
		self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "ExperienceBar_QuestXP")
		self:UnregisterEvent("UPDATE_EXPANSION_LEVEL")

		self:ExperienceBar_Update()
		E:EnableMover(self.expBar.mover:GetName())
	else
		self:UnregisterEvent("PLAYER_XP_UPDATE")
		self:UnregisterEvent("DISABLE_XP_GAIN")
		self:UnregisterEvent("ENABLE_XP_GAIN")
		self:UnregisterEvent("UPDATE_EXHAUSTION")
		self:UnregisterEvent("QUEST_LOG_UPDATE")
		self:UnregisterEvent("ZONE_CHANGED")
		self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
		self:RegisterEvent("UPDATE_EXPANSION_LEVEL", "ExperienceBar_Toggle")

		self.expBar:Hide()
		E:DisableMover(self.expBar.mover:GetName())
	end
end

function mod:LoadExperienceBar()
	self.expBar = self:CreateBar("ElvUI_ExperienceBar", self.ExperienceBar_OnEnter, self.ExperienceBar_OnClick, "LEFT", LeftChatPanel, "RIGHT", -E.Border + E.Spacing*3, 0)
	local bar = self.expBar
	bar:HookScript("OnMouseUp", self.ExperienceBar_OnClick)

	bar.statusBar:SetStatusBarColor(0, 0.4, 1, .8)
	bar.statusBar:SetFrameLevel(4)

	bar.rested = CreateFrame("StatusBar", "ElvUI_ExperienceBar_Rested", bar)
	bar.rested:SetInside()
	bar.rested:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(bar.rested)
	bar.rested:SetStatusBarColor(1, 0, 1, 0.2)
	bar.rested:SetFrameLevel(2)
	bar.rested.statusBar = bar.rested:GetStatusBarTexture()
	bar.rested.statusBar:SetDrawLayer("ARTWORK", 2)

	bar.questBar = CreateFrame("StatusBar", "ElvUI_ExperienceBar_Quest", bar)
	bar.questBar:SetInside()
	bar.questBar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(bar.questBar)
	bar.questBar:SetStatusBarColor(unpack(self.db.experience.questXP.color))
	bar.questBar:SetFrameLevel(3)
	bar.questBar.statusBar = bar.questBar:GetStatusBarTexture()
	bar.questBar.statusBar:SetDrawLayer("ARTWORK", 3)

	bar.eventFrame = CreateFrame("Frame")
	bar.eventFrame:Hide()
	bar.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	bar.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	bar.eventFrame:SetScript("OnEvent", function(_, event)
		mod:ExperienceBar_Update(event)
	end)

	bar.questBar.eventFrame = CreateFrame("Frame")
	bar.questBar.eventFrame:Hide()
	bar.questBar.eventFrame:RegisterEvent("QUEST_LOG_UPDATE")
	bar.questBar.eventFrame:RegisterEvent("PLAYER_XP_UPDATE")
	bar.questBar.eventFrame:RegisterEvent("UPDATE_EXHAUSTION")
	bar.questBar.eventFrame:RegisterEvent("ZONE_CHANGED")
	bar.questBar.eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	bar.questBar.eventFrame:RegisterEvent("UNIT_PORTRAIT_UPDATE")
	bar.questBar.eventFrame:SetScript("OnEvent", function(self, event)
		mod:ExperienceBar_Update(event)
	end)

	bar.bubbles = CreateFrame("StatusBar", nil, bar)
	bar.bubbles:SetStatusBarTexture("Interface\\AddOns\\ElvUI\\media\\textures\\Bubbles")
	bar.bubbles:SetPoint("CENTER", bar, "CENTER", 0, 0)
	bar.bubbles:SetWidth(bar:GetWidth() - 4)
	bar.bubbles:SetHeight(bar:GetHeight() - 8)
	bar.bubbles:SetInside()
	-- XXX: Blizz tiling breakage.
	bar.bubbles:GetStatusBarTexture():SetHorizTile(false)
	bar.bubbles:SetFrameLevel(bar:GetFrameLevel() + 4)

	self:ExperienceBar_UpdateDimensions()

	E:CreateMover(bar, "ExperienceBarMover", L["Experience Bar"], nil, nil, nil, nil, nil, "databars,experience")
	self:ExperienceBar_Toggle()
end