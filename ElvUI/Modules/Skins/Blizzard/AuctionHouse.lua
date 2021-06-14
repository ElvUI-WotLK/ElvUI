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
	AuctionFrame.backdrop:Point("TOPLEFT", 11, 0)
	AuctionFrame.backdrop:Point("BOTTOMRIGHT", 0, 23)

	S:HookScript(AuctionFrame, "OnShow", function(self)
		S:SetUIPanelWindowInfo(self, "xoffset", 0, nil, true)
		S:SetUIPanelWindowInfo(self, "yoffset", -12, nil, true)
		S:SetUIPanelWindowInfo(self, "width")
		S:SetBackdropHitRect(self)
		S:Unhook(self, "OnShow")
	end)

	S:HandleCloseButton(AuctionFrameCloseButton, AuctionFrame.backdrop)

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
			tab:Point("TOPLEFT", AuctionFrame, "BOTTOMLEFT", 12, 25)
			tab.SetPoint = E.noop
		else
			tab:Point("TOPLEFT", _G["AuctionFrameTab"..(i - 1)], "TOPRIGHT", -15, 0)
		end
	end

	for i = 1, NUM_FILTERS_TO_DISPLAY do
		local tab = _G["AuctionFilterButton"..i]
		tab:StripTextures()

		local highlight = tab:GetHighlightTexture()
		highlight:SetTexture(E.Media.Textures.Highlight)
		highlight:SetInside()
		highlight:SetVertexColor(0.9, 0.9, 0.9, 0.35)
	end

	local frames = {
		["Browse"] = 8,		-- NUM_BROWSE_TO_DISPLAY
		["Auctions"] = 9,	-- NUM_AUCTIONS_TO_DISPLAY
		["Bid"] = 9			-- NUM_BIDS_TO_DISPLAY
	}
	local function itemNameSetVertexColor(self, r, g, b)
		self.parent.highlight:SetVertexColor(r, g, b, 0.35)
		self.parent.itemButton:SetBackdropBorderColor(r, g, b)
	end
	local function itemNameHide(self)
		self.parent.itemButton:SetBackdropBorderColor(unpack(E.media.bordercolor))
	end
	for frameName, numButtons in pairs(frames) do
		for i = 1, numButtons do
			local button = _G[frameName.."Button"..i]
			local name = _G[frameName.."Button"..i.."Name"]
			local itemButton = _G[frameName.."Button"..i.."Item"]
			local itemTexture = _G[frameName.."Button"..i.."ItemIconTexture"]
			local highlight = _G[frameName.."Button"..i.."Highlight"]

			button:StripTextures()

			highlight:SetTexture(E.Media.Textures.Highlight)
			highlight:SetInside()

			itemButton:SetTemplate()
			itemButton:StyleButton()
			itemButton:GetNormalTexture():SetTexture("")
			itemButton:Point("TOPLEFT", 0, -1)
			itemButton:Size(34)

			itemTexture:SetTexCoord(unpack(E.TexCoords))
			itemTexture:SetInside()

			button.highlight = highlight
			button.itemButton = itemButton
			name.parent = button

			hooksecurefunc(name, "SetVertexColor", itemNameSetVertexColor)
			hooksecurefunc(name, "Hide", itemNameHide)
		end
	end

	-- Custom Backdrops
	local function createBackdrop(parent)
		local background = CreateFrame("Frame", nil, parent)
		background:SetTemplate("Transparent")
		background:SetFrameLevel(parent:GetFrameLevel() - 1)
		return background
	end

	AuctionFrameBrowse.LeftBackground = createBackdrop(AuctionFrameBrowse)
	AuctionFrameBrowse.LeftBackground:Point("TOPLEFT", 19, -86)
	AuctionFrameBrowse.LeftBackground:Point("BOTTOMRIGHT", -574, 60)

	AuctionFrameBrowse.RightBackground = createBackdrop(AuctionFrameBrowse)
	AuctionFrameBrowse.RightBackground:Point("TOPLEFT", 187, -86)
	AuctionFrameBrowse.RightBackground:Point("BOTTOMRIGHT", 66, 60)

	AuctionFrameBid.Background = createBackdrop(AuctionFrameBid)
	AuctionFrameBid.Background:Point("TOPLEFT", 19, -49)
	AuctionFrameBid.Background:Point("BOTTOMRIGHT", 66, 60)

	AuctionFrameAuctions.LeftBackground = createBackdrop(AuctionFrameAuctions)
	AuctionFrameAuctions.LeftBackground:Point("TOPLEFT", 19, -49)
	AuctionFrameAuctions.LeftBackground:Point("BOTTOMRIGHT", -546, 60)

	AuctionFrameAuctions.RightBackground = createBackdrop(AuctionFrameAuctions)
	AuctionFrameAuctions.RightBackground:Point("TOPLEFT", 215, -49)
	AuctionFrameAuctions.RightBackground:Point("BOTTOMRIGHT", 66, 60)

	AuctionFrameMoneyFrame:Point("BOTTOMRIGHT", AuctionFrame, "BOTTOMLEFT", 181, 37)

	-- Browse Frame
	BrowseTitle:ClearAllPoints()
	BrowseTitle:Point("TOP", AuctionFrame, "TOP", 0, -5)

	BrowseNameText:Point("TOPLEFT", 25, -19)
	BrowseName:Size(163, 18)
	BrowseName:Point("TOPLEFT", BrowseNameText, "BOTTOMLEFT", -5, -4)

	BrowseResetButton:Point("TOPLEFT", 104, -59)

	BrowseLevelText:Point("BOTTOMLEFT", AuctionFrameBrowse, "TOPLEFT", 233, -31)
	BrowseMinLevel:Point("TOPLEFT", BrowseLevelText, "BOTTOMLEFT", 0, -6)
	BrowseLevelHyphen:Point("LEFT", BrowseMinLevel, "RIGHT", 2, 1)
	BrowseMaxLevel:Point("LEFT", BrowseMinLevel, "RIGHT", 12, 0)

	S:HandleDropDownBox(BrowseDropDown, 155)

	BrowseSearchButton:Point("TOPRIGHT", 15, -34)

	S:HandleNextPrevButton(BrowsePrevPageButton, "left", nil, true)
	BrowsePrevPageButton:Size(32)
	BrowsePrevPageButton:Point("TOPLEFT", 636, -28)
	BrowsePrevPageButton:SetHitRectInsets(6, 6, 6, 6)
	BrowsePrevPageButton:GetRegions():Point("LEFT", BrowsePrevPageButton, "RIGHT", -5, 0)

	S:HandleNextPrevButton(BrowseNextPageButton, "right", nil, true)
	BrowseNextPageButton:Size(32)
	BrowseNextPageButton:Point("TOPRIGHT", 72, -28)
	BrowseNextPageButton:SetHitRectInsets(6, 6, 6, 6)
	BrowseNextPageButton:GetRegions():Point("RIGHT", BrowseNextPageButton, "LEFT", 5, 0)

	BrowseFilterScrollFrame:StripTextures()
	BrowseFilterScrollFrame:Size(144, 301)
	BrowseFilterScrollFrame:Point("TOPRIGHT", AuctionFrameBrowse, "TOPLEFT", 163, -86)

	AuctionFilterButton1:Point("TOPLEFT", 23, -87)

	S:HandleScrollBar(BrowseFilterScrollFrameScrollBar)
	BrowseFilterScrollFrameScrollBar:Point("TOPLEFT", BrowseFilterScrollFrame, "TOPRIGHT", 3, -19)
	BrowseFilterScrollFrameScrollBar:Point("BOTTOMLEFT", BrowseFilterScrollFrame, "BOTTOMRIGHT", 3, 19)

	BrowseQualitySort:Point("TOPLEFT", 186, -67)
	BrowseCurrentBidSort:Width(209)

	BrowseScrollFrame:StripTextures()
	BrowseScrollFrame:Size(616, 301)
	BrowseScrollFrame:Point("TOPRIGHT", 45, -86)

	BrowseButton1:Point("TOPLEFT", 191, -89)
	BrowseSearchCountText:Point("BOTTOM", 80, 75)

	S:HandleScrollBar(BrowseScrollFrameScrollBar)
	BrowseScrollFrameScrollBar:Point("TOPLEFT", BrowseScrollFrame, "TOPRIGHT", 3, -19)
	BrowseScrollFrameScrollBar:Point("BOTTOMLEFT", BrowseScrollFrame, "BOTTOMRIGHT", 3, 19)

	BrowseBidPrice:Point("BOTTOM", 50, 34)
	BrowseBidText:Point("RIGHT", BrowseBidPrice, "LEFT", -12, -1)

	BrowseCloseButton:Point("BOTTOMRIGHT", 66, 31)
	BrowseBuyoutButton:Point("RIGHT", BrowseCloseButton, "LEFT", -5, 0)
	BrowseBidButton:Point("RIGHT", BrowseBuyoutButton, "LEFT", -5, 0)

	hooksecurefunc("AuctionFrameFilters_UpdateClasses", function()
		local scrollShown = #OPEN_FILTER_LIST > NUM_FILTERS_TO_DISPLAY

		if scrollShown then
			AuctionFrameBrowse.LeftBackground:Point("BOTTOMRIGHT", -595, 60)
		else
			AuctionFrameBrowse.LeftBackground:Point("BOTTOMRIGHT", -574, 60)

			for i = 1, NUM_FILTERS_TO_DISPLAY do
				_G["AuctionFilterButton"..i]:Width(157)
			end
		end
	end)

	hooksecurefunc("AuctionFrameBrowse_Update", function()
		local scrollShown = BrowseScrollFrame:IsShown()

		for i = 1, NUM_BROWSE_TO_DISPLAY do
			_G["BrowseButton"..i]:Width(scrollShown and 608 or 629)
		end

		BrowseCurrentBidSort:Width(scrollShown and 188 or 209)
		AuctionFrameBrowse.RightBackground:Point("BOTTOMRIGHT", scrollShown and 45 or 66, 60)
	end)

	-- Bid Frame
	BidTitle:ClearAllPoints()
	BidTitle:Point("TOP", AuctionFrame, "TOP", 0, -5)

	BidQualitySort:Width(238)
	BidQualitySort:Point("TOPLEFT", 18, -30)
	BidBidSort:Width(179)

	BidScrollFrame:StripTextures()
	BidScrollFrame:Size(784, 338)
	BidScrollFrame:Point("TOPRIGHT", 45, -49)

	BidButton1:Point("TOPLEFT", 23, -52)

	S:HandleScrollBar(BidScrollFrameScrollBar)
	BidScrollFrameScrollBar:Point("TOPLEFT", BidScrollFrame, "TOPRIGHT", 3, -19)
	BidScrollFrameScrollBar:Point("BOTTOMLEFT", BidScrollFrame, "BOTTOMRIGHT", 3, 19)

	BidBidPrice:Point("BOTTOM", 50, 34)
	BidBidText:Point("BOTTOMRIGHT", AuctionFrameBid, "BOTTOM", -50, 36)

	BidCloseButton:Point("BOTTOMRIGHT", 66, 31)
	BidBuyoutButton:Point("RIGHT", BidCloseButton, "LEFT", -5, 0)
	BidBidButton:Point("RIGHT", BidBuyoutButton, "LEFT", -5, 0)

	hooksecurefunc("AuctionFrameBid_Update", function()
		local scrollShown = BidScrollFrame:IsShown()

		for i = 1, NUM_BIDS_TO_DISPLAY do
			_G["BidButton"..i]:Width(scrollShown and 776 or 797)
		end

		BidBidSort:Width(scrollShown and 158 or 179)
		AuctionFrameBid.Background:Point("BOTTOMRIGHT", scrollShown and 45 or 66, 60)
	end)

	-- Auctions Frame
	AuctionsTitle:ClearAllPoints()
	AuctionsTitle:Point("TOP", AuctionFrame, "TOP", 0, -5)

	AuctionsTabText:Point("TOP", AuctionFrameAuctions, "TOPLEFT", 115, -32)

	AuctionsBlockFrame:Size(191, 336)
	AuctionsBlockFrame:Point("TOPLEFT", 20, -50)

	AuctionsItemText:Point("TOPLEFT", 25, -56)

	AuctionsItemButton:StripTextures()
	AuctionsItemButton:SetTemplate("Default", true)
	AuctionsItemButton:StyleButton(nil, true)
	AuctionsItemButton:Point("TOPLEFT", 30, -71)

	AuctionsStackSizeEntry.backdrop:SetAllPoints()
	AuctionsStackSizeEntry:Point("TOPLEFT", 34, -128)
	select(9, AuctionsStackSizeEntry:GetRegions()):Point("BOTTOMLEFT", AuctionsStackSizeEntry, "TOPLEFT", -8, 2)

	AuctionsNumStacksEntry.backdrop:SetAllPoints()
	AuctionsNumStacksEntry:Point("TOPLEFT", AuctionsStackSizeEntry, "BOTTOMLEFT", 0, -19)
	select(9, AuctionsNumStacksEntry:GetRegions()):Point("BOTTOMLEFT", AuctionsNumStacksEntry, "TOPLEFT", -9, 2)

	S:HandleDropDownBox(PriceDropDown)
	PriceDropDown:Point("TOPRIGHT", AuctionFrameAuctions, "TOPLEFT", 216, -193)
	select(5, PriceDropDown:GetRegions()):Point("LEFT", PriceDropDown, "RIGHT", -190, 3)

	StartPrice:Point("BOTTOMLEFT", 35, 191)
	BuyoutPrice:Point("BOTTOMLEFT", 35, 151)

	S:HandleDropDownBox(DurationDropDown)
	DurationDropDown:Point("BOTTOMRIGHT", AuctionFrameAuctions, "BOTTOMLEFT", 216, 109)
	select(5, DurationDropDown:GetRegions()):Point("LEFT", DurationDropDown, "RIGHT", -190, 3)

	AuctionsDepositText:Point("LEFT", AuctionFrameAuctions, "BOTTOMLEFT", 26, 103)

	AuctionsCreateAuctionButton:Width(185)
	AuctionsCreateAuctionButton:Point("BOTTOMLEFT", 23, 64)

	AuctionsQualitySort:Point("TOPLEFT", 214, -30)
	AuctionsBidSort:Width(224)

	AuctionsScrollFrame:StripTextures()
	AuctionsScrollFrame:Size(588, 338)
	AuctionsScrollFrame:Point("TOPRIGHT", 45, -49)

	AuctionsButton1:Point("TOPLEFT", 219, -52)

	S:HandleScrollBar(AuctionsScrollFrameScrollBar)
	AuctionsScrollFrameScrollBar:Point("TOPLEFT", AuctionsScrollFrame, "TOPRIGHT", 3, -19)
	AuctionsScrollFrameScrollBar:Point("BOTTOMLEFT", AuctionsScrollFrame, "BOTTOMRIGHT", 3, 19)

	AuctionsCloseButton:Point("BOTTOMRIGHT", 66, 31)
	AuctionsCancelAuctionButton:Point("RIGHT", AuctionsCloseButton, "LEFT", -5, 0)

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

	hooksecurefunc("AuctionFrameAuctions_Update", function()
		local scrollShown = AuctionsScrollFrame:IsShown()

		for i = 1, NUM_AUCTIONS_TO_DISPLAY do
			_G["AuctionsButton"..i]:Width(scrollShown and 580 or 601)
		end

		AuctionsBidSort:Width(scrollShown and 203 or 224)
		AuctionFrameAuctions.RightBackground:Point("BOTTOMRIGHT", scrollShown and 45 or 66, 60)
	end)

	-- DressUp Frame
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
		S:SetUIPanelWindowInfo(AuctionFrame, "width", nil, 188)
		PlaySound("igCharacterInfoOpen")
	end)

	AuctionDressUpFrame:SetScript("OnHide", function()
		S:SetUIPanelWindowInfo(AuctionFrame, "width")
		PlaySound("igCharacterInfoClose")
	end)

	-- Progress Frame
	AuctionProgressFrame:StripTextures()
	AuctionProgressFrame:SetTemplate("Transparent")

	S:HandleStatusBar(AuctionProgressBar, {1, 0.7, 0})
	AuctionProgressBar:Size(190, 18)
	AuctionProgressBar:Point("CENTER", 5, 0)

	AuctionProgressBarText:ClearAllPoints()
	AuctionProgressBarText:SetPoint("CENTER")

	S:HandleCloseButton(AuctionProgressFrameCancelButton)
	AuctionProgressFrameCancelButton.Texture:Size(26)
	AuctionProgressFrameCancelButton:Point("LEFT", AuctionProgressBar, "RIGHT", 8, 0)
	AuctionProgressFrameCancelButton:SetHitRectInsets(4, 3, 4, 3)

	AuctionProgressBarIcon:CreateBackdrop("Default")
	AuctionProgressBarIcon:Size(38)
	AuctionProgressBarIcon:Point("RIGHT", AuctionProgressBar, "LEFT", -9, 0)
	AuctionProgressBarIcon:SetTexCoord(unpack(E.TexCoords))

	-- Localization specific adjustments
	local locale = GetLocale()
	if locale == "deDE" then
		BrowseResetButton:Width(80)

		AuctionDressUpFrameResetButton:Width(80)
	elseif locale == "frFR" then
		BrowseMinLevel:Width(25)
		BrowseMaxLevel:Width(25)
		BrowseDropDown:Point("TOPLEFT", BrowseLevelText, "BOTTOMRIGHT", 10, -1)
	elseif locale == "koKR" then
		BrowseDropDown:Point("TOPLEFT", BrowseLevelText, "BOTTOMRIGHT", 10, -1)
	elseif locale == "zhTW" then
		BrowseDropDown:Point("TOPLEFT", BrowseLevelText, "BOTTOMRIGHT", -5, 4)
		BrowseDropDownName:Point("BOTTOMLEFT", BrowseDropDown, "TOPLEFT", 20, -3)

		BidDurationSort:Width(79)
	--	BidBidSort:Width(168)
	end
end)