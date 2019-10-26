local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local unpack = unpack
local find = string.find
--WoW API / Variables
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.trainer then return end

	ClassTrainerFrame:SetAttribute("UIPanelLayout-width", E:Scale(710))
	ClassTrainerFrame:SetAttribute("UIPanelLayout-height", E:Scale(470))
	ClassTrainerFrame:Size(710, 470)
	ClassTrainerFrame:StripTextures(true)
	ClassTrainerFrame:CreateBackdrop("Transparent")
	ClassTrainerFrame.backdrop:Point("TOPLEFT", 11, -12)
	ClassTrainerFrame.backdrop:Point("BOTTOMRIGHT", -31, 70)

	ClassTrainerListScrollFrame:StripTextures()
	ClassTrainerListScrollFrame:Size(300)
	ClassTrainerListScrollFrame.SetHeight = E.noop
	ClassTrainerListScrollFrame:ClearAllPoints()
	ClassTrainerListScrollFrame:Point("TOPLEFT", 17, -85)

	ClassTrainerDetailScrollFrame:StripTextures()
	ClassTrainerDetailScrollFrame:Size(295, 280)
	ClassTrainerDetailScrollFrame.SetHeight = E.noop
	ClassTrainerDetailScrollFrame:ClearAllPoints()
	ClassTrainerDetailScrollFrame:Point("TOPRIGHT", ClassTrainerFrame, -64, -85)
	ClassTrainerDetailScrollFrame.scrollBarHideable = nil

	ClassTrainerFrame.bg1 = CreateFrame("Frame", nil, ClassTrainerFrame)
	ClassTrainerFrame.bg1:SetTemplate("Transparent")
	ClassTrainerFrame.bg1:Point("TOPLEFT", 18, -77)
	ClassTrainerFrame.bg1:Point("BOTTOMRIGHT", -367, 77)
	ClassTrainerFrame.bg1:SetFrameLevel(ClassTrainerFrame.bg1:GetFrameLevel() - 1)

	ClassTrainerFrame.bg2 = CreateFrame("Frame", nil, ClassTrainerFrame)
	ClassTrainerFrame.bg2:SetTemplate("Transparent")
	ClassTrainerFrame.bg2:Point("TOPLEFT", ClassTrainerFrame.bg1, "TOPRIGHT", 1, 0)
	ClassTrainerFrame.bg2:Point("BOTTOMRIGHT", ClassTrainerFrame, "BOTTOMRIGHT", -38, 77)
	ClassTrainerFrame.bg2:SetFrameLevel(ClassTrainerFrame.bg2:GetFrameLevel() - 1)

	ClassTrainerDetailScrollChildFrame:StripTextures()
	ClassTrainerDetailScrollChildFrame:Size(300, 150)

	ClassTrainerExpandButtonFrame:StripTextures()

	S:HandleDropDownBox(ClassTrainerFrameFilterDropDown)
	ClassTrainerFrameFilterDropDown:Point("TOPRIGHT", -55, -40)

	S:HandleScrollBar(ClassTrainerListScrollFrameScrollBar)
	S:HandleScrollBar(ClassTrainerDetailScrollFrameScrollBar)

	ClassTrainerCancelButton:ClearAllPoints()
	ClassTrainerCancelButton:Point("TOPRIGHT", ClassTrainerDetailScrollFrame, "BOTTOMRIGHT", 23, -3)
	S:HandleButton(ClassTrainerCancelButton)

	ClassTrainerTrainButton:ClearAllPoints()
	ClassTrainerTrainButton:Point("TOPRIGHT", ClassTrainerCancelButton, "TOPLEFT", -3, 0)
	S:HandleButton(ClassTrainerTrainButton)

	ClassTrainerMoneyFrame:ClearAllPoints()
	ClassTrainerMoneyFrame:Point("BOTTOMLEFT", ClassTrainerFrame, "BOTTOMRIGHT", -180, 107)

	ClassTrainerSkillHighlight:SetTexture(E.Media.Textures.Highlight)
	ClassTrainerSkillHighlight:SetAlpha(0.35)

	S:HandleCloseButton(ClassTrainerFrameCloseButton, ClassTrainerFrame.backdrop)

	ClassTrainerSkillIcon:StripTextures()
	ClassTrainerSkillIcon:StyleButton(nil, true)

	hooksecurefunc("ClassTrainer_SetSelection", function()
		local skillIcon = ClassTrainerSkillIcon:GetNormalTexture()
		if skillIcon then
			skillIcon:SetInside()
			skillIcon:SetTexCoord(unpack(E.TexCoords))

			ClassTrainerSkillIcon:SetTemplate("Default")
		end
	end)

	CLASS_TRAINER_SKILLS_DISPLAYED = 19

	hooksecurefunc("ClassTrainer_SetToTradeSkillTrainer", function()
		CLASS_TRAINER_SKILLS_DISPLAYED = 19
	end)

	hooksecurefunc("ClassTrainer_SetToClassTrainer", function()
		CLASS_TRAINER_SKILLS_DISPLAYED = 19
	end)

	for i = 12, 19 do
		CreateFrame("Button", "ClassTrainerSkill"..i, ClassTrainerFrame, "ClassTrainerSkillButtonTemplate"):Point("TOPLEFT", _G["ClassTrainerSkill"..i - 1], "BOTTOMLEFT")
	end

	ClassTrainerSkill1:Point("TOPLEFT", 22, -80)

	for i = 1, CLASS_TRAINER_SKILLS_DISPLAYED do
		local skillButton = _G["ClassTrainerSkill"..i]
		local highlight = _G["ClassTrainerSkill"..i.."Highlight"]

		skillButton:SetNormalTexture(E.Media.Textures.Plus)
		skillButton.SetNormalTexture = E.noop
		skillButton:GetNormalTexture():Size(16)

		highlight:SetTexture("")
		highlight.SetTexture = E.noop

		hooksecurefunc(skillButton, "SetNormalTexture", function(self, texture)
			if find(texture, "MinusButton") then
				self:GetNormalTexture():SetTexture(E.Media.Textures.Minus)
			elseif find(texture, "PlusButton") then
				self:GetNormalTexture():SetTexture(E.Media.Textures.Plus)
			else
				self:GetNormalTexture():SetTexture("")
			end
		end)
	end

	ClassTrainerCollapseAllButton:Point("LEFT", ClassTrainerExpandTabLeft, "RIGHT", 5, 20)

	ClassTrainerCollapseAllButton:SetNormalTexture(E.Media.Textures.Plus)
	ClassTrainerCollapseAllButton.SetNormalTexture = E.noop
	ClassTrainerCollapseAllButton:GetNormalTexture():Point("LEFT", 3, 2)
	ClassTrainerCollapseAllButton:GetNormalTexture():Size(16)

	ClassTrainerCollapseAllButton:SetHighlightTexture("")
	ClassTrainerCollapseAllButton.SetHighlightTexture = E.noop

	ClassTrainerCollapseAllButton:SetDisabledTexture(E.Media.Textures.Plus)
	ClassTrainerCollapseAllButton.SetDisabledTexture = E.noop
	ClassTrainerCollapseAllButton:GetDisabledTexture():Point("LEFT", 3, 2)
	ClassTrainerCollapseAllButton:GetDisabledTexture():Size(16)
	ClassTrainerCollapseAllButton:GetDisabledTexture():SetDesaturated(true)

	hooksecurefunc(ClassTrainerCollapseAllButton, "SetNormalTexture", function(self, texture)
		if find(texture, "MinusButton") then
			self:GetNormalTexture():SetTexture(E.Media.Textures.Minus)
		else
			self:GetNormalTexture():SetTexture(E.Media.Textures.Plus)
		end
	end)
end

S:AddCallbackForAddon("Blizzard_TrainerUI", "Skin_Blizzard_TrainerUI", LoadSkin)