local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
--WoW API / Variables

S:AddCallback("Skin_Tutorial", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.tutorial then return end

	TutorialFrameAlertButton:StripTextures()
	TutorialFrameAlertButton:CreateBackdrop("Default", true)
	TutorialFrameAlertButton:Size(50)

	local TutorialFrameAlertButtonIcon = TutorialFrameAlertButton:GetNormalTexture()
	TutorialFrameAlertButtonIcon:SetTexture("INTERFACE\\ICONS\\INV_Letter_18")
	TutorialFrameAlertButtonIcon:Point("TOPLEFT", 5, -5)
	TutorialFrameAlertButtonIcon:Point("BOTTOMRIGHT", -5, 5)
	TutorialFrameAlertButtonIcon:SetTexCoord(unpack(E.TexCoords))

	TutorialFrameBackground:Hide()
--	TutorialFrameTop:Hide()
--	TutorialFrameBottom:Hide()
	TutorialFrame:DisableDrawLayer("BORDER")

	TutorialFrame:CreateBackdrop("Transparent")
	TutorialFrame.backdrop:Point("TOPLEFT", 11, -12)
	TutorialFrame.backdrop:Point("BOTTOMRIGHT", -1, 2)

	TutorialFrameTitle:Point("TOP", 0, -19)

	S:HandleCloseButton((select(4, TutorialFrame:GetChildren())), TutorialFrame.backdrop)

	S:HandleNextPrevButton(TutorialFrameNextButton)
	TutorialFrameNextButton:Point("BOTTOMRIGHT", -132, 7)
	TutorialFrameNextButton:Size(22)

	S:HandleNextPrevButton(TutorialFramePrevButton)
	TutorialFramePrevButton:Point("BOTTOMLEFT", 30, 7)
	TutorialFramePrevButton:Size(22)

	S:HandleButton(TutorialFrameOkayButton)

	TutorialFrameCallOut:Kill()
end)