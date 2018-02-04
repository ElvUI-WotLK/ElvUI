local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local ipairs = ipairs
local find = string.find

local InCombatLockdown = InCombatLockdown
local IsShiftKeyDown = IsShiftKeyDown

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.BlizzardOptions ~= true then return end

	-- Game Menu Interface/Tabs
	for i = 1, 2 do
		local tab = _G["InterfaceOptionsFrameTab"..i]

		tab:StripTextures()
		S:HandleTab(tab)

		tab.backdrop:SetTemplate("Transparent")
		tab.backdrop:Point("TOPLEFT", 10, E.PixelMode and -4 or -6)
		tab.backdrop:Point("BOTTOMRIGHT", -10, 1)
	end

	InterfaceOptionsFrameTab1:ClearAllPoints()
	InterfaceOptionsFrameTab1:SetPoint("BOTTOMLEFT", InterfaceOptionsFrameCategories, "TOPLEFT", -11, -2)

	-- Game Menu Plus / Minus Buttons
	local maxButtons = (InterfaceOptionsFrameAddOns:GetHeight() - 8) / InterfaceOptionsFrameAddOns.buttonHeight
	for i = 1, maxButtons do
		local buttonToggle = _G["InterfaceOptionsFrameAddOnsButton"..i.."Toggle"]
		buttonToggle:SetNormalTexture("")
		buttonToggle.SetNormalTexture = E.noop
		buttonToggle:SetPushedTexture("")
		buttonToggle.SetPushedTexture = E.noop
		buttonToggle:SetHighlightTexture(nil)

		buttonToggle.Text = buttonToggle:CreateFontString(nil, "OVERLAY")
		buttonToggle.Text:FontTemplate(nil, 22)
		buttonToggle.Text:Point("CENTER")
		buttonToggle.Text:SetText("+")

		hooksecurefunc(buttonToggle, "SetNormalTexture", function(self, texture)
			if find(texture, "MinusButton") then
				self.Text:SetText("-")
			else
				self.Text:SetText("+")
			end
		end)
	end

	-- Interface Options Frame
	InterfaceOptionsFrame:SetTemplate("Transparent")
	InterfaceOptionsFrame:SetClampedToScreen(true)
	InterfaceOptionsFrame:SetMovable(true)
	InterfaceOptionsFrame:EnableMouse(true)
	InterfaceOptionsFrame:RegisterForDrag("LeftButton", "RightButton")
	InterfaceOptionsFrame:SetScript("OnDragStart", function(self)
		if InCombatLockdown() then return end

		self:StartMoving()
		self.isMoving = true
	end)
	InterfaceOptionsFrame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		self.isMoving = false
	end)

	VideoOptionsFrame:SetTemplate("Transparent")

	AudioOptionsFrame:SetTemplate("Transparent")

	S:HandleButton(VideoOptionsFrameDefaults)
	VideoOptionsFrameDefaults:ClearAllPoints()
	VideoOptionsFrameDefaults:SetPoint("TOPLEFT", VideoOptionsFrameCategoryFrame, "BOTTOMLEFT", -1, -5)

	S:HandleButton(InterfaceOptionsFrameDefaults)
	InterfaceOptionsFrameDefaults:ClearAllPoints()
	InterfaceOptionsFrameDefaults:SetPoint("TOPLEFT", InterfaceOptionsFrameCategories, "BOTTOMLEFT", -1, -5)

	S:HandleButton(InterfaceOptionsFrameCancel)
	InterfaceOptionsFrameCancel:ClearAllPoints()
	InterfaceOptionsFrameCancel:SetPoint("TOPRIGHT", InterfaceOptionsFramePanelContainer, "BOTTOMRIGHT", 0, -6)

	S:HandleButton(VideoOptionsFrameApply)

	S:HandleButton(VideoOptionsFrameCancel)
	VideoOptionsFrameCancel:ClearAllPoints()
	VideoOptionsFrameCancel:SetPoint("RIGHT", VideoOptionsFrameApply, "LEFT", -4, 0)

	S:HandleButton(VideoOptionsFrameOkay)
	VideoOptionsFrameOkay:ClearAllPoints()
	VideoOptionsFrameOkay:SetPoint("RIGHT", VideoOptionsFrameCancel, "LEFT", -4, 0)

	S:HandleButton(AudioOptionsFrameDefaults)
	S:HandleButton(AudioOptionsFrameCancel)

	S:HandleButton(AudioOptionsFrameOkay)
	AudioOptionsFrameOkay:ClearAllPoints()
	AudioOptionsFrameOkay:SetPoint("RIGHT", AudioOptionsFrameCancel, "LEFT", -4, 0)

	S:HandleButton(InterfaceOptionsFrameOkay)
	InterfaceOptionsFrameOkay:ClearAllPoints()
	InterfaceOptionsFrameOkay:SetPoint("RIGHT",InterfaceOptionsFrameCancel, "LEFT", -4, 0)

	local BlizzardHeader = {
		"InterfaceOptionsFrame",
		"AudioOptionsFrame",
		"VideoOptionsFrame",
	}

	for i = 1, #BlizzardHeader do
		local title = _G[BlizzardHeader[i].."Header"]
		if title then
			title:SetTexture("")
			title:ClearAllPoints()
			title:SetPoint("TOP", BlizzardHeader[i], 0, 0)
		end
	end

	InterfaceOptionsFrameCategoriesList:StripTextures()
	InterfaceOptionsFrameAddOnsList:StripTextures()

	S:HandleScrollBar(InterfaceOptionsFrameCategoriesListScrollBar)
	S:HandleScrollBar(InterfaceOptionsFrameAddOnsListScrollBar)

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
	for i = 1, #frames do
		local SkinFrames = _G[frames[i]]
		if SkinFrames then
			SkinFrames:StripTextures()
			SkinFrames:CreateBackdrop("Transparent")
			if SkinFrames ~= _G["VideoOptionsFramePanelContainer"] and SkinFrames ~= _G["InterfaceOptionsFramePanelContainer"] then
				SkinFrames.backdrop:Point("TOPLEFT", -1 ,0)
				SkinFrames.backdrop:Point("BOTTOMRIGHT", 0, 1)
			else
				SkinFrames.backdrop:Point("TOPLEFT", 0, 0)
				SkinFrames.backdrop:Point("BOTTOMRIGHT", 0, 0)
			end
		end
	end

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
	for i = 1, #interfacecheckbox do
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
		"LanguagesPanelLocaleDropDown"
	}
	for i = 1, #interfacedropdown do
		local idropdown = _G["InterfaceOptions"..interfacedropdown[i]]
		if idropdown then
			S:HandleDropDownBox(idropdown)
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
	for i = 1, #optioncheckbox do
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
	for i = 1, #optiondropdown do
		local odropdown = _G[optiondropdown[i]]
		if odropdown then
			S:HandleDropDownBox(odropdown, i == 3 and 195 or 165)
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

	-- Mac Menu
	if IsMacClient() then
		S:HandleButton(GameMenuButtonMacOptions)

		-- Skin main frame and reposition the header
		MacOptionsFrame:SetTemplate("Default", true)
		MacOptionsFrameHeader:SetTexture("")
		MacOptionsFrameHeader:ClearAllPoints()
		MacOptionsFrameHeader:SetPoint("TOP", MacOptionsFrame, 0, 0)

		S:HandleDropDownBox(MacOptionsFrameResolutionDropDown)
		S:HandleDropDownBox(MacOptionsFrameFramerateDropDown)
		S:HandleDropDownBox(MacOptionsFrameCodecDropDown)

		S:HandleSliderFrame(MacOptionsFrameQualitySlider)

		for i = 1, 8 do
			S:HandleCheckBox(_G["MacOptionsFrameCheckButton"..i])
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
		local tPoint, tRTo, tRP, _, tY = MacOptionsButtonCompress:GetPoint()
		MacOptionsButtonCompress:SetWidth(136)
		MacOptionsButtonCompress:ClearAllPoints()
		MacOptionsButtonCompress:Point(tPoint, tRTo, tRP, 4, tY)

		MacOptionsFrameCancel:SetWidth(96)
		MacOptionsFrameCancel:SetHeight(22)
		tPoint, tRTo, tRP, _, tY = MacOptionsFrameCancel:GetPoint()
		MacOptionsFrameCancel:ClearAllPoints()
		MacOptionsFrameCancel:Point(tPoint, tRTo, tRP, -14, tY)

		MacOptionsFrameOkay:ClearAllPoints()
		MacOptionsFrameOkay:SetWidth(96)
		MacOptionsFrameOkay:SetHeight(22)
		MacOptionsFrameOkay:Point("LEFT",MacOptionsFrameCancel, -99, 0)

		MacOptionsButtonKeybindings:ClearAllPoints()
		MacOptionsButtonKeybindings:SetWidth(96)
		MacOptionsButtonKeybindings:SetHeight(22)
		MacOptionsButtonKeybindings:Point("LEFT",MacOptionsFrameOkay, -99, 0)

		MacOptionsFrameDefaults:SetWidth(96)
		MacOptionsFrameDefaults:SetHeight(22)

		MacOptionsCompressFrame:SetTemplate("Default", true)

		MacOptionsCompressFrameHeader:SetTexture("")
		MacOptionsCompressFrameHeader:ClearAllPoints()
		MacOptionsCompressFrameHeader:SetPoint("TOP", MacOptionsCompressFrame, 0, 0)

		S:HandleButton(MacOptionsCompressFrameDelete)
		S:HandleButton(MacOptionsCompressFrameSkip)
		S:HandleButton(MacOptionsCompressFrameCompress)

		MacOptionsCancelFrame:SetTemplate("Default", true)

		MacOptionsCancelFrameHeader:SetTexture("")
		MacOptionsCancelFrameHeader:ClearAllPoints()
		MacOptionsCancelFrameHeader:SetPoint("TOP", MacOptionsCancelFrame, 0, 0)

		S:HandleButton(MacOptionsCancelFrameNo)
		S:HandleButton(MacOptionsCancelFrameYes)
	end

	-- Chat Config
	ChatConfigFrame:StripTextures()
	ChatConfigFrame:SetTemplate("Transparent")
	ChatConfigCategoryFrame:SetTemplate("Transparent")
	ChatConfigBackgroundFrame:SetTemplate("Transparent")

	ChatConfigChatSettingsClassColorLegend:SetTemplate("Transparent")
	ChatConfigChannelSettingsClassColorLegend:SetTemplate("Transparent")

	ChatConfigCombatSettingsFilters:SetTemplate("Transparent")

	ChatConfigCombatSettingsFiltersScrollFrame:StripTextures()

	S:HandleScrollBar(ChatConfigCombatSettingsFiltersScrollFrameScrollBar)
	ChatConfigCombatSettingsFiltersScrollFrameScrollBarBorder:Kill()

	S:HandleButton(ChatConfigCombatSettingsFiltersDeleteButton)
	ChatConfigCombatSettingsFiltersDeleteButton:Point("TOPRIGHT", ChatConfigCombatSettingsFilters, "BOTTOMRIGHT", 0, -1)

	S:HandleButton(ChatConfigCombatSettingsFiltersAddFilterButton)
	ChatConfigCombatSettingsFiltersAddFilterButton:Point("RIGHT", ChatConfigCombatSettingsFiltersDeleteButton, "LEFT", -1, 0)

	S:HandleButton(ChatConfigCombatSettingsFiltersCopyFilterButton)
	ChatConfigCombatSettingsFiltersCopyFilterButton:Point("RIGHT", ChatConfigCombatSettingsFiltersAddFilterButton, "LEFT", -1, 0)

	S:HandleNextPrevButton(ChatConfigMoveFilterUpButton, true)
	S:SquareButton_SetIcon(ChatConfigMoveFilterUpButton, "UP")
	ChatConfigMoveFilterUpButton:Size(26)
	ChatConfigMoveFilterUpButton:Point("TOPLEFT", ChatConfigCombatSettingsFilters, "BOTTOMLEFT", 3, -1)
	ChatConfigMoveFilterUpButton:SetHitRectInsets(0, 0, 0, 0)

	S:HandleNextPrevButton(ChatConfigMoveFilterDownButton, true)
	ChatConfigMoveFilterDownButton:Size(26)
	ChatConfigMoveFilterDownButton:Point("LEFT", ChatConfigMoveFilterUpButton, "RIGHT", 1, 0)
	ChatConfigMoveFilterDownButton:SetHitRectInsets(0, 0, 0, 0)

	CombatConfigColorsHighlighting:StripTextures()
	CombatConfigColorsColorizeUnitName:StripTextures()
	CombatConfigColorsColorizeSpellNames:StripTextures()

	CombatConfigColorsColorizeDamageNumber:StripTextures()
	CombatConfigColorsColorizeDamageSchool:StripTextures()
	CombatConfigColorsColorizeEntireLine:StripTextures()

	S:HandleEditBox(CombatConfigSettingsNameEditBox)

	S:HandleButton(CombatConfigSettingsSaveButton)

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
	}

	for i = 1, #combatConfigCheck do
		S:HandleCheckBox(_G[combatConfigCheck[i]])
	end

	for i = 1, 5 do
		local tab = _G["CombatConfigTab"..i]

		tab:StripTextures()
		tab:CreateBackdrop("Default", true)
		tab.backdrop:Point("TOPLEFT", 1, -10)
		tab.backdrop:Point("BOTTOMRIGHT", -1, 2)

		tab:HookScript("OnEnter", S.SetModifiedBackdrop)
		tab:HookScript("OnLeave", S.SetOriginalBackdrop)
	end

	S:HandleButton(ChatConfigFrameDefaultButton)
	ChatConfigFrameDefaultButton:Point("BOTTOMLEFT", 12, 8)
	ChatConfigFrameDefaultButton:Width(125)

	S:HandleButton(CombatLogDefaultButton)

	S:HandleButton(ChatConfigFrameCancelButton)
	ChatConfigFrameCancelButton:Point("BOTTOMRIGHT", -11, 8)

	S:HandleButton(ChatConfigFrameOkayButton)

	S:SecureHook("ChatConfig_CreateCheckboxes", function(frame, checkBoxTable, checkBoxTemplate)
		local checkBoxNameString = frame:GetName().."CheckBox"
		if checkBoxTemplate == "ChatConfigCheckBoxTemplate" then
			frame:SetTemplate("Transparent")
			for index, _ in ipairs(checkBoxTable) do
				local checkBoxName = checkBoxNameString..index
				local checkbox = _G[checkBoxName]
				if not checkbox.backdrop then
					checkbox:StripTextures()
					checkbox:CreateBackdrop()
					checkbox.backdrop:Point("TOPLEFT", 3, -1)
					checkbox.backdrop:Point("BOTTOMRIGHT", -3, 1)
					checkbox.backdrop:SetFrameLevel(checkbox:GetParent():GetFrameLevel() + 1)

					S:HandleCheckBox(_G[checkBoxName.."Check"])
				end
			end
		elseif(checkBoxTemplate == "ChatConfigCheckBoxWithSwatchTemplate") or (checkBoxTemplate == "ChatConfigCheckBoxWithSwatchAndClassColorTemplate") then
			frame:SetTemplate("Transparent")
			for index, _ in ipairs(checkBoxTable) do
				local checkBoxName = checkBoxNameString..index
				local checkbox = _G[checkBoxName]
				if not checkbox.backdrop then
					checkbox:StripTextures()
					checkbox:CreateBackdrop()
					checkbox.backdrop:Point("TOPLEFT", 3, -1)
					checkbox.backdrop:Point("BOTTOMRIGHT", -3, 1)
					checkbox.backdrop:SetFrameLevel(checkbox:GetParent():GetFrameLevel() + 1)

					S:HandleCheckBox(_G[checkBoxName.."Check"])

					if checkBoxTemplate == "ChatConfigCheckBoxWithSwatchAndClassColorTemplate" then
						S:HandleCheckBox(_G[checkBoxName.."ColorClasses"])
					end
				end
			end
		end
	end)

	S:SecureHook("ChatConfig_CreateTieredCheckboxes", function(frame, checkBoxTable)
		local checkBoxNameString = frame:GetName().."CheckBox"
		for index, value in ipairs(checkBoxTable) do
			local checkBoxName = checkBoxNameString..index
			if _G[checkBoxName] then
				S:HandleCheckBox(_G[checkBoxName])
				if value.subTypes then
					local subCheckBoxNameString = checkBoxName.."_"
					for k, _ in ipairs(value.subTypes) do
						local subCheckBoxName = subCheckBoxNameString..k
						if _G[subCheckBoxName] then
							S:HandleCheckBox(_G[subCheckBoxNameString..k])
						end
					end
				end
			end
		end
	end)

	S:SecureHook("ChatConfig_CreateColorSwatches", function(frame, swatchTable)
		frame:SetTemplate("Transparent")
		local nameString = frame:GetName().."Swatch"
		for index, _ in ipairs(swatchTable) do
			local swatchName = nameString..index
			local swatch = _G[swatchName]
			if not swatch.backdrop then
				swatch:StripTextures()
				swatch:CreateBackdrop()
				swatch.backdrop:Point("TOPLEFT", 3, -1)
				swatch.backdrop:Point("BOTTOMRIGHT", -3, 1)
				swatch.backdrop:SetFrameLevel(swatch:GetParent():GetFrameLevel() + 1)
			end
		end
	end)
end

S:AddCallback("SkinBlizzard", LoadSkin)