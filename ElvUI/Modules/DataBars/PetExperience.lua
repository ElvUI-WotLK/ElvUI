local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule("DataBars")
local LSM = LibStub("LibSharedMedia-3.0")

--Lua functions
local max, min = math.max, math.min
local format = string.format
--WoW API
local GetPetExperience = GetPetExperience
local HasPetUI = HasPetUI
local UnitLevel = UnitLevel

function mod:PetExperienceBar_Update(event)
	if E.myclass ~= "HUNTER" or not mod.db.petExperience.enable then return end

	local bar = self.petExpBar
	local _, hunterPet = HasPetUI()
	local hideBar = not hunterPet or (UnitLevel("pet") == self.maxExpansionLevel and self.db.petExperience.hideAtMaxLevel)

	if hideBar or (event == "PLAYER_REGEN_DISABLED" and self.db.petExperience.hideInCombat) then
		E:DisableMover(self.petExpBar.mover:GetName())
		bar:Hide()
	elseif not hideBar and (not self.db.petExperience.hideInCombat or not self.inCombatLockdown) then
		E:EnableMover(self.petExpBar.mover:GetName())
		bar:Show()

		local textFormat = self.db.petExperience.textFormat
		local curExp, maxExp = GetPetExperience()
		maxExp = max(1, maxExp)

		bar.statusBar:SetMinMaxValues(min(0, curExp), maxExp)
	--	bar.statusBar:SetValue(curExp - 1 >= 0 and curExp - 1 or 0)
		bar.statusBar:SetValue(curExp)

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

function mod:PetExperienceBar_OnEnter()
	if mod.db.petExperience.mouseover then
		E:UIFrameFadeIn(self, 0.4, self:GetAlpha(), 1)
	end

	local curExp, maxExp = GetPetExperience()
	maxExp = max(1, maxExp)

	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, "ANCHOR_CURSOR", 0, -4)

	GameTooltip:AddLine(L["Pet Experience"])
	GameTooltip:AddLine(" ")

	GameTooltip:AddDoubleLine(L["XP:"], format("%d / %d (%d%%)", curExp, maxExp, curExp / maxExp * 100), 1, 1, 1)
	GameTooltip:AddDoubleLine(L["Remaining:"], format("%d (%d%% - %d %s)", maxExp - curExp, (maxExp - curExp) / maxExp * 100, 20 * (maxExp - curExp) / maxExp, L["Bars"]), 1, 1, 1)

	GameTooltip:Show()
end

function mod:PetExperienceBar_OnClick()

end

function mod:PetExperienceBar_UpdateDimensions()
	if E.myclass ~= "HUNTER" then return end

	self.petExpBar:Size(self.db.petExperience.width, self.db.petExperience.height)
	self.petExpBar:SetAlpha(self.db.petExperience.mouseover and 0 or 1)

	self.petExpBar.text:FontTemplate(LSM:Fetch("font", self.db.petExperience.font), self.db.petExperience.textSize, self.db.petExperience.fontOutline)

	self.petExpBar.statusBar:SetOrientation(self.db.petExperience.orientation)
	self.petExpBar.statusBar:SetRotatesTexture(self.db.petExperience.orientation ~= "HORIZONTAL")

	if self.petExpBar.bubbles then
		self:UpdateBarBubbles(self.petExpBar, self.db.petExperience)
	elseif self.db.petExperience.showBubbles then
		local bubbles = self:CreateBarBubbles(self.petExpBar)
		bubbles:SetFrameLevel(5)
		self:UpdateBarBubbles(self.petExpBar, self.db.petExperience)
	end
end

function mod:PetExperienceBar_Toggle()
	if E.myclass ~= "HUNTER" then return end

	if self.db.petExperience.enable then
		self.petExpBar.eventFrame:RegisterEvent("UNIT_PET")
		self.petExpBar.eventFrame:RegisterEvent("UNIT_PET_EXPERIENCE")
		self.petExpBar.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
		self.petExpBar.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

		self:PetExperienceBar_Update()
		E:EnableMover(self.petExpBar.mover:GetName())
	else
		self.petExpBar.eventFrame:UnregisterEvent("UNIT_PET")
		self.petExpBar.eventFrame:UnregisterEvent("UNIT_PET_EXPERIENCE")
		self.petExpBar.eventFrame:UnregisterEvent("PLAYER_REGEN_DISABLED")
		self.petExpBar.eventFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")

		self.petExpBar:Hide()
		E:DisableMover(self.petExpBar.mover:GetName())
	end
end

function mod:PetExperienceBar_Load()
	if E.myclass ~= "HUNTER" then return end

	self.petExpBar = self:CreateBar("ElvUI_PetExperienceBar", self.PetExperienceBar_OnEnter, self.PetExperienceBar_OnClick, "LEFT", LeftChatPanel, "RIGHT", -E.Border + E.Spacing*3, 0)
	self.petExpBar.statusBar:SetStatusBarColor(1, 1, 0.41, 0.8)

	self.petExpBar.eventFrame = CreateFrame("Frame")
	self.petExpBar.eventFrame:Hide()
	self.petExpBar.eventFrame:SetScript("OnEvent", function(_, event, arg1)
		if event == "UNIT_PET" then
			if arg1 == "player" then
				self:PetExperienceBar_Toggle()
			end
		elseif event == "PLAYER_REGEN_DISABLED" then
			self.inCombatLockdown = true
		elseif event == "PLAYER_REGEN_ENABLED" then
			self.inCombatLockdown = false
		else
			self:PetExperienceBar_Update(event)
		end
	end)

	self:PetExperienceBar_UpdateDimensions()

	E:CreateMover(self.petExpBar, "PetExperienceBarMover", L["Pet Experience Bar"], nil, nil, nil, nil, nil, "databars,petExperience")
	self:PetExperienceBar_Toggle()
end