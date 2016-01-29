local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.auctionhouse ~= true then return end
	S:HandleCloseButton(AuctionFrameCloseButton)
	S:HandleScrollBar(AuctionsScrollFrameScrollBar)
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
	
	S:HandleCheckBox(IsUsableCheckButton)
	S:HandleCheckBox(ShowOnPlayerCheckButton)
	
	AuctionDressUpFrame:StripTextures(true)
	AuctionDressUpFrame:CreateBackdrop("Transparent")
	AuctionDressUpFrame.backdrop:Point("TOPLEFT", 1, -3)
	AuctionDressUpFrame.backdrop:Point("BOTTOMRIGHT", -2, 0)

	S:HandleButton(AuctionDressUpFrameResetButton)
	S:HandleCloseButton(AuctionDressUpFrameCloseButton)
	
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
	
	S:HandleNextPrevButton(BrowseNextPageButton)
	S:HandleNextPrevButton(BrowsePrevPageButton)
	
	local buttons = {
		"BrowseBidButton",
		"BidBidButton",
		"BrowseBuyoutButton",
		"BidBuyoutButton",
		"BrowseCloseButton",
		"BidCloseButton",
		"BrowseSearchButton",
		"AuctionsCloseButton",
		"BrowseResetButton"
	}
	
	for _, button in pairs(buttons) do
		S:HandleButton(_G[button])
	end
	
	S:HandleButton(AuctionsStackSizeMaxButton, true)
	S:HandleButton(AuctionsNumStacksMaxButton, true)
	S:HandleButton(AuctionsCreateAuctionButton, true)
	S:HandleButton(AuctionsCancelAuctionButton, true)
	
	--Fix Button Positions
	AuctionsCloseButton:Point("BOTTOMRIGHT", AuctionFrameAuctions, "BOTTOMRIGHT", 66, 10)
	AuctionsCancelAuctionButton:Point("RIGHT", AuctionsCloseButton, "LEFT", -4, 0)
	BidBuyoutButton:Point("RIGHT", BidCloseButton, "LEFT", -4, 0)
	BidBidButton:Point("RIGHT", BidBuyoutButton, "LEFT", -4, 0)
	BrowseBuyoutButton:Point("RIGHT", BrowseCloseButton, "LEFT", -4, 0)
	BrowseBidButton:Point("RIGHT", BrowseBuyoutButton, "LEFT", -4, 0)		
	AuctionsItemButton:StripTextures()
	AuctionsItemButton:StyleButton()
	AuctionsItemButton:SetTemplate("Default", true)
	BrowseResetButton:Point("TOPLEFT", AuctionFrameBrowse, "TOPLEFT", 81, -74)
	BrowseSearchButton:Point("TOPRIGHT", AuctionFrameBrowse, "TOPRIGHT", 25, -34)
	
	AuctionsItemButton:HookScript("OnEvent", function(self, event, ...)
		self:SetBackdropBorderColor(unpack(E["media"].bordercolor))
		if(event == 'NEW_AUCTION_UPDATE' and self:GetNormalTexture()) then
			self:GetNormalTexture():SetTexCoord(unpack(E.TexCoords));
			self:GetNormalTexture():SetInside();
		end
	end);
	
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
	end
	
	for i=1, 3 do
		S:HandleTab(_G["AuctionFrameTab"..i])
	end
	
	for i=1, NUM_FILTERS_TO_DISPLAY do
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
	BrowseMaxLevel:Point("LEFT", BrowseMinLevel, "RIGHT", 8, 0)
	AuctionsStackSizeEntry.backdrop:SetAllPoints()
	AuctionsNumStacksEntry.backdrop:SetAllPoints()
	
	for i=1, NUM_BROWSE_TO_DISPLAY do
		local button = _G["BrowseButton"..i]
		local icon = _G["BrowseButton"..i.."Item"]
		local name = _G["BrowseButton"..i.."Name"];
		
		_G["BrowseButton"..i.."ItemIconTexture"]:SetTexCoord(unpack(E.TexCoords));
		_G["BrowseButton"..i.."ItemIconTexture"]:SetInside();
		
		if(icon) then
			icon:StyleButton();
			icon:GetNormalTexture():SetTexture("");
			icon:SetTemplate("Default");
			
			hooksecurefunc(name, "SetVertexColor", function(self, r, g, b)
				if(r == 1 and g == 1 and b == 1) then
					icon:SetBackdropBorderColor(unpack(E["media"].bordercolor));
				else
					icon:SetBackdropBorderColor(r, g, b);
				end
			end);
			hooksecurefunc(name, "Hide", function(self, r, g, b)
				icon:SetBackdropBorderColor(unpack(E["media"].bordercolor));
			end);
		end
		
		button:StripTextures();
		button:StyleButton();
		_G["BrowseButton"..i.."Highlight"] = button:GetHighlightTexture();
		button:GetHighlightTexture():ClearAllPoints();
		button:GetHighlightTexture():Point("TOPLEFT", icon, "TOPRIGHT", 2, 0);
		button:GetHighlightTexture():SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 5);
		button:GetPushedTexture():SetAllPoints(button:GetHighlightTexture());
	end
	
	for i=1, NUM_AUCTIONS_TO_DISPLAY do
		local button = _G["AuctionsButton"..i]
		local icon = _G["AuctionsButton"..i.."Item"]
		local name = _G["AuctionsButton"..i.."Name"];
		
		_G["AuctionsButton"..i.."ItemIconTexture"]:SetTexCoord(unpack(E.TexCoords))
		_G["AuctionsButton"..i.."ItemIconTexture"]:SetInside()
		
		icon:StyleButton();
		icon:GetNormalTexture():SetTexture("");
		icon:SetTemplate("Default");
		
		hooksecurefunc(name, "SetVertexColor", function(self, r, g, b)
			if(r == 1 and g == 1 and b == 1) then
				icon:SetBackdropBorderColor(unpack(E["media"].bordercolor));
			else
				icon:SetBackdropBorderColor(r, g, b);
			end
		end);
		hooksecurefunc(name, "Hide", function(self, r, g, b)
			icon:SetBackdropBorderColor(unpack(E["media"].bordercolor));
		end);
		
		button:StripTextures()
		button:StyleButton()
		_G["AuctionsButton"..i.."Highlight"] = button:GetHighlightTexture()
		button:GetHighlightTexture():ClearAllPoints()
		button:GetHighlightTexture():Point("TOPLEFT", icon, "TOPRIGHT", 2, 0)
		button:GetHighlightTexture():SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 5)
		button:GetPushedTexture():SetAllPoints(button:GetHighlightTexture())		
	end
	
	for i=1, NUM_BIDS_TO_DISPLAY do
		local button = _G["BidButton"..i]
		local icon = _G["BidButton"..i.."Item"]
		local name = _G["BidButton"..i.."Name"];
		
		_G["BidButton"..i.."ItemIconTexture"]:SetTexCoord(unpack(E.TexCoords))
		_G["BidButton"..i.."ItemIconTexture"]:SetInside()
		
		icon:StyleButton()
		icon:GetNormalTexture():SetTexture("")
		icon:SetTemplate("Default");
		
		icon:CreateBackdrop("Default")
		icon.backdrop:SetAllPoints()
		
		hooksecurefunc(name, "SetVertexColor", function(self, r, g, b)
			if(r == 1 and g == 1 and b == 1) then
				icon:SetBackdropBorderColor(unpack(E["media"].bordercolor));
			else
				icon:SetBackdropBorderColor(r, g, b);
			end
		end);
		hooksecurefunc(name, "Hide", function(self, r, g, b)
			icon:SetBackdropBorderColor(unpack(E["media"].bordercolor));
		end);
		
		button:StripTextures()
		button:StyleButton()
		_G["BidButton"..i.."Highlight"] = button:GetHighlightTexture()
		button:GetHighlightTexture():ClearAllPoints()
		button:GetHighlightTexture():Point("TOPLEFT", icon, "TOPRIGHT", 2, 0)
		button:GetHighlightTexture():SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 5)
		button:GetPushedTexture():SetAllPoints(button:GetHighlightTexture())			
	end
	
	--[[for i=1, AuctionFrameBrowse:GetNumRegions() do 
		local region = select(i, AuctionFrameBrowse:GetRegions());
		if region:GetObjectType() == "FontString" then 
			print(region:GetText(), region:GetName()) 
		end 
	end]]
	
	--Custom Backdrops
	AuctionFrameBrowse.bg1 = CreateFrame("Frame", nil, AuctionFrameBrowse)
	AuctionFrameBrowse.bg1:SetTemplate("Default")
	AuctionFrameBrowse.bg1:Point("TOPLEFT", 20, -103)
	AuctionFrameBrowse.bg1:Point("BOTTOMRIGHT", -575, 40)
	BrowseNoResultsText:SetParent(AuctionFrameBrowse.bg1)
	BrowseSearchCountText:SetParent(AuctionFrameBrowse.bg1)
	AuctionFrameBrowse.bg1:SetFrameLevel(AuctionFrameBrowse.bg1:GetFrameLevel() - 1)
	BrowseFilterScrollFrame:Height(300) --Adjust scrollbar height a little off

	AuctionFrameBrowse.bg2 = CreateFrame("Frame", nil, AuctionFrameBrowse)
	AuctionFrameBrowse.bg2:SetTemplate("Default")
	AuctionFrameBrowse.bg2:Point("TOPLEFT", AuctionFrameBrowse.bg1, "TOPRIGHT", 4, 0)
	AuctionFrameBrowse.bg2:Point("BOTTOMRIGHT", AuctionFrame, "BOTTOMRIGHT", -8, 40)
	AuctionFrameBrowse.bg2:SetFrameLevel(AuctionFrameBrowse.bg2:GetFrameLevel() - 1)
	BrowseScrollFrame:Height(300) --Adjust scrollbar height a little off
	
	AuctionFrameBid.bg = CreateFrame("Frame", nil, AuctionFrameBid)
	AuctionFrameBid.bg:SetTemplate("Default")
	AuctionFrameBid.bg:Point("TOPLEFT", 22, -72)
	AuctionFrameBid.bg:Point("BOTTOMRIGHT", 66, 39)
	AuctionFrameBid.bg:SetFrameLevel(AuctionFrameBid.bg:GetFrameLevel() - 1)
	BidScrollFrame:Height(332)	

	AuctionsScrollFrame:Height(336)	
	AuctionFrameAuctions.bg1 = CreateFrame("Frame", nil, AuctionFrameAuctions)
	AuctionFrameAuctions.bg1:SetTemplate("Default")
	AuctionFrameAuctions.bg1:Point("TOPLEFT", 15, -70)
	AuctionFrameAuctions.bg1:Point("BOTTOMRIGHT", -545, 35);
	AuctionFrameAuctions.bg1:SetFrameLevel(AuctionFrameAuctions.bg1:GetFrameLevel() - 2)	
	
	AuctionFrameAuctions.bg2 = CreateFrame("Frame", nil, AuctionFrameAuctions)
	AuctionFrameAuctions.bg2:SetTemplate("Default")
	AuctionFrameAuctions.bg2:Point("TOPLEFT", AuctionFrameAuctions.bg1, "TOPRIGHT", 3, 0)
	AuctionFrameAuctions.bg2:Point("BOTTOMRIGHT", AuctionFrame, -8, 35);
	AuctionFrameAuctions.bg2:SetFrameLevel(AuctionFrameAuctions.bg2:GetFrameLevel() - 2)	
end

S:RegisterSkin("Blizzard_AuctionUI", LoadSkin)