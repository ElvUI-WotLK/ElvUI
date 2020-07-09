local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
--WoW API / Variables

S:AddCallback("Skin_DressingRoom", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.dressingroom then return end

	DressUpFrame:StripTextures()
	DressUpFrame:CreateBackdrop("Transparent")
	DressUpFrame.backdrop:Point("TOPLEFT", 11, -12)
	DressUpFrame.backdrop:Point("BOTTOMRIGHT", -32, 76)

	S:SetUIPanelWindowInfo(DressUpFrame, "width")
	S:SetBackdropHitRect(DressUpFrame)

	DressUpFramePortrait:Kill()

	SetDressUpBackground()
	DressUpBackgroundTopLeft:SetDesaturated(true)
	DressUpBackgroundTopRight:SetDesaturated(true)
	DressUpBackgroundBotLeft:SetDesaturated(true)
	DressUpBackgroundBotRight:SetDesaturated(true)

	S:HandleCloseButton(DressUpFrameCloseButton, DressUpFrame.backdrop)

	S:HandleRotateButton(DressUpModelRotateLeftButton)
	S:HandleRotateButton(DressUpModelRotateRightButton)

	S:HandleButton(DressUpFrameCancelButton)
	S:HandleButton(DressUpFrameResetButton)

	DressUpModel:CreateBackdrop("Default")
	DressUpModel.backdrop:SetOutside(DressUpModel)

	DressUpFrameDescriptionText:Point("CENTER", DressUpFrameTitleText, "BOTTOM", 10, -18)

	DressUpModelRotateLeftButton:Point("TOPLEFT", DressUpFrame, 29, -76)
	DressUpModelRotateRightButton:Point("TOPLEFT", DressUpModelRotateLeftButton, "TOPRIGHT", 3, 0)

	DressUpModel:Size(323, 331)
	DressUpModel:ClearAllPoints()
	DressUpModel:Point("TOPLEFT", 20, -67)

	DressUpBackgroundTopLeft:Point("TOPLEFT", 23, -67)

	DressUpFrameCancelButton:Point("CENTER", DressUpFrame, "TOPLEFT", 304, -417)
	DressUpFrameResetButton:Point("RIGHT", DressUpFrameCancelButton, "LEFT", -3, 0)
end)