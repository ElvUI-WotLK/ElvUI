local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
--WoW API / Variables

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.tutorial then return end

	for i = 1, TutorialFrame:GetNumChildren() do
		local child = select(i, TutorialFrame:GetChildren())
		if child.GetPushedTexture and child:GetPushedTexture() and not child:GetName() then
			S:HandleCloseButton(child)
			child:SetPoint("TOPRIGHT", TutorialFrame, "TOPRIGHT", 2, 4)
		end
	end

	local TutorialFrameAlertButton = TutorialFrameAlertButton
	local TutorialFrameAlertButtonIcon = TutorialFrameAlertButton:GetNormalTexture()

	TutorialFrameAlertButton:StripTextures()
	TutorialFrameAlertButton:CreateBackdrop("Default", true)
	TutorialFrameAlertButton:SetWidth(50)
	TutorialFrameAlertButton:SetHeight(50)

	TutorialFrameAlertButtonIcon:SetTexture("INTERFACE\\ICONS\\INV_Letter_18")
	TutorialFrameAlertButtonIcon:ClearAllPoints()
	TutorialFrameAlertButtonIcon:SetPoint("TOPLEFT", TutorialFrameAlertButton, "TOPLEFT", 5, -5)
	TutorialFrameAlertButtonIcon:SetPoint("BOTTOMRIGHT", TutorialFrameAlertButton, "BOTTOMRIGHT", -5, 5)
	TutorialFrameAlertButtonIcon:SetTexCoord(unpack(E.TexCoords))

	TutorialFrame:StripTextures()
	TutorialFrame:SetTemplate("Transparent")

	S:HandleNextPrevButton(TutorialFrameNextButton)
	TutorialFrameNextButton:SetPoint("BOTTOMRIGHT", TutorialFrame, "BOTTOMRIGHT", -132, 7)
	TutorialFrameNextButton:SetWidth(22)
	TutorialFrameNextButton:SetHeight(22)

	S:HandleNextPrevButton(TutorialFramePrevButton)
	TutorialFramePrevButton:SetPoint("BOTTOMLEFT", TutorialFrame, "BOTTOMLEFT", 30, 7)
	TutorialFramePrevButton:SetWidth(22)
	TutorialFramePrevButton:SetHeight(22)

	S:HandleButton(TutorialFrameOkayButton)

	TutorialFrameCallOut:Kill()
end

S:AddCallback("Skin_Tutorial", LoadSkin)