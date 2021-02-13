local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule("DataBars")
local LSM = LibStub("LibSharedMedia-3.0")

--Lua functions
local _G = _G
local format = format
--WoW API / Variables
local GetExpansionLevel = GetExpansionLevel
local MAX_PLAYER_LEVEL_TABLE = MAX_PLAYER_LEVEL_TABLE
local InCombatLockdown = InCombatLockdown
local CreateFrame = CreateFrame
local HasPetUI = HasPetUI

function mod:UpdatePetExperience(event)
	if E.myclass ~= "HUNTER" then return end
	if not mod.db.petExperience.enable then return end

    local bar = self.petExpBar
	local hideXP = ((UnitLevel("pet") == MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()] and self.db.petExperience.hideAtMaxLevel))

	if hideXP or (event == "PLAYER_REGEN_DISABLED" and self.db.petExperience.hideInCombat) then
		E:DisableMover(self.petExpBar.mover:GetName())
		bar:Hide()
	elseif not hideXP and (not self.db.petExperience.hideInCombat or not InCombatLockdown()) then
		E:EnableMover(self.petExpBar.mover:GetName())
		bar:Show()

		local cur, max = self:GetXP("pet")
		if max <= 0 then max = 1 end
		bar.statusBar:SetMinMaxValues(0, max)
		bar.statusBar:SetValue(cur - 1 >= 0 and cur - 1 or 0)
		bar.statusBar:SetValue(cur)

		local text = ""
		local textFormat = self.db.petExperience.textFormat

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

		bar.text:SetText(text)
	end
end

function mod:PetExperienceBar_OnEnter()
	local GameTooltip = _G.GameTooltip
	if mod.db.petExperience.mouseover then
		E:UIFrameFadeIn(self, 0.4, self:GetAlpha(), 1)
	end

	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, "ANCHOR_CURSOR", 0, -4)

	local cur, max = mod:GetXP("pet")
	if max <= 0 then max = 1 end

	GameTooltip:AddLine(L["Pet Experience"])
	GameTooltip:AddLine(" ")

	GameTooltip:AddDoubleLine(L["XP:"], format(" %d / %d (%d%%)", cur, max, cur/max * 100), 1, 1, 1)
	GameTooltip:AddDoubleLine(L["Remaining:"], format(" %d (%d%% - %d "..L["Bars"]..")", max - cur, (max - cur) / max * 100, 20 * (max - cur) / max), 1, 1, 1)

	GameTooltip:Show()
end

function mod:PetExperienceBar_OnClick() end

function mod:UpdatePetExperienceDimensions()
	if E.myclass ~= "HUNTER" then return end
	self.petExpBar:Width(self.db.petExperience.width)
	self.petExpBar:Height(self.db.petExperience.height)

	self.petExpBar.text:FontTemplate(LSM:Fetch("font", self.db.petExperience.font), self.db.petExperience.textSize, self.db.petExperience.fontOutline)

	self.petExpBar.statusBar:SetOrientation(self.db.petExperience.orientation)

	if self.db.petExperience.orientation == "HORIZONTAL" then
		self.petExpBar.statusBar:SetRotatesTexture(false)
	else
		self.petExpBar.statusBar:SetRotatesTexture(true)
	end

	if self.db.petExperience.mouseover then
		self.petExpBar:SetAlpha(0)
	else
		self.petExpBar:SetAlpha(1)
	end
end

function mod:EnableDisable_PetExperienceBar()
	if E.myclass ~= "HUNTER" then return end
	if (UnitLevel("pet") ~= MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()] or not self.db.petExperience.hideAtMaxLevel) and self.db.petExperience.enable and HasPetUI() then
		self:UpdatePetExperience()
		E:EnableMover(self.petExpBar.mover:GetName())
	else
		self.petExpBar:Hide()
		E:DisableMover(self.petExpBar.mover:GetName())
	end
end

function mod:LoadPetExperienceBar()
	if E.myclass ~= "HUNTER" then return end
    self.petExpBar = self:CreateBar("ElvUI_PetExperienceBar", self.PetExperienceBar_OnEnter, self.PetExperienceBar_OnClick, "LEFT", LeftChatPanel, "RIGHT", -E.Border + E.Spacing*3, 0)
	self.petExpBar.statusBar:SetStatusBarColor(1, 1, .41, .8)

	self.petExpBar.eventFrame = CreateFrame("Frame")
	self.petExpBar.eventFrame:Hide()
	self.petExpBar.eventFrame:RegisterEvent("UNIT_PET")
	self.petExpBar.eventFrame:RegisterEvent("UNIT_PET_EXPERIENCE")
	self.petExpBar.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	self.petExpBar.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	self.petExpBar.eventFrame:SetScript("OnEvent", function(self, event)
		if event == "UNIT_PET" then
			mod:EnableDisable_PetExperienceBar()
		else
			mod:UpdatePetExperience(event)
		end
	end)

	self:UpdatePetExperienceDimensions()

	E:CreateMover(self.petExpBar, "PetExperienceBarMover", L["Pet Experience Bar"], nil, nil, nil, nil, nil, "databars,petExperience")
	self:EnableDisable_PetExperienceBar()
end
