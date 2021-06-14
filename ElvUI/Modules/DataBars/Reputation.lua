local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule("DataBars")
local LSM = LibStub("LibSharedMedia-3.0")

--Lua functions
local _G = _G
local max = math.max
local format = string.format
--WoW API
local GetWatchedFactionInfo = GetWatchedFactionInfo
local ToggleCharacter = ToggleCharacter
-- WoW Variables
local FACTION_BAR_COLORS = FACTION_BAR_COLORS
local REPUTATION = REPUTATION
local STANDING = STANDING
local UNKNOWN = UNKNOWN

function mod:ReputationBar_Update(event)
	if not mod.db.reputation.enable then return end

	local bar = self.repBar

	local name, standingID, minRep, maxRep, value = GetWatchedFactionInfo()

	if not name or (event == "PLAYER_REGEN_DISABLED" and self.db.reputation.hideInCombat) then
		E:DisableMover(self.repBar.mover:GetName())
		bar:Hide()
	elseif name and (not self.db.reputation.hideInCombat or not self.inCombatLockdown) then
		E:EnableMover(self.repBar.mover:GetName())
		bar:Show()

		if self.db.reputation.hideInVehicle then
			E:RegisterObjectForVehicleLock(bar, E.UIParent)
		else
			E:UnregisterObjectForVehicleLock(bar)
		end

		local textFormat = self.db.reputation.textFormat
		local standing = _G["FACTION_STANDING_LABEL"..standingID] or UNKNOWN
		local color = FACTION_BAR_COLORS[standingID] or FACTION_BAR_COLORS[1]
		local maxMinDiff = max(1, maxRep - minRep)

		bar.statusBar:SetStatusBarColor(color.r, color.g, color.b)
		bar.statusBar:SetMinMaxValues(minRep, maxRep)
		bar.statusBar:SetValue(value)

		if textFormat == "PERCENT" then
			bar.text:SetFormattedText("%s: %d%% [%s]", name, ((value - minRep) / maxMinDiff * 100), standing)
		elseif textFormat == "CURMAX" then
			bar.text:SetFormattedText("%s: %s - %s [%s]", name, E:ShortValue(value - minRep), E:ShortValue(maxRep - minRep), standing)
		elseif textFormat == "CURPERC" then
			bar.text:SetFormattedText("%s: %s - %d%% [%s]", name, E:ShortValue(value - minRep), ((value - minRep) / maxMinDiff * 100), standing)
		elseif textFormat == "CUR" then
			bar.text:SetFormattedText("%s: %s [%s]", name, E:ShortValue(value - minRep), standing)
		elseif textFormat == "REM" then
			bar.text:SetFormattedText("%s: %s [%s]", name, E:ShortValue((maxRep - minRep) - (value - minRep)), standing)
		elseif textFormat == "CURREM" then
			bar.text:SetFormattedText("%s: %s - %s [%s]", name, E:ShortValue(value - minRep), E:ShortValue((maxRep - minRep) - (value - minRep)), standing)
		elseif textFormat == "CURPERCREM" then
			bar.text:SetFormattedText("%s: %s - %d%% (%s) [%s]", name, E:ShortValue(value - minRep), ((value - minRep) / maxMinDiff * 100), E:ShortValue((maxRep - minRep) - (value - minRep)), standing)
		end
	end
end

function mod:ReputationBar_OnEnter()
	if mod.db.reputation.mouseover then
		E:UIFrameFadeIn(self, 0.4, self:GetAlpha(), 1)
	end

	local name, reaction, minRep, maxRep, value = GetWatchedFactionInfo()
	if name then
		GameTooltip:ClearLines()
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR", 0, -4)

		GameTooltip:AddLine(name)
		GameTooltip:AddLine(" ")

		GameTooltip:AddDoubleLine(STANDING..":", _G["FACTION_STANDING_LABEL"..reaction], 1, 1, 1)
		GameTooltip:AddDoubleLine(REPUTATION..":", format("%d / %d (%d%%)", value - minRep, maxRep - minRep, (value - minRep) / ((maxRep - minRep == 0) and maxRep or (maxRep - minRep)) * 100), 1, 1, 1)

		GameTooltip:Show()
	end
end

function mod:ReputationBar_OnClick()
	ToggleCharacter("ReputationFrame")
end

function mod:ReputationBar_UpdateDimensions()
	self.repBar:Size(self.db.reputation.width, self.db.reputation.height)
	self.repBar:SetAlpha(self.db.reputation.mouseover and 0 or 1)

	self.repBar.text:FontTemplate(LSM:Fetch("font", self.db.reputation.font), self.db.reputation.textSize, self.db.reputation.fontOutline)

	self.repBar.statusBar:SetOrientation(self.db.reputation.orientation)
	self.repBar.statusBar:SetRotatesTexture(self.db.reputation.orientation ~= "HORIZONTAL")

	if self.repBar.bubbles then
		self:UpdateBarBubbles(self.repBar, self.db.reputation)
	elseif self.db.reputation.showBubbles then
		local bubbles = self:CreateBarBubbles(self.repBar)
		bubbles:SetFrameLevel(5)
		self:UpdateBarBubbles(self.repBar, self.db.reputation)
	end
end

function mod:ReputationBar_Toggle()
	if self.db.reputation.enable then
		self.repBar.eventFrame:RegisterEvent("UPDATE_FACTION")
		self.repBar.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
		self.repBar.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

		self:ReputationBar_Update()
		E:EnableMover(self.repBar.mover:GetName())
	else
		self.repBar.eventFrame:UnregisterEvent("UPDATE_FACTION")
		self.repBar.eventFrame:UnregisterEvent("PLAYER_REGEN_DISABLED")
		self.repBar.eventFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")

		self.repBar:Hide()
		E:DisableMover(self.repBar.mover:GetName())
	end
end

function mod:ReputationBar_Load()
	self.repBar = self:CreateBar("ElvUI_ReputationBar", self.ReputationBar_OnEnter, self.ReputationBar_OnClick, "RIGHT", RightChatPanel, "LEFT", E.Border - E.Spacing*3, 0)

	self.repBar.eventFrame = CreateFrame("Frame")
	self.repBar.eventFrame:Hide()
	self.repBar.eventFrame:SetScript("OnEvent", function(_, event)
		if event == "PLAYER_REGEN_DISABLED" then
			self.inCombatLockdown = true
		elseif event == "PLAYER_REGEN_ENABLED" then
			self.inCombatLockdown = false
		end

		self:ReputationBar_Update(event)
	end)

	self:ReputationBar_UpdateDimensions()

	E:CreateMover(self.repBar, "ReputationBarMover", L["Reputation Bar"], nil, nil, nil, nil, nil, "databars,reputation")
	self:ReputationBar_Toggle()
end