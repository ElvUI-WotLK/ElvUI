local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local select = select
local find, gsub = string.find, string.gsub
--WoW API / Variables

S:AddCallback("Skin_Gossip", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.gossip then return end

	-- Gossip
	GossipFramePortrait:Kill()
	GossipFrameGreetingPanel:StripTextures()

	GossipFrame:CreateBackdrop("Transparent")
	GossipFrame.backdrop:Point("TOPLEFT", 11, -12)
	GossipFrame.backdrop:Point("BOTTOMRIGHT", -32, 0)

	S:SetUIPanelWindowInfo(GossipFrame, "width")
	S:SetBackdropHitRect(GossipFrame)

	GossipGreetingText:SetTextColor(1, 1, 1)

	S:HandleCloseButton(GossipFrameCloseButton, GossipFrame.backdrop)

	S:HandleScrollBar(GossipGreetingScrollFrameScrollBar)
	S:HandleButton(GossipFrameGreetingGoodbyeButton)

	for i = 1, NUMGOSSIPBUTTONS do
		local button = _G["GossipTitleButton"..i]
		S:HandleButtonHighlight(button)
		select(3, button:GetRegions()):SetTextColor(1, 1, 1)
	end

	GossipFrameNpcNameText:ClearAllPoints()
	GossipFrameNpcNameText:Point("TOP", GossipFrame, "TOP", -6, -15)

	GossipGreetingScrollFrame:Size(304, 402)
	GossipGreetingScrollFrame:Point("TOPLEFT", GossipFrame, "TOPLEFT", 19, -73)

	GossipGreetingScrollFrameScrollBar:Point("TOPLEFT", GossipGreetingScrollFrame, "TOPRIGHT", 3, -19)
	GossipGreetingScrollFrameScrollBar:Point("BOTTOMLEFT", GossipGreetingScrollFrame, "BOTTOMRIGHT", 3, 19)

	GossipFrameGreetingGoodbyeButton:Point("BOTTOMRIGHT", -40, 8)

	hooksecurefunc("GossipFrameUpdate", function()
		for i = 1, GossipFrame.buttonIndex do
			local button = _G["GossipTitleButton"..i]

			if button:GetText() and find(button:GetText(), "|cff000000") then
				button:SetText(gsub(button:GetText(), "|cff000000", "|cffFFFF00"))
			end
		end
	end)

	-- ItemText
	ItemTextScrollFrame:StripTextures()
	ItemTextFrame:StripTextures(true)
	ItemTextFrame:CreateBackdrop("Transparent")
	ItemTextFrame.backdrop:Point("TOPLEFT", 11, -12)
	ItemTextFrame.backdrop:Point("BOTTOMRIGHT", -32, 76)

	S:SetUIPanelWindowInfo(ItemTextFrame, "width")
	S:SetBackdropHitRect(ItemTextFrame)

	ItemTextPageText:SetTextColor(1, 1, 1)
	ItemTextPageText.SetTextColor = E.noop

	S:HandleCloseButton(ItemTextCloseButton, ItemTextFrame.backdrop)

	S:HandleNextPrevButton(ItemTextPrevPageButton)
	S:HandleNextPrevButton(ItemTextNextPageButton)

	S:HandleScrollBar(ItemTextScrollFrameScrollBar)

	ItemTextTitleText:Point("CENTER", -15, 230)

	ItemTextCurrentPage:Point("TOP", -15, -52)

	ItemTextPrevPageButton:Point("CENTER", ItemTextFrame, "TOPLEFT", 100, -58)
	ItemTextNextPageButton:Point("CENTER", ItemTextFrame, "TOPRIGHT", -130, -58)

	ItemTextPrevPageButton:GetRegions():Point("LEFT", ItemTextPrevPageButton, "RIGHT", 3, 0)
	ItemTextNextPageButton:GetRegions():Point("RIGHT", ItemTextNextPageButton, "LEFT", -3, 0)

	ItemTextScrollFrame:Width(283)
	ItemTextScrollFrame:Point("TOPRIGHT", -61, -73)

	ItemTextScrollFrameScrollBar:Point("TOPLEFT", ItemTextScrollFrame, "TOPRIGHT", 3, -19)
	ItemTextScrollFrameScrollBar:Point("BOTTOMLEFT", ItemTextScrollFrame, "BOTTOMRIGHT", 3, 19)
end)