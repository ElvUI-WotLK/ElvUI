local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local select = select
--WoW API / Variables

S:AddCallback("Skin_ArenaRegistrar", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.arenaregistrar then return end

	ArenaRegistrarFrame:StripTextures(true)
	ArenaRegistrarFrame:CreateBackdrop("Transparent")
	ArenaRegistrarFrame.backdrop:Point("TOPLEFT", 11, -12)
	ArenaRegistrarFrame.backdrop:Point("BOTTOMRIGHT", -32, 76)

	S:SetUIPanelWindowInfo(ArenaRegistrarFrame, "width")
	S:SetBackdropHitRect(ArenaRegistrarFrame)

	S:HandleCloseButton(ArenaRegistrarFrameCloseButton, ArenaRegistrarFrame.backdrop)

	ArenaRegistrarGreetingFrame:StripTextures()
	ArenaRegistrarGreetingFrame:GetRegions():SetTextColor(1, 1, 1)

	RegistrationText:SetTextColor(1, 1, 1)
	ArenaRegistrarPurchaseText:SetTextColor(1, 1, 1)

	for i = 1, 6 do
		local button = _G["ArenaRegistrarButton"..i]
		S:HandleButtonHighlight(button)
		select(3, button:GetRegions()):SetTextColor(1, 1, 1)
	end

	S:HandleButton(ArenaRegistrarFrameGoodbyeButton)
	S:HandleButton(ArenaRegistrarFrameCancelButton)
	S:HandleButton(ArenaRegistrarFramePurchaseButton)

	select(6, ArenaRegistrarFrameEditBox:GetRegions()):Kill()
	select(7, ArenaRegistrarFrameEditBox:GetRegions()):Kill()
	S:HandleEditBox(ArenaRegistrarFrameEditBox)

	ArenaRegistrarFrameEditBox:Height(18)

	ArenaRegistrarFrameGoodbyeButton:Width(80)
	ArenaRegistrarFrameGoodbyeButton:Point("BOTTOMRIGHT", -40, 84)
	ArenaRegistrarFrameCancelButton:Point("BOTTOMRIGHT", -40, 84)
	ArenaRegistrarFramePurchaseButton:Point("BOTTOMLEFT", 19, 84)

	-- PVP Banner
	PVPBannerFrame:StripTextures()
	PVPBannerFrame:CreateBackdrop("Transparent")
	PVPBannerFrame.backdrop:Point("TOPLEFT", 11, -12)
	PVPBannerFrame.backdrop:Point("BOTTOMRIGHT", -32, 76)

	S:SetUIPanelWindowInfo(PVPBannerFrame, "width")
	S:SetBackdropHitRect(PVPBannerFrame)

	S:HandleCloseButton(PVPBannerFrameCloseButton, PVPBannerFrame.backdrop)

	PVPBannerFramePortrait:Kill()

	PVPBannerFrameCustomizationFrame:StripTextures()

	for i = 1, 2 do
		_G["PVPBannerFrameCustomization"..i]:StripTextures()
		S:HandleNextPrevButton(_G["PVPBannerFrameCustomization"..i.."LeftButton"])
		S:HandleNextPrevButton(_G["PVPBannerFrameCustomization"..i.."RightButton"])
	end

	S:HandleButton(PVPColorPickerButton1)
	S:HandleButton(PVPColorPickerButton2)
	S:HandleButton(PVPColorPickerButton3)

	S:HandleButton(PVPBannerFrameAcceptButton)
	S:HandleButton(PVPBannerFrameCancelButton)
	local PVPBannerFrameCancelButton2 = select(4, PVPBannerFrame:GetChildren())
	S:HandleButton(PVPBannerFrameCancelButton2)

	PVPBannerFrameCustomization1:Point("TOPLEFT", PVPBannerFrameCustomizationBorder, "TOPLEFT", 48, -50)

	PVPColorPickerButton1:Point("TOP", PVPBannerFrameCustomization2, "BOTTOM", 1, -7)
	PVPColorPickerButton2:Point("TOP", PVPBannerFrameCustomization2, "BOTTOM", 1, -33)
	PVPColorPickerButton3:Point("TOP", PVPBannerFrameCustomization2, "BOTTOM", 1, -59)

	PVPBannerFrameCancelButton2:Point("CENTER", PVPBannerFrame, "TOPLEFT", 304, -417)
	PVPBannerFrameAcceptButton:Point("CENTER", PVPBannerFrame, "TOPLEFT", 221, -417)
end)