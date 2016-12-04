local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.gossip ~= true then return end

	ItemTextFrame:StripTextures(true)
	ItemTextScrollFrame:StripTextures()
	S:HandleScrollBar(ItemTextScrollFrameScrollBar)
	ItemTextFrame:CreateBackdrop("Transparent")
	ItemTextFrame.backdrop:Point("TOPLEFT", 13, -13)
	ItemTextFrame.backdrop:Point("BOTTOMRIGHT", -32, 74)
	S:HandleCloseButton(ItemTextCloseButton)
	S:HandleNextPrevButton(ItemTextPrevPageButton)
	S:HandleNextPrevButton(ItemTextNextPageButton)
	ItemTextPageText:SetTextColor(1, 1, 1)
	ItemTextPageText.SetTextColor = E.noop

	S:HandleScrollBar(GossipGreetingScrollFrameScrollBar, 5)

	GossipFrameGreetingPanel:StripTextures();

	GossipFramePortrait:Kill();

	S:HandleButton(GossipFrameGreetingGoodbyeButton);
	GossipFrameGreetingGoodbyeButton:Point("BOTTOMRIGHT", GossipFrame, -34, 71);

	for i = 1, NUMGOSSIPBUTTONS do
		local obj = select(3,_G["GossipTitleButton"..i]:GetRegions())
		obj:SetTextColor(1,1,1)
	end

	GossipGreetingText:SetTextColor(1,1,1)
	GossipFrame:CreateBackdrop("Transparent")
	GossipFrame.backdrop:Point("TOPLEFT", 15, -19);
	GossipFrame.backdrop:Point("BOTTOMRIGHT", -30, 67);
	S:HandleCloseButton(GossipFrameCloseButton);

	hooksecurefunc("GossipFrameUpdate", function()
		for i=1, NUMGOSSIPBUTTONS do
			local button = _G["GossipTitleButton"..i]

			if button:GetFontString() then
				if button:GetFontString():GetText() and button:GetFontString():GetText():find("|cff000000") then
					button:GetFontString():SetText(string.gsub(button:GetFontString():GetText(), "|cff000000", "|cffFFFF00"))
				end
			end
		end
	end)
end

S:AddCallback("Gossip", LoadSkin);