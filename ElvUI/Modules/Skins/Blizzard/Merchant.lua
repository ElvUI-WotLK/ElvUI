local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local unpack = unpack
--WoW API / Variables
local GetBuybackItemInfo = GetBuybackItemInfo
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local GetMerchantNumItems = GetMerchantNumItems

S:AddCallback("Skin_Merchant", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.merchant then return end

	local MerchantFrame = _G.MerchantFrame
	MerchantFrame:StripTextures(true)
	MerchantFrame:CreateBackdrop("Transparent")
	MerchantFrame.backdrop:Point("TOPLEFT", 11, -12)
	MerchantFrame.backdrop:Point("BOTTOMRIGHT", -32, 76)

	S:SetUIPanelWindowInfo(MerchantFrame, "width")
	S:SetBackdropHitRect(MerchantFrame)

	MerchantFrame:EnableMouseWheel(true)
	MerchantFrame:SetScript("OnMouseWheel", function(_, value)
		if value > 0 then
			if MerchantPrevPageButton:IsShown() and MerchantPrevPageButton:IsEnabled() == 1 then
				MerchantPrevPageButton_OnClick()
			end
		else
			if MerchantNextPageButton:IsShown() and MerchantNextPageButton:IsEnabled() == 1 then
				MerchantNextPageButton_OnClick()
			end
		end
	end)

	S:HandleCloseButton(MerchantFrameCloseButton, MerchantFrame.backdrop)

	local function skinMerchantButton(buttonName, buyback)
		local button = _G[buttonName]
		local itemButton = _G[buttonName.."ItemButton"]
		local icon = _G[buttonName.."ItemButtonIconTexture"]
		local name = _G[buttonName.."Name"]
		local nameFrame = _G[buttonName.."NameFrame"]
		local money = _G[buttonName.."MoneyFrame"]
		local slot = _G[buttonName.."SlotTexture"]

		button:StripTextures(true)
		button:CreateBackdrop("Default")
		button.backdrop:Point("TOPLEFT", -2, 2)

		if buyback then
			button.backdrop:Point("BOTTOMRIGHT", 4, -13)
		else
			button.backdrop:Point("BOTTOMRIGHT", 4, -6)
		end

		itemButton:StripTextures()
		itemButton:StyleButton()
		itemButton:SetTemplate("Default", true)
		itemButton:Size(40)
		itemButton:Point("TOPLEFT", 4, -4)

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside()

		name:Point("LEFT", slot, "RIGHT", -4, 5)
		nameFrame:Point("LEFT", slot, "RIGHT", -6, -17)

		money:ClearAllPoints()
		money:Point("BOTTOMLEFT", itemButton, "BOTTOMRIGHT", 3, 0)

		if not buyback then
			for j = 1, 2 do
				local currencyItem = _G[buttonName.."AltCurrencyFrameItem"..j]
				local currencyIcon = _G[buttonName.."AltCurrencyFrameItem"..j.."Texture"]

				currencyIcon.backdrop = CreateFrame("Frame", nil, currencyItem)
				currencyIcon.backdrop:SetTemplate("Default")
				currencyIcon.backdrop:SetFrameLevel(currencyItem:GetFrameLevel())
				currencyIcon.backdrop:SetOutside(currencyIcon)

				currencyIcon:SetTexCoord(unpack(E.TexCoords))
				currencyIcon:SetParent(currencyIcon.backdrop)
			end
		end
	end

	for i = 1, 12 do
		skinMerchantButton("MerchantItem"..i)

		if i % 2 == 0 then
			_G["MerchantItem"..i]:Point("TOPLEFT", _G["MerchantItem"..i-1], "TOPRIGHT", 13, 0)
		end
	end

	skinMerchantButton("MerchantBuyBackItem", true)

	S:HandleNextPrevButton(MerchantNextPageButton, nil, nil, true)
	S:HandleNextPrevButton(MerchantPrevPageButton, nil, nil, true)

	S:HandleButton(MerchantRepairItemButton)
	MerchantRepairItemButton:StyleButton(false)
	-- texWidth, texHeight, cropWidth, cropHeight, offsetX, offsetY = 128, 64, 26, 26, 5, 6
	MerchantRepairItemButton:GetRegions():SetTexCoord(0.0390625, 0.2421875, 0.09375, 0.5)
	MerchantRepairItemButton:GetRegions():SetInside()

	S:HandleButton(MerchantRepairAllButton)
	MerchantRepairAllIcon:StyleButton(false)
	-- texWidth, texHeight, cropWidth, cropHeight, offsetX, offsetY = 128, 64, 26, 26, 41, 6
	MerchantRepairAllIcon:SetTexCoord(0.3203125, 0.5234375, 0.09375, 0.5)
	MerchantRepairAllIcon:SetInside()

	S:HandleButton(MerchantGuildBankRepairButton)
	MerchantGuildBankRepairButton:StyleButton()
	-- texWidth, texHeight, cropWidth, cropHeight, offsetX, offsetY = 128, 64, 26, 26, 77, 6
	MerchantGuildBankRepairButtonIcon:SetTexCoord(0.6015625, 0.8046875, 0.09375, 0.5)
	MerchantGuildBankRepairButtonIcon:SetInside()

	S:HandleTab(MerchantFrameTab1)
	S:HandleTab(MerchantFrameTab2)

	MerchantNameText:Point("TOP", -6, -22)

	MerchantItem1:SetPoint("TOPLEFT", 21, -54)

	MerchantPrevPageButton:Point("CENTER", MerchantFrame, "BOTTOMLEFT", 37, 172)
	MerchantNextPageButton:Point("CENTER", MerchantFrame, "BOTTOMLEFT", 324, 172)

	MerchantPageText:Point("BOTTOM", -14, 166)

	MerchantBuyBackItem:Point("TOPLEFT", MerchantItem10, "BOTTOMLEFT", 0, -39)

	MerchantGuildBankRepairButton:Point("LEFT", MerchantRepairAllButton, "RIGHT", 5, 0)
	MerchantRepairItemButton:Point("RIGHT", MerchantRepairAllButton, "LEFT", -5, 0)
	MerchantRepairItemButton.SetPoint = E.noop

	MerchantMoneyFrame:Point("BOTTOMRIGHT", -30, 86)

	MerchantFrameTab1:Point("CENTER", MerchantFrame, "BOTTOMLEFT", 54, 62)
	MerchantFrameTab2:Point("LEFT", MerchantFrameTab1, "RIGHT", -15, 0)

	hooksecurefunc(MerchantRepairAllButton, "Show", function(self)
		-- CanMerchantRepair && CanGuildBankRepair
		if self:GetWidth() == 32 then
			MerchantRepairText:SetPoint("CENTER", MerchantFrame, "BOTTOMLEFT", 94, 151)
			MerchantRepairAllButton:Point("BOTTOMRIGHT", MerchantFrame, "BOTTOMLEFT", 111, 105)
		else
			MerchantRepairText:SetPoint("BOTTOMLEFT", MerchantFrame, "BOTTOMLEFT", 26, 125)
			MerchantRepairAllButton:Point("BOTTOMRIGHT", MerchantFrame, "BOTTOMLEFT", 172, 113)
		end
	end)

	hooksecurefunc("MerchantFrame_UpdateMerchantInfo", function()
		local numMerchantItems = GetMerchantNumItems()
		local index = (MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE
		local _, button, name, quality

		for i = 1, BUYBACK_ITEMS_PER_PAGE do
			index = index + 1

			if index <= numMerchantItems then
				button = _G["MerchantItem"..i.."ItemButton"]
				name = _G["MerchantItem"..i.."Name"]

				if button.link then
					_, _, quality = GetItemInfo(button.link)

					if quality then
						local r, g, b = GetItemQualityColor(quality)
						button:SetBackdropBorderColor(r, g, b)
						name:SetTextColor(r, g, b)
					else
						button:SetBackdropBorderColor(unpack(E.media.bordercolor))
						name:SetTextColor(1, 1, 1)
					end
				else
					button:SetBackdropBorderColor(unpack(E.media.bordercolor))
					name:SetTextColor(1, 1, 1)
				end
			end

			local itemName = GetBuybackItemInfo(GetNumBuybackItems())
			if itemName then
				_, _, quality = GetItemInfo(itemName)

				if quality then
					local r, g, b = GetItemQualityColor(quality)
					MerchantBuyBackItemItemButton:SetBackdropBorderColor(r, g, b)
					MerchantBuyBackItemName:SetTextColor(r, g, b)
				else
					MerchantBuyBackItemItemButton:SetBackdropBorderColor(unpack(E.media.bordercolor))
					MerchantBuyBackItemName:SetTextColor(1, 1, 1)
				end
			else
				MerchantBuyBackItemItemButton:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		end

		MerchantItem3:SetPoint("TOPLEFT", "MerchantItem1", "BOTTOMLEFT", 0, -11)
		MerchantItem5:SetPoint("TOPLEFT", "MerchantItem3", "BOTTOMLEFT", 0, -11)
		MerchantItem7:SetPoint("TOPLEFT", "MerchantItem5", "BOTTOMLEFT", 0, -11)
		MerchantItem9:SetPoint("TOPLEFT", "MerchantItem7", "BOTTOMLEFT", 0, -11)
	end)

	hooksecurefunc("MerchantFrame_UpdateBuybackInfo", function()
		local numBuybackItems = GetNumBuybackItems()
		local _, button, name, quality

		for i = 1, BUYBACK_ITEMS_PER_PAGE do
			if i <= numBuybackItems then
				local itemName = GetBuybackItemInfo(i)

				if itemName then
					button = _G["MerchantItem"..i.."ItemButton"]
					name = _G["MerchantItem"..i.."Name"]
					_, _, quality = GetItemInfo(itemName)

					if quality then
						local r, g, b = GetItemQualityColor(quality)
						button:SetBackdropBorderColor(r, g, b)
						name:SetTextColor(r, g, b)
					else
						button:SetBackdropBorderColor(unpack(E.media.bordercolor))
						name:SetTextColor(1, 1, 1)
					end
				end
			end
		end

		MerchantItem3:SetPoint("TOPLEFT", "MerchantItem1", "BOTTOMLEFT", 0, -15)
		MerchantItem5:SetPoint("TOPLEFT", "MerchantItem3", "BOTTOMLEFT", 0, -15)
		MerchantItem7:SetPoint("TOPLEFT", "MerchantItem5", "BOTTOMLEFT", 0, -15)
		MerchantItem9:SetPoint("TOPLEFT", "MerchantItem7", "BOTTOMLEFT", 0, -15)
	end)
end)