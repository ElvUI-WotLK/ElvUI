local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local unpack = unpack
local fmod = math.fmod
--WoW API / Variables
local hooksecurefunc = hooksecurefunc
local CLASS_SORT_ORDER = CLASS_SORT_ORDER

S:AddCallbackForAddon("Blizzard_Calendar", "Skin_Blizzard_Calendar", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.calendar then return end

	CalendarFrame:StripTextures()
	CalendarFrame:CreateBackdrop("Transparent")
	CalendarFrame.backdrop:Point("TOPLEFT", 3, -7)
	CalendarFrame.backdrop:Point("BOTTOMRIGHT", -2, -4)

	S:SecureHook("Calendar_Show", function()
		S:SetUIPanelWindowInfo(CalendarFrame, "xoffset", 8, nil, true)
		S:SetUIPanelWindowInfo(CalendarFrame, "yoffset", -5, nil, true)
		S:SetUIPanelWindowInfo(CalendarFrame, "width", nil, -8)
		S:SetBackdropHitRect(CalendarFrame)
		S:Unhook("Calendar_Show")
	end)

	CalendarFrameModalOverlay:SetFrameStrata("DIALOG")
	CalendarModalDummy:SetAllPoints(CalendarFrameModalOverlay)
	CalendarFrameBlocker:SetAllPoints(CalendarFrameModalOverlay)

	CalendarFrame:EnableMouseWheel(true)
	CalendarFrame:SetScript("OnMouseWheel", function(_, value)
		if value > 0 then
			if CalendarPrevMonthButton:IsEnabled() == 1 then
				CalendarPrevMonthButton_OnClick()
			end
		else
			if CalendarNextMonthButton:IsEnabled() == 1 then
				CalendarNextMonthButton_OnClick()
			end
		end
	end)

	S:HandleCloseButton(CalendarCloseButton, CalendarFrame.backdrop)

	S:HandleNextPrevButton(CalendarPrevMonthButton)
	S:HandleNextPrevButton(CalendarNextMonthButton)

	CalendarPrevMonthButton:Point("RIGHT", CalendarMonthBackground, "LEFT", 0, -8)
	CalendarNextMonthButton:Point("LEFT", CalendarMonthBackground, "RIGHT", 0, -8)

	do
		local frame = CalendarFilterFrame
		local button = CalendarFilterButton
		local text = CalendarFilterFrameText

		frame:StripTextures()
		frame:Width(155)
		frame:Point("TOPRIGHT", -32, -24)

		text:Point("RIGHT", -34, 3)

		button:Point("RIGHT", frame, "RIGHT", -10, 3)
		button.SetPoint = E.noop

		S:HandleNextPrevButton(button)

		frame:CreateBackdrop("Default")
		frame.backdrop:Point("TOPLEFT", 20, 4)
		frame.backdrop:Point("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)
	end

	local bg = CreateFrame("Frame", "CalendarFrameBackdrop", CalendarFrame)
	bg:SetTemplate("Default")
	bg:SetOutside(CalendarDayButton1, 3, 3, CalendarDayButton42)

	CalendarContextMenu:SetTemplate("Transparent")
	CalendarContextMenu.SetBackdropColor = E.noop
	CalendarContextMenu.SetBackdropBorderColor = E.noop

	CalendarInviteStatusContextMenu:SetTemplate("Transparent")
	CalendarInviteStatusContextMenu.SetBackdropColor = E.noop
	CalendarInviteStatusContextMenu.SetBackdropBorderColor = E.noop

	for i = 1, 7 do
		_G["CalendarContextMenuButton"..i]:StyleButton()
	end

	for i = 1, 42 do
		local button = _G["CalendarDayButton"..i]
		local eventTexture = _G["CalendarDayButton"..i.."EventTexture"]
		local overlayFrame = _G["CalendarDayButton"..i.."OverlayFrame"]
		button:SetFrameLevel(button:GetFrameLevel() + 1)
		button:Size(91 - E.Border)
		button:SetTemplate("Default", nil, true)
		button:SetBackdropColor(0, 0, 0, 0)
		button:GetNormalTexture():SetInside()
		button:GetNormalTexture():SetDrawLayer("BACKGROUND")
		button:GetHighlightTexture():SetInside()
		button:GetHighlightTexture():SetTexture(1, 1, 1, 0.3)
		eventTexture:SetInside()
		overlayFrame:SetInside()

		hooksecurefunc(eventTexture, "SetTexCoord", function(self, left, right, top, bottom)
			if left == 0 and right == 1 and top == 0 and bottom == 1 then
				if self._blocked then return end

				self._blocked = true
				self:SetTexCoord(unpack(E.TexCoords))
				self._blocked = nil
			end
		end)

		for j = 1, 4 do
			local EventButton = _G["CalendarDayButton"..i.."EventButton"..j]
			EventButton:StripTextures()
			EventButton:StyleButton()
		end

		button:ClearAllPoints()
		if i == 1 then
			button:SetPoint("TOPLEFT", CalendarWeekday1Background, "BOTTOMLEFT", 0, 0)
		elseif fmod(i, 7) == 1 then
			button:SetPoint("TOPLEFT", _G["CalendarDayButton"..(i - 7)], "BOTTOMLEFT", 0, -E.Border)
		else
			button:SetPoint("TOPLEFT", _G["CalendarDayButton"..(i - 1)], "TOPRIGHT", E.Border, 0)
		end
	end

	CalendarTodayFrame:StripTextures()
	CalendarTodayFrame:SetTemplate("Default")
	CalendarTodayFrame:Size(CalendarDayButton1:GetWidth(), CalendarDayButton1:GetHeight())
	CalendarTodayFrame:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
	local value = E.db.general.valuecolor
	CalendarTodayFrame:SetBackdropColor(value.r, value.g, value.b, 0.5)
	CalendarTodayFrame:HookScript("OnUpdate", function(self) self:SetAlpha(CalendarTodayTextureGlow:GetAlpha()) end)
	CalendarTodayFrame:CreateShadow()
	CalendarTodayFrame.shadow:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))

	CalendarCreateEventFrame:StripTextures()
	CalendarCreateEventFrame:SetTemplate("Transparent")
	CalendarCreateEventFrame:Point("TOPLEFT", CalendarFrame, "TOPRIGHT", -3, -7)
	CalendarCreateEventTitleFrame:StripTextures()

	CalendarCreateEventFrameModalOverlay:SetAllPoints(CalendarCreateEventFrame)
	CalendarCreateEventFrameModalOverlay:SetFrameStrata("DIALOG")
	CalendarEventFrameBlocker:SetAllPoints(CalendarCreateEventFrameModalOverlay)

	S:HandleButton(CalendarCreateEventCreateButton, true)
	S:HandleButton(CalendarCreateEventMassInviteButton, true)
	S:HandleButton(CalendarCreateEventInviteButton, true)
	CalendarCreateEventInviteButton:Point("TOPLEFT", CalendarCreateEventInviteEdit, "TOPRIGHT", 4, 1)
	CalendarCreateEventInviteEdit:Width(CalendarCreateEventInviteEdit:GetWidth() - 2)

	CalendarCreateEventInviteList:StripTextures()
	CalendarCreateEventInviteList:SetTemplate("Default")

	S:HandleEditBox(CalendarCreateEventInviteEdit)
	S:HandleEditBox(CalendarCreateEventTitleEdit)
	S:HandleDropDownBox(CalendarCreateEventTypeDropDown, 157)

	CalendarCreateEventDescriptionContainer:StripTextures()
	CalendarCreateEventDescriptionContainer:SetTemplate("Default")

	S:HandleCloseButton(CalendarCreateEventCloseButton, CalendarCreateEventFrame)

	S:HandleCheckBox(CalendarCreateEventLockEventCheck)

	S:HandleDropDownBox(CalendarCreateEventHourDropDown, 68)
	S:HandleDropDownBox(CalendarCreateEventMinuteDropDown, 68)
	S:HandleDropDownBox(CalendarCreateEventAMPMDropDown, 68)
	S:HandleDropDownBox(CalendarCreateEventRepeatOptionDropDown, 157)

	CalendarCreateEventIcon:CreateBackdrop()
	CalendarCreateEventIcon:Point("TOPLEFT", 14, -26)
	CalendarCreateEventIcon:SetTexCoord(unpack(E.TexCoords))
	CalendarCreateEventIcon.SetTexCoord = E.noop

	CalendarCreateEventTitleEdit:Size(160, 18)
	CalendarCreateEventTitleEdit:Point("TOPLEFT", 14, -85)

	CalendarCreateEventTypeDropDown:Point("TOPLEFT", 158, -81)

	CalendarCreateEventHourDropDown:Point("TOPLEFT", -7, -108)
	CalendarCreateEventMinuteDropDown:Point("LEFT", CalendarCreateEventHourDropDown, "RIGHT", -23, 0)
	CalendarCreateEventAMPMDropDown:Point("LEFT", CalendarCreateEventMinuteDropDown, "RIGHT", -23, 0)

	CalendarCreateEventRepeatOptionDropDown:Point("TOPLEFT", 158, -108)

	CalendarCreateEventDescriptionContainer:Size(294, 68)
	CalendarCreateEventDescriptionContainer:Point("TOPLEFT", 13, -138)

	CalendarCreateEventLockEventCheck:Point("TOPRIGHT", -122, 1)

	CalendarCreateEventInviteList:Point("TOP", 0, -43)
	CalendarCreateEventInviteEdit:Point("TOPLEFT", CalendarCreateEventInviteList, "BOTTOMLEFT", 1, -8)
	CalendarCreateEventMassInviteButton:Point("BOTTOMLEFT", 13, 13)
	CalendarCreateEventCreateButton:Point("BOTTOMRIGHT", -13, 13)

	CalendarCreateEventInviteListSection:StripTextures()

	CalendarClassButtonContainer:HookScript("OnShow", function()
		for i, class in ipairs(CLASS_SORT_ORDER) do
			local button = _G["CalendarClassButton"..i]
			button:StripTextures()
			button:CreateBackdrop("Default")
			button:Size(23)

			local coords = CLASS_ICON_TCOORDS[class]
			local buttonIcon = button:GetNormalTexture()
			buttonIcon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
			buttonIcon:SetTexCoord(coords[1] + 0.02, coords[2] - 0.02, coords[3] + 0.02, coords[4] - 0.02)
		end

		CalendarClassButton1:Point("TOPLEFT", 2, 0)

		CalendarClassTotalsButton:StripTextures()
		CalendarClassTotalsButton:CreateBackdrop("Default")
		CalendarClassTotalsButton:Size(23)
	end)

	-- Texture Picker Frame
	CalendarTexturePickerFrame:StripTextures()
	CalendarTexturePickerTitleFrame:StripTextures()

	CalendarTexturePickerFrame:SetTemplate("Transparent")
	CalendarTexturePickerFrame:Width(280)
	CalendarTexturePickerFrame:ClearAllPoints()
	CalendarTexturePickerFrame:Point("TOPLEFT", CalendarEventFrameBlocker, "TOPRIGHT", 31, 0)

	S:HandleScrollBar(CalendarTexturePickerScrollBar)
	S:HandleButton(CalendarTexturePickerAcceptButton, true)
	S:HandleButton(CalendarTexturePickerCancelButton, true)
	S:HandleButton(CalendarCreateEventInviteButton, true)
	S:HandleButton(CalendarCreateEventRaidInviteButton, true)

	for i = 1, 16 do
		_G["CalendarTexturePickerScrollFrameButton"..i]:StyleButton()
	end

	CalendarTexturePickerScrollFrame:CreateBackdrop("Transparent")
	CalendarTexturePickerScrollFrame.backdrop:Point("TOPLEFT", -2, 2)
	CalendarTexturePickerScrollFrame.backdrop:Point("BOTTOMRIGHT", 2, -4)

	CalendarTexturePickerScrollFrame:Point("TOPLEFT", 10, -20)

	CalendarTexturePickerScrollBar:Point("TOPLEFT", CalendarTexturePickerScrollFrame, "TOPRIGHT", 5, -17)
	CalendarTexturePickerScrollBar:Point("BOTTOMLEFT", CalendarTexturePickerScrollFrame, "BOTTOMRIGHT", 5, 15)

	CalendarTexturePickerCancelButton:Point("BOTTOMRIGHT", -8, 8)

	-- Mass Invite Frame
	CalendarMassInviteFrame:StripTextures()
	CalendarMassInviteFrame:SetTemplate("Transparent")

	S:HandleCloseButton(CalendarMassInviteCloseButton, CalendarMassInviteFrame)

	CalendarMassInviteTitleFrame:StripTextures()

	S:HandleDropDownBox(CalendarMassInviteGuildRankMenu, 140)

	S:HandleEditBox(CalendarMassInviteGuildMinLevelEdit)
	S:HandleEditBox(CalendarMassInviteGuildMaxLevelEdit)

	S:HandleButton(CalendarMassInviteGuildAcceptButton)
	S:HandleButton(CalendarMassInviteArenaButton2)
	S:HandleButton(CalendarMassInviteArenaButton3)
	S:HandleButton(CalendarMassInviteArenaButton5)

	CalendarMassInviteFrame:Size(307, 179)
	CalendarMassInviteFrame:ClearAllPoints()
	CalendarMassInviteFrame:Point("TOPLEFT", CalendarCreateEventFrame, "TOPRIGHT", 31, 0)

	CalendarMassInviteGuildLevelText:Point("TOPLEFT", 40, -53)

	CalendarMassInviteFrameLevelDivider:Point("TOPLEFT", 51, -74)
	CalendarMassInviteGuildMinLevelEdit:Height(18)
	CalendarMassInviteGuildMinLevelEdit:Point("TOPLEFT", 20, -72)
	CalendarMassInviteGuildMaxLevelEdit:Height(18)
	CalendarMassInviteGuildMaxLevelEdit:Point("TOPLEFT", 65, -72)

	CalendarMassInviteGuildRankText:Point("TOPLEFT", 188, -53)
	CalendarMassInviteGuildRankMenu:Point("TOPLEFT", 167, -68)

	CalendarMassInviteGuildAcceptButton:Point("TOPRIGHT", -8, -100)

	CalendarMassInviteArenaButton2:Point("TOPLEFT", 8, -149)
	CalendarMassInviteArenaButton3:Point("TOP", 0, -149)
	CalendarMassInviteArenaButton5:Point("TOPRIGHT", -8, -149)

	select(6, CalendarMassInviteFrame:GetRegions()):Point("TOP", 0, -130)

	-- Raid View
	CalendarViewRaidFrame:StripTextures()
	CalendarViewRaidFrame:SetTemplate("Transparent")
	CalendarViewRaidFrame:Point("TOPLEFT", CalendarFrame, "TOPRIGHT", -3, -7)

	S:HandleCloseButton(CalendarViewRaidCloseButton, CalendarViewRaidFrame)

	CalendarViewRaidTitleFrame:StripTextures()

	-- Holiday View
	CalendarViewHolidayFrame:StripTextures(true)
	CalendarViewHolidayFrame:SetTemplate("Transparent")
	CalendarViewHolidayFrame:Point("TOPLEFT", CalendarFrame, "TOPRIGHT", -3, -7)
	CalendarViewHolidayTitleFrame:StripTextures()
	S:HandleCloseButton(CalendarViewHolidayCloseButton, CalendarViewHolidayFrame)

	-- Event View
	CalendarViewEventFrame:StripTextures()
	CalendarViewEventFrame:SetTemplate("Transparent")
	CalendarViewEventFrame:Point("TOPLEFT", CalendarFrame, "TOPRIGHT", -3, -7)

	S:HandleCloseButton(CalendarViewEventCloseButton, CalendarViewEventFrame)

	CalendarViewEventTitleFrame:StripTextures()

	CalendarViewEventDescriptionContainer:StripTextures()
	CalendarViewEventDescriptionContainer:SetTemplate("Transparent")

	CalendarViewEventInviteList:StripTextures()
	CalendarViewEventInviteList:SetTemplate("Transparent")
	CalendarViewEventInviteListSection:StripTextures()

	S:HandleScrollBar(CalendarViewEventDescriptionScrollFrameScrollBar)
	S:HandleScrollBar(CalendarViewEventInviteListScrollFrameScrollBar)

	CalendarViewEventFrameModalOverlay:SetAllPoints(CalendarViewEventFrame)
	CalendarViewEventFrameModalOverlay:SetFrameStrata("DIALOG")

	S:HandleButton(CalendarViewEventAcceptButton)
	S:HandleButton(CalendarViewEventTentativeButton)
	S:HandleButton(CalendarViewEventRemoveButton)
	S:HandleButton(CalendarViewEventDeclineButton)

	CalendarViewEventIcon:CreateBackdrop()
	CalendarViewEventIcon:SetTexCoord(unpack(E.TexCoords))
	CalendarViewEventIcon.SetTexCoord = E.noop

	CalendarViewEventDescriptionContainer:Size(294, 68)
	CalendarViewEventDescriptionContainer:Point("TOPLEFT", 13, -94)

	CalendarViewEventDescriptionScrollFrameScrollBar:Point("TOPLEFT", CalendarViewEventDescriptionScrollFrame, "TOPRIGHT", 4, -15)
	CalendarViewEventDescriptionScrollFrameScrollBar:Point("BOTTOMLEFT", CalendarViewEventDescriptionScrollFrame, "BOTTOMRIGHT", 4, 15)

	CalendarViewEventInviteListScrollFrameScrollBar:Point("TOPLEFT", CalendarViewEventInviteListScrollFrame, "TOPRIGHT", 7, -16)
	CalendarViewEventInviteListScrollFrameScrollBar:Point("BOTTOMLEFT", CalendarViewEventInviteListScrollFrame, "BOTTOMRIGHT", 7, 16)

	CalendarViewEventIcon:Point("TOPLEFT", 14, -26)

	CalendarViewEventInviteListSection:Point("TOPLEFT", 0, -177)

	-- Event Picker Frame
	CalendarEventPickerFrame:StripTextures()
	CalendarEventPickerTitleFrame:StripTextures()

	CalendarEventPickerFrame:SetTemplate("Transparent")
	CalendarEventPickerFrame:SetFrameLevel(CalendarFrameModalOverlay:GetFrameLevel() + 10)

	S:HandleScrollBar(CalendarEventPickerScrollBar)
	S:HandleButton(CalendarEventPickerCloseButton, true)

	CalendarEventPickerScrollFrame:Width(253)
	CalendarEventPickerScrollFrame:Point("TOPLEFT", 8, -22)

	CalendarEventPickerScrollBar:Point("TOPLEFT", CalendarEventPickerScrollFrame, "TOPRIGHT", 3, -19)
	CalendarEventPickerScrollBar:Point("BOTTOMLEFT", CalendarEventPickerScrollFrame, "BOTTOMRIGHT", 3, 17)

	CalendarEventPickerCloseButton:Point("BOTTOMRIGHT", -8, 8)

	-- Create Event
	S:HandleScrollBar(CalendarCreateEventDescriptionScrollFrameScrollBar)
	S:HandleScrollBar(CalendarCreateEventInviteListScrollFrameScrollBar)

	CalendarCreateEventDescriptionScrollFrameScrollBar:Point("TOPLEFT", CalendarCreateEventDescriptionScrollFrame, "TOPRIGHT", 4, -15)
	CalendarCreateEventDescriptionScrollFrameScrollBar:Point("BOTTOMLEFT", CalendarCreateEventDescriptionScrollFrame, "BOTTOMRIGHT", 4, 15)

	CalendarCreateEventInviteListScrollFrameScrollBar:Point("TOPLEFT", CalendarCreateEventInviteListScrollFrame, "TOPRIGHT", 7, -16)
	CalendarCreateEventInviteListScrollFrameScrollBar:Point("BOTTOMLEFT", CalendarCreateEventInviteListScrollFrame, "BOTTOMRIGHT", 7, 16)

	if CalendarCreateEventInviteListScrollFrame.buttons then
		for _, button in ipairs(CalendarCreateEventInviteListScrollFrame.buttons) do
			S:HandleButtonHighlight(button)
		end
	else
		CalendarCreateEventInviteList:HookScript("OnEvent", function(self, event)
			if event == "ADDON_LOADED" then
				for _, button in ipairs(self.scrollFrame.buttons) do
					S:HandleButtonHighlight(button)
				end
			end
		end)
	end
end)