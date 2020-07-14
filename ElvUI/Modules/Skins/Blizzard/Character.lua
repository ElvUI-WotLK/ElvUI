local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local getmetatable = getmetatable
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

local NUM_COMPANIONS_PER_PAGE = NUM_COMPANIONS_PER_PAGE
local NUM_FACTIONS_DISPLAYED = NUM_FACTIONS_DISPLAYED
local NUM_GEARSET_ICONS_PER_ROW = NUM_GEARSET_ICONS_PER_ROW

S:AddCallback("Skin_Character", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.character then return end

	-- CharacterFrame
	CharacterFrame:StripTextures(true)
	CharacterFrame:CreateBackdrop("Transparent")
	CharacterFrame.backdrop:Point("TOPLEFT", 11, -12)
	CharacterFrame.backdrop:Point("BOTTOMRIGHT", -32, 76)

	S:SetUIPanelWindowInfo(CharacterFrame, "width")

	S:SetBackdropHitRect(PaperDollFrame, CharacterFrame.backdrop)
	S:SetBackdropHitRect(PetPaperDollFrame, CharacterFrame.backdrop)
	S:SetBackdropHitRect(PetPaperDollFrameCompanionFrame, CharacterFrame.backdrop)
	S:SetBackdropHitRect(PetPaperDollFramePetFrame, CharacterFrame.backdrop)
	S:SetBackdropHitRect(ReputationFrame, CharacterFrame.backdrop)
	S:SetBackdropHitRect(SkillFrame, CharacterFrame.backdrop)
	S:SetBackdropHitRect(TokenFrame, CharacterFrame.backdrop)

	S:HandleCloseButton(CharacterFrameCloseButton, CharacterFrame.backdrop)

	PaperDollFrame:StripTextures(true)

	for i = 1, #CHARACTERFRAME_SUBFRAMES do
		S:HandleTab(_G["CharacterFrameTab"..i])
	end

	hooksecurefunc("PetPaperDollFrame_UpdateIsAvailable", function()
		if not PetPaperDollFrame.hidden then
			CharacterFrameTab3:Point("LEFT", "CharacterFrameTab2", "RIGHT", -15, 0)
		end
	end)

	-- PaperDollFrame
	PlayerTitleFrame:StripTextures()
	PlayerTitleFrame:CreateBackdrop("Default")
	PlayerTitleFrame.backdrop:Point("TOPLEFT", 20, 3)
	PlayerTitleFrame.backdrop:Point("BOTTOMRIGHT", -16, 15)
	PlayerTitleFrame.backdrop:SetFrameLevel(PlayerTitleFrame:GetFrameLevel())

	S:HandleNextPrevButton(PlayerTitleFrameButton)
	PlayerTitleFrameButton:Size(16)
	PlayerTitleFrameButton:Point("TOPRIGHT", PlayerTitleFrameRight, "TOPRIGHT", -18, -16)

	PlayerTitlePickerFrame:StripTextures()
	PlayerTitlePickerFrame:CreateBackdrop("Transparent")
	PlayerTitlePickerFrame.backdrop:Point("TOPLEFT", 6, -10)
	PlayerTitlePickerFrame.backdrop:Point("BOTTOMRIGHT", -13, 6)
	PlayerTitlePickerFrame.backdrop:SetFrameLevel(PlayerTitlePickerFrame:GetFrameLevel())

	S:HandleScrollBar(PlayerTitlePickerScrollFrameScrollBar)

	PlayerTitlePickerScrollFrameScrollBar:Point("TOPLEFT", PlayerTitlePickerScrollFrame, "TOPRIGHT", 1, -14)
	PlayerTitlePickerScrollFrameScrollBar:Point("BOTTOMLEFT", PlayerTitlePickerScrollFrame, "BOTTOMRIGHT", 1, 15)

	for _, button in ipairs(PlayerTitlePickerScrollFrame.buttons) do
		button.text:FontTemplate()
		S:HandleButtonHighlight(button)
	end

	S:HandleRotateButton(CharacterModelFrameRotateLeftButton)
	S:HandleRotateButton(CharacterModelFrameRotateRightButton)

	PlayerStatFrameLeftDropDown:Point("BOTTOMLEFT", PlayerStatLeftTop, "TOPLEFT", -19, -8)

	S:HandleDropDownBox(PlayerStatFrameLeftDropDown, 140, "down")
	S:HandleDropDownBox(PlayerStatFrameRightDropDown, 140, "down")

	CharacterAttributesFrame:StripTextures()

	PaperDollFrameItemFlyoutButtons:EnableMouse(false)
	PaperDollFrameItemFlyoutHighlight:Kill()

	GearManagerToggleButton:Size(25, 29)
	GearManagerToggleButton:Point("TOPRIGHT", -46, -40)
	GearManagerToggleButton:CreateBackdrop("Default")
	-- texWidth, texHeight, cropWidth, cropHeight, offsetX, offsetY = 64, 64, 40, 46, 13, 10
	GearManagerToggleButton:GetNormalTexture():SetTexCoord(0.203125, 0.828125, 0.15625, 0.875)
	-- texWidth, texHeight, cropWidth, cropHeight, offsetX, offsetY = 64, 64, 40, 46, 12, 12
	GearManagerToggleButton:GetPushedTexture():SetTexCoord(0.1875, 0.8125, 0.1875, 0.90625)
	GearManagerToggleButton:GetHighlightTexture():SetTexture(1, 1, 1, 0.3)
	GearManagerToggleButton:GetHighlightTexture():SetAllPoints()

	PlayerTitleFrame:Point("TOP", CharacterLevelText, "BOTTOM", -7, -7)
	PlayerTitlePickerFrame:Point("TOPLEFT", PlayerTitleFrame, "BOTTOMLEFT", 14, 26)

	CharacterModelFrame:Size(237, 217)
	CharacterModelFrame:Point("TOPLEFT", 63, -76)

	CharacterModelFrameRotateLeftButton:Point("TOPLEFT", 4, -4)
	CharacterModelFrameRotateRightButton:Point("TOPLEFT", CharacterModelFrameRotateLeftButton, "TOPRIGHT", 3, 0)

	CharacterResistanceFrame:Point("TOPRIGHT", PaperDollFrame, "TOPLEFT", 300, -81)

	CharacterHeadSlot:Point("TOPLEFT", 19, -76)
	CharacterHandsSlot:Point("TOPLEFT", 307, -76)
	CharacterMainHandSlot:Point("TOPLEFT", PaperDollFrame, "BOTTOMLEFT", 110, 131)

	CharacterAttributesFrame:Point("TOPLEFT", 66, -292)

	local popoutButtonOnEnter = function(self) self.icon:SetVertexColor(unpack(E.media.rgbvaluecolor)) end
	local popoutButtonOnLeave = function(self) self.icon:SetVertexColor(1, 1, 1) end

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

	for i, slotFrame in ipairs(slots) do
		local slotFrameName = slotFrame:GetName()
		local icon = _G[slotFrameName.."IconTexture"]

		slotFrame:StripTextures()
		slotFrame:StyleButton(false)
		slotFrame:SetTemplate("Default", true, true)

		icon:SetInside()
		icon:SetTexCoord(unpack(E.TexCoords))

		slotFrame:SetFrameLevel(PaperDollFrame:GetFrameLevel() + 2)

		if i ~= 20 then
			local cooldown = _G[slotFrameName.."Cooldown"]
			local popout = _G[slotFrameName.."PopoutButton"]

			E:RegisterCooldown(cooldown)

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

	local nStripped = 0
	hooksecurefunc("PaperDollFrameItemFlyout_Show", function()
		if nStripped < PaperDollFrameItemFlyoutButtons.numBGs then
			nStripped = PaperDollFrameItemFlyoutButtons.numBGs
			PaperDollFrameItemFlyoutButtons:StripTextures()
		end
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

	hooksecurefunc("PaperDollFrameItemFlyout_DisplayButton", function(button)
		if not button.isSkinned then
			button.icon = _G[button:GetName().."IconTexture"]

			button:GetNormalTexture():SetTexture(nil)
			button:SetTemplate("Default")
			button:StyleButton()

			button.icon:SetInside()
			button.icon:SetTexCoord(unpack(E.TexCoords))

			E:RegisterCooldown(button.cooldown)
		end

		if not button.location or button.location >= PDFITEMFLYOUT_FIRST_SPECIAL_LOCATION then return end

		local id = EquipmentManager_GetItemInfoByLocation(button.location)
		local _, _, quality = GetItemInfo(id)

		button:SetBackdropBorderColor(GetItemQualityColor(quality))
	end)

	local function handleResistanceFrame(frameName)
		for i = 1, 5 do
			local frame = _G[frameName..i]
			frame:Size(24)
			frame:SetTemplate("Default")

			if i ~= 1 then
				frame:ClearAllPoints()
				frame:Point("TOP", _G[frameName..i-1], "BOTTOM", 0, -(E.Border + E.Spacing))
			end

			local texture, text = frame:GetRegions()

			texture:SetInside()
			texture:SetDrawLayer("ARTWORK")

			text:SetDrawLayer("OVERLAY")
			text:Point("CENTER", -1, 0)

			if i == 1 then		-- Arcane
				-- texWidth, texHeight, cropWidth, cropHeight, offsetX, offsetY = 32, 256, 18, 18, 8, 64
				texture:SetTexCoord(0.25, 0.8125, 0.25, 0.3203125)
			elseif i == 2 then	-- Fire
				-- texWidth, texHeight, cropWidth, cropHeight, offsetX, offsetY = 32, 256, 18, 18, 8, 6
				texture:SetTexCoord(0.25, 0.8125, 0.0234375, 0.09375)
			elseif i == 3 then	-- Nature
				-- texWidth, texHeight, cropWidth, cropHeight, offsetX, offsetY = 32, 256, 18, 18, 8, 35
				texture:SetTexCoord(0.25, 0.8125, 0.13671875, 0.20703125)
			elseif i == 4 then	-- Frost
				-- texWidth, texHeight, cropWidth, cropHeight, offsetX, offsetY = 32, 256, 18, 18, 8, 94
				texture:SetTexCoord(0.25, 0.8125, 0.3671875, 0.4375)
			elseif i == 5 then	-- Shadow
				-- texWidth, texHeight, cropWidth, cropHeight, offsetX, offsetY = 32, 256, 18, 18, 8, 122
				texture:SetTexCoord(0.25, 0.8125, 0.4765625, 0.546875)
			end
		end
	end

	handleResistanceFrame("MagicResFrame")

	-- GearManager Dialog
	GearManagerDialog:StripTextures()
	GearManagerDialog:CreateBackdrop("Transparent")
	GearManagerDialog.backdrop:Point("TOPLEFT", 5, -2)
	GearManagerDialog.backdrop:Point("BOTTOMRIGHT", -3, 4)

	S:SetBackdropHitRect(GearManagerDialog)

	S:HandleCloseButton(GearManagerDialogClose, GearManagerDialog.backdrop)

	for i, button in ipairs(GearManagerDialog.buttons) do
		button:StripTextures()
		button:CreateBackdrop("Default")
		button.backdrop:SetAllPoints()

		button:StyleButton(nil, true)

		button.icon:SetInside()
		button.icon:SetTexCoord(unpack(E.TexCoords))
	end

	S:HandleButton(GearManagerDialogDeleteSet)
	S:HandleButton(GearManagerDialogEquipSet)
	S:HandleButton(GearManagerDialogSaveSet)

	GearSetButton1:Point("TOPLEFT", 15, -29)
	GearSetButton6:Point("TOP", GearSetButton1, "BOTTOM", 0, -13)

	GearManagerDialogDeleteSet:Point("BOTTOMLEFT", 11, 12)
	GearManagerDialogEquipSet:Point("BOTTOMLEFT", 92, 12)
	GearManagerDialogSaveSet:Point("BOTTOMRIGHT", -10, 12)

	-- GearManager DialogPopup
	GearManagerDialogPopup:EnableMouse(true)
	GearManagerDialogPopup:StripTextures()
	GearManagerDialogPopup:CreateBackdrop("Transparent")
	GearManagerDialogPopup.backdrop:Point("TOPLEFT", 5, -10)
	GearManagerDialogPopup.backdrop:Point("BOTTOMRIGHT", -39, 8)

	S:SetBackdropHitRect(GearManagerDialogPopup)

	GearManagerDialogPopupScrollFrame:StripTextures()
	S:HandleScrollBar(GearManagerDialogPopupScrollFrameScrollBar)

	S:HandleEditBox(GearManagerDialogPopupEditBox)

	for i, button in ipairs(GearManagerDialogPopup.buttons) do
		button:StripTextures()
		button:SetFrameLevel(button:GetFrameLevel() + 2)
		button:CreateBackdrop("Default")
		button.backdrop:SetAllPoints()

		button:StyleButton(true, true)

		button.icon:SetInside()
		button.icon:SetTexCoord(unpack(E.TexCoords))

		if i > 1 then
			local lastPos = (i - 1) / NUM_GEARSET_ICONS_PER_ROW

			if lastPos == math.floor(lastPos) then
				button:SetPoint("TOPLEFT", GearManagerDialogPopup.buttons[i-NUM_GEARSET_ICONS_PER_ROW], "BOTTOMLEFT", 0, -7)
			else
				button:SetPoint("TOPLEFT", GearManagerDialogPopup.buttons[i-1], "TOPRIGHT", 7, 0)
			end
		end
	end

	S:HandleButton(GearManagerDialogPopupOkay)
	S:HandleButton(GearManagerDialogPopupCancel)

	local text1, text2 = select(5, GearManagerDialogPopup:GetRegions())
	text1:Point("TOPLEFT", 24, -19)
	text2:Point("TOPLEFT", 24, -63)

	if GetLocale() == "ruRU" then
		text1:SetText(string.utf8sub(GEARSETS_POPUP_TEXT, 0, -7) .. "):")
	end

	GearManagerDialogPopupEditBox:Point("TOPLEFT", 24, -36)

	GearManagerDialogPopupButton1:Point("TOPLEFT", 17, -83)

	GearManagerDialogPopupScrollFrame:SetTemplate("Transparent")
	GearManagerDialogPopupScrollFrame:Size(216, 130)
	GearManagerDialogPopupScrollFrame:Point("TOPRIGHT", -68, -79)
	GearManagerDialogPopupScrollFrameScrollBar:Point("TOPLEFT", GearManagerDialogPopupScrollFrame, "TOPRIGHT", 3, -19)
	GearManagerDialogPopupScrollFrameScrollBar:Point("BOTTOMLEFT", GearManagerDialogPopupScrollFrame, "BOTTOMRIGHT", 3, 19)

	GearManagerDialogPopupOkay:Point("BOTTOMRIGHT", GearManagerDialogPopupCancel, "BOTTOMLEFT", -3, 0)
	GearManagerDialogPopupCancel:Point("BOTTOMRIGHT", -47, 16)

	-- PetPaperDollFrame
	PetPaperDollFrame:StripTextures(true)

	for i = 1, 3 do
		local tab = _G["PetPaperDollFrameTab"..i]
		tab:StripTextures()
		tab:CreateBackdrop("Default", true)
		tab.backdrop:Point("TOPLEFT", 2, -7)
		tab.backdrop:Point("BOTTOMRIGHT", -1, -1)
		S:SetBackdropHitRect(tab)

		tab:HookScript("OnEnter", S.SetModifiedBackdrop)
		tab:HookScript("OnLeave", S.SetOriginalBackdrop)
	end

	-- PetPaperDollFrame PetFrame
	S:HandleRotateButton(PetModelFrameRotateLeftButton)
	S:HandleRotateButton(PetModelFrameRotateRightButton)

	handleResistanceFrame("PetMagicResFrame")

	PetAttributesFrame:StripTextures()

	PetPaperDollFrameExpBar:StripTextures()
	PetPaperDollFrameExpBar:CreateBackdrop("Default")
	PetPaperDollFrameExpBar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(PetPaperDollFrameExpBar)

	S:HandleButton(PetPaperDollCloseButton)

	local function updateHappiness(self)
		local _, isHunterPet = HasPetUI()
		local happiness = GetPetHappiness()
		if not isHunterPet or not happiness then return end

		if happiness == 1 then
			-- texWidth, texHeight, cropWidth, cropHeight, offsetX, offsetY = 128, 64, 16, 16, 52, 4
			self:GetRegions():SetTexCoord(0.40625, 0.53125, 0.0625, 0.3125)
		elseif happiness == 2 then
			-- texWidth, texHeight, cropWidth, cropHeight, offsetX, offsetY = 128, 64, 16, 16, 28, 4
			self:GetRegions():SetTexCoord(0.21875, 0.34375, 0.0625, 0.3125)
		elseif happiness == 3 then
			-- texWidth, texHeight, cropWidth, cropHeight, offsetX, offsetY = 128, 64, 16, 16, 52, 4
			self:GetRegions():SetTexCoord(0.03125, 0.15625, 0.0625, 0.3125)
		end
	end

	PetModelFrame:Width(325)
	PetModelFrame:Point("TOPLEFT", 19, -71)

	PetModelFrameRotateLeftButton:Point("TOPLEFT", PetPaperDollFrame, "TOPLEFT", 23, -75)
	PetModelFrameRotateRightButton:Point("TOPLEFT", PetModelFrameRotateLeftButton, "TOPRIGHT", 3, 0)

	PetResistanceFrame:Point("TOPRIGHT", PetPaperDollFrame, "TOPLEFT", 344, -75)

	PetPaperDollPetInfo:SetFrameLevel(PetModelFrame:GetFrameLevel() + 2)
	PetPaperDollPetInfo:CreateBackdrop("Default")
	PetPaperDollPetInfo:Size(25)
	PetPaperDollPetInfo:Point("TOPLEFT", PetModelFrameRotateLeftButton, "BOTTOMLEFT", 10, -4)
	-- texWidth, texHeight, cropWidth, cropHeight, offsetX, offsetY = 128, 64, 16, 16, 52, 4
	PetPaperDollPetInfo:GetRegions():SetTexCoord(0.03125, 0.15625, 0.0625, 0.3125)

	PetPaperDollPetInfo:RegisterEvent("UNIT_HAPPINESS")
	PetPaperDollPetInfo:SetScript("OnEvent", updateHappiness)
	PetPaperDollPetInfo:SetScript("OnShow", updateHappiness)
	updateHappiness(PetPaperDollPetInfo)

	PetLevelText:Point("CENTER", 0, -50)
	PetAttributesFrame:Point("TOPLEFT", 67, -310)

	PetPaperDollFrameExpBar:Width(323)
	PetPaperDollFrameExpBar:Point("BOTTOMLEFT", 20, 112)

	PetPaperDollCloseButton:Point("CENTER", PetPaperDollFramePetFrame, "TOPLEFT", 304, -417)

	-- PetPaperDollFrame CompanionFrame
	PetPaperDollFrameCompanionFrame:StripTextures()

	S:HandleRotateButton(CompanionModelFrameRotateLeftButton)
	S:HandleRotateButton(CompanionModelFrameRotateRightButton)

	S:HandleButton(CompanionSummonButton)

	S:HandleNextPrevButton(CompanionPrevPageButton)
	S:HandleNextPrevButton(CompanionNextPageButton)

	hooksecurefunc("PetPaperDollFrame_UpdateCompanions", function()
		for i = 1, NUM_COMPANIONS_PER_PAGE do
			local button = _G["CompanionButton"..i]

			if button.creatureID then
				local iconNormal = button:GetNormalTexture()
				iconNormal:SetTexCoord(unpack(E.TexCoords))
				iconNormal:SetInside()
			end
		end
	end)

	for i = 1, NUM_COMPANIONS_PER_PAGE do
		local button = _G["CompanionButton"..i]
		local iconDisabled = button:GetDisabledTexture()
		local activeTexture = _G["CompanionButton"..i.."ActiveTexture"]

		button:StyleButton(nil, true)
		button:SetTemplate("Default", true)

		iconDisabled:SetAlpha(0)

		activeTexture:SetInside(button)
		activeTexture:SetTexture(1, 1, 1, .15)

		if i == 7 then
			button:Point("TOP", CompanionButton1, "BOTTOM", 0, -5)
		elseif i ~= 1 then
			button:Point("LEFT", _G["CompanionButton"..i-1], "RIGHT", 5, 0)
		end
	end

	CompanionModelFrame:Size(325, 174)
	CompanionModelFrame:Point("TOPLEFT", 19, -71)

	CompanionModelFrameRotateLeftButton:Point("TOPLEFT", PetPaperDollFrame, "TOPLEFT", 23, -75)
	CompanionModelFrameRotateRightButton:Point("TOPLEFT", CompanionModelFrameRotateLeftButton, "TOPRIGHT", 3, 0)

	CompanionButton1:Point("TOPLEFT", 58, -308)

	CompanionSummonButton:Width(149)
	CompanionSummonButton:Point("CENTER", -11, -24)

	CompanionPrevPageButton:Point("BOTTOMLEFT", 122, 92)
	CompanionNextPageButton:Point("LEFT", CompanionPrevPageButton, "RIGHT", 83, 0)

	CompanionPageNumber:Point("CENTER", -10, -155)

	-- Reputation Frame
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

	ReputationFrameFactionLabel:Point("TOPLEFT", 70, -60)
	ReputationFrameStandingLabel:Point("TOPLEFT", 235, -60)

	ReputationBar1:Point("TOPRIGHT", -51, -81)

	ReputationListScrollFrame:Width(304)
	ReputationListScrollFrame:Point("TOPRIGHT", -61, -74)
	ReputationListScrollFrameScrollBar:Point("TOPLEFT", ReputationListScrollFrame, "TOPRIGHT", 3, -19)
	ReputationListScrollFrameScrollBar:Point("BOTTOMLEFT", ReputationListScrollFrame, "BOTTOMRIGHT", 3, 19)

	ReputationListScrollFrame:SetScript("OnShow", function()
		ReputationBar1:Point("TOPRIGHT", -75, -81)
	end)
	ReputationListScrollFrame:SetScript("OnHide", function()
		ReputationBar1:Point("TOPRIGHT", -51, -81)
	end)

	-- Reputation DetailFrame
	ReputationDetailFrame:StripTextures()
	ReputationDetailFrame:SetTemplate("Transparent")
	ReputationDetailFrame:Point("TOPLEFT", ReputationFrame, "TOPRIGHT", -33, -12)

	S:HandleCloseButton(ReputationDetailCloseButton, ReputationDetailFrame)

	S:HandleCheckBox(ReputationDetailAtWarCheckBox)
	ReputationDetailAtWarCheckBox:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-SwordCheck")
	S:HandleCheckBox(ReputationDetailInactiveCheckBox)
	S:HandleCheckBox(ReputationDetailMainScreenCheckBox)

	-- Skill Frame
	SkillFrame:StripTextures(true)

	SkillFrameExpandButtonFrame:StripTextures()

	SkillFrameCollapseAllButton:SetNormalTexture(E.Media.Textures.Plus)
	SkillFrameCollapseAllButton.SetNormalTexture = E.noop
	SkillFrameCollapseAllButton:GetNormalTexture():Size(16)
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

		statusBar:Width(276)
		statusBar:CreateBackdrop("Default")
		statusBar:SetStatusBarTexture(E.media.normTex)
		E:RegisterStatusBar(statusBar)

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
	E:RegisterStatusBar(SkillDetailStatusBar)

	S:HandleCloseButton(SkillDetailStatusBarUnlearnButton)
	SkillDetailStatusBarUnlearnButton:SetPoint("LEFT", SkillDetailStatusBarBorder, "RIGHT")
	SkillDetailStatusBarUnlearnButton.Texture:Size(16)
	SkillDetailStatusBarUnlearnButton.Texture:SetVertexColor(1, 0, 0)
	SkillDetailStatusBarUnlearnButton:HookScript("OnEnter", function(btn) btn.Texture:SetVertexColor(1, 1, 1) end)
	SkillDetailStatusBarUnlearnButton:HookScript("OnLeave", function(btn) btn.Texture:SetVertexColor(1, 0, 0) end)

	SkillListScrollFrame:StripTextures()
	S:HandleScrollBar(SkillListScrollFrameScrollBar)

	SkillDetailScrollFrame:StripTextures()
	S:HandleScrollBar(SkillDetailScrollFrameScrollBar)

	S:HandleButton(SkillFrameCancelButton)

	SkillFrameExpandButtonFrame:Point("TOPLEFT", 30, -50)

	SkillTypeLabel1:Point("LEFT", SkillFrame, "TOPLEFT", 22, -85)
	SkillRankFrame1:Point("TOPLEFT", 38, -78)

	SkillListScrollFrame:Width(304)
	SkillListScrollFrame:Point("TOPRIGHT", -61, -74)

	SkillListScrollFrameScrollBar:Point("TOPLEFT", SkillListScrollFrame, "TOPRIGHT", 3, -19)
	SkillListScrollFrameScrollBar:Point("BOTTOMLEFT", SkillListScrollFrame, "BOTTOMRIGHT", 3, 19)

	SkillDetailScrollFrame:Size(304, 98)
	SkillDetailScrollFrame:Point("TOPLEFT", SkillListScrollFrame, "BOTTOMLEFT", 0, -7)

	SkillDetailScrollFrameScrollBar:Point("TOPLEFT", SkillDetailScrollFrame, "TOPRIGHT", 3, -19)
	SkillDetailScrollFrameScrollBar:Point("BOTTOMLEFT", SkillDetailScrollFrame, "BOTTOMRIGHT", 3, 19)

	SkillFrameCancelButton:Point("CENTER", SkillFrame, "TOPLEFT", 304, -417)

	-- Token Frame
	TokenFrame:StripTextures(true)

	select(4, TokenFrame:GetChildren()):Hide()

	S:HandleScrollBar(TokenFrameContainerScrollBar)

	S:HandleButton(TokenFrameCancelButton)

	TokenFrameContainer:Size(304, 360)
	TokenFrameContainer:Point("TOPLEFT", 19, -39)

	TokenFrameContainerScrollBar:Point("TOPLEFT", TokenFrameContainer, "TOPRIGHT", 3, -19)
	TokenFrameContainerScrollBar:Point("BOTTOMLEFT", TokenFrameContainer, "BOTTOMRIGHT", 3, 19)

	TokenFrameMoneyFrame:Point("BOTTOMRIGHT", -115, 88)

	TokenFrameCancelButton:Point("CENTER", TokenFrame, "TOPLEFT", 304, -417)

	TokenFrameContainerScrollBar.Show = function(self)
		TokenFrameContainer:SetWidth(304)
		for _, button in ipairs(TokenFrameContainer.buttons) do
			button:SetWidth(300)
		end
		getmetatable(self).__index.Show(self)
	end

	TokenFrameContainerScrollBar.Hide = function(self)
		TokenFrameContainer:SetWidth(325)
		for _, button in ipairs(TokenFrameContainer.buttons) do
			button:SetWidth(325)
		end
		getmetatable(self).__index.Hide(self)
	end

	local function skinTokenButton(button)
		if not button.isSkinned then
			button.categoryLeft:Kill()
			button.categoryRight:Kill()
			button.highlight:Kill()

			button.expandIcon:Size(16)
			button.expandIcon:SetTexCoord(0, 1, 0, 1)
			button.expandIcon.SetTexCoord = E.noop

			button.isSkinned = true
		end
	end

	local tokenSkinned = 0

	local function updateTokenContainer()
		local offset = HybridScrollFrame_GetOffset(TokenFrameContainer)
		local buttons = TokenFrameContainer.buttons
		local numButtons = #buttons
		local index, button
		local _, name, isHeader, isExpanded, extraCurrencyType, icon

		if numButtons > tokenSkinned then
			for i = tokenSkinned + 1, numButtons do
				skinTokenButton(TokenFrameContainer.buttons[i])
			end

			tokenSkinned = numButtons
		end

		for i = 1, numButtons do
			index = offset + i
			button = buttons[i]

			name, isHeader, isExpanded, _, _, _, extraCurrencyType, icon = GetCurrencyListInfo(index)

			if name then
				if isHeader then
					if isExpanded then
						button.expandIcon:SetTexture(E.Media.Textures.Minus)
					else
						button.expandIcon:SetTexture(E.Media.Textures.Plus)
					end
				else
					if extraCurrencyType == 1 then
						button.icon:SetTexCoord(unpack(E.TexCoords))
					elseif extraCurrencyType == 2 then
						local factionGroup = UnitFactionGroup("player")

						if factionGroup then
							button.icon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionGroup)
							-- texWidth, texHeight, cropWidth, cropHeight, offsetX, offsetY = 64, 64, 36, 36, 4, 1
							button.icon:SetTexCoord(0.0625, 0.625, 0.015625, 0.578125)
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
	end

	hooksecurefunc("TokenFrame_Update", updateTokenContainer)
	hooksecurefunc(TokenFrameContainer, "update", updateTokenContainer)

	-- Token Frame Popup
	TokenFramePopup:StripTextures()
	TokenFramePopup:SetTemplate("Transparent")

	S:HandleCloseButton(TokenFramePopupCloseButton, TokenFramePopup)

	S:HandleCheckBox(TokenFramePopupInactiveCheckBox)
	S:HandleCheckBox(TokenFramePopupBackpackCheckBox)

	TokenFramePopup:Point("TOPLEFT", TokenFrame, "TOPRIGHT", -33, -12)
end)