local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local ipairs, unpack = ipairs, unpack
--WoW API / Variables
local CreateFrame = CreateFrame
local GetAuctionSellItemInfo = GetAuctionSellItemInfo
local GetItemQualityColor = GetItemQualityColor
local hooksecurefunc = hooksecurefunc

local NUM_BROWSE_TO_DISPLAY = NUM_BROWSE_TO_DISPLAY

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.auctionhouse then return end

	AuctionFrame:StripTextures(true)
	AuctionFrame:CreateBackdrop("Transparent")
	AuctionFrame.backdrop:Point("TOPLEFT", 10, 0)
	AuctionFrame.backdrop:Point("BOTTOMRIGHT", 0, 0)

	local buttons = {
		BrowseSearchButton,
		BrowseResetButton,
		BrowseBidButton,
		BrowseBuyoutButton,
		BrowseCloseButton,
		BidBidButton,
		BidBuyoutButton,
		BidCloseButton,
		AuctionsCreateAuctionButton,
		AuctionsCancelAuctionButton,
		AuctionsStackSizeMaxButton,
		AuctionsNumStacksMaxButton,
		AuctionsCloseButton
	}
	local checkBoxes = {
		IsUsableCheckButton,
		ShowOnPlayerCheckButton
	}
	local editBoxes = {
		BrowseName,
		BrowseMinLevel,
		BrowseMaxLevel,
		BrowseBidPriceGold,
		BrowseBidPriceSilver,
		BrowseBidPriceCopper,
		BidBidPriceGold,
		BidBidPriceSilver,
		BidBidPriceCopper,
		AuctionsStackSizeEntry,
		AuctionsNumStacksEntry,
		StartPriceGold,
		StartPriceSilver,
		StartPriceCopper,
		BuyoutPriceGold,
		BuyoutPriceSilver,
		BuyoutPriceCopper
	}
	local sortTabs = {
		BrowseQualitySort,
		BrowseLevelSort,
		BrowseDurationSort,
		BrowseHighBidderSort,
		BrowseCurrentBidSort,
		BidQualitySort,
		BidLevelSort,
		BidDurationSort,
		BidBuyoutSort,
		BidStatusSort,
		BidBidSort,
		AuctionsQualitySort,
		AuctionsDurationSort,
		AuctionsHighBidderSort,
		AuctionsBidSort
	}

	for _, button in ipairs(buttons) do
		S:HandleButton(button, true)
	end
	for _, checkBox in ipairs(checkBoxes) do
		S:HandleCheckBox(checkBox)
	end
	for _, editBox in ipairs(editBoxes) do
		S:HandleEditBox(editBox)
		editBox:SetTextInsets(1, 1, -1, 1)
	end
	for _, tab in ipairs(sortTabs) do
		tab:StripTextures()
		tab:SetNormalTexture([[Interface\Buttons\UI-SortArrow]])
		tab:StyleButton()
	end

	for i = 1, AuctionFrame.numTabs do
		local tab = _G["AuctionFrameTab"..i]

		S:HandleTab(tab)

		if i == 1 then
			tab:ClearAllPoints()
			tab:Point("BOTTOMLEFT", AuctionFrame, "BOTTOMLEFT", 20, -30)
			tab.SetPoint = E.noop
		end
	end

	for i = 1, NUM_FILTERS_TO_DISPLAY do
		local tab = _G["AuctionFilterButton"..i]

		tab:StripTextures()

		tab:SetHighlightTexture(E.Media.Textures.Highlight)
		tab:GetHighlightTexture():SetInside()
		tab:GetHighlightTexture():SetAlpha(0.35)
	end

	S:HandleCloseButton(AuctionFrameCloseButton, AuctionFrame.backdrop)

	AuctionFrameMoneyFrame:Point("BOTTOMRIGHT", AuctionFrame, "BOTTOMLEFT", 181, 11)

	-- Browse Frame
	BrowseTitle:ClearAllPoints()
	BrowseTitle:Point("TOP", AuctionFrame, "TOP", 0, -5)

	BrowseScrollFrame:StripTextures()

	BrowseFilterScrollFrame:StripTextures()

	S:HandleScrollBar(BrowseFilterScrollFrameScrollBar)

	S:HandleScrollBar(BrowseScrollFrameScrollBar)
	BrowseScrollFrameScrollBar:ClearAllPoints()
	BrowseScrollFrameScrollBar:Point("TOPRIGHT", BrowseScrollFrame, "TOPRIGHT", 24, -18)
	BrowseScrollFrameScrollBar:Point("BOTTOMRIGHT", BrowseScrollFrame, "BOTTOMRIGHT", 0, 18)

	S:HandleNextPrevButton(BrowsePrevPageButton, nil, nil, true)
	BrowsePrevPageButton:Point("TOPLEFT", 640, -50)
	BrowsePrevPageButton:Size(32)
	BrowsePrevPageButton:SetHitRectInsets(6, 6, 6, 6)

	S:HandleNextPrevButton(BrowseNextPageButton, nil, nil, true)
	BrowseNextPageButton:Point("TOPRIGHT", 60, -50)
	BrowseNextPageButton:Size(32)
	BrowseNextPageButton:SetHitRectInsets(6, 6, 6, 6)

	BrowseCloseButton:Point("BOTTOMRIGHT", 66, 6)
	BrowseBuyoutButton:Point("RIGHT", BrowseCloseButton, "LEFT", -4, 0)
	BrowseBidButton:Point("RIGHT", BrowseBuyoutButton, "LEFT", -4, 0)
	BrowseResetButton:Point("TOPLEFT", 20, -74)
	BrowseSearchButton:Point("TOPRIGHT", 10, -30)

	BrowseNameText:Point("TOPLEFT", 18, -30)
	BrowseName:Point("TOPLEFT", BrowseNameText, "BOTTOMLEFT", 3, -3)
	BrowseName:Size(140, 18)

	BrowseLevelText:Point("BOTTOMLEFT", AuctionFrameBrowse, "TOPLEFT", 200, -40)
	BrowseMaxLevel:Point("LEFT", BrowseMinLevel, "RIGHT", 8, 0)

	BrowseBidPrice:Point("BOTTOM", 25, 10)

	-- Bid Frame
	BidTitle:ClearAllPoints()
	BidTitle:Point("TOP", AuctionFrame, "TOP", 0, -5)

	BidScrollFrame:StripTextures()

	BidBidText:ClearAllPoints()
	BidBidText:Point("RIGHT", BidBidButton, "LEFT", -270, 2)

	BidCloseButton:Point("BOTTOMRIGHT", 66, 6)
	BidBuyoutButton:Point("RIGHT", BidCloseButton, "LEFT", -4, 0)
	BidBidButton:Point("RIGHT", BidBuyoutButton, "LEFT", -4, 0)

	BidBidPrice:Point("BOTTOM", 25, 10)

	S:HandleScrollBar(BidScrollFrameScrollBar)
	BidScrollFrameScrollBar:ClearAllPoints()
	BidScrollFrameScrollBar:Point("TOPRIGHT", BidScrollFrame, "TOPRIGHT", 23, -18)
	BidScrollFrameScrollBar:Point("BOTTOMRIGHT", BidScrollFrame, "BOTTOMRIGHT", 0, 16)

	-- Auctions Frame
	AuctionsTitle:ClearAllPoints()
	AuctionsTitle:Point("TOP", AuctionFrame, "TOP", 0, -5)

	AuctionsScrollFrame:StripTextures()

	S:HandleScrollBar(AuctionsScrollFrameScrollBar)
	AuctionsScrollFrameScrollBar:ClearAllPoints()
	AuctionsScrollFrameScrollBar:Point("TOPRIGHT", AuctionsScrollFrame, "TOPRIGHT", 23, -20)
	AuctionsScrollFrameScrollBar:Point("BOTTOMRIGHT", AuctionsScrollFrame, "BOTTOMRIGHT", 0, 18)

	AuctionsCloseButton:Point("BOTTOMRIGHT", 66, 6)
	AuctionsCancelAuctionButton:Point("RIGHT", AuctionsCloseButton, "LEFT", -4, 0)

	AuctionsStackSizeEntry.backdrop:SetAllPoints()
	AuctionsNumStacksEntry.backdrop:SetAllPoints()

	AuctionsItemButton:StripTextures()
	AuctionsItemButton:SetTemplate("Default", true)
	AuctionsItemButton:StyleButton()

	AuctionsItemButton:HookScript("OnEvent", function(self, event)
		local normalTexture = self:GetNormalTexture()

		if event == "NEW_AUCTION_UPDATE" and normalTexture then
			normalTexture:SetTexCoord(unpack(E.TexCoords))
			normalTexture:SetInside()

			local _, _, _, quality = GetAuctionSellItemInfo()

			if quality then
				self:SetBackdropBorderColor(GetItemQualityColor(quality))
			else
				self:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		else
			self:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	end)

	S:HandleDropDownBox(BrowseDropDown, 155)
	BrowseDropDown:Point("TOPLEFT", BrowseLevelText, "BOTTOMRIGHT", -5, 0)
	S:HandleDropDownBox(PriceDropDown)
	S:HandleDropDownBox(DurationDropDown)

	-- Progress Frame
	AuctionProgressFrame:StripTextures()
	AuctionProgressFrame:SetTemplate("Transparent")

	S:HandleButton(AuctionProgressFrameCancelButton)
	AuctionProgressFrameCancelButton:SetHitRectInsets(0, 0, 0, 0)
	AuctionProgressFrameCancelButton:GetNormalTexture():SetTexture(E.Media.Textures.Close)
	AuctionProgressFrameCancelButton:GetNormalTexture():SetInside()
	AuctionProgressFrameCancelButton:Size(28)
	AuctionProgressFrameCancelButton:Point("LEFT", AuctionProgressBar, "RIGHT", 8, 0)

	AuctionProgressBarIcon.backdrop = CreateFrame("Frame", nil, AuctionProgressBarIcon:GetParent())
	AuctionProgressBarIcon.backdrop:SetTemplate("Default")
	AuctionProgressBarIcon.backdrop:SetOutside(AuctionProgressBarIcon)

	AuctionProgressBarIcon:SetTexCoord(unpack(E.TexCoords))
	AuctionProgressBarIcon:SetParent(AuctionProgressBarIcon.backdrop)

	AuctionProgressBarText:ClearAllPoints()
	AuctionProgressBarText:SetPoint("CENTER")

	AuctionProgressBar:StripTextures()
	AuctionProgressBar:CreateBackdrop("Default")
	AuctionProgressBar:SetStatusBarTexture(E.media.normTex)
	AuctionProgressBar:SetStatusBarColor(1, 1, 0)

	local frames = {
		["Browse"] = NUM_BROWSE_TO_DISPLAY,
		["Auctions"] = NUM_AUCTIONS_TO_DISPLAY,
		["Bid"] = NUM_BIDS_TO_DISPLAY
	}

	for frameName, numButtons in pairs(frames) do
		for i = 1, numButtons do
			local button = _G[frameName.."Button"..i]
			local itemButton = _G[frameName.."Button"..i.."Item"]
			local name = _G[frameName.."Button"..i.."Name"]

			if button then
				button:StripTextures()

				local highlight = _G[frameName.."Button"..i.."Highlight"]
				highlight:SetTexture(E.Media.Textures.Highlight)
				highlight:SetInside()

				hooksecurefunc(name, "SetVertexColor", function(_, r, g, b)
					highlight:SetVertexColor(r, g, b, 0.35)
				end)
			end

			if itemButton then
				itemButton:SetTemplate()
				itemButton:StyleButton()
				itemButton:GetNormalTexture():SetTexture("")
				itemButton:Point("TOPLEFT", 0, -1)
				itemButton:Size(34)

				local texture = _G[frameName.."Button"..i.."ItemIconTexture"]
				texture:SetTexCoord(unpack(E.TexCoords))
				texture:SetInside()

				hooksecurefunc(name, "SetVertexColor", function(_, r, g, b)
					itemButton:SetBackdropBorderColor(r, g, b)
				end)
				hooksecurefunc(name, "Hide", function()
					itemButton:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end)
			end
		end
	end

	-- Custom Backdrops
	for _, frame in ipairs({AuctionFrameBrowse, AuctionFrameAuctions}) do
		frame.LeftBackground = CreateFrame("Frame", nil, frame)
		frame.LeftBackground:SetTemplate("Transparent")
		frame.LeftBackground:SetFrameLevel(frame:GetFrameLevel() - 1)

		frame.RightBackground = CreateFrame("Frame", nil, frame)
		frame.RightBackground:SetTemplate("Transparent")
		frame.RightBackground:SetFrameLevel(frame:GetFrameLevel() - 1)
	end

	AuctionFrameAuctions.LeftBackground:Point("TOPLEFT", 15, -72)
	AuctionFrameAuctions.LeftBackground:Point("BOTTOMRIGHT", -545, 34)

	AuctionFrameAuctions.RightBackground:Point("TOPLEFT", AuctionFrameAuctions.LeftBackground, "TOPRIGHT", 3, 0)
	AuctionFrameAuctions.RightBackground:Point("BOTTOMRIGHT", AuctionFrame, -8, 34)

	AuctionFrameBrowse.LeftBackground:Point("TOPLEFT", 20, -103)
	AuctionFrameBrowse.LeftBackground:Point("BOTTOMRIGHT", -575, 34)

	AuctionFrameBrowse.RightBackground:Point("TOPLEFT", AuctionFrameBrowse.LeftBackground, "TOPRIGHT", 4, 0)
	AuctionFrameBrowse.RightBackground:Point("BOTTOMRIGHT", AuctionFrame, "BOTTOMRIGHT", -8, 34)

	AuctionFrameBid.Background = CreateFrame("Frame", nil, AuctionFrameBid)
	AuctionFrameBid.Background:SetTemplate("Transparent")
	AuctionFrameBid.Background:Point("TOPLEFT", 22, -72)
	AuctionFrameBid.Background:Point("BOTTOMRIGHT", 66, 34)
	AuctionFrameBid.Background:SetFrameLevel(AuctionFrameBid:GetFrameLevel() - 1)

	-- DressUpFrame
	AuctionDressUpFrame:StripTextures()
	AuctionDressUpFrame:CreateBackdrop("Transparent")
	AuctionDressUpFrame.backdrop:Point("TOPLEFT", 0, 10)
	AuctionDressUpFrame.backdrop:Point("BOTTOMRIGHT", -5, 3)
	AuctionDressUpFrame:Point("TOPLEFT", AuctionFrame, "TOPRIGHT", 1, -28)

	AuctionDressUpModel:CreateBackdrop()
	AuctionDressUpModel.backdrop:SetOutside(AuctionDressUpBackgroundTop, nil, nil, AuctionDressUpBackgroundBot)

	SetAuctionDressUpBackground()
	AuctionDressUpBackgroundTop:SetDesaturated(true)
	AuctionDressUpBackgroundBot:SetDesaturated(true)

	S:HandleRotateButton(AuctionDressUpModelRotateLeftButton)
	AuctionDressUpModelRotateLeftButton:Point("TOPLEFT", AuctionDressUpFrame, 8, -17)

	S:HandleRotateButton(AuctionDressUpModelRotateRightButton)
	AuctionDressUpModelRotateRightButton:Point("TOPLEFT", AuctionDressUpModelRotateLeftButton, "TOPRIGHT", 3, 0)

	S:HandleButton(AuctionDressUpFrameResetButton)

	S:HandleCloseButton(AuctionDressUpFrameCloseButton, AuctionDressUpFrame.backdrop)
end

S:AddCallbackForAddon("Blizzard_AuctionUI", "Skin_Blizzard_AuctionUI", LoadSkin)