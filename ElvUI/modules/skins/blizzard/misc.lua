local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local S = E:GetModule('Skins')

local ceil = math.ceil

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.misc ~= true then return end
	-- Blizzard frame we want to reskin
	local skins = {
		"StaticPopup1",
		"StaticPopup2",
		"StaticPopup3",
		"GameMenuFrame",
		"InterfaceOptionsFrame",
		"VideoOptionsFrame",
		"AudioOptionsFrame",
		"BNToastFrame",
		"TicketStatusFrameButton",
		"DropDownList1MenuBackdrop",
		"DropDownList2MenuBackdrop",
		"DropDownList1Backdrop",
		"DropDownList2Backdrop",
		"AutoCompleteBox",
		"ConsolidatedBuffsTooltip",
		"ReadyCheckFrame",
		"StackSplitFrame",
	}

	for i = 1, getn(skins) do
		_G[skins[i]]:SetTemplate("Transparent")
	end

	
	local ChatMenus = {
		"ChatMenu",
		"EmoteMenu",
		"LanguageMenu",
		"VoiceMacroMenu",		
	}
	--
	for i = 1, getn(ChatMenus) do
		if _G[ChatMenus[i]] == _G["ChatMenu"] then
			_G[ChatMenus[i]]:HookScript("OnShow", function(self) self:SetTemplate("Default", true) self:SetBackdropColor(unpack(E['media'].backdropfadecolor)) self:ClearAllPoints() self:Point("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 0, 30) end)
		else
			_G[ChatMenus[i]]:HookScript("OnShow", function(self) self:SetTemplate("Default", true) self:SetBackdropColor(unpack(E['media'].backdropfadecolor)) end)
		end
	end
	
	-- reskin popup buttons
	for i = 1, 3 do
		_G["StaticPopup"..i.."CloseButton"]:StripTextures()
		S:HandleCloseButton(_G["StaticPopup"..i.."CloseButton"]);
		
		for j = 1, 3 do
			S:HandleButton(_G["StaticPopup"..i.."Button"..j])
			S:HandleEditBox(_G["StaticPopup"..i.."EditBox"])
			for k = 1, _G["StaticPopup"..i.."EditBox"]:GetNumRegions() do
				local region = select(k, _G["StaticPopup"..i.."EditBox"]:GetRegions())
				if region and region:GetObjectType() == "Texture" then
					if region:GetTexture() == "Interface\\ChatFrame\\UI-ChatInputBorder-Left" or region:GetTexture() == "Interface\\ChatFrame\\UI-ChatInputBorder-Right" then
						region:Kill()
					end
				end
			end
			S:HandleEditBox(_G["StaticPopup"..i.."MoneyInputFrameGold"])
			S:HandleEditBox(_G["StaticPopup"..i.."MoneyInputFrameSilver"])
			S:HandleEditBox(_G["StaticPopup"..i.."MoneyInputFrameCopper"])
			_G["StaticPopup"..i.."EditBox"].backdrop:Point("TOPLEFT", -2, -4)
			_G["StaticPopup"..i.."EditBox"].backdrop:Point("BOTTOMRIGHT", 2, 4)
			_G["StaticPopup"..i.."ItemFrameNameFrame"]:Kill()
			_G["StaticPopup"..i.."ItemFrame"]:GetNormalTexture():Kill()
			_G["StaticPopup"..i.."ItemFrame"]:SetTemplate("Default")
			_G["StaticPopup"..i.."ItemFrame"]:StyleButton()
			_G["StaticPopup"..i.."ItemFrameIconTexture"]:SetTexCoord(unpack(E.TexCoords))
			_G["StaticPopup"..i.."ItemFrameIconTexture"]:SetInside()
		end
		
		select(8, _G["StaticPopup"..i.."WideEditBox"]:GetRegions()):Hide();
		S:HandleEditBox(_G["StaticPopup"..i.."WideEditBox"]);
		_G["StaticPopup"..i.."WideEditBox"]:Height(22);
	end
	
	-- reskin all esc/menu buttons
	local BlizzardMenuButtons = {
		"Options", 
		"SoundOptions", 
		"UIOptions", 
		"Keybindings", 
		"Macros",
		"Logout", 
		"Quit",
		"Continue",
	}
	
	for i = 1, getn(BlizzardMenuButtons) do
		local ElvuiMenuButtons = _G["GameMenuButton"..BlizzardMenuButtons[i]]
		if ElvuiMenuButtons then
			S:HandleButton(ElvuiMenuButtons)
		end
	end
	
	-- hide header textures and move text/buttons.
	local BlizzardHeader = {
		"GameMenuFrame", 
		"InterfaceOptionsFrame", 
		"AudioOptionsFrame", 
		"VideoOptionsFrame",
	}
	
	for i = 1, getn(BlizzardHeader) do
		local title = _G[BlizzardHeader[i].."Header"]			
		if title then
			title:SetTexture("")
			title:ClearAllPoints()
			if title == _G["GameMenuFrameHeader"] then
				title:SetPoint("TOP", GameMenuFrame, 0, 7)
			else
				title:SetPoint("TOP", BlizzardHeader[i], 0, 0)
			end
		end
	end
	
	-- here we reskin all "normal" buttons
	local BlizzardButtons = {
		"VideoOptionsFrameOkay", 
		"VideoOptionsFrameCancel", 
		"VideoOptionsFrameDefaults", 
		"VideoOptionsFrameApply", 
		"AudioOptionsFrameOkay", 
		"AudioOptionsFrameCancel", 
		"AudioOptionsFrameDefaults", 
		"InterfaceOptionsFrameDefaults", 
		"InterfaceOptionsFrameOkay", 
		"InterfaceOptionsFrameCancel",
		"ReadyCheckFrameYesButton",
		"ReadyCheckFrameNoButton",
		"StackSplitOkayButton",
		"StackSplitCancelButton",
		"RolePollPopupAcceptButton"
	}
	
	for i = 1, getn(BlizzardButtons) do
		local ElvuiButtons = _G[BlizzardButtons[i]]
		if ElvuiButtons then
			S:HandleButton(ElvuiButtons)
		end
	end
	
	-- if a button position is not really where we want, we move it here
	VideoOptionsFrameCancel:ClearAllPoints()
	VideoOptionsFrameCancel:SetPoint("RIGHT",VideoOptionsFrameApply,"LEFT",-4,0)		 
	VideoOptionsFrameOkay:ClearAllPoints()
	VideoOptionsFrameOkay:SetPoint("RIGHT",VideoOptionsFrameCancel,"LEFT",-4,0)	
	AudioOptionsFrameOkay:ClearAllPoints()
	AudioOptionsFrameOkay:SetPoint("RIGHT",AudioOptionsFrameCancel,"LEFT",-4,0)
	InterfaceOptionsFrameOkay:ClearAllPoints()
	InterfaceOptionsFrameOkay:SetPoint("RIGHT",InterfaceOptionsFrameCancel,"LEFT", -4,0)
	ReadyCheckFrameYesButton:SetParent(ReadyCheckFrame)
	ReadyCheckFrameNoButton:SetParent(ReadyCheckFrame) 
	ReadyCheckFrameYesButton:SetPoint("RIGHT", ReadyCheckFrame, "CENTER", -1, 0)
	ReadyCheckFrameNoButton:SetPoint("LEFT", ReadyCheckFrameYesButton, "RIGHT", 3, 0)
	ReadyCheckFrameText:SetParent(ReadyCheckFrame)	
	ReadyCheckFrameText:ClearAllPoints()
	ReadyCheckFrameText:SetPoint("TOP", 0, -12)
	
	-- others
	ReadyCheckListenerFrame:SetAlpha(0)
	ReadyCheckFrame:HookScript("OnShow", function(self) if UnitIsUnit("player", self.initiator) then self:Hide() end end) -- bug fix, don't show it if initiator
	StackSplitFrame:GetRegions():Hide()

	InterfaceOptionsFrame:SetClampedToScreen(true)
	InterfaceOptionsFrame:SetMovable(true)
	InterfaceOptionsFrame:EnableMouse(true)
	InterfaceOptionsFrame:RegisterForDrag("LeftButton", "RightButton")
	InterfaceOptionsFrame:SetScript("OnDragStart", function(self) 
		if InCombatLockdown() then return end
		
		if IsShiftKeyDown() then
			self:StartMoving() 
		end
	end)
	InterfaceOptionsFrame:SetScript("OnDragStop", function(self) 
		self:StopMovingOrSizing()
	end)
	
	-- mac menu/option panel, made by affli.
	if IsMacClient() then
		S:HandleButton(GameMenuButtonMacOptions);
		
		-- Skin main frame and reposition the header
		MacOptionsFrame:SetTemplate("Default", true)
		MacOptionsFrameHeader:SetTexture("")
		MacOptionsFrameHeader:ClearAllPoints()
		MacOptionsFrameHeader:SetPoint("TOP", MacOptionsFrame, 0, 0)
		
		S:HandleDropDownBox(MacOptionsFrameResolutionDropDown);
		S:HandleDropDownBox(MacOptionsFrameFramerateDropDown);
		S:HandleDropDownBox(MacOptionsFrameCodecDropDown);
		
		S:HandleSliderFrame(MacOptionsFrameQualitySlider);
		
		for i = 1, 8 do
			S:HandleCheckBox(_G["MacOptionsFrameCheckButton"..i]);
		end
		
		--Skin internal frames
		MacOptionsFrameMovieRecording:SetTemplate("Default", true)
		MacOptionsITunesRemote:SetTemplate("Default", true)
 
		--Skin buttons
		S:HandleButton(MacOptionsFrameCancel)
		S:HandleButton(MacOptionsFrameOkay)
		S:HandleButton(MacOptionsButtonKeybindings)
		S:HandleButton(MacOptionsFrameDefaults)
		S:HandleButton(MacOptionsButtonCompress)
 
		--Reposition and resize buttons
		local tPoint, tRTo, tRP, tX, tY =  MacOptionsButtonCompress:GetPoint()
		MacOptionsButtonCompress:SetWidth(136)
		MacOptionsButtonCompress:ClearAllPoints()
		MacOptionsButtonCompress:Point(tPoint, tRTo, tRP, 4, tY)
 
		MacOptionsFrameCancel:SetWidth(96)
		MacOptionsFrameCancel:SetHeight(22)
		tPoint, tRTo, tRP, tX, tY =  MacOptionsFrameCancel:GetPoint()
		MacOptionsFrameCancel:ClearAllPoints()
		MacOptionsFrameCancel:Point(tPoint, tRTo, tRP, -14, tY)
 
		MacOptionsFrameOkay:ClearAllPoints()
		MacOptionsFrameOkay:SetWidth(96)
		MacOptionsFrameOkay:SetHeight(22)
		MacOptionsFrameOkay:Point("LEFT",MacOptionsFrameCancel, -99,0)
 
		MacOptionsButtonKeybindings:ClearAllPoints()
		MacOptionsButtonKeybindings:SetWidth(96)
		MacOptionsButtonKeybindings:SetHeight(22)
		MacOptionsButtonKeybindings:Point("LEFT",MacOptionsFrameOkay, -99,0)
 
		MacOptionsFrameDefaults:SetWidth(96)
		MacOptionsFrameDefaults:SetHeight(22)
		
		MacOptionsCompressFrame:SetTemplate("Default", true);
		
		MacOptionsCompressFrameHeader:SetTexture("")
		MacOptionsCompressFrameHeader:ClearAllPoints();
		MacOptionsCompressFrameHeader:SetPoint("TOP", MacOptionsCompressFrame, 0, 0);
		
		S:HandleButton(MacOptionsCompressFrameDelete);
		S:HandleButton(MacOptionsCompressFrameSkip);
		S:HandleButton(MacOptionsCompressFrameCompress);
		
		MacOptionsCancelFrame:SetTemplate("Default", true);
		
		MacOptionsCancelFrameHeader:SetTexture("");
		MacOptionsCancelFrameHeader:ClearAllPoints();
		MacOptionsCancelFrameHeader:SetPoint("TOP", MacOptionsCancelFrame, 0, 0);
		
		S:HandleButton(MacOptionsCancelFrameNo);
		S:HandleButton(MacOptionsCancelFrameYes);
	end
	
	BNToastFrameCloseButton:Size(32);
	BNToastFrameCloseButton:Point("TOPRIGHT", "BNToastFrame", 4, 4);
	S:HandleCloseButton(BNToastFrameCloseButton);
	
	OpacityFrame:StripTextures()
	OpacityFrame:SetTemplate("Transparent")
	
	S:HandleSliderFrame(OpacityFrameSlider);
	
	WatchFrameCollapseExpandButton:StripTextures()
	S:HandleCloseButton(WatchFrameCollapseExpandButton)
	WatchFrameCollapseExpandButton.backdrop:SetAllPoints()
	WatchFrameCollapseExpandButton.text:SetText('-')
	WatchFrameCollapseExpandButton:SetFrameStrata('MEDIUM')
	
	hooksecurefunc('WatchFrame_Expand', function()
		WatchFrameCollapseExpandButton.text:SetText('-')
	end)
	
	hooksecurefunc('WatchFrame_Collapse', function()
		WatchFrameCollapseExpandButton.text:SetText('+')
	end)	
	
	--Chat Config
	ChatConfigFrame:StripTextures();
	ChatConfigFrame:SetTemplate("Transparent");
	ChatConfigCategoryFrame:SetTemplate("Transparent");
	ChatConfigBackgroundFrame:SetTemplate("Transparent");
	
	ChatConfigChatSettingsClassColorLegend:SetTemplate("Transparent");
	ChatConfigChannelSettingsClassColorLegend:SetTemplate("Transparent");
	
	ChatConfigCombatSettingsFilters:SetTemplate("Transparent");
	
	ChatConfigCombatSettingsFiltersScrollFrame:StripTextures();
	S:HandleScrollBar(ChatConfigCombatSettingsFiltersScrollFrameScrollBar);
	
	S:HandleButton(ChatConfigCombatSettingsFiltersDeleteButton);
	S:HandleButton(ChatConfigCombatSettingsFiltersAddFilterButton);
	ChatConfigCombatSettingsFiltersAddFilterButton:Point("RIGHT", ChatConfigCombatSettingsFiltersDeleteButton, "LEFT", -1, 0);
	S:HandleButton(ChatConfigCombatSettingsFiltersCopyFilterButton);
	ChatConfigCombatSettingsFiltersCopyFilterButton:Point("RIGHT", ChatConfigCombatSettingsFiltersAddFilterButton, "LEFT", -1, 0);
	
	S:HandleNextPrevButton(ChatConfigMoveFilterUpButton, true);
	S:SquareButton_SetIcon(ChatConfigMoveFilterUpButton, "UP");
	ChatConfigMoveFilterUpButton:Size(26);
	ChatConfigMoveFilterUpButton:Point("TOPLEFT", ChatConfigCombatSettingsFilters, "BOTTOMLEFT", 3, -1);
	S:HandleNextPrevButton(ChatConfigMoveFilterDownButton, true);
	ChatConfigMoveFilterDownButton:Size(26);
	ChatConfigMoveFilterDownButton:Point("LEFT", ChatConfigMoveFilterUpButton, "RIGHT", 1, 0);
	
	CombatConfigColorsHighlighting:StripTextures();
	CombatConfigColorsColorizeUnitName:StripTextures();
	CombatConfigColorsColorizeSpellNames:StripTextures();
	
	CombatConfigColorsColorizeDamageNumber:StripTextures();
	CombatConfigColorsColorizeDamageSchool:StripTextures();
	CombatConfigColorsColorizeEntireLine:StripTextures();
	
	S:HandleEditBox(CombatConfigSettingsNameEditBox);
	
	S:HandleButton(CombatConfigSettingsSaveButton);
	
	local combatConfigCheck = {
		"CombatConfigColorsHighlightingLine",
		"CombatConfigColorsHighlightingAbility",
		"CombatConfigColorsHighlightingDamage",
		"CombatConfigColorsHighlightingSchool",
		"CombatConfigColorsColorizeUnitNameCheck",
		"CombatConfigColorsColorizeSpellNamesCheck",
		"CombatConfigColorsColorizeSpellNamesSchoolColoring",
		"CombatConfigColorsColorizeDamageNumberCheck",
		"CombatConfigColorsColorizeDamageNumberSchoolColoring",
		"CombatConfigColorsColorizeDamageSchoolCheck",
		"CombatConfigColorsColorizeEntireLineCheck",
		"CombatConfigFormattingShowTimeStamp",
		"CombatConfigFormattingShowBraces",
		"CombatConfigFormattingUnitNames",
		"CombatConfigFormattingSpellNames",
		"CombatConfigFormattingItemNames",
		"CombatConfigFormattingFullText",
		"CombatConfigSettingsShowQuickButton",
		"CombatConfigSettingsSolo",
		"CombatConfigSettingsParty",
		"CombatConfigSettingsRaid"
	};
	
	for i = 1, getn(combatConfigCheck) do
		S:HandleCheckBox(_G[combatConfigCheck[i]]);
	end
	
	for i = 1, 5 do
		local tab = _G["CombatConfigTab"..i];
		tab:StripTextures();
		
		tab:CreateBackdrop("Default", true);
		tab.backdrop:Point("TOPLEFT", 1, -10);
		tab.backdrop:Point("BOTTOMRIGHT", -1, 2);
		
		tab:HookScript("OnEnter", S.SetModifiedBackdrop);
		tab:HookScript("OnLeave", S.SetOriginalBackdrop);
	end
	
	S:HandleButton(ChatConfigFrameDefaultButton);
	S:HandleButton(CombatLogDefaultButton);
	S:HandleButton(ChatConfigFrameCancelButton);
	S:HandleButton(ChatConfigFrameOkayButton);
	
	S:SecureHook("ChatConfig_CreateCheckboxes", function(frame, checkBoxTable, checkBoxTemplate)
		local checkBoxNameString = frame:GetName().."CheckBox";
		if(checkBoxTemplate == "ChatConfigCheckBoxTemplate") then
			frame:SetTemplate("Transparent");
			for index, value in ipairs(checkBoxTable) do
				local checkBoxName = checkBoxNameString..index;
				local checkbox = _G[checkBoxName];
				if(not checkbox.backdrop) then
					checkbox:StripTextures();
					checkbox:CreateBackdrop();
					checkbox.backdrop:Point("TOPLEFT", 3, -1);
					checkbox.backdrop:Point("BOTTOMRIGHT", -3, 1);
					checkbox.backdrop:SetFrameLevel(checkbox:GetParent():GetFrameLevel() + 1);
					
					S:HandleCheckBox(_G[checkBoxName.."Check"]);
				end
			end
		elseif(checkBoxTemplate == "ChatConfigCheckBoxWithSwatchTemplate") or (checkBoxTemplate == "ChatConfigCheckBoxWithSwatchAndClassColorTemplate") then
			frame:SetTemplate("Transparent");
			for index, value in ipairs(checkBoxTable) do
				local checkBoxName = checkBoxNameString..index;
				local checkbox = _G[checkBoxName];
				if(not checkbox.backdrop) then
					checkbox:StripTextures();
					
					checkbox:CreateBackdrop();
					checkbox.backdrop:Point("TOPLEFT", 3, -1);
					checkbox.backdrop:Point("BOTTOMRIGHT", -3, 1);
					checkbox.backdrop:SetFrameLevel(checkbox:GetParent():GetFrameLevel() + 1);
					
					S:HandleCheckBox(_G[checkBoxName.."Check"]);
					
					if(checkBoxTemplate == "ChatConfigCheckBoxWithSwatchAndClassColorTemplate") then
						S:HandleCheckBox(_G[checkBoxName.."ColorClasses"]);
					end
				end
			end
		end
	end);
	
	S:SecureHook("ChatConfig_CreateTieredCheckboxes", function(frame, checkBoxTable, checkBoxTemplate, subCheckBoxTemplate)
		local checkBoxNameString = frame:GetName().."CheckBox";
		for index, value in ipairs(checkBoxTable) do
			local checkBoxName = checkBoxNameString..index;
			if(_G[checkBoxName]) then
				S:HandleCheckBox(_G[checkBoxName]);
				if(value.subTypes) then
					local subCheckBoxNameString = checkBoxName.."_";
					for k, v in ipairs(value.subTypes) do
						local subCheckBoxName = subCheckBoxNameString..k;
						if(_G[subCheckBoxName]) then
							S:HandleCheckBox(_G[subCheckBoxNameString..k]);
						end
					end
				end
			end
		end
	end);
	
	S:SecureHook("ChatConfig_CreateColorSwatches", function(frame, swatchTable, swatchTemplate)
		frame:SetTemplate("Transparent");
		local nameString = frame:GetName().."Swatch";
		for index, value in ipairs(swatchTable) do
			local swatchName = nameString..index;
			local swatch = _G[swatchName];
			if(not swatch.backdrop) then
				swatch:StripTextures();
				
				swatch:CreateBackdrop();
				swatch.backdrop:Point("TOPLEFT", 3, -1);
				swatch.backdrop:Point("BOTTOMRIGHT", -3, 1);
				swatch.backdrop:SetFrameLevel(swatch:GetParent():GetFrameLevel() + 1);
			end
		end
	end);

	--DROPDOWN MENU
	hooksecurefunc("UIDropDownMenu_InitializeHelper", function(frame)
		for i = 1, UIDROPDOWNMENU_MAXLEVELS do
			_G["DropDownList"..i.."Backdrop"]:SetTemplate("Default", true)
			_G["DropDownList"..i.."MenuBackdrop"]:SetTemplate("Default", true)
		end
	end)	
	
	local function SkinWatchFrameItems()
		for i=1, WATCHFRAME_NUM_ITEMS do
			local button = _G["WatchFrameItem"..i]
			if not button.skinned then
				button:CreateBackdrop('Default')
				button.backdrop:SetAllPoints()
				button:StyleButton()
				_G["WatchFrameItem"..i.."NormalTexture"]:SetAlpha(0)
				_G["WatchFrameItem"..i.."IconTexture"]:SetInside()
				_G["WatchFrameItem"..i.."IconTexture"]:SetTexCoord(unpack(E.TexCoords))
				E:RegisterCooldown(_G["WatchFrameItem"..i.."Cooldown"])
				button.skinned = true
			end
		end
	end
	
	WatchFrame:HookScript("OnEvent", SkinWatchFrameItems)

    local frames = {
        "VideoOptionsFrameCategoryFrame",
        "VideoOptionsFramePanelContainer",
		"VideoOptionsResolutionPanelBrightness",
		"AudioOptionsFrameCategoryFrame",
        "AudioOptionsFramePanelContainer",
        "InterfaceOptionsFrameCategories",
        "InterfaceOptionsFramePanelContainer",
        "InterfaceOptionsFrameAddOns",
		"AudioOptionsSoundPanelPlayback",
        "AudioOptionsSoundPanelVolume",
        "AudioOptionsSoundPanelHardware",
		"VideoOptionsEffectsPanelQuality",
		"VideoOptionsEffectsPanelShaders",
    }
    for i = 1, getn(frames) do
        local SkinFrames = _G[frames[i]]
        if SkinFrames then
            SkinFrames:StripTextures()
            SkinFrames:CreateBackdrop("Transparent")
            if SkinFrames ~= _G["VideoOptionsFramePanelContainer"] and SkinFrames ~= _G["InterfaceOptionsFramePanelContainer"] then
                SkinFrames.backdrop:Point("TOPLEFT",-1,0)
                SkinFrames.backdrop:Point("BOTTOMRIGHT",0,1)
            else
                SkinFrames.backdrop:Point("TOPLEFT", 0, 0)
                SkinFrames.backdrop:Point("BOTTOMRIGHT", 0, 0)
            end
        end
    end
    local interfacetab = {
        "InterfaceOptionsFrameTab1",
        "InterfaceOptionsFrameTab2",
    }
    for i = 1, getn(interfacetab) do
        local itab = _G[interfacetab[i]]
        if itab then
            itab:StripTextures()
            S:HandleTab(itab)
        end
    end
    InterfaceOptionsFrameTab1:ClearAllPoints()
    InterfaceOptionsFrameTab1:SetPoint("BOTTOMLEFT",InterfaceOptionsFrameCategories,"TOPLEFT",-11,-2)
    VideoOptionsFrameDefaults:ClearAllPoints()
    InterfaceOptionsFrameDefaults:ClearAllPoints()
    InterfaceOptionsFrameCancel:ClearAllPoints()
    VideoOptionsFrameDefaults:SetPoint("TOPLEFT",VideoOptionsFrameCategoryFrame,"BOTTOMLEFT",-1,-5)
    InterfaceOptionsFrameDefaults:SetPoint("TOPLEFT",InterfaceOptionsFrameCategories,"BOTTOMLEFT",-1,-5)
    InterfaceOptionsFrameCancel:SetPoint("TOPRIGHT",InterfaceOptionsFramePanelContainer,"BOTTOMRIGHT",0,-6)

    local interfacecheckbox = {
        "ControlsPanelStickyTargeting",
        "ControlsPanelAutoDismount",
        "ControlsPanelAutoClearAFK",
        "ControlsPanelBlockTrades",
        "ControlsPanelBlockGuildInvites",
        "ControlsPanelLootAtMouse",
        "ControlsPanelAutoLootCorpse",
        "CombatPanelAttackOnAssist",
        "CombatPanelAutoRange",
		"CombatPanelStopAutoAttack",
        "CombatPanelNameplateClassColors",
		"CombatPanelAutoSelfCast",
        "CombatPanelTargetOfTarget",
        "CombatPanelEnemyCastBarsOnPortrait",
        "CombatPanelEnemyCastBarsOnNameplates",
        "DisplayPanelShowCloak",
        "DisplayPanelShowHelm",
        "DisplayPanelShowAggroPercentage",
        "DisplayPanelPlayAggroSounds",
        "DisplayPanelDetailedLootInfo",
        "DisplayPanelShowFreeBagSpace",
        "DisplayPanelCinematicSubtitles",
        "DisplayPanelRotateMinimap",
        "DisplayPanelScreenEdgeFlash",
		"DisplayPanelShowClock",
		"DisplayPanelColorblindMode",
		"DisplayPanelShowItemLevel",
		"ObjectivesPanelInstantQuestText",
        "ObjectivesPanelAutoQuestTracking",
        "ObjectivesPanelAutoQuestProgress",
        "ObjectivesPanelMapQuestDifficulty",
        "ObjectivesPanelAdvancedWorldMap",
        "ObjectivesPanelWatchFrameWidth",
        "SocialPanelProfanityFilter",
        "SocialPanelSpamFilter",
        "SocialPanelChatBubbles",
        "SocialPanelPartyChat",
        "SocialPanelChatHoverDelay",
        "SocialPanelGuildMemberAlert",
		"SocialPanelGuildRecruitment",
        "SocialPanelChatMouseScroll",
        "SocialPanelWholeChatWindowClickable",
        "ActionBarsPanelLockActionBars",
        "ActionBarsPanelSecureAbilityToggle",
        "ActionBarsPanelAlwaysShowActionBars",
        "ActionBarsPanelBottomLeft",
        "ActionBarsPanelBottomRight",
        "ActionBarsPanelRight",
        "ActionBarsPanelRightTwo",
        "NamesPanelMyName",
        "NamesPanelFriendlyPlayerNames",
        "NamesPanelFriendlyPets",
        "NamesPanelFriendlyGuardians",
        "NamesPanelFriendlyTotems",
        "NamesPanelUnitNameplatesFriends",
        "NamesPanelUnitNameplatesFriendlyGuardians",
        "NamesPanelUnitNameplatesFriendlyPets",
        "NamesPanelUnitNameplatesFriendlyTotems",
        "NamesPanelGuilds",
		"NamesPanelNPCNames",
		"NamesPanelUnitNameplatesAllowOverlap",
        "NamesPanelTitles",
        "NamesPanelNonCombatCreature",
        "NamesPanelEnemyPlayerNames",
        "NamesPanelEnemyPets",
        "NamesPanelEnemyGuardians",
        "NamesPanelEnemyTotems",
        "NamesPanelUnitNameplatesEnemyPets",
        "NamesPanelUnitNameplatesEnemies",
        "NamesPanelUnitNameplatesEnemyGuardians",
        "NamesPanelUnitNameplatesEnemyTotems",
        "CombatTextPanelTargetDamage",
        "CombatTextPanelPeriodicDamage",
        "CombatTextPanelPetDamage",
        "CombatTextPanelHealing",
        "CombatTextPanelTargetEffects",
        "CombatTextPanelOtherTargetEffects",
        "CombatTextPanelEnableFCT",
        "CombatTextPanelDodgeParryMiss",
        "CombatTextPanelDamageReduction",
        "CombatTextPanelRepChanges",
        "CombatTextPanelReactiveAbilities",
        "CombatTextPanelFriendlyHealerNames",
        "CombatTextPanelCombatState",
        "CombatTextPanelComboPoints",
        "CombatTextPanelLowManaHealth",
        "CombatTextPanelEnergyGains",
        "CombatTextPanelPeriodicEnergyGains",
        "CombatTextPanelHonorGains",
        "CombatTextPanelAuras",
        "BuffsPanelBuffDurations",
        "BuffsPanelDispellableDebuffs",
        "BuffsPanelCastableBuffs",
        "BuffsPanelConsolidateBuffs",
        "BuffsPanelShowCastableDebuffs",
        "CameraPanelFollowTerrain",
        "CameraPanelHeadBob",
        "CameraPanelWaterCollision",
        "CameraPanelSmartPivot",
        "MousePanelInvertMouse",
        "MousePanelClickToMove",
        "MousePanelWoWMouse",
        "HelpPanelShowTutorials",
        "HelpPanelLoadingScreenTips",
        "HelpPanelEnhancedTooltips",
        "HelpPanelBeginnerTooltips",
        "HelpPanelShowLuaErrors",
        "StatusTextPanelPlayer",
        "StatusTextPanelPet",
        "StatusTextPanelParty",
        "StatusTextPanelTarget",
        "StatusTextPanelPercentages",
        "StatusTextPanelXP",
        "UnitFramePanelPartyBackground",
        "UnitFramePanelPartyPets",
        "UnitFramePanelArenaEnemyFrames",
        "UnitFramePanelArenaEnemyCastBar",
        "UnitFramePanelArenaEnemyPets",
		"UnitFramePanelPartyInRaid",
		"UnitFramePanelRaidRange",
        "UnitFramePanelFullSizeFocusFrame",
		"FeaturesPanelPreviewTalentChanges",
		"FeaturesPanelEquipmentManager",
    }
    for i = 1, getn(interfacecheckbox) do
        local icheckbox = _G["InterfaceOptions"..interfacecheckbox[i]]
        if icheckbox then
            S:HandleCheckBox(icheckbox)
        end
    end
    local interfacedropdown ={
        "ControlsPanelAutoLootKeyDropDown",
        "CombatPanelTOTDropDown",
        "CombatPanelFocusCastKeyDropDown",
        "CombatPanelSelfCastKeyDropDown",
        "DisplayPanelAggroWarningDisplay",
        "DisplayPanelWorldPVPObjectiveDisplay",
        "SocialPanelChatStyle",
        "SocialPanelTimestamps",
        "CombatTextPanelFCTDropDown",
        "CameraPanelStyleDropDown",
        "MousePanelClickMoveStyleDropDown",
    }
    for i = 1, getn(interfacedropdown) do
        local idropdown = _G["InterfaceOptions"..interfacedropdown[i]]
        if idropdown then
            S:HandleDropDownBox(idropdown)
            DropDownList1:SetTemplate("Transparent")
        end
    end
	
    S:HandleButton(InterfaceOptionsHelpPanelResetTutorials)
	
    local optioncheckbox = {
        "AudioOptionsSoundPanelEnableSound",
        "AudioOptionsSoundPanelSoundEffects",
        "AudioOptionsSoundPanelErrorSpeech",
        "AudioOptionsSoundPanelEmoteSounds",
        "AudioOptionsSoundPanelPetSounds",
        "AudioOptionsSoundPanelMusic",
        "AudioOptionsSoundPanelLoopMusic",
        "AudioOptionsSoundPanelAmbientSounds",
        "AudioOptionsSoundPanelSoundInBG",
        "AudioOptionsSoundPanelReverb",
        "AudioOptionsSoundPanelHRTF",
        "AudioOptionsSoundPanelEnableDSPs",
        "AudioOptionsSoundPanelUseHardware",
		"VideoOptionsResolutionPanelVSync",
		"VideoOptionsResolutionPanelTripleBuffer",
		"VideoOptionsResolutionPanelHardwareCursor",
		"VideoOptionsResolutionPanelFixInputLag",
		"VideoOptionsResolutionPanelUseUIScale",
		"VideoOptionsResolutionPanelWindowed",
		"VideoOptionsResolutionPanelMaximized",
		"VideoOptionsResolutionPanelDisableResize",
		"VideoOptionsResolutionPanelDesktopGamma",
		"VideoOptionsEffectsPanelSpecularLighting",
		"VideoOptionsEffectsPanelFullScreenGlow",
		"VideoOptionsEffectsPanelDeathEffect",
		"VideoOptionsEffectsPanelProjectedTextures",
    }
    for i = 1, getn(optioncheckbox) do
        local ocheckbox = _G[optioncheckbox[i]]
        if ocheckbox then
            S:HandleCheckBox(ocheckbox)
        end
    end
    local optiondropdown = {
        "VideoOptionsResolutionPanelResolutionDropDown",
        "VideoOptionsResolutionPanelRefreshDropDown",
        "VideoOptionsResolutionPanelMultiSampleDropDown",
        "AudioOptionsSoundPanelHardwareDropDown",
    }
    for i = 1, getn(optiondropdown) do
        local odropdown = _G[optiondropdown[i]]
        if odropdown then
            S:HandleDropDownBox(odropdown,165)
            DropDownList1:SetTemplate("Transparent")
        end
    end
	
	local sliders = {
		"VideoOptionsResolutionPanelUIScaleSlider",
		"VideoOptionsEffectsPanelQualitySlider",
		"VideoOptionsEffectsPanelViewDistance",
		"VideoOptionsEffectsPanelEnvironmentDetail",
		"VideoOptionsEffectsPanelTextureResolution",
		"VideoOptionsEffectsPanelTerrainDetail",
		"VideoOptionsEffectsPanelClutterDensity",
		"VideoOptionsEffectsPanelTextureFiltering",
		"VideoOptionsEffectsPanelParticleDensity",
		"VideoOptionsEffectsPanelShadowQuality",
		"VideoOptionsEffectsPanelClutterRadius",
		"VideoOptionsEffectsPanelWeatherIntensity",
		"VideoOptionsEffectsPanelPlayerTexture",
		"VideoOptionsResolutionPanelGammaSlider",
		"AudioOptionsSoundPanelSoundQuality",
		"AudioOptionsSoundPanelSoundChannels",
		"AudioOptionsSoundPanelMasterVolume",
		"AudioOptionsSoundPanelSoundVolume",
		"AudioOptionsSoundPanelMusicVolume",
		"AudioOptionsSoundPanelAmbienceVolume",
		"InterfaceOptionsCameraPanelMaxDistanceSlider",
		"InterfaceOptionsCameraPanelFollowSpeedSlider",
		"InterfaceOptionsMousePanelMouseLookSpeedSlider",
		"InterfaceOptionsMousePanelMouseSensitivitySlider",
	}

	for _, slider in pairs(sliders) do
		S:HandleSliderFrame(_G[slider])
	end
end

S:RegisterSkin('ElvUI', LoadSkin)