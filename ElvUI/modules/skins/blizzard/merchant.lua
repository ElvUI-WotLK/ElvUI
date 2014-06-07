local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule('Skins');

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.merchant ~= true then return end
	
	MerchantFrame:StripTextures(true);
	MerchantFrame:CreateBackdrop('Transparent');
	MerchantFrame.backdrop:Point('TOPLEFT', 10, -11);
	MerchantFrame.backdrop:Point('BOTTOMRIGHT', -28, 60);
	
	S:HandleCloseButton(MerchantFrameCloseButton, MerchantFrame.backdrop);
	
	for i = 1, 12 do
		local Item = _G['MerchantItem'..i];
		local Button = _G['MerchantItem'..i..'ItemButton'];
		local IconTexture = _G['MerchantItem'..i..'ItemButtonIconTexture'];
		
		Item:StripTextures(true);
		Item:CreateBackdrop('Default');
		
		Button:StripTextures();
		Button:StyleButton();
		Button:SetTemplate('Default', true);
		Button:Point('TOPLEFT', Item, 'TOPLEFT', 4, -4);
		
		IconTexture:SetTexCoord(unpack(E.TexCoords));
		IconTexture:SetInside();
		
		_G['MerchantItem'..i..'MoneyFrame']:ClearAllPoints();
		_G['MerchantItem'..i..'MoneyFrame']:Point('BOTTOMLEFT', Button, 'BOTTOMRIGHT', 3, 0);
	end
	
	S:HandleNextPrevButton(MerchantNextPageButton);
	S:HandleNextPrevButton(MerchantPrevPageButton);
	
	MerchantRepairItemButton:StyleButton();
	MerchantRepairItemButton:SetTemplate('Default', true);
	for i=1, MerchantRepairItemButton:GetNumRegions() do
		local region = select(i, MerchantRepairItemButton:GetRegions());

		if region:GetObjectType() == 'Texture' then
			region:SetTexCoord(0.04, 0.24, 0.06, 0.5);
			region:SetInside();
		end
	end
	
	MerchantRepairAllButton:StyleButton();
	MerchantRepairAllButton:SetTemplate('Default', true);
	MerchantRepairAllIcon:SetTexCoord(0.34, 0.1, 0.34, 0.535, 0.535, 0.1, 0.535, 0.535);
	MerchantRepairAllIcon:SetInside();
	
	MerchantGuildBankRepairButton:StyleButton();
	MerchantGuildBankRepairButton:SetTemplate('Default', true);
	MerchantGuildBankRepairButtonIcon:SetTexCoord(0.61, 0.82, 0.1, 0.52);
	MerchantGuildBankRepairButtonIcon:SetInside();
	
	MerchantBuyBackItem:StripTextures(true);
	MerchantBuyBackItem:CreateBackdrop('Transparent');
	MerchantBuyBackItem.backdrop:Point('TOPLEFT', -6, 6);
	MerchantBuyBackItem.backdrop:Point('BOTTOMRIGHT', 6, -6);
	
	MerchantBuyBackItemItemButton:StripTextures();
	MerchantBuyBackItemItemButton:StyleButton();
	MerchantBuyBackItemItemButton:SetTemplate('Default', true);
	MerchantBuyBackItemItemButtonIconTexture:SetTexCoord(unpack(E.TexCoords));
	MerchantBuyBackItemItemButtonIconTexture:SetInside();
	
	for i= 1, 2 do
		S:HandleTab(_G['MerchantFrameTab'..i]);
	end
end

S:RegisterSkin('ElvUI', LoadSkin);