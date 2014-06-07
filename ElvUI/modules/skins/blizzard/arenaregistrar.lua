local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.arenaregistrar ~= true then return end
	
	ArenaRegistrarFrame:StripTextures(true)
	ArenaRegistrarFrame:CreateBackdrop("Transparent")
	ArenaRegistrarFrame.backdrop:Point("TOPLEFT", 12, -17)
	ArenaRegistrarFrame.backdrop:Point("BOTTOMRIGHT", -28, 65)
	
	S:HandleCloseButton(ArenaRegistrarFrameCloseButton)
	
	select(1, ArenaRegistrarGreetingFrame:GetRegions()):SetTextColor(1, 1, 0)
	RegistrationText:SetTextColor(1, 1, 0)
	ArenaRegistrarPurchaseText:SetTextColor(1, 1, 1)
	for i = 1, MAX_TEAM_BORDERS do
		local text = select(3, _G['ArenaRegistrarButton'..i]:GetRegions())
		text:SetTextColor(1, 1, 1)
	end
	
	ArenaRegistrarGreetingFrame:StripTextures()
	
	S:HandleButton(ArenaRegistrarFramePurchaseButton)
	S:HandleButton(ArenaRegistrarFrameCancelButton)
	S:HandleButton(ArenaRegistrarFrameGoodbyeButton)
	
	S:HandleEditBox(ArenaRegistrarFrameEditBox)
	ArenaRegistrarFrameEditBox.backdrop:Point("TOPLEFT", 0, -5)
	ArenaRegistrarFrameEditBox.backdrop:Point("BOTTOMRIGHT", -5, 5)
	for i=1, ArenaRegistrarFrameEditBox:GetNumRegions() do
		local region = select(i, ArenaRegistrarFrameEditBox:GetRegions())
		if region and region:GetObjectType() == "Texture" then
			if region:GetTexture() == "Interface\\ChatFrame\\UI-ChatInputBorder-Left" or region:GetTexture() == "Interface\\ChatFrame\\UI-ChatInputBorder-Right" then
				region:Kill()
			end
		end
	end
	
	PVPBannerFrame:StripTextures()
	PVPBannerFrame:CreateBackdrop("Transparent")
	PVPBannerFrame.backdrop:Point("TOPLEFT", 12, -12)
	PVPBannerFrame.backdrop:Point("BOTTOMRIGHT", -32, 74)
	
	PVPBannerFramePortrait:Kill()
	
	S:HandleCloseButton(PVPBannerFrameCloseButton)
	
	PVPBannerFrameCustomizationFrame:StripTextures()
	
	for i=1, 2 do
		_G["PVPBannerFrameCustomization"..i]:StripTextures()
		S:HandleNextPrevButton(_G["PVPBannerFrameCustomization"..i.."LeftButton"])
		S:HandleNextPrevButton(_G["PVPBannerFrameCustomization"..i.."RightButton"])
	end
	
	for i=1, 3 do
		S:HandleButton(_G["PVPColorPickerButton"..i])
	end
	
	S:HandleButton(PVPBannerFrameAcceptButton)
	S:HandleButton(PVPBannerFrameCancelButton)
end

S:RegisterSkin('ElvUI', LoadSkin)