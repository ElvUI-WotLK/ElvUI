local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
--WoW API / Variables

S:AddCallback("Skin_GuildRegistrar", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.guildregistrar then return end

	GuildRegistrarFrame:StripTextures(true)
	GuildRegistrarFrame:CreateBackdrop("Transparent")
	GuildRegistrarFrame.backdrop:Point("TOPLEFT", 11, -12)
	GuildRegistrarFrame.backdrop:Point("BOTTOMRIGHT", -32, 76)

	S:SetUIPanelWindowInfo(GuildRegistrarFrame, "width")
	S:SetBackdropHitRect(GuildRegistrarFrame)

	S:HandleCloseButton(GuildRegistrarFrameCloseButton, GuildRegistrarFrame.backdrop)

	GuildRegistrarGreetingFrame:StripTextures()

	for i = 1, 2 do
		S:HandleButtonHighlight(_G["GuildRegistrarButton"..i])
	end

	S:HandleButton(GuildRegistrarFrameGoodbyeButton)
	S:HandleButton(GuildRegistrarFrameCancelButton)
	S:HandleButton(GuildRegistrarFramePurchaseButton)

	S:HandleEditBox(GuildRegistrarFrameEditBox)

	local leftBG, rightBG = select(6, GuildRegistrarFrameEditBox:GetRegions())
	leftBG:Kill()
	rightBG:Kill()

	AvailableServicesText:SetTextColor(1, 1, 0)
	GuildRegistrarPurchaseText:SetTextColor(1, 1, 1)
	GuildRegistrarButton1:GetFontString():SetTextColor(1, 1, 1)
	GuildRegistrarButton2:GetFontString():SetTextColor(1, 1, 1)

	GuildRegistrarFrameEditBox:Height(20)

	GuildRegistrarFrameGoodbyeButton:Point("BOTTOMRIGHT", -40, 84)
	GuildRegistrarFrameCancelButton:Point("BOTTOMRIGHT", -40, 84)
	GuildRegistrarFramePurchaseButton:Point("BOTTOMLEFT", 19, 84)
end)