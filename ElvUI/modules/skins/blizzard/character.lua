local E, L, V, P, G = unpack(select(2, ...)); -- Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local find = string.find;

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
	
	PaperDollFrameItemFlyoutHighlight:Kill()
	local function SkinItemFlyouts(button)
		if(not button.isSkinned) then
			button.icon = _G[button:GetName() .. "IconTexture"];

			button:GetNormalTexture():SetTexture(nil);
			button:SetTemplate("Default");
			button:StyleButton(false);

			button.icon:SetInside();
			button.icon:SetTexCoord(unpack(E.TexCoords));
		end

		cooldown = _G[button:GetName() .."Cooldown"];
		if(cooldown) then
			E:RegisterCooldown(cooldown);
		end

		local location = button.location;
		if(not location) then return; end
		if(location >= PDFITEMFLYOUT_FIRST_SPECIAL_LOCATION) then return; end

		local id = EquipmentManager_GetItemInfoByLocation(location);
		local _, _, quality = GetItemInfo(id);
		local r, g, b = GetItemQualityColor(quality);

		button:SetBackdropBorderColor(r, g, b);
	end
	hooksecurefunc("PaperDollFrameItemFlyout_DisplayButton", SkinItemFlyouts);
	
	local function SkinFrameFlyouts(button)
		PaperDollFrameItemFlyoutButtons:StripTextures();
	end
 	PaperDollFrameItemFlyout:HookScript('OnShow', SkinFrameFlyouts)
	
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
	CharacterModelFrameRotateRightButton:SetPoint("TOPLEFT", CharacterModelFrameRotateLeftButton, "TOPRIGHT", 3, 0);
	
	CharacterResistanceFrame:CreateBackdrop("Default");
	CharacterResistanceFrame.backdrop:SetOutside(MagicResFrame1, nil, nil, MagicResFrame5);

	for i = 1, 5 do
		local frame = _G["MagicResFrame" .. i];
		frame:Size(24);
		frame = _G["PetMagicResFrame" .. i];
		frame:Size(24);
	end

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
	PetModelFrameRotateRightButton:SetPoint("TOPLEFT", PetModelFrameRotateLeftButton, "TOPRIGHT", 3, 0);

	PetResistanceFrame:CreateBackdrop("Default");
	PetResistanceFrame.backdrop:SetOutside(PetMagicResFrame1, nil, nil, PetMagicResFrame5);

	select(1, PetMagicResFrame1:GetRegions()):SetTexCoord(0.21875, 0.78125, 0.25, 0.3203125);
	select(1, PetMagicResFrame2:GetRegions()):SetTexCoord(0.21875, 0.78125, 0.0234375, 0.09375);
	select(1, PetMagicResFrame3:GetRegions()):SetTexCoord(0.21875, 0.78125, 0.13671875, 0.20703125);
	select(1, PetMagicResFrame4:GetRegions()):SetTexCoord(0.21875, 0.78125, 0.36328125, 0.43359375);
	select(1, PetMagicResFrame5:GetRegions()):SetTexCoord(0.21875, 0.78125, 0.4765625, 0.546875);

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
	
	PetPaperDollPetInfo:SetPoint("TOPLEFT", PetModelFrameRotateLeftButton, "BOTTOMLEFT", 9, -3);
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
	CompanionModelFrameRotateRightButton:SetPoint("TOPLEFT", CompanionModelFrameRotateLeftButton, "TOPRIGHT", 3, 0);
	
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

	for i = 1, NUM_FACTIONS_DISPLAYED do
		local factionRow = _G["ReputationBar" .. i];
		local factionBar = _G["ReputationBar" .. i .. "ReputationBar"];
		local factionButton = _G["ReputationBar" .. i .. "ExpandOrCollapseButton"];

		factionRow:StripTextures(true);

		factionBar:StripTextures();
		factionBar:SetStatusBarTexture(E["media"].normTex);
		E:RegisterStatusBar(factionBar);
		factionBar:CreateBackdrop("Default");

		factionButton:StripTextures(true);
		factionButton:SetNormalTexture(nil);
		factionButton.SetNormalTexture = E.noop;

		factionButton.Text = factionButton:CreateFontString(nil, "OVERLAY");
		factionButton.Text:FontTemplate(nil, 22);
		factionButton.Text:Point("CENTER");
		factionButton.Text:SetText("+");
	end

	local function UpdateFaction()
		local factionOffset = FauxScrollFrame_GetOffset(ReputationListScrollFrame);
		local factionIndex, factionRow, factionButton;
		local numFactions = GetNumFactions();
		for i = 1, NUM_FACTIONS_DISPLAYED, 1 do
			factionRow = _G["ReputationBar" .. i];
			factionButton = _G["ReputationBar" .. i .. "ExpandOrCollapseButton"];
			factionIndex = factionOffset + i;
			if(factionIndex <= numFactions) then
				if(factionRow.isCollapsed) then
					factionButton.Text:SetText("+");
				else
					factionButton.Text:SetText("-");
				end
			end
		end
	end
	hooksecurefunc("ReputationFrame_Update", UpdateFaction);
	
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
	
	SkillFrameCollapseAllButton:SetNormalTexture("");
	SkillFrameCollapseAllButton.SetNormalTexture = E.noop;
	SkillFrameCollapseAllButton:SetHighlightTexture(nil);

	SkillFrameCollapseAllButton.Text = SkillFrameCollapseAllButton:CreateFontString(nil, "OVERLAY");
	SkillFrameCollapseAllButton.Text:FontTemplate(nil, 22);
	SkillFrameCollapseAllButton.Text:Point("CENTER", -10, 0);
	SkillFrameCollapseAllButton.Text:SetText("+");

	hooksecurefunc(SkillFrameCollapseAllButton, "SetNormalTexture", function(self, texture)
		if(find(texture, "MinusButton")) then
			self.Text:SetText("-");
		else
			self.Text:SetText("+");
		end
	end);

	for i = 1, SKILLS_TO_DISPLAY do
		local statusBar = _G["SkillRankFrame" .. i];
		local statusBarBorder = _G["SkillRankFrame" .. i .. "Border"];
		local statusBarBackground = _G["SkillRankFrame" .. i .. "Background"];

		statusBar:SetStatusBarTexture(E["media"].normTex);
		E:RegisterStatusBar(statusBar);
		statusBar:CreateBackdrop("Default");

		statusBarBorder:StripTextures();
		statusBarBackground:SetTexture(nil);

		local skillTypeLabelText = _G["SkillTypeLabel" .. i];
		skillTypeLabelText:SetNormalTexture("");
		skillTypeLabelText.SetNormalTexture = E.noop;
		skillTypeLabelText:SetHighlightTexture(nil);

		skillTypeLabelText.Text = skillTypeLabelText:CreateFontString(nil, "OVERLAY");
		skillTypeLabelText.Text:FontTemplate(nil, 22);
		skillTypeLabelText.Text:Point("LEFT", 3, 0);
		skillTypeLabelText.Text:SetText("+");

		hooksecurefunc(skillTypeLabelText, "SetNormalTexture", function(self, texture)
			if(find(texture, "MinusButton")) then
				self.Text:SetText("-");
			else
				self.Text:SetText("+");
			end
		end);
	end
	
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