local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins");

local function LoadSkin()
	if(E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.merchant ~= true) then return; end

	MerchantFrame:StripTextures(true);
	MerchantFrame:CreateBackdrop("Transparent");
	MerchantFrame.backdrop:Point("TOPLEFT", 10, -11);
	MerchantFrame.backdrop:Point("BOTTOMRIGHT", -28, 60);

	S:HandleCloseButton(MerchantFrameCloseButton, MerchantFrame.backdrop);

	for i = 1, 12 do
		local item = _G["MerchantItem" .. i];
		local itemButton = _G["MerchantItem" .. i .. "ItemButton"];
		local iconTexture = _G["MerchantItem" .. i .. "ItemButtonIconTexture"];

		item:StripTextures(true);
		item:CreateBackdrop("Default");

		itemButton:StripTextures();
		itemButton:StyleButton();
		itemButton:SetTemplate("Default", true);
		itemButton:Point("TOPLEFT", item, "TOPLEFT", 4, -4);

		iconTexture:SetTexCoord(unpack(E.TexCoords));
		iconTexture:SetInside();

		_G["MerchantItem" .. i .. "MoneyFrame"]:ClearAllPoints();
		_G["MerchantItem" .. i .. "MoneyFrame"]:Point("BOTTOMLEFT", itemButton, "BOTTOMRIGHT", 3, 0);
	end

	S:HandleNextPrevButton(MerchantNextPageButton);
	S:HandleNextPrevButton(MerchantPrevPageButton);

	MerchantRepairItemButton:StyleButton();
	MerchantRepairItemButton:SetTemplate("Default", true);
	for i = 1, MerchantRepairItemButton:GetNumRegions() do
		local region = select(i, MerchantRepairItemButton:GetRegions());
		if(region:GetObjectType() == "Texture") then
			region:SetTexCoord(0.04, 0.24, 0.06, 0.5);
			region:SetInside();
		end
	end

	MerchantRepairAllButton:StyleButton();
	MerchantRepairAllButton:SetTemplate("Default", true);
	MerchantRepairAllIcon:SetTexCoord(0.34, 0.1, 0.34, 0.535, 0.535, 0.1, 0.535, 0.535);
	MerchantRepairAllIcon:SetInside();

	MerchantGuildBankRepairButton:StyleButton();
	MerchantGuildBankRepairButton:SetTemplate("Default", true);
	MerchantGuildBankRepairButtonIcon:SetTexCoord(0.61, 0.82, 0.1, 0.52);
	MerchantGuildBankRepairButtonIcon:SetInside();

	MerchantBuyBackItem:StripTextures(true);
	MerchantBuyBackItem:CreateBackdrop("Transparent");
	MerchantBuyBackItem.backdrop:Point("TOPLEFT", -6, 6);
	MerchantBuyBackItem.backdrop:Point("BOTTOMRIGHT", 6, -6);

	MerchantBuyBackItemItemButton:StripTextures();
	MerchantBuyBackItemItemButton:StyleButton();
	MerchantBuyBackItemItemButton:SetTemplate("Default", true);
	MerchantBuyBackItemItemButtonIconTexture:SetTexCoord(unpack(E.TexCoords));
	MerchantBuyBackItemItemButtonIconTexture:SetInside();

	for i = 1, 2 do
		S:HandleTab(_G["MerchantFrameTab" .. i]);
	end

	hooksecurefunc("MerchantFrame_UpdateMerchantInfo", function()
		local numMerchantItems = GetMerchantNumItems();
		local index;
		local itemButton, itemName;
		for i = 1, BUYBACK_ITEMS_PER_PAGE do
			index = (((MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE) + i);
			itemButton = _G["MerchantItem" .. i .. "ItemButton"];
			itemName = _G["MerchantItem" .. i .. "Name"];

			if(index <= numMerchantItems) then
				if(itemButton.link) then
					local _, _, quality = GetItemInfo(itemButton.link);
					local r, g, b = GetItemQualityColor(quality);

					itemName:SetTextColor(r, g, b);
					if(quality > 1) then
						itemButton:SetBackdropBorderColor(r, g, b);
					else
						itemButton:SetBackdropBorderColor(unpack(E["media"].bordercolor));
					end
				end
			end

			local buybackName = GetBuybackItemInfo(GetNumBuybackItems());
			if(buybackName) then
				local _, _, quality = GetItemInfo(buybackName);
				local r, g, b = GetItemQualityColor(quality);

				MerchantBuyBackItemName:SetTextColor(r, g, b);
				if(quality > 1) then
					MerchantBuyBackItemItemButton:SetBackdropBorderColor(r, g, b);
				else
					MerchantBuyBackItemItemButton:SetBackdropBorderColor(unpack(E["media"].bordercolor));
				end
			else
				MerchantBuyBackItemItemButton:SetBackdropBorderColor(unpack(E["media"].bordercolor));
			end
		end
	end);

	hooksecurefunc("MerchantFrame_UpdateBuybackInfo", function()
		local numBuybackItems = GetNumBuybackItems();
		local itemButton, itemName;
		for i = 1, BUYBACK_ITEMS_PER_PAGE do
			itemButton = _G["MerchantItem" .. i .. "ItemButton"];
			itemName = _G["MerchantItem" .. i .. "Name"];

			if(i <= numBuybackItems) then
				local buybackName = GetBuybackItemInfo(i);
				if(buybackName) then
					local _, _, quality = GetItemInfo(buybackName);
					local r, g, b = GetItemQualityColor(quality);

					itemName:SetTextColor(r, g, b);
					if(quality > 1) then
						itemButton:SetBackdropBorderColor(r, g, b);
					else
						itemButton:SetBackdropBorderColor(unpack(E["media"].bordercolor));
					end
				end
			end
		end
	end);
end

S:AddCallback("Merchant", LoadSkin);