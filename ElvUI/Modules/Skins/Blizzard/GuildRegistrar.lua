local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
--WoW API / Variables

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.guildregistrar then return end

	GuildRegistrarFrame:StripTextures(true)
	GuildRegistrarFrame:CreateBackdrop("Transparent")
	GuildRegistrarFrame.backdrop:Point("TOPLEFT", 11, -12)
	GuildRegistrarFrame.backdrop:Point("BOTTOMRIGHT", -32, 76)

	S:SetUIPanelWindowInfo(GuildRegistrarFrame, "width")

	GuildRegistrarGreetingFrame:StripTextures()

	GuildRegistrarFrameGoodbyeButton:Point("BOTTOMRIGHT", -39, 81)
	GuildRegistrarFrameCancelButton:Point("BOTTOMRIGHT", -39, 81)
	GuildRegistrarFramePurchaseButton:Point("BOTTOMLEFT", 21, 81)

	S:HandleButton(GuildRegistrarFrameGoodbyeButton)
	S:HandleButton(GuildRegistrarFrameCancelButton)
	S:HandleButton(GuildRegistrarFramePurchaseButton)
	S:HandleCloseButton(GuildRegistrarFrameCloseButton, GuildRegistrarFrame.backdrop)
	S:HandleEditBox(GuildRegistrarFrameEditBox)

	for i = 1, GuildRegistrarFrameEditBox:GetNumRegions() do
		local region = select(i, GuildRegistrarFrameEditBox:GetRegions())
		if region and region:GetObjectType() == "Texture" then
			if region:GetTexture() == "Interface\\ChatFrame\\UI-ChatInputBorder-Left" or region:GetTexture() == "Interface\\ChatFrame\\UI-ChatInputBorder-Right" then
				region:Kill()
			end
		end
	end

	GuildRegistrarFrameEditBox:Height(20)

	for i = 1, 2 do
		_G["GuildRegistrarButton"..i]:GetFontString():SetTextColor(1, 1, 1)
	end

	GuildRegistrarPurchaseText:SetTextColor(1, 1, 1)
	AvailableServicesText:SetTextColor(1, 1, 0)
end

S:AddCallback("Skin_GuildRegistrar", LoadSkin)