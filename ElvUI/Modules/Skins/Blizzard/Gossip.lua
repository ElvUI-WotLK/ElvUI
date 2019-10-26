local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local select = select
local find, gsub = string.find, string.gsub
--WoW API / Variables

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.gossip then return end

	ItemTextScrollFrame:StripTextures()
	GossipFrameGreetingPanel:StripTextures()

	ItemTextFrame:StripTextures(true)
	ItemTextFrame:CreateBackdrop("Transparent")
	ItemTextFrame.backdrop:Point("TOPLEFT", 11, -12)
	ItemTextFrame.backdrop:Point("BOTTOMRIGHT", -32, 76)

	S:SetUIPanelWindowInfo(ItemTextFrame, "width")

	ItemTextPageText:SetTextColor(1, 1, 1)
	ItemTextPageText.SetTextColor = E.noop

	S:HandleCloseButton(ItemTextCloseButton, ItemTextFrame.backdrop)

	GossipFramePortrait:Kill()

	GossipGreetingText:SetTextColor(1, 1, 1)

	GossipFrame:CreateBackdrop("Transparent")
	GossipFrame.backdrop:Point("TOPLEFT", 11, -12)
	GossipFrame.backdrop:Point("BOTTOMRIGHT", -32, 0)

	S:SetUIPanelWindowInfo(GossipFrame, "width")

	GossipFrameNpcNameText:ClearAllPoints()
	GossipFrameNpcNameText:Point("TOP", GossipFrame, "TOP", -6, -17)

	GossipGreetingScrollFrame:Height(402)

	S:HandleButton(GossipFrameGreetingGoodbyeButton)
	GossipFrameGreetingGoodbyeButton:Point("BOTTOMRIGHT", -37, 4)

	S:HandleNextPrevButton(ItemTextPrevPageButton)
	ItemTextPrevPageButton:Point("CENTER", ItemTextFrame, "TOPLEFT", 45, -60)

	S:HandleNextPrevButton(ItemTextNextPageButton)
	ItemTextNextPageButton:Point("CENTER", ItemTextFrame, "TOPRIGHT", -80, -60)

	ItemTextCurrentPage:Point("TOP", -15, -52)

	S:HandleScrollBar(ItemTextScrollFrameScrollBar)
	S:HandleScrollBar(GossipGreetingScrollFrameScrollBar, 5)

	S:HandleCloseButton(GossipFrameCloseButton, GossipFrame.backdrop)
	GossipFrameCloseButton:Point("CENTER", GossipFrame, "TOPRIGHT", -44, -25)

	for i = 1, NUMGOSSIPBUTTONS do
		local button = _G["GossipTitleButton"..i]
		local obj = select(3, button:GetRegions())

		S:HandleButtonHighlight(button)

		obj:SetTextColor(1, 1, 1)
	end

	hooksecurefunc("GossipFrameUpdate", function()
		for i = 1, NUMGOSSIPBUTTONS do
			local button = _G["GossipTitleButton"..i]

			if button:GetFontString() then
				if button:GetFontString():GetText() and find(button:GetFontString():GetText(), "|cff000000") then
					button:GetFontString():SetText(gsub(button:GetFontString():GetText(), "|cff000000", "|cffFFFF00"))
				end
			end
		end
	end)
end

S:AddCallback("Skin_Gossip", LoadSkin)