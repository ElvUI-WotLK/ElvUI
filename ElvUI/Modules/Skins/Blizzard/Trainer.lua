local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local unpack = unpack
--WoW API / Variables
local hooksecurefunc = hooksecurefunc

S:AddCallbackForAddon("Blizzard_TrainerUI", "Skin_Blizzard_TrainerUI", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.trainer then return end

	ClassTrainerFrame:StripTextures(true)
	ClassTrainerFrame:CreateBackdrop("Transparent")
	ClassTrainerFrame.backdrop:Point("TOPLEFT", 11, -12)
	ClassTrainerFrame.backdrop:Point("BOTTOMRIGHT", -32, 76)

	S:SetUIPanelWindowInfo(ClassTrainerFrame, "width")
	S:SetBackdropHitRect(ClassTrainerFrame)

	S:HandleCloseButton(ClassTrainerFrameCloseButton, ClassTrainerFrame.backdrop)

	ClassTrainerListScrollFrame:StripTextures()

	ClassTrainerDetailScrollFrame:StripTextures()
	ClassTrainerDetailScrollFrame.scrollBarHideable = nil

	ClassTrainerExpandButtonFrame:StripTextures()

	ClassTrainerDetailScrollChildFrame:StripTextures()

	S:HandleDropDownBox(ClassTrainerFrameFilterDropDown)

	S:HandleScrollBar(ClassTrainerListScrollFrameScrollBar)
	S:HandleScrollBar(ClassTrainerDetailScrollFrameScrollBar)

	ClassTrainerSkillHighlight:SetTexture(E.Media.Textures.Highlight)
	ClassTrainerSkillHighlight:SetAlpha(0.35)

	ClassTrainerSkillIcon:StripTextures()
	ClassTrainerSkillIcon:StyleButton(nil, true)

	S:HandleCollapseExpandButton(ClassTrainerCollapseAllButton, "+", nil, nil, 1)

	for i = 1, CLASS_TRAINER_SKILLS_DISPLAYED do
		local skillButton = _G["ClassTrainerSkill"..i]
		local highlight = _G["ClassTrainerSkill"..i.."Highlight"]

		S:HandleCollapseExpandButton(skillButton, "+", nil, nil, 1)

		highlight:SetTexture("")
		highlight.SetTexture = E.noop
	end

	S:HandleButton(ClassTrainerCancelButton)
	S:HandleButton(ClassTrainerTrainButton)

	ClassTrainerGreetingText:Width(317)
	ClassTrainerGreetingText:Point("TOPLEFT", 22, -35)
	ClassTrainerGreetingText:SetJustifyH("CENTER")

	ClassTrainerCollapseAllButton:Point("LEFT", ClassTrainerExpandTabLeft, "RIGHT", -1, 5)

	ClassTrainerFrameFilterDropDown:Point("TOPRIGHT", -32, -60)

	ClassTrainerSkill1:Point("TOPLEFT", 22, -91)

	ClassTrainerListScrollFrame:Size(304, 164)
	ClassTrainerListScrollFrame.SetHeight = E.noop
	ClassTrainerListScrollFrame:Point("TOPRIGHT", -61, -88)

	ClassTrainerListScrollFrameScrollBar:Point("TOPLEFT", ClassTrainerListScrollFrame, "TOPRIGHT", 3, -19)
	ClassTrainerListScrollFrameScrollBar:Point("BOTTOMLEFT", ClassTrainerListScrollFrame, "BOTTOMRIGHT", 3, 19)

	ClassTrainerDetailScrollFrame:Size(304, 140)
	ClassTrainerDetailScrollFrame.SetHeight = E.noop
	ClassTrainerDetailScrollFrame:Point("TOPLEFT", ClassTrainerListScrollFrame, "BOTTOMLEFT", 0, -7)

	ClassTrainerDetailScrollChildFrame:Width(304)
	ClassTrainerSkillName:Width(300)

	ClassTrainerDetailScrollFrameScrollBar:Point("TOPLEFT", ClassTrainerDetailScrollFrame, "TOPRIGHT", 3, -19)
	ClassTrainerDetailScrollFrameScrollBar:Point("BOTTOMLEFT", ClassTrainerDetailScrollFrame, "BOTTOMRIGHT", 3, 19)

	ClassTrainerMoneyFrame:Point("BOTTOMRIGHT", ClassTrainerFrame, "BOTTOMLEFT", 180, 88)

	ClassTrainerCancelButton:Point("CENTER", ClassTrainerFrame, "TOPLEFT", 304, -417)
	ClassTrainerTrainButton:Point("CENTER", ClassTrainerFrame, "TOPLEFT", 221, -417)

	hooksecurefunc("ClassTrainer_SetToClassTrainer", function()
		CLASS_TRAINER_SKILLS_DISPLAYED = 10
	end)

	hooksecurefunc("ClassTrainer_SetSelection", function()
		local skillIcon = ClassTrainerSkillIcon:GetNormalTexture()
		if skillIcon then
			skillIcon:SetInside()
			skillIcon:SetTexCoord(unpack(E.TexCoords))

			ClassTrainerSkillIcon:SetTemplate("Default")
		end
	end)
end)