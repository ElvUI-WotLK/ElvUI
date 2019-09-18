local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local ipairs = ipairs
local find = string.find
--WoW API / Variables
local InCombatLockdown = InCombatLockdown
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.BlizzardOptions then return end

	-- Game Menu Interface/Tabs
	for i = 1, 2 do
		local tab = _G["InterfaceOptionsFrameTab"..i]

		tab:StripTextures()
		S:HandleTab(tab)

		tab.backdrop:SetTemplate("Transparent")
		tab.backdrop:Point("TOPLEFT", 10, E.PixelMode and -4 or -6)
		tab.backdrop:Point("BOTTOMRIGHT", -10, 1)

		if i == 1 then
			tab:ClearAllPoints()
			tab:SetPoint("BOTTOMLEFT", InterfaceOptionsFrameCategories, "TOPLEFT", -11, -2)
		end
	end

	-- Game Menu Plus / Minus Buttons
	for _, button in ipairs(InterfaceOptionsFrameAddOns.buttons) do
		button.toggle:SetNormalTexture("")
		button.toggle.SetNormalTexture = E.noop
		button.toggle:SetPushedTexture("")
		button.toggle.SetPushedTexture = E.noop
		button.toggle:SetHighlightTexture(nil)

		local text = button.toggle:CreateFontString(nil, "OVERLAY")
		text:FontTemplate(nil, 22)
		text:Point("CENTER")
		text:SetText("+")
		button.toggle.text = text

		hooksecurefunc(button.toggle, "SetNormalTexture", function(self, texture)
			if find(texture, "MinusButton") then
				self.text:SetText("-")
			else
				self.text:SetText("+")
			end
		end)
	end

	-- Interface Options Frame
	local frames = {
		InterfaceOptionsFrame,
		AudioOptionsFrame,
		VideoOptionsFrame
	}
	for _, frame in ipairs(frames) do
		frame:SetTemplate("Transparent")
		frame:SetClampedToScreen(true)
		frame:SetMovable(true)
		frame:EnableMouse(true)
		frame:RegisterForDrag("LeftButton", "RightButton")
		frame:SetScript("OnDragStart", function(self)
			if InCombatLockdown() then return end

			self:StartMoving()
		end)
		frame:SetScript("OnDragStop", function(self)
			self:StopMovingOrSizing()
		end)
	end

	S:HandleScrollBar(InterfaceOptionsFrameCategoriesListScrollBar)
	S:HandleScrollBar(InterfaceOptionsFrameAddOnsListScrollBar)

	local optionHeaders = {
		"InterfaceOptionsFrameHeader",
		"AudioOptionsFrameHeader",
		"VideoOptionsFrameHeader",
	}
	for _, header in ipairs(optionHeaders) do
		header = _G[header]
		if header then
			header:SetTexture("")
			header:ClearAllPoints()
			header:SetPoint("TOP", header:GetParent(), 0, 0)
		end
	end

	local optionFrames = {
		"InterfaceOptionsFrameCategories",
		"InterfaceOptionsFrameAddOns",
		"InterfaceOptionsFramePanelContainer",

		"AudioOptionsFrameCategoryFrame",
		"AudioOptionsFramePanelContainer",
		"AudioOptionsSoundPanelPlayback",
		"AudioOptionsSoundPanelVolume",
		"AudioOptionsSoundPanelHardware",

		"VideoOptionsFrameCategoryFrame",
		"VideoOptionsFramePanelContainer",
		"VideoOptionsResolutionPanelBrightness",
		"VideoOptionsEffectsPanelQuality",
		"VideoOptionsEffectsPanelShaders",
	}
	for _, frame in ipairs(optionFrames) do
		frame = _G[frame]
		if frame then
			frame:StripTextures()
			frame:CreateBackdrop("Transparent")

			if frame ~= VideoOptionsFramePanelContainer and frame ~= InterfaceOptionsFramePanelContainer then
				frame.backdrop:Point("TOPLEFT", -1 ,0)
				frame.backdrop:Point("BOTTOMRIGHT", 0, 1)
			else
				frame.backdrop:Point("TOPLEFT", 0, 0)
				frame.backdrop:Point("BOTTOMRIGHT", 0, 0)
			end
		end
	end

	local checkboxes = {
		"InterfaceOptionsControlsPanelStickyTargeting",
		"InterfaceOptionsControlsPanelAutoDismount",
		"InterfaceOptionsControlsPanelAutoClearAFK",
		"InterfaceOptionsControlsPanelBlockTrades",
		"InterfaceOptionsControlsPanelLootAtMouse",
		"InterfaceOptionsControlsPanelAutoLootCorpse",
		"InterfaceOptionsCombatPanelAttackOnAssist",
		"InterfaceOptionsCombatPanelAutoRange",
		"InterfaceOptionsCombatPanelStopAutoAttack",
		"InterfaceOptionsCombatPanelNameplateClassColors",
		"InterfaceOptionsCombatPanelAutoSelfCast",
		"InterfaceOptionsCombatPanelTargetOfTarget",
		"InterfaceOptionsCombatPanelEnemyCastBarsOnPortrait",
		"InterfaceOptionsCombatPanelEnemyCastBarsOnNameplates",
		"InterfaceOptionsDisplayPanelShowCloak",
		"InterfaceOptionsDisplayPanelShowHelm",
		"InterfaceOptionsDisplayPanelShowAggroPercentage",
		"InterfaceOptionsDisplayPanelPlayAggroSounds",
		"InterfaceOptionsDisplayPanelDetailedLootInfo",
		"InterfaceOptionsDisplayPanelShowFreeBagSpace",
		"InterfaceOptionsDisplayPanelCinematicSubtitles",
		"InterfaceOptionsDisplayPanelRotateMinimap",
		"InterfaceOptionsDisplayPanelScreenEdgeFlash",
		"InterfaceOptionsDisplayPanelShowClock",
		"InterfaceOptionsDisplayPanelColorblindMode",
		"InterfaceOptionsDisplayPanelShowItemLevel",
		"InterfaceOptionsObjectivesPanelInstantQuestText",
		"InterfaceOptionsObjectivesPanelAutoQuestTracking",
		"InterfaceOptionsObjectivesPanelAutoQuestProgress",
		"InterfaceOptionsObjectivesPanelMapQuestDifficulty",
		"InterfaceOptionsObjectivesPanelAdvancedWorldMap",
		"InterfaceOptionsObjectivesPanelWatchFrameWidth",
		"InterfaceOptionsSocialPanelProfanityFilter",
		"InterfaceOptionsSocialPanelSpamFilter",
		"InterfaceOptionsSocialPanelChatBubbles",
		"InterfaceOptionsSocialPanelPartyChat",
		"InterfaceOptionsSocialPanelChatHoverDelay",
		"InterfaceOptionsSocialPanelGuildMemberAlert",
		"InterfaceOptionsSocialPanelGuildRecruitment",
		"InterfaceOptionsSocialPanelChatMouseScroll",
		"InterfaceOptionsSocialPanelWholeChatWindowClickable",
		"InterfaceOptionsActionBarsPanelLockActionBars",
		"InterfaceOptionsActionBarsPanelSecureAbilityToggle",
		"InterfaceOptionsActionBarsPanelAlwaysShowActionBars",
		"InterfaceOptionsActionBarsPanelBottomLeft",
		"InterfaceOptionsActionBarsPanelBottomRight",
		"InterfaceOptionsActionBarsPanelRight",
		"InterfaceOptionsActionBarsPanelRightTwo",
		"InterfaceOptionsNamesPanelMyName",
		"InterfaceOptionsNamesPanelFriendlyPlayerNames",
		"InterfaceOptionsNamesPanelFriendlyPets",
		"InterfaceOptionsNamesPanelFriendlyGuardians",
		"InterfaceOptionsNamesPanelFriendlyTotems",
		"InterfaceOptionsNamesPanelUnitNameplatesFriends",
		"InterfaceOptionsNamesPanelUnitNameplatesFriendlyGuardians",
		"InterfaceOptionsNamesPanelUnitNameplatesFriendlyPets",
		"InterfaceOptionsNamesPanelUnitNameplatesFriendlyTotems",
		"InterfaceOptionsNamesPanelGuilds",
		"InterfaceOptionsNamesPanelNPCNames",
		"InterfaceOptionsNamesPanelUnitNameplatesAllowOverlap",
		"InterfaceOptionsNamesPanelTitles",
		"InterfaceOptionsNamesPanelNonCombatCreature",
		"InterfaceOptionsNamesPanelEnemyPlayerNames",
		"InterfaceOptionsNamesPanelEnemyPets",
		"InterfaceOptionsNamesPanelEnemyGuardians",
		"InterfaceOptionsNamesPanelEnemyTotems",
		"InterfaceOptionsNamesPanelUnitNameplatesEnemyPets",
		"InterfaceOptionsNamesPanelUnitNameplatesEnemies",
		"InterfaceOptionsNamesPanelUnitNameplatesEnemyGuardians",
		"InterfaceOptionsNamesPanelUnitNameplatesEnemyTotems",
		"InterfaceOptionsCombatTextPanelTargetDamage",
		"InterfaceOptionsCombatTextPanelPeriodicDamage",
		"InterfaceOptionsCombatTextPanelPetDamage",
		"InterfaceOptionsCombatTextPanelHealing",
		"InterfaceOptionsCombatTextPanelTargetEffects",
		"InterfaceOptionsCombatTextPanelOtherTargetEffects",
		"InterfaceOptionsCombatTextPanelEnableFCT",
		"InterfaceOptionsCombatTextPanelDodgeParryMiss",
		"InterfaceOptionsCombatTextPanelDamageReduction",
		"InterfaceOptionsCombatTextPanelRepChanges",
		"InterfaceOptionsCombatTextPanelReactiveAbilities",
		"InterfaceOptionsCombatTextPanelFriendlyHealerNames",
		"InterfaceOptionsCombatTextPanelCombatState",
		"InterfaceOptionsCombatTextPanelComboPoints",
		"InterfaceOptionsCombatTextPanelLowManaHealth",
		"InterfaceOptionsCombatTextPanelEnergyGains",
		"InterfaceOptionsCombatTextPanelPeriodicEnergyGains",
		"InterfaceOptionsCombatTextPanelHonorGains",
		"InterfaceOptionsCombatTextPanelAuras",
		"InterfaceOptionsBuffsPanelBuffDurations",
		"InterfaceOptionsBuffsPanelDispellableDebuffs",
		"InterfaceOptionsBuffsPanelCastableBuffs",
		"InterfaceOptionsBuffsPanelConsolidateBuffs",
		"InterfaceOptionsBuffsPanelShowCastableDebuffs",
		"InterfaceOptionsCameraPanelFollowTerrain",
		"InterfaceOptionsCameraPanelHeadBob",
		"InterfaceOptionsCameraPanelWaterCollision",
		"InterfaceOptionsCameraPanelSmartPivot",
		"InterfaceOptionsMousePanelInvertMouse",
		"InterfaceOptionsMousePanelClickToMove",
		"InterfaceOptionsMousePanelWoWMouse",
		"InterfaceOptionsHelpPanelShowTutorials",
		"InterfaceOptionsHelpPanelLoadingScreenTips",
		"InterfaceOptionsHelpPanelEnhancedTooltips",
		"InterfaceOptionsHelpPanelBeginnerTooltips",
		"InterfaceOptionsHelpPanelShowLuaErrors",
		"InterfaceOptionsStatusTextPanelPlayer",
		"InterfaceOptionsStatusTextPanelPet",
		"InterfaceOptionsStatusTextPanelParty",
		"InterfaceOptionsStatusTextPanelTarget",
		"InterfaceOptionsStatusTextPanelPercentages",
		"InterfaceOptionsStatusTextPanelXP",
		"InterfaceOptionsUnitFramePanelPartyBackground",
		"InterfaceOptionsUnitFramePanelPartyPets",
		"InterfaceOptionsUnitFramePanelArenaEnemyFrames",
		"InterfaceOptionsUnitFramePanelArenaEnemyCastBar",
		"InterfaceOptionsUnitFramePanelArenaEnemyPets",
		"InterfaceOptionsUnitFramePanelPartyInRaid",
		"InterfaceOptionsUnitFramePanelRaidRange",
		"InterfaceOptionsUnitFramePanelFullSizeFocusFrame",
		"InterfaceOptionsFeaturesPanelPreviewTalentChanges",
		"InterfaceOptionsFeaturesPanelEquipmentManager",

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
	for _, checkbox in ipairs(checkboxes) do
		checkbox = _G[checkbox]
		if checkbox then
			S:HandleCheckBox(checkbox)
		end
	end

	local sliders = {
		"InterfaceOptionsCameraPanelMaxDistanceSlider",
		"InterfaceOptionsCameraPanelFollowSpeedSlider",
		"InterfaceOptionsMousePanelMouseLookSpeedSlider",
		"InterfaceOptionsMousePanelMouseSensitivitySlider",

		"AudioOptionsSoundPanelSoundQuality",
		"AudioOptionsSoundPanelSoundChannels",
		"AudioOptionsSoundPanelMasterVolume",
		"AudioOptionsSoundPanelSoundVolume",
		"AudioOptionsSoundPanelMusicVolume",
		"AudioOptionsSoundPanelAmbienceVolume",

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
	}
	for _, slider in ipairs(sliders) do
		S:HandleSliderFrame(_G[slider])
	end

	local buttons = {
		"InterfaceOptionsFrameDefaults",
		"InterfaceOptionsFrameOkay",
		"InterfaceOptionsFrameCancel",
		"InterfaceOptionsHelpPanelResetTutorials",

		"AudioOptionsFrameDefaults",
		"AudioOptionsFrameOkay",
		"AudioOptionsFrameCancel",

		"VideoOptionsFrameDefaults",
		"VideoOptionsFrameOkay",
		"VideoOptionsFrameCancel",
		"VideoOptionsFrameApply",
	}
	for _, button in ipairs(buttons) do
		S:HandleButton(_G[button])
	end

	local dropdowns ={
		"InterfaceOptionsControlsPanelAutoLootKeyDropDown",
		"InterfaceOptionsCombatPanelTOTDropDown",
		"InterfaceOptionsCombatPanelFocusCastKeyDropDown",
		"InterfaceOptionsCombatPanelSelfCastKeyDropDown",
		"InterfaceOptionsDisplayPanelAggroWarningDisplay",
		"InterfaceOptionsDisplayPanelWorldPVPObjectiveDisplay",
		"InterfaceOptionsSocialPanelChatStyle",
		"InterfaceOptionsSocialPanelTimestamps",
		"InterfaceOptionsCombatTextPanelFCTDropDown",
		"InterfaceOptionsCameraPanelStyleDropDown",
		"InterfaceOptionsMousePanelClickMoveStyleDropDown",
		"InterfaceOptionsLanguagesPanelLocaleDropDown",

		"AudioOptionsSoundPanelHardwareDropDown",

		"VideoOptionsResolutionPanelResolutionDropDown",
		"VideoOptionsResolutionPanelRefreshDropDown",
	}
	for _, dropdown in ipairs(dropdowns) do
		dropdown = _G[dropdown]
		if dropdown then
			S:HandleDropDownBox(dropdown)
		end
	end

	S:HandleDropDownBox(VideoOptionsResolutionPanelMultiSampleDropDown, 195)

	VideoOptionsFrameDefaults:ClearAllPoints()
	VideoOptionsFrameDefaults:SetPoint("TOPLEFT", VideoOptionsFrameCategoryFrame, "BOTTOMLEFT", -1, -5)

	InterfaceOptionsFrameDefaults:ClearAllPoints()
	InterfaceOptionsFrameDefaults:SetPoint("TOPLEFT", InterfaceOptionsFrameCategories, "BOTTOMLEFT", -1, -5)

	InterfaceOptionsFrameCancel:ClearAllPoints()
	InterfaceOptionsFrameCancel:SetPoint("TOPRIGHT", InterfaceOptionsFramePanelContainer, "BOTTOMRIGHT", 0, -6)

	VideoOptionsFrameCancel:ClearAllPoints()
	VideoOptionsFrameCancel:SetPoint("RIGHT", VideoOptionsFrameApply, "LEFT", -4, 0)

	VideoOptionsFrameOkay:ClearAllPoints()
	VideoOptionsFrameOkay:SetPoint("RIGHT", VideoOptionsFrameCancel, "LEFT", -4, 0)

	AudioOptionsFrameOkay:ClearAllPoints()
	AudioOptionsFrameOkay:SetPoint("RIGHT", AudioOptionsFrameCancel, "LEFT", -4, 0)

	InterfaceOptionsFrameOkay:ClearAllPoints()
	InterfaceOptionsFrameOkay:SetPoint("RIGHT",InterfaceOptionsFrameCancel, "LEFT", -4, 0)

	InterfaceOptionsFrameCategoriesList:StripTextures()
	InterfaceOptionsFrameAddOnsList:StripTextures()

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
	S:HandleButton(ChatConfigCombatSettingsFiltersAddFilterButton)
	S:HandleButton(ChatConfigCombatSettingsFiltersCopyFilterButton)

	ChatConfigCombatSettingsFiltersDeleteButton:Point("TOPRIGHT", ChatConfigCombatSettingsFilters, "BOTTOMRIGHT", 0, -1)
	ChatConfigCombatSettingsFiltersAddFilterButton:Point("RIGHT", ChatConfigCombatSettingsFiltersDeleteButton, "LEFT", -1, 0)
	ChatConfigCombatSettingsFiltersCopyFilterButton:Point("RIGHT", ChatConfigCombatSettingsFiltersAddFilterButton, "LEFT", -1, 0)

	S:HandleNextPrevButton(ChatConfigMoveFilterUpButton)
	ChatConfigMoveFilterUpButton:Size(26)
	ChatConfigMoveFilterUpButton:Point("TOPLEFT", ChatConfigCombatSettingsFilters, "BOTTOMLEFT", 3, -1)
	ChatConfigMoveFilterUpButton:SetHitRectInsets(0, 0, 0, 0)

	S:HandleNextPrevButton(ChatConfigMoveFilterDownButton)
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

	local combatCheckboxes = {
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
	for i = 1, #combatCheckboxes do
		S:HandleCheckBox(_G[combatCheckboxes[i]])
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
	S:HandleButton(CombatLogDefaultButton)
	S:HandleButton(ChatConfigFrameCancelButton)
	S:HandleButton(ChatConfigFrameOkayButton)

	ChatConfigFrameDefaultButton:Point("BOTTOMLEFT", 12, 8)
	ChatConfigFrameDefaultButton:Width(125)

	ChatConfigFrameCancelButton:Point("BOTTOMRIGHT", -11, 8)

	S:HandleColorSwatch(CombatConfigColorsColorizeSpellNamesColorSwatch)
	S:HandleColorSwatch(CombatConfigColorsColorizeDamageNumberColorSwatch)

	hooksecurefunc("ChatConfig_CreateCheckboxes", function(frame, checkBoxTable, checkBoxTemplate)
		frame:SetTemplate("Transparent")

		local checkBoxNameString = frame:GetName().."CheckBox"
		local checkBoxName, checkbox

		for index in ipairs(checkBoxTable) do
			checkBoxName = checkBoxNameString..index
			checkbox = _G[checkBoxName]

			if not checkbox.backdrop then
				checkbox:StripTextures()
				checkbox:CreateBackdrop()
				checkbox.backdrop:Point("TOPLEFT", 3, -1)
				checkbox.backdrop:Point("BOTTOMRIGHT", -3, 1)
				checkbox.backdrop:SetFrameLevel(checkbox:GetParent():GetFrameLevel() + 1)

				S:HandleCheckBox(_G[checkBoxName.."Check"])

				if checkBoxTemplate == "ChatConfigCheckBoxWithSwatchTemplate" or checkBoxTemplate == "ChatConfigCheckBoxWithSwatchAndClassColorTemplate" then
					if checkBoxTemplate == "ChatConfigCheckBoxWithSwatchAndClassColorTemplate" then
						S:HandleCheckBox(_G[checkBoxName.."ColorClasses"])
					end

					S:HandleColorSwatch(_G[checkBoxName.."ColorSwatch"])
				end
			end
		end
	end)

	hooksecurefunc("ChatConfig_CreateTieredCheckboxes", function(frame, checkBoxTable)
		local checkBoxNameString = frame:GetName().."CheckBox"
		local checkBoxName

		for index, value in ipairs(checkBoxTable) do
			checkBoxName = checkBoxNameString..index

			if _G[checkBoxName] then
				S:HandleCheckBox(_G[checkBoxName])

				if value.subTypes then
					local subCheckBox

					for i in ipairs(value.subTypes) do
						subCheckBox = _G[checkBoxName.."_"..i]

						if subCheckBox then
							S:HandleCheckBox(subCheckBox)
						end
					end
				end
			end
		end
	end)

	hooksecurefunc("ChatConfig_CreateColorSwatches", function(frame, swatchTable)
		frame:SetTemplate("Transparent")

		local nameString = frame:GetName().."Swatch"
		local swatch

		for index in ipairs(swatchTable) do
			swatch = _G[nameString..index]

			if not swatch.backdrop then
				swatch:StripTextures()
				swatch:CreateBackdrop()
				swatch.backdrop:Point("TOPLEFT", 3, -1)
				swatch.backdrop:Point("BOTTOMRIGHT", -3, 1)
				swatch.backdrop:SetFrameLevel(swatch:GetParent():GetFrameLevel() + 1)

				S:HandleColorSwatch(_G[nameString..index.."ColorSwatch"])
			end
		end
	end)
end

S:AddCallback("Skin_BlizzardOptions", LoadSkin)