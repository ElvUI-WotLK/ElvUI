local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local type = type
local unpack = unpack
--WoW API / Variables

S:AddCallback("Skin_Misc", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.misc then return end

	-- ESC/Menu Buttons
	GameMenuFrame:StripTextures()
	GameMenuFrame:CreateBackdrop("Transparent")

	GameMenuFrameHeader:Point("TOP", 0, 7)

	local menuButtons = {
		GameMenuButtonOptions,
		GameMenuButtonSoundOptions,
		GameMenuButtonUIOptions,
	--	GameMenuButtonMacOptions,
		GameMenuButtonKeybindings,
		GameMenuButtonMacros,
	--	GameMenuButtonRatings,
		GameMenuButtonLogout,
		GameMenuButtonQuit,
		GameMenuButtonContinue,

		ElvUI_MenuButton
	}

	for i = 1, #menuButtons do
		local button = menuButtons[i]
		if button then
			S:HandleButton(menuButtons[i])
		end
	end

	-- Static Popups
	for i = 1, 4 do
		local staticPopup = _G["StaticPopup"..i]
		local itemFrame = _G["StaticPopup"..i.."ItemFrame"]
		local itemFrameBox = _G["StaticPopup"..i.."EditBox"]
		local itemFrameTexture = _G["StaticPopup"..i.."ItemFrameIconTexture"]
		local itemFrameNormal = _G["StaticPopup"..i.."ItemFrameNormalTexture"]
		local itemFrameName = _G["StaticPopup"..i.."ItemFrameNameFrame"]
		local closeButton = _G["StaticPopup"..i.."CloseButton"]
		local wideBox = _G["StaticPopup"..i.."WideEditBox"]

		staticPopup:SetTemplate("Transparent")

		S:HandleEditBox(itemFrameBox)
		itemFrameBox.backdrop:Point("TOPLEFT", -2, -4)
		itemFrameBox.backdrop:Point("BOTTOMRIGHT", 2, 4)

		S:HandleEditBox(_G["StaticPopup"..i.."MoneyInputFrameGold"])
		S:HandleEditBox(_G["StaticPopup"..i.."MoneyInputFrameSilver"])
		S:HandleEditBox(_G["StaticPopup"..i.."MoneyInputFrameCopper"])

		for j = 1, itemFrameBox:GetNumRegions() do
			local region = select(j, itemFrameBox:GetRegions())
			if region and region:GetObjectType() == "Texture" then
				if region:GetTexture() == "Interface\\ChatFrame\\UI-ChatInputBorder-Left" or region:GetTexture() == "Interface\\ChatFrame\\UI-ChatInputBorder-Right" then
					region:Kill()
				end
			end
		end

		closeButton:StripTextures()
		S:HandleCloseButton(closeButton, staticPopup)

		itemFrame:GetNormalTexture():Kill()
		itemFrame:SetTemplate()
		itemFrame:StyleButton()

		hooksecurefunc("StaticPopup_Show", function(which, _, _, data)
			local info = StaticPopupDialogs[which]
			if not info then return nil end

			if info.hasItemFrame then
				if data and type(data) == "table" then
					if data.color then
						itemFrame:SetBackdropBorderColor(unpack(data.color))
					else
						itemFrame:SetBackdropBorderColor(1, 1, 1, 1)
					end
				end
			end
		end)

		itemFrameTexture:SetTexCoord(unpack(E.TexCoords))
		itemFrameTexture:SetInside()

		itemFrameNormal:SetAlpha(0)
		itemFrameName:Kill()

		select(8, wideBox:GetRegions()):Hide()
		S:HandleEditBox(wideBox)
		wideBox:Height(22)

		for j = 1, 3 do
			S:HandleButton(_G["StaticPopup"..i.."Button"..j])
		end
	end

	-- Other Frames
	TicketStatusFrameButton:SetTemplate("Transparent")
	AutoCompleteBox:SetTemplate("Transparent")
	ConsolidatedBuffsTooltip:SetTemplate("Transparent")

	-- BNToast Frame
	BNToastFrame:SetTemplate("Transparent")

	BNToastFrameCloseButton:Size(32)
	BNToastFrameCloseButton:Point("TOPRIGHT", "BNToastFrame", 4, 4)

	S:HandleCloseButton(BNToastFrameCloseButton, BNToastFrame)

	-- Ready Check Frame
	ReadyCheckFrame:EnableMouse(true)
	ReadyCheckFrame:SetTemplate("Transparent")

	S:HandleButton(ReadyCheckFrameYesButton)
	ReadyCheckFrameYesButton:SetParent(ReadyCheckFrame)
	ReadyCheckFrameYesButton:ClearAllPoints()
	ReadyCheckFrameYesButton:Point("TOPRIGHT", ReadyCheckFrame, "CENTER", -3, -5)

	S:HandleButton(ReadyCheckFrameNoButton)
	ReadyCheckFrameNoButton:SetParent(ReadyCheckFrame)
	ReadyCheckFrameNoButton:ClearAllPoints()
	ReadyCheckFrameNoButton:Point("TOPLEFT", ReadyCheckFrame, "CENTER", 4, -5)

	ReadyCheckFrameText:SetParent(ReadyCheckFrame)
	ReadyCheckFrameText:Point("TOP", 0, -15)
	ReadyCheckFrameText:SetTextColor(1, 1, 1)

	ReadyCheckListenerFrame:SetAlpha(0)

	-- Coin PickUp Frame
	CoinPickupFrame:StripTextures()
	CoinPickupFrame:SetTemplate("Transparent")

	S:HandleButton(CoinPickupOkayButton)
	S:HandleButton(CoinPickupCancelButton)

	-- Zone Text Frame
	ZoneTextFrame:ClearAllPoints()
	ZoneTextFrame:Point("TOP", UIParent, 0, -128)

	-- Stack Split Frame
	StackSplitFrame:SetTemplate("Transparent")
	StackSplitFrame:GetRegions():Hide()
	StackSplitFrame:SetFrameStrata("DIALOG")

	StackSplitFrame.bg1 = CreateFrame("Frame", nil, StackSplitFrame)
	StackSplitFrame.bg1:SetFrameLevel(StackSplitFrame.bg1:GetFrameLevel() - 1)
	StackSplitFrame.bg1:SetTemplate("Transparent")
	StackSplitFrame.bg1:Point("TOPLEFT", 10, -15)
	StackSplitFrame.bg1:Point("BOTTOMRIGHT", -10, 55)

	S:HandleButton(StackSplitOkayButton)
	S:HandleButton(StackSplitCancelButton)

	-- Opacity Frame
	OpacityFrame:StripTextures()
	OpacityFrame:SetTemplate("Transparent")

	S:HandleSliderFrame(OpacityFrameSlider)

	-- Channel Pullout Frame
	ChannelPullout:SetTemplate("Transparent")

	ChannelPulloutBackground:Kill()

	S:HandleTab(ChannelPulloutTab)
	ChannelPulloutTab:Size(107, 26)
	ChannelPulloutTabText:Point("LEFT", ChannelPulloutTabLeft, "RIGHT", 0, 4)

	S:HandleCloseButton(ChannelPulloutCloseButton, ChannelPullout)
	ChannelPulloutCloseButton:Size(32)

	-- Dropdown Menu
	local checkBoxSkin = E.private.skins.dropdownCheckBoxSkin
	local menuLevel = 0
	local maxButtons = 0

	local function dropDownButtonShow(self)
		if self.notCheckable then
			self.check.backdrop:Hide()
		else
			self.check.backdrop:Show()
		end
	end

	local function skinDropdownMenu()
		local updateButtons = maxButtons < UIDROPDOWNMENU_MAXBUTTONS

		if updateButtons or menuLevel < UIDROPDOWNMENU_MAXLEVELS then
			for i = 1, UIDROPDOWNMENU_MAXLEVELS do
				local frame = _G["DropDownList"..i]

				if not frame.isSkinned then
					_G["DropDownList"..i.."Backdrop"]:SetTemplate("Transparent")
					_G["DropDownList"..i.."MenuBackdrop"]:SetTemplate("Transparent")

					frame.isSkinned = true
				end

				if updateButtons then
					for j = 1, UIDROPDOWNMENU_MAXBUTTONS do
						local button = _G["DropDownList"..i.."Button"..j]

						if not button.isSkinned then
							S:HandleButtonHighlight(_G["DropDownList"..i.."Button"..j.."Highlight"])

							if checkBoxSkin then
								local check = _G["DropDownList"..i.."Button"..j.."Check"]
								check:Size(12)
								check:Point("LEFT", 1, 0)
								check:CreateBackdrop()
								check:SetTexture(E.media.normTex)
								check:SetVertexColor(1, 0.82, 0, 0.8)

								button.check = check
								hooksecurefunc(button, "Show", dropDownButtonShow)
							end

							S:HandleColorSwatch(_G["DropDownList"..i.."Button"..j.."ColorSwatch"], 14)

							button.isSkinned = true
						end
					end
				end
			end

			menuLevel = UIDROPDOWNMENU_MAXLEVELS
			maxButtons = UIDROPDOWNMENU_MAXBUTTONS
		end
	end

	skinDropdownMenu()
	hooksecurefunc("UIDropDownMenu_InitializeHelper", skinDropdownMenu)

	-- Chat Menu
	local chatMenus = {
		"ChatMenu",
		"EmoteMenu",
		"LanguageMenu",
		"VoiceMacroMenu",
	}

	for i = 1, #chatMenus do
		if chatMenus[i] == "ChatMenu" then
			_G[chatMenus[i]]:HookScript("OnShow", function(self)
				self:SetTemplate("Transparent")
				self:SetBackdropColor(unpack(E.media.backdropfadecolor))
				self:ClearAllPoints()
				self:Point("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 0, 30)
			end)
		else
			_G[chatMenus[i]]:HookScript("OnShow", function(self)
				self:SetTemplate("Transparent")
				self:SetBackdropColor(unpack(E.media.backdropfadecolor))
			end)
		end
	end

	for i = 1, 32 do
		_G["ChatMenuButton"..i]:StyleButton()
		_G["EmoteMenuButton"..i]:StyleButton()
		_G["LanguageMenuButton"..i]:StyleButton()
		_G["VoiceMacroMenuButton"..i]:StyleButton()
	end

	local locale = GetLocale()
	if locale == "koKR" then
		S:HandleButton(GameMenuButtonRatings)

		RatingMenuFrame:SetTemplate("Transparent")
		RatingMenuFrameHeader:Kill()
		S:HandleButton(RatingMenuButtonOkay)
	elseif locale == "ruRU" then
		-- Declension Frame
		DeclensionFrame:SetTemplate("Transparent")

		S:HandleNextPrevButton(DeclensionFrameSetPrev)
		S:HandleNextPrevButton(DeclensionFrameSetNext)
		S:HandleButton(DeclensionFrameOkayButton)
		S:HandleButton(DeclensionFrameCancelButton)

		for i = 1, RUSSIAN_DECLENSION_PATTERNS do
			local editBox = _G["DeclensionFrameDeclension"..i.."Edit"]
			if editBox then
				editBox:StripTextures()
				S:HandleEditBox(editBox)
			end
		end
	end
end)