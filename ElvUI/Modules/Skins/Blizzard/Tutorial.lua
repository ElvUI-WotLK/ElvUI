local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
--WoW API / Variables

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.tutorial then return end

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
end

S:AddCallback("Skin_Tutorial", LoadSkin)