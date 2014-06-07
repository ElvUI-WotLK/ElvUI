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
		-- Skin main frame and reposition the header
		MacOptionsFrame:SetTemplate("Default", true)
		MacOptionsFrameHeader:SetTexture("")
		MacOptionsFrameHeader:ClearAllPoints()
		MacOptionsFrameHeader:SetPoint("TOP", MacOptionsFrame, 0, 0)
 
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

	end
	
	OpacityFrame:StripTextures()
	OpacityFrame:SetTemplate("Transparent")	
	
	WatchFrameCollapseExpandButton:StripTextures()
	S:HandleCloseButton(WatchFrameCollapseExpandButton)
	WatchFrameCollapseExpandButton:Size(30)
	WatchFrameCollapseExpandButton.text:SetText('-')
	WatchFrameCollapseExpandButton:SetFrameStrata('MEDIUM')
	
	hooksecurefunc('WatchFrame_Expand', function()
		WatchFrameCollapseExpandButton.text:SetText('-')
	end)
	
	hooksecurefunc('WatchFrame_Collapse', function()
		WatchFrameCollapseExpandButton.text:SetText('+')
	end)	
	
	--Chat Config
	local StripAllTextures = {
		"ChatConfigFrame",
		"ChatConfigBackgroundFrame",
		"ChatConfigCategoryFrame",
		"ChatConfigChatSettingsClassColorLegend",
		"ChatConfigChatSettingsLeft",
		"ChatConfigChannelSettingsLeft",
		"ChatConfigChannelSettingsClassColorLegend",
		"ChatConfigOtherSettingsCombat",
		"ChatConfigOtherSettingsPVP",
		"ChatConfigOtherSettingsSystem",
		"ChatConfigOtherSettingsCreature",
		"ChatConfigCombatSettingsFilters",
		"CombatConfigMessageSourcesDoneBy",
		"CombatConfigMessageSourcesDoneTo",
		"CombatConfigColorsUnitColors",
		"CombatConfigColorsHighlighting",
		"CombatConfigColorsColorizeUnitName",
		"CombatConfigColorsColorizeSpellNames",
		"CombatConfigColorsColorizeDamageNumber",
		"CombatConfigColorsColorizeDamageSchool",
		"CombatConfigColorsColorizeEntireLine",
	}
			
	for _, object in pairs(StripAllTextures) do
		_G[object]:StripTextures()
	end
			
	ChatConfigFrame:SetTemplate("Transparent")
	ChatConfigBackgroundFrame:SetTemplate("Transparent")
	ChatConfigCategoryFrame:SetTemplate("Transparent")
	ChatConfigCombatSettingsFilters:SetTemplate("Transparent")
	ChatConfigChannelSettingsClassColorLegend:SetTemplate("Transparent")
	ChatConfigChatSettingsClassColorLegend:SetTemplate("Transparent")
	
	local chatbuttons = {
		"ChatConfigFrameDefaultButton",
		"ChatConfigFrameOkayButton",
		"CombatLogDefaultButton",
		"ChatConfigCombatSettingsFiltersCopyFilterButton",
		"ChatConfigCombatSettingsFiltersAddFilterButton",
		"ChatConfigCombatSettingsFiltersDeleteButton",
		"CombatConfigSettingsSaveButton",
		"ChatConfigFrameCancelButton",
	}
			
	for i = 1, #chatbuttons do
		S:HandleButton(_G[chatbuttons[i]], true)
	end	
	
	ChatConfigFrameOkayButton:Point("RIGHT", ChatConfigFrameCancelButton, "RIGHT", -11, -1)
	ChatConfigCombatSettingsFiltersDeleteButton:Point("TOPRIGHT", ChatConfigCombatSettingsFilters, "BOTTOMRIGHT", 0, -1)
	ChatConfigCombatSettingsFiltersAddFilterButton:Point("RIGHT", ChatConfigCombatSettingsFiltersDeleteButton, "LEFT", -1, 0)
	ChatConfigCombatSettingsFiltersCopyFilterButton:Point("RIGHT", ChatConfigCombatSettingsFiltersAddFilterButton, "LEFT", -1, 0)
	
	for i=1, 5 do
		local tab = _G["CombatConfigTab"..i]
		tab:StripTextures()
	end
	
	S:HandleEditBox(CombatConfigSettingsNameEditBox)
	
    local frames = {
		"ChatConfigFrame",
		"ChatConfigCategoryFrame",
		"ChatConfigBackgroundFrame",
		"ChatConfigChatSettingsClassColorLegend",
		"ChatConfigChannelSettingsClassColorLegend",
		"ChatConfigCombatSettingsFilters",
		"ChatConfigCombatSettingsFiltersScrollFrame",
		"CombatConfigColorsHighlighting",
		"CombatConfigColorsColorizeUnitName",
		"CombatConfigColorsColorizeSpellNames",
		"CombatConfigColorsColorizeDamageNumber",
		"CombatConfigColorsColorizeDamageSchool",
		"CombatConfigColorsColorizeEntireLine",
		"ChatConfigChatSettingsLeft",
		"ChatConfigOtherSettingsCombat",
		"ChatConfigOtherSettingsPVP",
		"ChatConfigOtherSettingsSystem",
		"ChatConfigOtherSettingsCreature",
		"ChatConfigChannelSettingsLeft",
		"CombatConfigMessageSourcesDoneBy",
		"CombatConfigMessageSourcesDoneTo",
		"CombatConfigColorsUnitColors",
    }
	
    for i = 1, getn(frames) do
        local SkinFrames = _G[frames[i]]
        SkinFrames:StripTextures()
        SkinFrames:SetTemplate("Transparent")
    end
	
    local otherframe = {
		"CombatConfigColorsColorizeSpellNames",
		"CombatConfigColorsColorizeDamageNumber",
		"CombatConfigColorsColorizeDamageSchool",
		"CombatConfigColorsColorizeEntireLine",
    }

    for i = 1, getn(otherframe) do
        local SkinFrames = _G[otherframe[i]]
        SkinFrames:ClearAllPoints()
        if SkinFrames == CombatConfigColorsColorizeSpellNames then
            SkinFrames:Point("TOP",CombatConfigColorsColorizeUnitName,"BOTTOM",0,-2)
        else
            SkinFrames:Point("TOP",_G[otherframe[i-1]],"BOTTOM",0,-2)
        end
    end
	
	-- >> Chat >> Channel Settings      /!\ I don't know why, but the skin works only after /reload ui, not at first login =(
    ChatConfigChannelSettingsLeft:RegisterEvent("PLAYER_ENTERING_WORLD")
    ChatConfigChannelSettingsLeft:SetScript("OnEvent", function(self, event)
        ChatConfigChannelSettingsLeft:UnregisterEvent("PLAYER_ENTERING_WORLD")
        for i = 1,#ChatConfigChannelSettingsLeft.checkBoxTable do
            _G["ChatConfigChannelSettingsLeftCheckBox"..i]:StripTextures()
            _G["ChatConfigChannelSettingsLeftCheckBox"..i]:CreateBackdrop()
            _G["ChatConfigChannelSettingsLeftCheckBox"..i].backdrop:Point("TOPLEFT",3,-1)
            _G["ChatConfigChannelSettingsLeftCheckBox"..i].backdrop:Point("BOTTOMRIGHT",-3,1)
            _G["ChatConfigChannelSettingsLeftCheckBox"..i]:SetHeight(ChatConfigOtherSettingsCombatCheckBox1:GetHeight())
            S:HandleCheckBox(_G["ChatConfigChannelSettingsLeftCheckBox"..i.."Check"])
            S:HandleCheckBox(_G["ChatConfigChannelSettingsLeftCheckBox"..i.."ColorClasses"])
            _G["ChatConfigChannelSettingsLeftCheckBox"..i.."ColorClasses"]:SetHeight(ChatConfigChatSettingsLeftCheckBox1Check:GetHeight())
        end
    end)
    
	--Makes the skin work, but only after /reload ui :o   (found in chatconfingframe.xml)
    CreateChatChannelList(self, GetChannelList())
    ChatConfig_CreateCheckboxes(ChatConfigChannelSettingsLeft, CHAT_CONFIG_CHANNEL_LIST, "ChatConfigCheckBoxWithSwatchAndClassColorTemplate", CHANNELS)
    ChatConfig_UpdateCheckboxes(ChatConfigChannelSettingsLeft)
    ChatConfigBackgroundFrame:SetScript("OnShow", function(self)
		-- >> Chat >> Chat Settings
        for i = 1,#CHAT_CONFIG_CHAT_LEFT do
            _G["ChatConfigChatSettingsLeftCheckBox"..i]:StripTextures()
            _G["ChatConfigChatSettingsLeftCheckBox"..i]:CreateBackdrop()
            _G["ChatConfigChatSettingsLeftCheckBox"..i].backdrop:Point("TOPLEFT",3,-1)
            _G["ChatConfigChatSettingsLeftCheckBox"..i].backdrop:Point("BOTTOMRIGHT",-3,1)
            _G["ChatConfigChatSettingsLeftCheckBox"..i]:SetHeight(ChatConfigOtherSettingsCombatCheckBox1:GetHeight())
            S:HandleCheckBox(_G["ChatConfigChatSettingsLeftCheckBox"..i.."Check"])
            S:HandleCheckBox(_G["ChatConfigChatSettingsLeftCheckBox"..i.."ColorClasses"])
            _G["ChatConfigChatSettingsLeftCheckBox"..i.."ColorClasses"]:SetHeight(ChatConfigChatSettingsLeftCheckBox1Check:GetHeight())
        end
		-- >> Other >> Combat
        for i = 1,#CHAT_CONFIG_OTHER_COMBAT do
            _G["ChatConfigOtherSettingsCombatCheckBox"..i]:StripTextures()
            _G["ChatConfigOtherSettingsCombatCheckBox"..i]:CreateBackdrop()
            _G["ChatConfigOtherSettingsCombatCheckBox"..i].backdrop:Point("TOPLEFT",3,-1)
            _G["ChatConfigOtherSettingsCombatCheckBox"..i].backdrop:Point("BOTTOMRIGHT",-3,1)
            S:HandleCheckBox(_G["ChatConfigOtherSettingsCombatCheckBox"..i.."Check"])
        end
		-- >> Other >> PvP
        for i = 1,#CHAT_CONFIG_OTHER_PVP do
            _G["ChatConfigOtherSettingsPVPCheckBox"..i]:StripTextures()
            _G["ChatConfigOtherSettingsPVPCheckBox"..i]:CreateBackdrop()
            _G["ChatConfigOtherSettingsPVPCheckBox"..i].backdrop:Point("TOPLEFT",3,-1)
            _G["ChatConfigOtherSettingsPVPCheckBox"..i].backdrop:Point("BOTTOMRIGHT",-3,1)
            S:HandleCheckBox(_G["ChatConfigOtherSettingsPVPCheckBox"..i.."Check"])
        end
		-- >> Other >> System
        for i = 1,#CHAT_CONFIG_OTHER_SYSTEM do
            _G["ChatConfigOtherSettingsSystemCheckBox"..i]:StripTextures()
            _G["ChatConfigOtherSettingsSystemCheckBox"..i]:CreateBackdrop()
            _G["ChatConfigOtherSettingsSystemCheckBox"..i].backdrop:Point("TOPLEFT",3,-1)
            _G["ChatConfigOtherSettingsSystemCheckBox"..i].backdrop:Point("BOTTOMRIGHT",-3,1)
            S:HandleCheckBox(_G["ChatConfigOtherSettingsSystemCheckBox"..i.."Check"])
        end
		-- >> Other >> Creatures
        for i = 1,#CHAT_CONFIG_CHAT_CREATURE_LEFT do
            _G["ChatConfigOtherSettingsCreatureCheckBox"..i]:StripTextures()
            _G["ChatConfigOtherSettingsCreatureCheckBox"..i]:CreateBackdrop()
            _G["ChatConfigOtherSettingsCreatureCheckBox"..i].backdrop:Point("TOPLEFT",3,-1)
            _G["ChatConfigOtherSettingsCreatureCheckBox"..i].backdrop:Point("BOTTOMRIGHT",-3,1)
            S:HandleCheckBox(_G["ChatConfigOtherSettingsCreatureCheckBox"..i.."Check"])
        end
		-- >> Sources >> DoneBy
        for i = 1,#COMBAT_CONFIG_MESSAGESOURCES_BY do
            _G["CombatConfigMessageSourcesDoneByCheckBox"..i]:StripTextures()
            _G["CombatConfigMessageSourcesDoneByCheckBox"..i]:CreateBackdrop()
            _G["CombatConfigMessageSourcesDoneByCheckBox"..i].backdrop:Point("TOPLEFT",3,-1)
            _G["CombatConfigMessageSourcesDoneByCheckBox"..i].backdrop:Point("BOTTOMRIGHT",-3,1)
            S:HandleCheckBox(_G["CombatConfigMessageSourcesDoneByCheckBox"..i.."Check"])
        end
		-- >> Sources >> DoneTo
        for i = 1,#COMBAT_CONFIG_MESSAGESOURCES_TO do
            _G["CombatConfigMessageSourcesDoneToCheckBox"..i]:StripTextures()
            _G["CombatConfigMessageSourcesDoneToCheckBox"..i]:CreateBackdrop()
            _G["CombatConfigMessageSourcesDoneToCheckBox"..i].backdrop:Point("TOPLEFT",3,-1)
            _G["CombatConfigMessageSourcesDoneToCheckBox"..i].backdrop:Point("BOTTOMRIGHT",-3,1)
            S:HandleCheckBox(_G["CombatConfigMessageSourcesDoneToCheckBox"..i.."Check"])
        end
		-- >> Combat >> Colors >> Unit Colors
        for i = 1,#COMBAT_CONFIG_UNIT_COLORS do
            _G["CombatConfigColorsUnitColorsSwatch"..i]:StripTextures()
            _G["CombatConfigColorsUnitColorsSwatch"..i]:CreateBackdrop()
            _G["CombatConfigColorsUnitColorsSwatch"..i].backdrop:Point("TOPLEFT",3,-1)
            _G["CombatConfigColorsUnitColorsSwatch"..i].backdrop:Point("BOTTOMRIGHT",-3,1)
        end
		-- >> Combat >> Messages Types
        for i=1,4 do
            for j=1,4 do
                if _G["CombatConfigMessageTypesLeftCheckBox"..i] and _G["CombatConfigMessageTypesLeftCheckBox"..i.."_"..j] then
                    S:HandleCheckBox(_G["CombatConfigMessageTypesLeftCheckBox"..i])
                    S:HandleCheckBox(_G["CombatConfigMessageTypesLeftCheckBox"..i.."_"..j])
                end
            end
            for j=1,10 do
                if _G["CombatConfigMessageTypesRightCheckBox"..i] and _G["CombatConfigMessageTypesRightCheckBox"..i.."_"..j] then
                    S:HandleCheckBox(_G["CombatConfigMessageTypesRightCheckBox"..i])
                    S:HandleCheckBox(_G["CombatConfigMessageTypesRightCheckBox"..i.."_"..j])
                end
            end
            S:HandleCheckBox(_G["CombatConfigMessageTypesMiscCheckBox"..i])
        end
    end)
-- >> Combat >> Tabs
    for i = 1,#COMBAT_CONFIG_TABS do
        local cctab = _G["CombatConfigTab"..i]
        if cctab then
            S:HandleTab(cctab)
            cctab:SetHeight(cctab:GetHeight()-2)
            cctab:SetWidth(ceil(cctab:GetWidth()+1.6))
            _G["CombatConfigTab"..i.."Text"]:SetPoint("BOTTOM",0,10)
        end
    end
    CombatConfigTab1:ClearAllPoints()
    CombatConfigTab1:SetPoint("BOTTOMLEFT",ChatConfigBackgroundFrame,"TOPLEFT",6,-2)
   
   local ccbuttons = {
		"ChatConfigFrameOkayButton",
		"ChatConfigFrameDefaultButton",
		"CombatLogDefaultButton",
		"ChatConfigCombatSettingsFiltersDeleteButton",
		"ChatConfigCombatSettingsFiltersAddFilterButton",
		"ChatConfigCombatSettingsFiltersCopyFilterButton",
		"CombatConfigSettingsSaveButton",
    }
   
   for i = 1, getn(ccbuttons) do
        local ccbtn = _G[ccbuttons[i]]
        if ccbtn then
			S:HandleButton(ccbtn)

        end
    end
    
	ChatConfigFrameOkayButton:SetPoint("TOPRIGHT",ChatConfigBackgroundFrame,"BOTTOMRIGHT",-3,-5)
    ChatConfigFrameDefaultButton:SetPoint("TOPLEFT",ChatConfigCategoryFrame,"BOTTOMLEFT",1,-5)
    CombatLogDefaultButton:SetPoint("TOPLEFT",ChatConfigCategoryFrame,"BOTTOMLEFT",1,-5)
    ChatConfigCombatSettingsFiltersDeleteButton:SetPoint("TOPRIGHT",ChatConfigCombatSettingsFilters,"BOTTOMRIGHT",-3,-1)
    ChatConfigCombatSettingsFiltersCopyFilterButton:SetPoint("RIGHT",ChatConfigCombatSettingsFiltersDeleteButton,"LEFT",-2,0)
    ChatConfigCombatSettingsFiltersAddFilterButton:SetPoint("RIGHT",ChatConfigCombatSettingsFiltersCopyFilterButton,"LEFT",-2,0)
   
   local cccheckbox = {
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
		"CombatConfigSettingsRaid",
    }
    for i = 1, getn(cccheckbox) do
		local ccbtn = _G[cccheckbox[i]]
        S:HandleCheckBox(ccbtn)
    end
	
    S:HandleNextPrevButton(ChatConfigMoveFilterUpButton,true)
    S:HandleNextPrevButton(ChatConfigMoveFilterDownButton,true)
    ChatConfigMoveFilterUpButton:ClearAllPoints()
    ChatConfigMoveFilterDownButton:ClearAllPoints()
    ChatConfigMoveFilterUpButton:SetPoint("TOPLEFT",ChatConfigCombatSettingsFilters,"BOTTOMLEFT",3,0)
    ChatConfigMoveFilterDownButton:SetPoint("LEFT",ChatConfigMoveFilterUpButton,24,0)
    S:HandleEditBox(CombatConfigSettingsNameEditBox)
    ChatConfigFrame:Size(680,596)
    ChatConfigFrameHeader:ClearAllPoints()
    ChatConfigFrameHeader:SetPoint("TOP", ChatConfigFrame, 0, -5)

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