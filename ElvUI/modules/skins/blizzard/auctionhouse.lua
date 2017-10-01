local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.auctionhouse ~= true then return end

	AuctionFrame:StripTextures(true)
	AuctionFrame:CreateBackdrop("Transparent")
	AuctionFrame.backdrop:Point("TOPLEFT", 10, -11)
	AuctionFrame.backdrop:Point("BOTTOMRIGHT", 0, 4)

	BrowseFilterScrollFrame:StripTextures()
	BrowseScrollFrame:StripTextures()
	AuctionsScrollFrame:StripTextures()
	BidScrollFrame:StripTextures()

	S:HandleDropDownBox(BrowseDropDown)
	S:HandleDropDownBox(PriceDropDown)
	S:HandleDropDownBox(DurationDropDown)

	S:HandleScrollBar(BrowseFilterScrollFrameScrollBar)
	S:HandleScrollBar(BrowseScrollFrameScrollBar)
	S:HandleScrollBar(AuctionsScrollFrameScrollBar)

	S:HandleCloseButton(AuctionFrameCloseButton)

	-- DressUpFrame
	AuctionDressUpFrame:StripTextures()
	AuctionDressUpFrame:CreateBackdrop("Default")

	SetAuctionDressUpBackground()
	AuctionDressUpBackgroundTop:SetDesaturated(true)
	AuctionDressUpBackgroundBot:SetDesaturated(true)

	AuctionDressUpFrame.backdrop:SetOutside(AuctionDressUpBackgroundTop, nil, nil, AuctionDressUpBackgroundBot)

	S:HandleRotateButton(AuctionDressUpModelRotateLeftButton)
	AuctionDressUpModelRotateLeftButton:Point("TOPLEFT", AuctionDressUpFrame, 8, -17)
	S:HandleRotateButton(AuctionDressUpModelRotateRightButton)
	AuctionDressUpModelRotateRightButton:Point("TOPLEFT", AuctionDressUpModelRotateLeftButton, "TOPRIGHT", 3, 0)

	S:HandleButton(AuctionDressUpFrameResetButton)
	S:HandleCloseButton(AuctionDressUpFrameCloseButton, AuctionDressUpFrame.backdrop)

	local buttons = {
		"BrowseBidButton",
		"BidBidButton",
		"BrowseBuyoutButton",
		"BidBuyoutButton",
		"BrowseCloseButton",
		"BidCloseButton",
		"BrowseSearchButton",
		"AuctionsCloseButton",
		"AuctionsCancelAuctionButton",
		"AuctionsCreateAuctionButton",
		"AuctionsNumStacksMaxButton",
		"AuctionsStackSizeMaxButton",
		"BrowseResetButton"
	}

	for _, button in pairs(buttons) do
		S:HandleButton(_G[button])
	end

	--Progress Frame
	AuctionProgressFrame:StripTextures()
	AuctionProgressFrame:SetTemplate("Transparent")
	AuctionProgressFrameCancelButton:StyleButton()
	AuctionProgressFrameCancelButton:SetTemplate("Default")
	AuctionProgressFrameCancelButton:SetHitRectInsets(0, 0, 0, 0)
	AuctionProgressFrameCancelButton:GetNormalTexture():SetInside()
	AuctionProgressFrameCancelButton:GetNormalTexture():SetTexCoord(0.67, 0.37, 0.61, 0.26)
	AuctionProgressFrameCancelButton:Size(28, 28)
	AuctionProgressFrameCancelButton:Point("LEFT", AuctionProgressBar, "RIGHT", 8, 0)

	AuctionProgressBarIcon:SetTexCoord(0.67, 0.37, 0.61, 0.26)

	local backdrop = CreateFrame("Frame", nil, AuctionProgressBarIcon:GetParent())
	backdrop:SetOutside(AuctionProgressBarIcon)
	backdrop:SetTemplate("Default")
	AuctionProgressBarIcon:SetParent(backdrop)

	AuctionProgressBarText:ClearAllPoints()
	AuctionProgressBarText:SetPoint("CENTER")

	AuctionProgressBar:StripTextures()
	AuctionProgressBar:CreateBackdrop("Default")
	AuctionProgressBar:SetStatusBarTexture(E["media"].normTex)
	E:RegisterStatusBar(AuctionProgressBar);
	AuctionProgressBar:SetStatusBarColor(1, 1, 0)

	--Fix Button Positions
	AuctionsCloseButton:Point("BOTTOMRIGHT", AuctionFrameAuctions, "BOTTOMRIGHT", 66, 14)
	AuctionsCancelAuctionButton:Point("RIGHT", AuctionsCloseButton, "LEFT", -4, 0)
	BidBuyoutButton:Point("RIGHT", BidCloseButton, "LEFT", -4, 0)
	BidBidButton:Point("RIGHT", BidBuyoutButton, "LEFT", -4, 0)
	BrowseBuyoutButton:Point("RIGHT", BrowseCloseButton, "LEFT", -4, 0)
	BrowseBidButton:Point("RIGHT", BrowseBuyoutButton, "LEFT", -4, 0)
	AuctionsCreateAuctionButton:Point("BOTTOMLEFT", 18, 44)

	BrowseResetButton:Width(82)
	BrowseResetButton:Point("TOPLEFT", AuctionFrameBrowse, "TOPLEFT", 20, -74)

	BrowseSearchButton:ClearAllPoints()
	BrowseSearchButton:Point("TOPRIGHT", AuctionFrameBrowse, "TOPRIGHT", 25, -30)

	S:HandleNextPrevButton(BrowseNextPageButton)
	BrowseNextPageButton:ClearAllPoints()
	BrowseNextPageButton:Point("BOTTOMLEFT", BrowseSearchButton, "BOTTOMRIGHT", 10, -27)

	S:HandleNextPrevButton(BrowsePrevPageButton)
	BrowsePrevPageButton:ClearAllPoints()
	BrowsePrevPageButton:Point("BOTTOMRIGHT", BrowseSearchButton, "BOTTOMLEFT", -10, -27)

	AuctionsItemButton:StripTextures()
	AuctionsItemButton:SetTemplate("Default", true)
	AuctionsItemButton:StyleButton()

	AuctionsItemButton:HookScript("OnEvent", function(self, event)
		self:SetBackdropBorderColor(unpack(E["media"].bordercolor))
		if event == "NEW_AUCTION_UPDATE" and self:GetNormalTexture() then
			self:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
			self:GetNormalTexture():SetInside()
		end
		local _, _, _, quality = GetAuctionSellItemInfo()
		if quality and quality > 1 then
			AuctionsItemButton:SetBackdropBorderColor(GetItemQualityColor(quality))
			AuctionsItemButtonName:SetTextColor(quality)
		else
			AuctionsItemButton:SetTemplate("Default", true)
		end
	end)

	local sorttabs = {
		"BrowseQualitySort",
		"BrowseLevelSort",
		"BrowseDurationSort",
		"BrowseHighBidderSort",
		"BrowseCurrentBidSort",
		"BidQualitySort",
		"BidLevelSort",
		"BidDurationSort",
		"BidBuyoutSort",
		"BidStatusSort",
		"BidBidSort",
		"AuctionsQualitySort",
		"AuctionsDurationSort",
		"AuctionsHighBidderSort",
		"AuctionsBidSort",
	}

	for _, sorttab in pairs(sorttabs) do
		_G[sorttab.."Left"]:Kill()
		_G[sorttab.."Middle"]:Kill()
		_G[sorttab.."Right"]:Kill()
		_G[sorttab]:StyleButton()
	end

	for i = 1, 3 do
		S:HandleTab(_G["AuctionFrameTab"..i])
	end

	AuctionFrameTab1:ClearAllPoints()
	AuctionFrameTab1:Point("BOTTOMLEFT", AuctionFrame, "BOTTOMLEFT", 25, -26)
	AuctionFrameTab1.SetPoint = E.noop

	for i = 1, NUM_FILTERS_TO_DISPLAY do
		local tab = _G["AuctionFilterButton"..i]

		tab:StripTextures()
		tab:StyleButton()
	end

	local editboxs = {
		"BrowseName",
		"BrowseMinLevel",
		"BrowseMaxLevel",
		"BrowseBidPriceGold",
		"BrowseBidPriceSilver",
		"BrowseBidPriceCopper",
		"BidBidPriceGold",
		"BidBidPriceSilver",
		"BidBidPriceCopper",
		"AuctionsStackSizeEntry",
		"AuctionsNumStacksEntry",
		"StartPriceGold",
		"StartPriceSilver",
		"StartPriceCopper",
		"BuyoutPriceGold",
		"BuyoutPriceSilver",
		"BuyoutPriceCopper"
	}

	for _, editbox in pairs(editboxs) do
		S:HandleEditBox(_G[editbox])
		_G[editbox]:SetTextInsets(1, 1, -1, 1)
	end

	AuctionsStackSizeEntry.backdrop:SetAllPoints()
  	AuctionsNumStacksEntry.backdrop:SetAllPoints()

	BrowseBidPrice:Point("BOTTOM", -15, 18)
	BrowseBidText:Point("BOTTOMRIGHT", AuctionFrameBrowse, "BOTTOM", -116, 21)

	BrowseMaxLevel:Point("LEFT", BrowseMinLevel, "RIGHT", 8, 0)
	BrowseLevelText:Point("BOTTOMLEFT", AuctionFrameBrowse, "TOPLEFT", 195, -48)

	BrowseName:Width(164)
	BrowseName:Point("TOPLEFT", AuctionFrameBrowse, "TOPLEFT", 20, -54)
	BrowseNameText:Point("TOPLEFT", BrowseName, "TOPLEFT", 0, 16)

	S:HandleCheckBox(IsUsableCheckButton)
	S:HandleCheckBox(ShowOnPlayerCheckButton)

	for i = 1, NUM_BROWSE_TO_DISPLAY do
		local button = _G["BrowseButton"..i]
		local icon = _G["BrowseButton"..i.."Item"]
		local name = _G["BrowseButton"..i.."Name"]
		local texture = _G["BrowseButton"..i.."ItemIconTexture"]

		if texture then
			texture:SetTexCoord(unpack(E.TexCoords))
			texture:SetInside()
		end

		if icon then
			icon:StyleButton()
			icon:GetNormalTexture():SetTexture("")
			icon:SetTemplate("Default")

			hooksecurefunc(name, "SetVertexColor", function(_, r, g, b)
				if(r == 1 and g == 1 and b == 1) then
					icon:SetBackdropBorderColor(unpack(E["media"].bordercolor))
				else
					icon:SetBackdropBorderColor(r, g, b)
				end
			end)
			hooksecurefunc(name, "Hide", function(_, r, g, b)
				icon:SetBackdropBorderColor(unpack(E["media"].bordercolor))
			end)
		end

		button:StripTextures()
		button:StyleButton()
		_G["BrowseButton"..i.."Highlight"] = button:GetHighlightTexture()
		button:GetHighlightTexture():ClearAllPoints()
		button:GetHighlightTexture():Point("TOPLEFT", icon, "TOPRIGHT", 2, 0)
		button:GetHighlightTexture():Point("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 5)
		button:GetPushedTexture():SetAllPoints(button:GetHighlightTexture())
	end

	for i = 1, NUM_AUCTIONS_TO_DISPLAY do
		local button = _G["AuctionsButton"..i]
		local icon = _G["AuctionsButton"..i.."Item"]
		local name = _G["AuctionsButton"..i.."Name"]

		_G["AuctionsButton"..i.."ItemIconTexture"]:SetTexCoord(unpack(E.TexCoords))
		_G["AuctionsButton"..i.."ItemIconTexture"]:SetInside()

		icon:StyleButton()
		icon:GetNormalTexture():SetTexture("")
		icon:SetTemplate("Default")

		hooksecurefunc(name, "SetVertexColor", function(_, r, g, b)
			if(r == 1 and g == 1 and b == 1) then
				icon:SetBackdropBorderColor(unpack(E["media"].bordercolor))
			else
				icon:SetBackdropBorderColor(r, g, b)
			end
		end)
		hooksecurefunc(name, "Hide", function(_, r, g, b)
			icon:SetBackdropBorderColor(unpack(E["media"].bordercolor))
		end)

		button:StripTextures()
		button:StyleButton()
		_G["AuctionsButton"..i.."Highlight"] = button:GetHighlightTexture()
		button:GetHighlightTexture():ClearAllPoints()
		button:GetHighlightTexture():Point("TOPLEFT", icon, "TOPRIGHT", 2, 0)
		button:GetHighlightTexture():Point("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 5)
		button:GetPushedTexture():SetAllPoints(button:GetHighlightTexture())
	end

	for i = 1, NUM_BIDS_TO_DISPLAY do
		local button = _G["BidButton"..i]
		local icon = _G["BidButton"..i.."Item"]
		local name = _G["BidButton"..i.."Name"]

		_G["BidButton"..i.."ItemIconTexture"]:SetTexCoord(unpack(E.TexCoords))
		_G["BidButton"..i.."ItemIconTexture"]:SetInside()

		icon:StyleButton()
		icon:GetNormalTexture():SetTexture("")
		icon:SetTemplate("Default")

		icon:CreateBackdrop("Default")
		icon.backdrop:SetAllPoints()

		hooksecurefunc(name, "SetVertexColor", function(_, r, g, b)
			if(r == 1 and g == 1 and b == 1) then
				icon:SetBackdropBorderColor(unpack(E["media"].bordercolor))
			else
				icon:SetBackdropBorderColor(r, g, b)
			end
		end)
		hooksecurefunc(name, "Hide", function(_, r, g, b)
			icon:SetBackdropBorderColor(unpack(E["media"].bordercolor))
		end)

		button:StripTextures()
		button:StyleButton()
		_G["BidButton"..i.."Highlight"] = button:GetHighlightTexture()
		button:GetHighlightTexture():ClearAllPoints()
		button:GetHighlightTexture():Point("TOPLEFT", icon, "TOPRIGHT", 2, 0)
		button:GetHighlightTexture():Point("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 5)
		button:GetPushedTexture():SetAllPoints(button:GetHighlightTexture())
	end

	--Custom Backdrops
	AuctionFrameBrowse.bg1 = CreateFrame("Frame", nil, AuctionFrameBrowse)
	AuctionFrameBrowse.bg1:SetTemplate("Default")
	AuctionFrameBrowse.bg1:Point("TOPLEFT", 20, -103)
	AuctionFrameBrowse.bg1:Point("BOTTOMRIGHT", -575, 40)
	BrowseNoResultsText:SetParent(AuctionFrameBrowse.bg1)
	BrowseSearchCountText:SetParent(AuctionFrameBrowse.bg1)
	AuctionFrameBrowse.bg1:SetFrameLevel(AuctionFrameBrowse.bg1:GetFrameLevel() - 1)

	AuctionFrameBrowse.bg2 = CreateFrame("Frame", nil, AuctionFrameBrowse)
	AuctionFrameBrowse.bg2:SetTemplate("Default")
	AuctionFrameBrowse.bg2:Point("TOPLEFT", AuctionFrameBrowse.bg1, "TOPRIGHT", 4, 0)
	AuctionFrameBrowse.bg2:Point("BOTTOMRIGHT", AuctionFrame, "BOTTOMRIGHT", -8, 40)
	AuctionFrameBrowse.bg2:SetFrameLevel(AuctionFrameBrowse.bg2:GetFrameLevel() - 1)

	AuctionFrameBid.bg = CreateFrame("Frame", nil, AuctionFrameBid)
	AuctionFrameBid.bg:SetTemplate("Default")
	AuctionFrameBid.bg:Point("TOPLEFT", 20, -72)
	AuctionFrameBid.bg:Point("BOTTOMRIGHT", 66, 40)
	AuctionFrameBid.bg:SetFrameLevel(AuctionFrameBid.bg:GetFrameLevel() - 1)

	AuctionFrameAuctions.bg1 = CreateFrame("Frame", nil, AuctionFrameAuctions)
	AuctionFrameAuctions.bg1:SetTemplate("Default")
	AuctionFrameAuctions.bg1:Point("TOPLEFT", 15, -72)
	AuctionFrameAuctions.bg1:Point("BOTTOMRIGHT", -545, 40)
	AuctionFrameAuctions.bg1:SetFrameLevel(AuctionFrameAuctions.bg1:GetFrameLevel() - 3)

	AuctionFrameAuctions.bg2 = CreateFrame("Frame", nil, AuctionFrameAuctions)
	AuctionFrameAuctions.bg2:SetTemplate("Default")
	AuctionFrameAuctions.bg2:Point("TOPLEFT", AuctionFrameAuctions.bg1, "TOPRIGHT", 3, 0)
	AuctionFrameAuctions.bg2:Point("BOTTOMRIGHT", AuctionFrame, -8, 40)
	AuctionFrameAuctions.bg2:SetFrameLevel(AuctionFrameAuctions.bg2:GetFrameLevel() - 3)
end

S:AddCallbackForAddon("Blizzard_AuctionUI", "AuctionHouse", LoadSkin)