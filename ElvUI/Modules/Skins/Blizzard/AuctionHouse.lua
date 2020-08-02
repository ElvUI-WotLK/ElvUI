local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local ipairs, unpack = ipairs, unpack
--WoW API / Variables
local GetAuctionSellItemInfo = GetAuctionSellItemInfo
local GetItemQualityColor = GetItemQualityColor
local PlaySound = PlaySound
local hooksecurefunc = hooksecurefunc

S:AddCallbackForAddon("Blizzard_AuctionUI", "Skin_Blizzard_AuctionUI", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.auctionhouse then return end

	AuctionFrame:StripTextures(true)
	AuctionFrame:CreateBackdrop("Transparent")
	AuctionFrame.backdrop:Point("TOPLEFT", 12, 0)
	AuctionFrame.backdrop:Point("BOTTOMRIGHT", 0, 0)

	S:HookScript(AuctionFrame, "OnShow", function(self)
		S:SetUIPanelWindowInfo(self, "xoffset", -1, nil, true)
		S:SetUIPanelWindowInfo(self, "yoffset", -12, nil, true)
		S:SetUIPanelWindowInfo(self, "width", nil, 1)
		S:SetBackdropHitRect(self)
		S:Unhook(self, "OnShow")
	end)

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
			tab:Point("BOTTOMLEFT", AuctionFrame, "BOTTOMLEFT", 12, -30)
			tab.SetPoint = E.noop
		end
	end

	AuctionFrameTab2:Point("TOPLEFT", AuctionFrameTab1, "TOPRIGHT", -15, 0)
	AuctionFrameTab3:Point("TOPLEFT", AuctionFrameTab2, "TOPRIGHT", -15, 0)

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
	BrowseFilterScrollFrameScrollBar:Point("TOPLEFT", BrowseFilterScrollFrame, "TOPRIGHT", 5, -19)
	BrowseFilterScrollFrameScrollBar:Point("BOTTOMLEFT", BrowseFilterScrollFrame, "BOTTOMRIGHT", 5, 18)

	S:HandleScrollBar(BrowseScrollFrameScrollBar)
	BrowseScrollFrameScrollBar:ClearAllPoints()
	BrowseScrollFrameScrollBar:Point("TOPRIGHT", BrowseScrollFrame, "TOPRIGHT", 25, -19)
	BrowseScrollFrameScrollBar:Point("BOTTOMRIGHT", BrowseScrollFrame, "BOTTOMRIGHT", 0, 19)

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

	BrowseBidText:Point("RIGHT", BrowseBidPrice, "LEFT", -11, 0)
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
	BidScrollFrameScrollBar:Point("TOPRIGHT", BidScrollFrame, "TOPRIGHT", 24, -19)
	BidScrollFrameScrollBar:Point("BOTTOMRIGHT", BidScrollFrame, "BOTTOMRIGHT", 0, 17)

	-- Auctions Frame
	AuctionsTitle:ClearAllPoints()
	AuctionsTitle:Point("TOP", AuctionFrame, "TOP", 0, -5)

	AuctionsScrollFrame:StripTextures()

	S:HandleScrollBar(AuctionsScrollFrameScrollBar)
	AuctionsScrollFrameScrollBar:ClearAllPoints()
	AuctionsScrollFrameScrollBar:Point("TOPRIGHT", AuctionsScrollFrame, "TOPRIGHT", 24, -21)
	AuctionsScrollFrameScrollBar:Point("BOTTOMRIGHT", AuctionsScrollFrame, "BOTTOMRIGHT", 0, 19)

	AuctionsCloseButton:Point("BOTTOMRIGHT", 66, 6)
	AuctionsCancelAuctionButton:Point("RIGHT", AuctionsCloseButton, "LEFT", -4, 0)

	AuctionsCreateAuctionButton:Width(181)
	AuctionsCreateAuctionButton:Point("BOTTOMLEFT", AuctionFrameAuctions, "BOTTOMLEFT", 26, 39)

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
		["Browse"] = 8,		-- NUM_BROWSE_TO_DISPLAY
		["Auctions"] = 9,	-- NUM_AUCTIONS_TO_DISPLAY
		["Bid"] = 9			-- NUM_BIDS_TO_DISPLAY
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

	AuctionFrameAuctions.LeftBackground:Point("TOPLEFT", 20, -72)
	AuctionFrameAuctions.LeftBackground:Point("BOTTOMRIGHT", -545, 34)

	AuctionFrameAuctions.RightBackground:Point("TOPLEFT", AuctionFrameAuctions.LeftBackground, "TOPRIGHT", 3, 0)
	AuctionFrameAuctions.RightBackground:Point("BOTTOMRIGHT", AuctionFrame, -8, 34)

	AuctionFrameBrowse.LeftBackground:Point("TOPLEFT", 20, -103)
	AuctionFrameBrowse.LeftBackground:Point("BOTTOMRIGHT", -575, 34)

	AuctionFrameBrowse.RightBackground:Point("TOPLEFT", AuctionFrameBrowse.LeftBackground, "TOPRIGHT", 4, 0)
	AuctionFrameBrowse.RightBackground:Point("BOTTOMRIGHT", AuctionFrame, "BOTTOMRIGHT", -8, 34)

	AuctionFrameBid.Background = CreateFrame("Frame", nil, AuctionFrameBid)
	AuctionFrameBid.Background:SetTemplate("Transparent")
	AuctionFrameBid.Background:Point("TOPLEFT", 20, -72)
	AuctionFrameBid.Background:Point("BOTTOMRIGHT", 66, 34)
	AuctionFrameBid.Background:SetFrameLevel(AuctionFrameBid:GetFrameLevel() - 1)

	-- DressUpFrame
	AuctionDressUpFrame:StripTextures()

	S:HandleCloseButton(AuctionDressUpFrameCloseButton, AuctionDressUpFrame)

	AuctionDressUpModel:CreateBackdrop()
	AuctionDressUpModel.backdrop:SetOutside(AuctionDressUpModel)

	SetAuctionDressUpBackground()
	AuctionDressUpBackgroundTop:SetDesaturated(true)
	AuctionDressUpBackgroundBot:SetDesaturated(true)

	S:HandleRotateButton(AuctionDressUpModelRotateLeftButton)
	S:HandleRotateButton(AuctionDressUpModelRotateRightButton)

	S:HandleButton(AuctionDressUpFrameResetButton)

	AuctionDressUpFrame:SetTemplate("Transparent")
	AuctionDressUpFrame:Size(189, 401)
	AuctionDressUpFrame:Point("TOPLEFT", AuctionFrame, "TOPRIGHT", -1, 0)

	AuctionDressUpModel:Size(171, 365)
	AuctionDressUpModel:Point("BOTTOM", AuctionDressUpFrame, "BOTTOM", 0, 9)

	AuctionDressUpBackgroundTop:Point("TOPLEFT", AuctionDressUpFrame, "TOPLEFT", 9, -27)

	AuctionDressUpModelRotateLeftButton:Point("TOPLEFT", AuctionDressUpFrame, "TOPLEFT", 12, -30)
	AuctionDressUpModelRotateRightButton:Point("TOPLEFT", AuctionDressUpModelRotateLeftButton, "TOPRIGHT", 3, 0)

	AuctionDressUpFrameResetButton:Point("BOTTOM", AuctionDressUpModel, "BOTTOM", 0, 7)

	AuctionDressUpFrame:SetScript("OnShow", function()
		S:SetUIPanelWindowInfo(AuctionFrame, "width", nil, 189)
		PlaySound("igCharacterInfoOpen")
	end)

	AuctionDressUpFrame:SetScript("OnHide", function()
		S:SetUIPanelWindowInfo(AuctionFrame, "width", nil, 1)
		PlaySound("igCharacterInfoClose")
	end)
end)