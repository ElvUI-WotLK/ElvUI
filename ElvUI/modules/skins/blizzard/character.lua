local E, L, V, P, G = unpack(select(2, ...)); -- Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.character ~= true then return end
	
	CharacterFrame:StripTextures(true)
	CharacterFrame:CreateBackdrop('Transparent')
	CharacterFrame.backdrop:Point('TOPLEFT', 10, -12)
	CharacterFrame.backdrop:Point('BOTTOMRIGHT', -32, 76)
	
	S:HandleCloseButton(CharacterFrameCloseButton)
	
	for i = 1, #CHARACTERFRAME_SUBFRAMES do
		local tab = _G["CharacterFrameTab"..i];
		S:HandleTab(tab);
	end
	
		GearManagerDialog:StripTextures()
	GearManagerDialog:CreateBackdrop('Transparent')
	GearManagerDialog.backdrop:Point('TOPLEFT', 5, -2)
	GearManagerDialog.backdrop:Point('BOTTOMRIGHT', -1, 4)
	
	S:HandleCloseButton(GearManagerDialogClose)
	
	for i = 1, 10 do
		_G['GearSetButton'..i]:StripTextures()
		_G['GearSetButton'..i]:StyleButton()
		_G['GearSetButton'..i]:CreateBackdrop('Default')
		_G['GearSetButton'..i].backdrop:SetAllPoints()
		_G['GearSetButton'..i..'Icon']:SetTexCoord(unpack(E.TexCoords))
		_G['GearSetButton'..i..'Icon']:SetInside()
	end
	
	S:HandleButton(GearManagerDialogDeleteSet)
	S:HandleButton(GearManagerDialogEquipSet)
	S:HandleButton(GearManagerDialogSaveSet)
	
	--[[PaperDollFrameItemFlyoutHighlight:Kill()
	local function SkinItemFlyouts()
		PaperDollFrameItemFlyoutButtons:StripTextures()
		
		for i=1, 25 do
			local button = _G['PaperDollFrameItemFlyoutButtons'..i]
			local icon = _G['PaperDollFrameItemFlyoutButtons'..i..'IconTexture']
			if button then
				button:StyleButton()
				button:SetTemplate("Default", true)
				button:GetNormalTexture():SetTexture(nil)
				button:SetFrameLevel(button:GetFrameLevel() + 2)
				
				icon:SetTexCoord(unpack(E.TexCoords))
				icon:SetDrawLayer("OVERLAY")
				icon:SetInside()
			end
		end
	end
	
	PaperDollFrameItemFlyout:HookScript('OnShow', SkinItemFlyouts)
	hooksecurefunc('PaperDollItemSlotButton_OnShow', SkinItemFlyouts)]]--
	
	GearManagerDialogPopup:StripTextures()
	GearManagerDialogPopup:CreateBackdrop("Transparent")
	GearManagerDialogPopup.backdrop:Point('TOPLEFT', 5, -2)
	GearManagerDialogPopup.backdrop:Point('BOTTOMRIGHT', -4, 8)
	
	S:HandleEditBox(GearManagerDialogPopupEditBox)
	
	GearManagerDialogPopupScrollFrame:StripTextures()
	S:HandleScrollBar(GearManagerDialogPopupScrollFrameScrollBar)
	
	for i=1, NUM_GEARSET_ICONS_SHOWN do
		local button = _G["GearManagerDialogPopupButton"..i]
		local icon = button.icon
		
		if button then
			button:StripTextures()
			button:StyleButton(true)
			
			icon:SetTexCoord(unpack(E.TexCoords))
			_G["GearManagerDialogPopupButton"..i.."Icon"]:SetTexture(nil)

			icon:SetInside()
			button:SetFrameLevel(button:GetFrameLevel() + 2)
			if not button.backdrop then
				button:CreateBackdrop("Default")
				button.backdrop:SetAllPoints()			
			end
		end
	end
	
	S:HandleButton(GearManagerDialogPopupOkay)
	S:HandleButton(GearManagerDialogPopupCancel)
	
	PaperDollFrame:StripTextures(true)
	
	PlayerTitleFrame:StripTextures()
	PlayerTitleFrame:CreateBackdrop('Default')
	PlayerTitleFrame.backdrop:Point('TOPLEFT', 20, 3)
	PlayerTitleFrame.backdrop:Point('BOTTOMRIGHT', -16, 14)
	S:HandleNextPrevButton(PlayerTitleFrameButton, true)
	PlayerTitleFrameButton:ClearAllPoints()
	PlayerTitleFrameButton:Point("RIGHT", PlayerTitleFrame.backdrop, "RIGHT", -2, 0)
	
	PlayerTitlePickerFrame:StripTextures()
	PlayerTitlePickerFrame:CreateBackdrop('Transparent')
	PlayerTitlePickerFrame.backdrop:Point('TOPLEFT', 5, -8)
	PlayerTitlePickerFrame.backdrop:Point('BOTTOMRIGHT', -10, 5)
	
	S:HandleScrollBar(PlayerTitlePickerScrollFrameScrollBar)
	
	_G['GearManagerToggleButton']:Size(26, 32);
	_G['GearManagerToggleButton']:CreateBackdrop('Default');
	
	GearManagerToggleButton:GetNormalTexture():SetTexCoord(0.1875, 0.796875, 0.125, 0.890625);
	GearManagerToggleButton:GetPushedTexture():SetTexCoord(0.1875, 0.796875, 0.125, 0.890625);
	GearManagerToggleButton:GetHighlightTexture():SetTexture(1, 1, 1, 0.3);
	GearManagerToggleButton:GetHighlightTexture():SetAllPoints();
	
	local slots = {"HeadSlot", "NeckSlot", "ShoulderSlot", "BackSlot", "ChestSlot", "ShirtSlot", "TabardSlot", "WristSlot",
		"HandsSlot", "WaistSlot", "LegsSlot", "FeetSlot", "Finger0Slot", "Finger1Slot", "Trinket0Slot", "Trinket1Slot",
		"MainHandSlot", "SecondaryHandSlot", "RangedSlot", "AmmoSlot"
	};
	
	for _, slot in pairs(slots) do
		local icon = _G["Character"..slot.."IconTexture"];
		local cooldown = _G["Character"..slot.."Cooldown"];
		
		slot = _G["Character"..slot];
		slot:StripTextures();
		slot:StyleButton(false);
		slot:SetTemplate("Default", true, true);
		
		icon:SetTexCoord(unpack(E.TexCoords));
		icon:SetInside();
		
		slot:SetFrameLevel(PaperDollFrame:GetFrameLevel() + 2);
		
		if(cooldown) then
			E:RegisterCooldown(cooldown);
		end
	end
	
	local function ColorItemBorder()
		for _, slot in pairs(slots) do
			local target = _G['Character'..slot]
			local slotId, _, _ = GetInventorySlotInfo(slot)
			local itemId = GetInventoryItemID('player', slotId)

			if itemId then
				local rarity = GetInventoryItemQuality("player", slotId);
				if rarity and rarity > 1 then
					target:SetBackdropBorderColor(GetItemQualityColor(rarity))
				else
					target:SetBackdropBorderColor(unpack(E['media'].bordercolor))
				end
			else
				target:SetBackdropBorderColor(unpack(E['media'].bordercolor))
			end
		end
	end
	
	local CheckItemBorderColor = CreateFrame('Frame')
	CheckItemBorderColor:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
	CheckItemBorderColor:SetScript('OnEvent', ColorItemBorder)	
	CharacterFrame:HookScript('OnShow', ColorItemBorder)
	ColorItemBorder()
	
	S:HandleRotateButton(CharacterModelFrameRotateLeftButton)
	S:HandleRotateButton(CharacterModelFrameRotateRightButton)
	
	CharacterResistanceFrame:CreateBackdrop('Default');
	CharacterResistanceFrame.backdrop:Point('TOPLEFT', -1, 1);
	CharacterResistanceFrame.backdrop:Point('BOTTOMRIGHT', 1, 14);
	
	select(1, MagicResFrame1:GetRegions()):SetTexCoord(0.21875, 0.78125, 0.25, 0.3203125);
	select(1, MagicResFrame2:GetRegions()):SetTexCoord(0.21875, 0.78125, 0.0234375, 0.09375);
	select(1, MagicResFrame3:GetRegions()):SetTexCoord(0.21875, 0.78125, 0.13671875, 0.20703125);
	select(1, MagicResFrame4:GetRegions()):SetTexCoord(0.21875, 0.78125, 0.36328125, 0.43359375);
	select(1, MagicResFrame5:GetRegions()):SetTexCoord(0.21875, 0.78125, 0.4765625, 0.546875);
	
	S:HandleDropDownBox(PlayerStatFrameLeftDropDown, 140)
	S:HandleDropDownBox(PlayerStatFrameRightDropDown, 140)
	CharacterAttributesFrame:StripTextures()
	
	PetPaperDollFrame:StripTextures(true)
	
	for i=1, 3 do
		local Tab = _G['PetPaperDollFrameTab'..i];
		Tab:StripTextures();
		Tab:CreateBackdrop("Default", true);
		Tab.backdrop:Point("TOPLEFT", 3, -7);
		Tab.backdrop:Point("BOTTOMRIGHT", -2, -1);
		
		Tab:HookScript('OnEnter', function(self) self.backdrop:SetBackdropBorderColor(unpack(E['media'].rgbvaluecolor)); end);
		Tab:HookScript('OnLeave', function(self) self.backdrop:SetBackdropBorderColor(unpack(E['media'].bordercolor)); end);
	end
	
	S:HandleRotateButton(PetModelFrameRotateLeftButton)
	S:HandleRotateButton(PetModelFrameRotateRightButton)
	
	PetAttributesFrame:StripTextures()
	
	S:HandleButton(PetPaperDollCloseButton)
	
	PetPaperDollFrameExpBar:StripTextures()
	PetPaperDollFrameExpBar:SetStatusBarTexture(E["media"].normTex)
	E:RegisterStatusBar(PetPaperDollFrameExpBar);
	PetPaperDollFrameExpBar:CreateBackdrop("Default")
	
	local function updHappiness(self)
		local happiness, damagePercentage = GetPetHappiness();
		local hasPetUI, isHunterPet = HasPetUI();
		if(not happiness or not isHunterPet) then
			return;	
		end
		local texture = self:GetRegions();
		if(happiness == 1) then
			texture:SetTexCoord(0.41, 0.53, 0.06, 0.30);
		elseif(happiness == 2) then
			texture:SetTexCoord(0.22, 0.345, 0.06, 0.30);
		elseif(happiness == 3) then
			texture:SetTexCoord(0.04, 0.15, 0.06, 0.30);
		end
	end
	
	PetPaperDollPetInfo:GetRegions():SetTexCoord(0.04, 0.15, 0.06, 0.30);
	PetPaperDollPetInfo:SetFrameLevel(PetModelFrame:GetFrameLevel() + 2);
	PetPaperDollPetInfo:CreateBackdrop("Default");
	PetPaperDollPetInfo:Size(24, 24);
	updHappiness(PetPaperDollPetInfo);
	
	PetPaperDollPetInfo:RegisterEvent("UNIT_HAPPINESS");
	PetPaperDollPetInfo:SetScript("OnEvent", updHappiness);
	PetPaperDollPetInfo:SetScript("OnShow", updHappiness);
	
	PetPaperDollFrameCompanionFrame:StripTextures()
	
	S:HandleRotateButton(CompanionModelFrameRotateLeftButton)
	S:HandleRotateButton(CompanionModelFrameRotateRightButton)
	
	S:HandleButton(CompanionSummonButton)
	
	hooksecurefunc('PetPaperDollFrame_UpdateCompanions', function()
		local Button, IconNormal, IconDisabled, ActiveTexture;
		
		for i = 1, NUM_COMPANIONS_PER_PAGE do
			Button = _G["CompanionButton"..i];
			IconNormal = Button:GetNormalTexture();
			IconDisabled = Button:GetDisabledTexture();
			ActiveTexture = _G['CompanionButton'..i..'ActiveTexture'];
			
			Button:StyleButton(nil, true);
			Button:SetTemplate('Default', true)
			
			if IconNormal then
				IconNormal:SetTexCoord(unpack(E.TexCoords));
				IconNormal:SetInside();
			end
			
			IconDisabled:SetTexture(nil);
			
			ActiveTexture:SetInside(Button);
			ActiveTexture:SetTexture(1, 1, 1, .15);
		end
	end);
	
	S:HandleNextPrevButton(CompanionPrevPageButton)
	S:HandleNextPrevButton(CompanionNextPageButton)
	
	ReputationFrame:StripTextures(true);

	local function UpdateFactionSkins()
		for i = 1, GetNumFactions() do
			local ReputationBar = _G["ReputationBar"..i.."ReputationBar"];

			if ReputationBar then
				ReputationBar:SetStatusBarTexture(E['media'].normTex);
				
				if not ReputationBar.backdrop then
					E:RegisterStatusBar(ReputationBar);
					ReputationBar:CreateBackdrop('Default');
				end
				
				_G['ReputationBar'..i..'Background']:SetTexture(nil);
				_G['ReputationBar'..i..'ReputationBarHighlight1']:SetTexture(nil);
				_G['ReputationBar'..i..'ReputationBarHighlight2']:SetTexture(nil);
				_G['ReputationBar'..i..'ReputationBarAtWarHighlight1']:SetTexture(nil);
				_G['ReputationBar'..i..'ReputationBarAtWarHighlight2']:SetTexture(nil);
				_G['ReputationBar'..i..'ReputationBarLeftTexture']:SetTexture(nil);
				_G['ReputationBar'..i..'ReputationBarRightTexture']:SetTexture(nil);
			end
		end
	end

	ReputationFrame:HookScript('OnShow', UpdateFactionSkins);
	ReputationFrame:HookScript('OnEvent', UpdateFactionSkins);
	
	ReputationListScrollFrame:StripTextures();
	S:HandleScrollBar(ReputationListScrollFrameScrollBar);
	
	ReputationDetailFrame:StripTextures();
	ReputationDetailFrame:SetTemplate('Transparent');
	
	S:HandleCloseButton(ReputationDetailCloseButton);
	
	S:HandleCheckBox(ReputationDetailAtWarCheckBox);
	ReputationDetailAtWarCheckBox:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-SwordCheck");
	S:HandleCheckBox(ReputationDetailInactiveCheckBox);
	S:HandleCheckBox(ReputationDetailMainScreenCheckBox);
	
	SkillFrame:StripTextures(true);
	
	SkillFrameExpandButtonFrame:StripTextures();
	
	hooksecurefunc('SkillFrame_SetStatusBar', function(statusBarID, skillIndex, numSkills, adjustedSkillPoints)
		local statusBar = _G['SkillRankFrame'..statusBarID];
		local statusBarBorder = _G['SkillRankFrame'..statusBarID..'Border'];
		local statusBarBackground = _G['SkillRankFrame'..statusBarID..'Background'];
		
		statusBar:SetStatusBarTexture(E['media'].normTex);
		
		if ( not statusBar.backdrop ) then
			E:RegisterStatusBar(statusBar);
			statusBar:CreateBackdrop('Default');
		end
		
		statusBarBorder:StripTextures();
		statusBarBackground:SetTexture(nil);
	end)
	
	hooksecurefunc('SkillDetailFrame_SetStatusBar', function()
		local StatusBar = _G["SkillDetailStatusBar"];
		local StatusBarBorder = _G['SkillDetailStatusBarBorder'];
		local StatusBarBackground = _G['SkillDetailStatusBarBackground'];
		
		if(not StatusBar.skinned) then
			StatusBar:SetStatusBarTexture(E['media'].normTex);
			E:RegisterStatusBar(StatusBar);
			StatusBar.skinned = true;
		end
		
		StatusBar:SetTemplate('Default');
		
		StatusBarBorder:SetTexture(nil);
		StatusBarBackground:SetTexture(nil);
	end)
	
	SkillListScrollFrame:StripTextures();
	S:HandleScrollBar(SkillListScrollFrameScrollBar);
	
	SkillDetailScrollFrame:StripTextures();
	S:HandleScrollBar(SkillDetailScrollFrameScrollBar);
	
	S:HandleButton(SkillFrameCancelButton);
	
	TokenFrame:StripTextures(true);
	
	select(4, TokenFrame:GetChildren()):Hide();
	
	hooksecurefunc('TokenFrame_Update', function()
		local scrollFrame = TokenFrameContainer;
		local offset = HybridScrollFrame_GetOffset(scrollFrame);
		local buttons = scrollFrame.buttons;
		local numButtons = #buttons;
		local name, isHeader, extraCurrencyType, icon, itemID;
		local button, index;
		
		for i = 1, numButtons do
			index = offset+i;
			name, isHeader, _, _, _, _, extraCurrencyType, icon, itemID = GetCurrencyListInfo(index);

			button = buttons[i];
			if name or name == "" then
				button.categoryLeft:Kill();
				button.categoryRight:Kill();
				button.highlight:Kill();
				
				if ( not isHeader ) then
					if ( extraCurrencyType == 1 ) then
						button.icon:SetTexCoord(unpack(E.TexCoords));
					elseif ( extraCurrencyType == 2 ) then
						local factionGroup = UnitFactionGroup('player');
						if ( factionGroup ) then
							button.icon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionGroup);
							button.icon:SetTexCoord( 0.03125, 0.59375, 0.03125, 0.59375 );
						else
							button.icon:SetTexCoord(unpack(E.TexCoords));
						end
					else
						button.icon:SetTexture(icon);
						button.icon:SetTexCoord(unpack(E.TexCoords));
					end
				end
			end
		end
	end)
	
	S:HandleScrollBar(TokenFrameContainerScrollBar);
	
	S:HandleButton(TokenFrameCancelButton);
	
	TokenFramePopup:StripTextures();
	TokenFramePopup:SetTemplate('Transparent');
	
	S:HandleCloseButton(TokenFramePopupCloseButton);
	
	S:HandleCheckBox(TokenFramePopupInactiveCheckBox);
	S:HandleCheckBox(TokenFramePopupBackpackCheckBox);
end

S:RegisterSkin('ElvUI', LoadSkin)