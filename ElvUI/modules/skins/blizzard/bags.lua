local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule('Skins');

function S:ContainerFrame_Update(self)
	local id = self:GetID();
	local name = self:GetName();
	local itemButton;
	local texture, itemCount, locked, quality;
	
	for i = 1, self.size, 1 do
		itemButton = _G[name..'Item'..i];
		
		texture, itemCount, locked, quality = GetContainerItemInfo(id, itemButton:GetID());
		isQuestItem, questId, isActive = GetContainerItemQuestInfo(id, itemButton:GetID());
		
		if(quality and quality > 1) then
			itemButton:SetBackdropBorderColor(GetItemQualityColor(quality));
		else
			itemButton:SetBackdropBorderColor(unpack(E['media'].bordercolor));
		end
		
		if(questId and not isActive) then
			itemButton:SetBackdropBorderColor(1, 0.2, 0.2);
		elseif(questId or isQuestItem) then
			itemButton:SetBackdropBorderColor(1, 0.2, 0.2);
		end
	end
end

function S:BankFrameItemButton_Update(button)
	local buttonID = button:GetID();
	local _, _, _, quality = GetContainerItemInfo(BANK_CONTAINER, buttonID);
	
	if(not button.isBag) then
		if(quality and quality > 1) then
			button:SetBackdropBorderColor(GetItemQualityColor(quality));
		else
			button:SetBackdropBorderColor(unpack(E['media'].bordercolor));
		end
		
		local isQuestItem, questId, isActive = GetContainerItemQuestInfo(BANK_CONTAINER, buttonID);
		
		if(questId and not isActive) then
			button:SetBackdropBorderColor(1, 0.2, 0.2);
		elseif(questId or isQuestItem) then
			button:SetBackdropBorderColor(1, 0.2, 0.2);
		end
	end
end

S:RegisterSkin('ElvUI', function()
	if(E.private.skins.blizzard.enable ~= true
		or E.private.skins.blizzard.bags ~= true
		or E.private.bags.enable)
	then
		return;
	end
	
	-- ContainerFrame
	local containerFrame, containerFrameClose;
	for i = 1, NUM_CONTAINER_FRAMES, 1 do
		containerFrame = _G['ContainerFrame'..i];
		containerFrameClose = _G['ContainerFrame'..i..'CloseButton'];
		
		containerFrame:CreateBackdrop('Transparent');
		containerFrame.backdrop:Point('TOPLEFT', 9, -4);
		containerFrame.backdrop:Point('BOTTOMRIGHT', -4, 2);
		
		containerFrame:StripTextures(true);
		
		local itemButton, itemButtonIcon;
		for k = 1, MAX_CONTAINER_ITEMS, 1 do
			itemButton = _G['ContainerFrame'..i..'Item'..k];
			itemButtonIcon = _G['ContainerFrame'..i..'Item'..k..'IconTexture'];
			
			itemButton:SetNormalTexture(nil);
			
			itemButton:SetTemplate('Default', true);
			itemButton:StyleButton();
			
			itemButtonIcon:SetInside();
			itemButtonIcon:SetTexCoord(unpack(E.TexCoords));
			
			_G['ContainerFrame'..i..'Item'..k..'IconQuestTexture']:SetAlpha(0);
		end
		
		S:HandleCloseButton(containerFrameClose);
	end
	
	S:SecureHook('ContainerFrame_Update');
	
	-- BankFrame
	BankFrame:CreateBackdrop('Transparent');
	BankFrame.backdrop:Point('TOPLEFT', 10, -11);
	BankFrame.backdrop:Point('BOTTOMRIGHT', -26, 93);
	
	BankFrame:StripTextures(true);
	
	S:HandleCloseButton(BankCloseButton);
	
	local button, buttonIcon;
	for i = 1, NUM_BANKGENERIC_SLOTS, 1 do
		button = _G['BankFrameItem'..i];
		buttonIcon = _G['BankFrameItem'..i..'IconTexture'];
		
		button:SetNormalTexture(nil);
		
		button:SetTemplate('Default', true);
		button:StyleButton();
		
		buttonIcon:SetInside();
		buttonIcon:SetTexCoord(unpack(E.TexCoords));
		
		_G['BankFrameItem'..i..'IconQuestTexture']:SetAlpha(0);
	end
	
	BankFrame.itemBackdrop = CreateFrame('Frame', 'BankFrameItemBackdrop', BankFrame);
	BankFrame.itemBackdrop:SetTemplate('Default');
	BankFrame.itemBackdrop:Point('TOPLEFT', BankFrameItem1, 'TOPLEFT', -6, 6);
	BankFrame.itemBackdrop:Point('BOTTOMRIGHT', BankFrameItem28, 'BOTTOMRIGHT', 6, -6);
	BankFrame.itemBackdrop:SetFrameLevel(BankFrame:GetFrameLevel());
	
	for i = 1, NUM_BANKBAGSLOTS, 1 do
		button = _G['BankFrameBag'..i];
		buttonIcon = _G['BankFrameBag'..i..'IconTexture'];
		
		button:SetNormalTexture(nil);
		
		button:SetTemplate('Default', true);
		button:StyleButton();
		
		buttonIcon:SetInside();
		buttonIcon:SetTexCoord(unpack(E.TexCoords));
		
		_G['BankFrameBag'..i..'HighlightFrameTexture']:SetInside();
		_G['BankFrameBag'..i..'HighlightFrameTexture']:SetTexture(unpack(E["media"].rgbvaluecolor), 0.3);
	end
	
	BankFrame.bagBackdrop = CreateFrame('Frame', 'BankFrameBagBackdrop', BankFrame);
	BankFrame.bagBackdrop:SetTemplate('Default');
	BankFrame.bagBackdrop:Point('TOPLEFT', BankFrameBag1, 'TOPLEFT', -6, 6);
	BankFrame.bagBackdrop:Point('BOTTOMRIGHT', BankFrameBag7, 'BOTTOMRIGHT', 6, -6);
	BankFrame.bagBackdrop:SetFrameLevel(BankFrame:GetFrameLevel());
	
	S:HandleButton(BankFramePurchaseButton);
	
	S:SecureHook('BankFrameItemButton_Update');
end);