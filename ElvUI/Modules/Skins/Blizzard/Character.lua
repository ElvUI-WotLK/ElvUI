local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local ipairs = ipairs
local select = select
local unpack = unpack
local find = string.find
--WoW API / Variables
local GetCurrencyListInfo = GetCurrencyListInfo
local GetInventoryItemQuality = GetInventoryItemQuality
local GetInventoryItemTexture = GetInventoryItemTexture
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local GetNumFactions = GetNumFactions
local GetPetHappiness = GetPetHappiness
local HasPetUI = HasPetUI
local UnitFactionGroup = UnitFactionGroup
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.character then return end

	CharacterFrame:StripTextures(true)
	CharacterFrame:CreateBackdrop("Transparent")
	CharacterFrame.backdrop:Point("TOPLEFT", 11, -12)
	CharacterFrame.backdrop:Point("BOTTOMRIGHT", -32, 76)

	S:HandleCloseButton(CharacterFrameCloseButton, CharacterFrame.backdrop)
	CharacterFrameCloseButton:Point("CENTER", CharacterFrame, "TOPRIGHT", -45, -25)

	for i = 1, #CHARACTERFRAME_SUBFRAMES do
		S:HandleTab(_G["CharacterFrameTab"..i])
	end

	GearManagerDialog:StripTextures()
	GearManagerDialog:CreateBackdrop("Transparent")
	GearManagerDialog.backdrop:Point("TOPLEFT", 5, -2)
	GearManagerDialog.backdrop:Point("BOTTOMRIGHT", -1, 4)

	S:HandleCloseButton(GearManagerDialogClose)

	for i = 1, 10 do
		local button = _G["GearSetButton"..i]
		local icon = _G["GearSetButton"..i.."Icon"]

		button:StripTextures()
		button:StyleButton()
		button:CreateBackdrop("Default")
		button.backdrop:SetAllPoints()

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside()
	end

	S:HandleButton(GearManagerDialogDeleteSet)
	S:HandleButton(GearManagerDialogEquipSet)
	S:HandleButton(GearManagerDialogSaveSet)

	PaperDollFrameItemFlyoutHighlight:Kill()

	hooksecurefunc("PaperDollFrameItemFlyout_DisplayButton", function(button)
		if not button.isSkinned then
			button.icon = _G[button:GetName().."IconTexture"]

			button:GetNormalTexture():SetTexture(nil)
			button:SetTemplate("Default")
			button:StyleButton(false)

			button.icon:SetInside()
			button.icon:SetTexCoord(unpack(E.TexCoords))
		end

		local cooldown = _G[button:GetName().."Cooldown"]
		if cooldown then
			E:RegisterCooldown(cooldown)
		end

		if not button.location then return end
		if button.location >= PDFITEMFLYOUT_FIRST_SPECIAL_LOCATION then return end

		local id = EquipmentManager_GetItemInfoByLocation(button.location)
		local _, _, quality = GetItemInfo(id)

		button:SetBackdropBorderColor(GetItemQualityColor(quality))
	end)

	GearManagerDialogPopup:StripTextures()
	GearManagerDialogPopup:CreateBackdrop("Transparent")
	GearManagerDialogPopup.backdrop:Point("TOPLEFT", 5, -2)
	GearManagerDialogPopup.backdrop:Point("BOTTOMRIGHT", -4, 8)

	S:HandleEditBox(GearManagerDialogPopupEditBox)

	GearManagerDialogPopupScrollFrame:StripTextures()
	S:HandleScrollBar(GearManagerDialogPopupScrollFrameScrollBar)

	for i = 1, NUM_GEARSET_ICONS_SHOWN do
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
	PlayerTitleFrame:CreateBackdrop("Default")
	PlayerTitleFrame.backdrop:Point("TOPLEFT", 20, 3)
	PlayerTitleFrame.backdrop:Point("BOTTOMRIGHT", -16, 14)
	PlayerTitleFrame.backdrop:SetFrameLevel(PlayerTitleFrame:GetFrameLevel())
	S:HandleNextPrevButton(PlayerTitleFrameButton)
	PlayerTitleFrameButton:ClearAllPoints()
	PlayerTitleFrameButton:Point("RIGHT", PlayerTitleFrame.backdrop, "RIGHT", -2, 0)

	PlayerTitlePickerFrame:StripTextures()
	PlayerTitlePickerFrame:CreateBackdrop("Transparent")
	PlayerTitlePickerFrame.backdrop:Point("TOPLEFT", 6, -10)
	PlayerTitlePickerFrame.backdrop:Point("BOTTOMRIGHT", -10, 6)
	PlayerTitlePickerFrame.backdrop:SetFrameLevel(PlayerTitlePickerFrame:GetFrameLevel())

	for i = 1, #PlayerTitlePickerScrollFrame.buttons do
		PlayerTitlePickerScrollFrame.buttons[i].text:FontTemplate()
	end

	S:HandleScrollBar(PlayerTitlePickerScrollFrameScrollBar)

	local GearManagerToggleButton = _G["GearManagerToggleButton"]
	GearManagerToggleButton:Size(26, 32)
	GearManagerToggleButton:CreateBackdrop("Default")
	GearManagerToggleButton:Point("TOPRIGHT", -48, -39)
	GearManagerToggleButton:GetNormalTexture():SetTexCoord(0.2000, 0.8160, 0.155, 0.90700)
	GearManagerToggleButton:GetPushedTexture():SetTexCoord(0.1900, 0.8160, 0.175, 0.90700)
	GearManagerToggleButton:GetHighlightTexture():SetTexture(1, 1, 1, 0.3)
	GearManagerToggleButton:GetHighlightTexture():SetAllPoints()

	local popoutButtonOnEnter = function(btn) btn.icon:SetVertexColor(unpack(E.media.rgbvaluecolor)) end
	local popoutButtonOnLeave = function(btn) btn.icon:SetVertexColor(1, 1, 1) end

	local slots = {
		[1] = CharacterHeadSlot,
		[2] = CharacterNeckSlot,
		[3] = CharacterShoulderSlot,
		[4] = CharacterShirtSlot,
		[5] = CharacterChestSlot,
		[6] = CharacterWaistSlot,
		[7] = CharacterLegsSlot,
		[8] = CharacterFeetSlot,
		[9] = CharacterWristSlot,
		[10] = CharacterHandsSlot,
		[11] = CharacterFinger0Slot,
		[12] = CharacterFinger1Slot,
		[13] = CharacterTrinket0Slot,
		[14] = CharacterTrinket1Slot,
		[15] = CharacterBackSlot,
		[16] = CharacterMainHandSlot,
		[17] = CharacterSecondaryHandSlot,
		[18] = CharacterRangedSlot,
		[19] = CharacterTabardSlot,
		[20] = CharacterAmmoSlot, -- 0
	}

	for _, slotFrame in ipairs(slots) do
		local slotFrameName = slotFrame:GetName()
		local icon = _G[slotFrameName.."IconTexture"]
		local cooldown = _G[slotFrameName.."Cooldown"]
		local popout = _G[slotFrameName.."PopoutButton"]

		slotFrame:StripTextures()
		slotFrame:StyleButton(false)
		slotFrame:SetTemplate("Default", true, true)

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside()

		slotFrame:SetFrameLevel(PaperDollFrame:GetFrameLevel() + 2)

		if cooldown then
			E:RegisterCooldown(cooldown)
		end

		if popout then
			popout:StripTextures()
			popout:HookScript("OnEnter", popoutButtonOnEnter)
			popout:HookScript("OnLeave", popoutButtonOnLeave)

			popout.icon = popout:CreateTexture(nil, "ARTWORK")
			popout.icon:Size(24)
			popout.icon:Point("CENTER")
			popout.icon:SetTexture(E.Media.Textures.ArrowUp)

			if slotFrame.verticalFlyout then
				popout.icon:SetRotation(S.ArrowRotation.down)
			else
				popout.icon:SetRotation(S.ArrowRotation.right)
			end
		end
	end

	local function updateSlotFrame(self, event, slotID, exist)
		if event then
			self = slots[slotID]
		end

		if exist then
			local quality = GetInventoryItemQuality("player", slotID)

			if quality then
				self:SetBackdropBorderColor(GetItemQualityColor(quality))
			else
				self:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		else
			self:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	end

	local function colorItemBorder()
		for _, slotFrame in ipairs(slots) do
			local slotID = slotFrame:GetID()
			updateSlotFrame(slotFrame, nil, slotID, GetInventoryItemTexture("player", slotID) ~= nil)
		end
	end

	hooksecurefunc(CharacterAmmoSlotIconTexture, "SetTexture", function(self, texture)
		updateSlotFrame(self:GetParent(), nil, 0, texture ~= "Interface\\PaperDoll\\UI-PaperDoll-Slot-Ranged")
	end)

	local f = CreateFrame("Frame")
	f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	f:SetScript("OnEvent", updateSlotFrame)

	CharacterFrame:HookScript("OnShow", colorItemBorder)
	colorItemBorder()

	hooksecurefunc("PaperDollFrameItemFlyout_Show", function(self)
		PaperDollFrameItemFlyoutButtons:StripTextures()
	end)

	hooksecurefunc("PaperDollFrameItemPopoutButton_SetReversed", function(self, isReversed)
		if self:GetParent().verticalFlyout then
			if isReversed then
				self.icon:SetRotation(S.ArrowRotation.up)
			else
				self.icon:SetRotation(S.ArrowRotation.down)
			end
		else
			if isReversed then
				self.icon:SetRotation(S.ArrowRotation.left)
			else
				self.icon:SetRotation(S.ArrowRotation.right)
			end
		end
	end)

	S:HandleRotateButton(CharacterModelFrameRotateLeftButton)
	CharacterModelFrameRotateLeftButton:SetPoint("TOPLEFT", 3, -3)
	S:HandleRotateButton(CharacterModelFrameRotateRightButton)
	CharacterModelFrameRotateRightButton:SetPoint("TOPLEFT", CharacterModelFrameRotateLeftButton, "TOPRIGHT", 3, 0)

	local function handleResistanceFrame(frameName)
		local frame
		for i = 1, 5 do
			frame = _G[frameName..i]
			frame:Size(24)
			frame:SetTemplate("Default")

			if i ~= 1 then
				frame:ClearAllPoints()
				frame:Point("TOP", _G[frameName..i-1], "BOTTOM", 0, -(E.Border + E.Spacing))
			end

			select(1, _G[frameName..i]:GetRegions()):SetInside()
			select(1, _G[frameName..i]:GetRegions()):SetDrawLayer("ARTWORK")
			select(2, _G[frameName..i]:GetRegions()):SetDrawLayer("OVERLAY")
		end
	end

	handleResistanceFrame("MagicResFrame")

	select(1, MagicResFrame1:GetRegions()):SetTexCoord(0.21875, 0.8125, 0.25, 0.32421875)		-- Arcane
	select(1, MagicResFrame2:GetRegions()):SetTexCoord(0.21875, 0.8125, 0.0234375, 0.09765625)	-- Fire
	select(1, MagicResFrame3:GetRegions()):SetTexCoord(0.21875, 0.8125, 0.13671875, 0.2109375)	-- Nature
	select(1, MagicResFrame4:GetRegions()):SetTexCoord(0.21875, 0.8125, 0.36328125, 0.4375)		-- Frost
	select(1, MagicResFrame5:GetRegions()):SetTexCoord(0.21875, 0.8125, 0.4765625, 0.55078125)	-- Shadow

	S:HandleDropDownBox(PlayerStatFrameLeftDropDown, 140, "down")
	S:HandleDropDownBox(PlayerStatFrameRightDropDown, 140, "down")
	CharacterAttributesFrame:StripTextures()

	PetPaperDollFrame:StripTextures(true)

	for i = 1, 3 do
		local tab = _G["PetPaperDollFrameTab"..i]
		tab:StripTextures()
		tab:CreateBackdrop("Default", true)
		tab.backdrop:Point("TOPLEFT", 3, -7)
		tab.backdrop:Point("BOTTOMRIGHT", -2, -1)

		tab:HookScript("OnEnter", function(self) self.backdrop:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor)) end)
		tab:HookScript("OnLeave", function(self) self.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor)) end)
	end

	S:HandleRotateButton(PetModelFrameRotateLeftButton)
	S:HandleRotateButton(PetModelFrameRotateRightButton)
	PetModelFrameRotateRightButton:SetPoint("TOPLEFT", PetModelFrameRotateLeftButton, "TOPRIGHT", 3, 0)

	handleResistanceFrame("PetMagicResFrame")

	select(1, PetMagicResFrame1:GetRegions()):SetTexCoord(0.21875, 0.8125, 0.25, 0.32421875)			-- Arcane
	select(1, PetMagicResFrame2:GetRegions()):SetTexCoord(0.21875, 0.8125, 0.0234375, 0.09765625)	-- Fire
	select(1, PetMagicResFrame3:GetRegions()):SetTexCoord(0.21875, 0.8125, 0.13671875, 0.2109375)	-- Nature
	select(1, PetMagicResFrame4:GetRegions()):SetTexCoord(0.21875, 0.8125, 0.36328125, 0.4375)		-- Frost
	select(1, PetMagicResFrame5:GetRegions()):SetTexCoord(0.21875, 0.8125, 0.4765625, 0.55078125)	-- Shadow

	PetAttributesFrame:StripTextures()

	S:HandleButton(PetPaperDollCloseButton)

	PetPaperDollFrameExpBar:StripTextures()
	PetPaperDollFrameExpBar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(PetPaperDollFrameExpBar)
	PetPaperDollFrameExpBar:CreateBackdrop("Default")

	local function updateHappiness(self)
		local happiness = GetPetHappiness()
		local _, isHunterPet = HasPetUI()
		if not happiness or not isHunterPet then return end

		local texture = self:GetRegions()
		if happiness == 1 then
			texture:SetTexCoord(0.41, 0.53, 0.06, 0.30)
		elseif happiness == 2 then
			texture:SetTexCoord(0.22, 0.345, 0.06, 0.30)
		elseif happiness == 3 then
			texture:SetTexCoord(0.04, 0.15, 0.06, 0.30)
		end
	end

	PetPaperDollPetInfo:SetPoint("TOPLEFT", PetModelFrameRotateLeftButton, "BOTTOMLEFT", 9, -3)
	PetPaperDollPetInfo:GetRegions():SetTexCoord(0.04, 0.15, 0.06, 0.30)
	PetPaperDollPetInfo:SetFrameLevel(PetModelFrame:GetFrameLevel() + 2)
	PetPaperDollPetInfo:CreateBackdrop("Default")
	PetPaperDollPetInfo:Size(24, 24)
	updateHappiness(PetPaperDollPetInfo)

	PetPaperDollPetInfo:RegisterEvent("UNIT_HAPPINESS")
	PetPaperDollPetInfo:SetScript("OnEvent", updateHappiness)
	PetPaperDollPetInfo:SetScript("OnShow", updateHappiness)

	PetPaperDollFrameCompanionFrame:StripTextures()

	S:HandleRotateButton(CompanionModelFrameRotateLeftButton)
	S:HandleRotateButton(CompanionModelFrameRotateRightButton)
	CompanionModelFrameRotateRightButton:SetPoint("TOPLEFT", CompanionModelFrameRotateLeftButton, "TOPRIGHT", 3, 0)

	S:HandleButton(CompanionSummonButton)

	hooksecurefunc("PetPaperDollFrame_UpdateCompanions", function()
		local button, iconNormal, iconDisabled, activeTexture

		for i = 1, NUM_COMPANIONS_PER_PAGE do
			button = _G["CompanionButton"..i]
			iconNormal = button:GetNormalTexture()
			iconDisabled = button:GetDisabledTexture()
			activeTexture = _G["CompanionButton"..i.."ActiveTexture"]

			button:StyleButton(nil, true)
			button:SetTemplate("Default", true)

			if iconNormal then
				iconNormal:SetTexCoord(unpack(E.TexCoords))
				iconNormal:SetInside()
			end

			iconDisabled:SetTexture(nil)

			activeTexture:SetInside(button)
			activeTexture:SetTexture(1, 1, 1, .15)
		end
	end)

	S:HandleNextPrevButton(CompanionPrevPageButton)
	S:HandleNextPrevButton(CompanionNextPageButton)

	ReputationFrame:StripTextures(true)

	for i = 1, NUM_FACTIONS_DISPLAYED do
		local factionRow = _G["ReputationBar"..i]
		local factionBar = _G["ReputationBar"..i.."ReputationBar"]
		local factionButton = _G["ReputationBar"..i.."ExpandOrCollapseButton"]

		factionRow:StripTextures(true)

		factionBar:StripTextures()
		factionBar:SetStatusBarTexture(E.media.normTex)
		E:RegisterStatusBar(factionBar)
		factionBar:CreateBackdrop("Default")

		factionButton:SetNormalTexture(E.Media.Textures.Minus)
		factionButton.SetNormalTexture = E.noop
		factionButton:GetNormalTexture():Size(15)
		factionButton:SetHighlightTexture(nil)
	end

	hooksecurefunc("ReputationFrame_Update", function()
		local factionOffset = FauxScrollFrame_GetOffset(ReputationListScrollFrame)
		local numFactions = GetNumFactions()
		local factionIndex, factionButton

		for i = 1, NUM_FACTIONS_DISPLAYED do
			factionIndex = factionOffset + i

			if factionIndex <= numFactions then
				factionButton = _G["ReputationBar"..i.."ExpandOrCollapseButton"]

				if _G["ReputationBar"..i].isCollapsed then
					factionButton:GetNormalTexture():SetTexture(E.Media.Textures.Plus)
				else
					factionButton:GetNormalTexture():SetTexture(E.Media.Textures.Minus)
				end
			end
		end
	end)

	ReputationListScrollFrame:StripTextures()
	S:HandleScrollBar(ReputationListScrollFrameScrollBar)

	ReputationDetailFrame:StripTextures()
	ReputationDetailFrame:SetTemplate("Transparent")
	ReputationDetailFrame:Point("TOPLEFT", ReputationFrame, "TOPRIGHT", -32, -12)

	S:HandleCloseButton(ReputationDetailCloseButton)
	ReputationDetailCloseButton:Point("TOPRIGHT", 3, 4)

	S:HandleCheckBox(ReputationDetailAtWarCheckBox)
	ReputationDetailAtWarCheckBox:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-SwordCheck")
	S:HandleCheckBox(ReputationDetailInactiveCheckBox)
	S:HandleCheckBox(ReputationDetailMainScreenCheckBox)

	SkillFrame:StripTextures(true)

	S:HandleCloseButton(SkillDetailStatusBarUnlearnButton)
	SkillDetailStatusBarUnlearnButton.Texture:Size(20)
	SkillDetailStatusBarUnlearnButton.Texture:SetVertexColor(1, 0, 0)
	SkillDetailStatusBarUnlearnButton:HookScript("OnEnter", function(btn) btn.Texture:SetVertexColor(1, 1, 1) end)
	SkillDetailStatusBarUnlearnButton:HookScript("OnLeave", function(btn) btn.Texture:SetVertexColor(1, 0, 0) end)

	SkillFrameExpandButtonFrame:StripTextures()

	SkillFrameCollapseAllButton:SetNormalTexture(E.Media.Textures.Plus)
	SkillFrameCollapseAllButton.SetNormalTexture = E.noop
	SkillFrameCollapseAllButton:GetNormalTexture():Size(16)
	SkillFrameCollapseAllButton:Point("LEFT", SkillFrameExpandTabLeft, "RIGHT", -40, -3)
	SkillFrameCollapseAllButton:SetHighlightTexture(nil)

	hooksecurefunc(SkillFrameCollapseAllButton, "SetNormalTexture", function(self, texture)
		if find(texture, "MinusButton") then
			SkillFrameCollapseAllButton:GetNormalTexture():SetTexture(E.Media.Textures.Minus)
		else
			SkillFrameCollapseAllButton:GetNormalTexture():SetTexture(E.Media.Textures.Plus)
		end
	end)

	for i = 1, SKILLS_TO_DISPLAY do
		local statusBar = _G["SkillRankFrame"..i]
		local statusBarBorder = _G["SkillRankFrame"..i.."Border"]
		local statusBarBackground = _G["SkillRankFrame"..i.."Background"]
		local skillTypeLabelText = _G["SkillTypeLabel"..i]

		statusBar:SetStatusBarTexture(E.media.normTex)
		E:RegisterStatusBar(statusBar)
		statusBar:CreateBackdrop("Default")

		statusBarBorder:StripTextures()
		statusBarBackground:SetTexture(nil)

		skillTypeLabelText:SetNormalTexture(E.Media.Textures.Plus)
		skillTypeLabelText.SetNormalTexture = E.noop
		skillTypeLabelText:GetNormalTexture():Size(16)
		skillTypeLabelText:SetHighlightTexture(nil)

		hooksecurefunc(skillTypeLabelText, "SetNormalTexture", function(self, texture)
			if find(texture, "MinusButton") then
				self:GetNormalTexture():SetTexture(E.Media.Textures.Minus)
			else
				self:GetNormalTexture():SetTexture(E.Media.Textures.Plus)
			end
		end)
	end

	SkillDetailStatusBar:StripTextures()
	SkillDetailStatusBar:SetParent(SkillDetailScrollFrame)
	SkillDetailStatusBar:CreateBackdrop("Default")
	SkillDetailStatusBar:SetStatusBarTexture(E.media.normTex)
	SkillDetailStatusBar:SetParent(SkillDetailScrollFrame)
	E:RegisterStatusBar(SkillDetailStatusBar)

	SkillListScrollFrame:StripTextures()
	S:HandleScrollBar(SkillListScrollFrameScrollBar)

	SkillDetailScrollFrame:StripTextures()
	S:HandleScrollBar(SkillDetailScrollFrameScrollBar)

	S:HandleButton(SkillFrameCancelButton)
	SkillFrameCancelButton:Point("CENTER", SkillFrame, "TOPLEFT", 307, -420)

	TokenFrame:StripTextures(true)

	select(4, TokenFrame:GetChildren()):Hide()

	hooksecurefunc("TokenFrame_Update", function()
		local offset = HybridScrollFrame_GetOffset(TokenFrameContainer)
		local buttons = TokenFrameContainer.buttons
		local index, button
		local _, name, isHeader, isExpanded, extraCurrencyType, icon

		for i = 1, #buttons do
			index = offset + i
			button = buttons[i]

			name, isHeader, isExpanded, _, _, _, extraCurrencyType, icon = GetCurrencyListInfo(index)

			if not button.isSkinned then
				button.categoryLeft:Kill()
				button.categoryRight:Kill()
				button.highlight:Kill()

				button.expandIcon:SetTexture(E.Media.Textures.Plus)
				button.expandIcon:SetTexCoord(0, 1, 0, 1)
				button.expandIcon:Size(16)

				button.isSkinned = true
			end

			if name or name == "" then
				if isHeader then
					if isExpanded then
						button.expandIcon:SetTexture(E.Media.Textures.Minus)
					else
						button.expandIcon:SetTexture(E.Media.Textures.Plus)
					end

					button.expandIcon:SetTexCoord(0, 1, 0, 1)
				else
					if extraCurrencyType == 1 then
						button.icon:SetTexCoord(unpack(E.TexCoords))
					elseif extraCurrencyType == 2 then
						local factionGroup = UnitFactionGroup("player")

						if factionGroup then
							button.icon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionGroup)
							button.icon:SetTexCoord(0.03125, 0.59375, 0.03125, 0.59375)
						else
							button.icon:SetTexCoord(unpack(E.TexCoords))
						end
					else
						button.icon:SetTexture(icon)
						button.icon:SetTexCoord(unpack(E.TexCoords))
					end
				end
			end
		end
	end)

	S:HandleScrollBar(TokenFrameContainerScrollBar)

	S:HandleButton(TokenFrameCancelButton)
	TokenFrameCancelButton:Point("CENTER", TokenFrame, "TOPLEFT", 307, -420)

	TokenFramePopup:StripTextures()
	TokenFramePopup:SetTemplate("Transparent")

	S:HandleCloseButton(TokenFramePopupCloseButton)

	S:HandleCheckBox(TokenFramePopupInactiveCheckBox)
	S:HandleCheckBox(TokenFramePopupBackpackCheckBox)
end

S:AddCallback("Skin_Character", LoadSkin)