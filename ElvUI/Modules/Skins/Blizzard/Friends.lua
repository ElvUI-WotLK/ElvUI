local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local ipairs = ipairs
local unpack = unpack
local floor = math.floor
--WoW API / Variables
local GetGuildRosterInfo = GetGuildRosterInfo
local GetNumRaidMembers = GetNumRaidMembers
local GetNumWhoResults = GetNumWhoResults
local GetWhoInfo = GetWhoInfo
local PlaySound = PlaySound

local GUILDMEMBERS_TO_DISPLAY = GUILDMEMBERS_TO_DISPLAY
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local WHOS_TO_DISPLAY = WHOS_TO_DISPLAY

S:AddCallback("Skin_Friends", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.friends then return end

	-- Friends Frame
	FriendsFrame:StripTextures(true)
	FriendsFrame:CreateBackdrop("Transparent")
	FriendsFrame.backdrop:Point("TOPLEFT", 11, -12)
	FriendsFrame.backdrop:Point("BOTTOMRIGHT", -32, 76)

	S:SetUIPanelWindowInfo(FriendsFrame, "width")
	S:SetBackdropHitRect(FriendsFrame)

	S:HandleCloseButton(FriendsFrameCloseButton, FriendsFrame.backdrop)

	S:HandleDropDownBox(FriendsFrameStatusDropDown, 70)

	S:HandleEditBox(FriendsFrameBroadcastInput)

	for i = 1, 2 do
		local tab = _G["FriendsTabHeaderTab"..i]
		tab:StripTextures()
		tab:CreateBackdrop("Default", true)
		tab.backdrop:Point("TOPLEFT", 3, -7)
		tab.backdrop:Point("BOTTOMRIGHT", -2, -1)

		tab:HookScript("OnEnter", S.SetModifiedBackdrop)
		tab:HookScript("OnLeave", S.SetOriginalBackdrop)
	end

	for i = 1, 5 do
		S:HandleTab(_G["FriendsFrameTab"..i])
	end

	FriendsFrameStatusDropDown:Point("TOPLEFT", FriendsListFrame, "TOPLEFT", 0, -37)

	FriendsFrameStatusDropDownMouseOver:Size(22, 18)
	FriendsFrameStatusDropDownMouseOver:Point("TOPLEFT", 21, -4)

	FriendsFrameStatusDropDownStatus:Point("LEFT", 25, 3)

	FriendsFrameBroadcastInput:Width(241)
	FriendsFrameBroadcastInput:Point("TOPLEFT", FriendsFrameStatusDropDown, "TOPRIGHT", 11, -3)

	FriendsTabHeaderTab1:Point("TOPLEFT", 30, -60)

	-- Friends List Frame
	for i = 1, FRIENDS_FRIENDS_TO_DISPLAY do
		_G["FriendsFrameFriendsScrollFrameButton"..i.."SummonButton"]:StyleButton()
		_G["FriendsFrameFriendsScrollFrameButton"..i.."SummonButtonIcon"]:SetTexCoord(unpack(E.TexCoords))
		_G["FriendsFrameFriendsScrollFrameButton"..i.."SummonButtonNormalTexture"]:SetAlpha(0)
	end

	S:HandleScrollBar(FriendsFrameFriendsScrollFrameScrollBar)

	S:HandleButton(FriendsFrameAddFriendButton, true)
	S:HandleButton(FriendsFrameSendMessageButton, true)

	FriendsFrameFriendsScrollFrame:Width(304)
	FriendsFrameFriendsScrollFrame:Point("TOPLEFT", FriendsFrame, 19, -92)

	FriendsFrameFriendsScrollFrameScrollBar:Point("TOPRIGHT", FriendsFrame, "TOPRIGHT", -40, -111)
	FriendsFrameFriendsScrollFrameScrollBar:Point("BOTTOMLEFT", FriendsFrameFriendsScrollFrame, "BOTTOMRIGHT", 3, 19)

	FriendsFrameAddFriendButton:Height(22)
	FriendsFrameAddFriendButton:Point("BOTTOMLEFT", FriendsFrame, 19, 84)

	FriendsFrameSendMessageButton:Height(22)
	FriendsFrameSendMessageButton:Point("BOTTOMRIGHT", FriendsFrame, -40, 84)

	-- Ignore List Frame
	S:HandleScrollBar(FriendsFrameIgnoreScrollFrameScrollBar)

	S:HandleButton(FriendsFrameIgnorePlayerButton, true)
	S:HandleButton(FriendsFrameUnsquelchButton, true)

	for i = 1, IGNORES_TO_DISPLAY do
		S:HandleButtonHighlight(_G["FriendsFrameIgnoreButton"..i])
	end

	FriendsFrameIgnoreButton1:Point("TOPLEFT", FriendsFrame, "TOPLEFT", 22, -95)

	FriendsFrameIgnoreScrollFrame:Width(304)
	FriendsFrameIgnoreScrollFrame:Point("TOPRIGHT", FriendsFrame, "TOPRIGHT", -61, -92)

	FriendsFrameIgnoreScrollFrameScrollBar:Point("TOPLEFT", FriendsFrameIgnoreScrollFrame, "TOPRIGHT", 3, -19)
	FriendsFrameIgnoreScrollFrameScrollBar:Point("BOTTOMLEFT", FriendsFrameIgnoreScrollFrame, "BOTTOMRIGHT", 3, 21)

	FriendsFrameIgnorePlayerButton:Height(22)
	FriendsFrameIgnorePlayerButton:Point("BOTTOMLEFT", FriendsFrame, 19, 84)

	FriendsFrameUnsquelchButton:Height(22)
	FriendsFrameUnsquelchButton:Point("BOTTOMRIGHT", FriendsFrame, -40, 84)

	-- Who Frame
	S:HandleDropDownBox(WhoFrameDropDown)
	S:SetBackdropHitRect(WhoFrameDropDown)

	for i = 1, 4 do
		local header = _G["WhoFrameColumnHeader"..i]
		header:StripTextures()
		header:StyleButton()
	end

	for i = 1, WHOS_TO_DISPLAY do
		local button = _G["WhoFrameButton"..i]
		local level = _G["WhoFrameButton"..i.."Level"]
		local name = _G["WhoFrameButton"..i.."Name"]
		local class = _G["WhoFrameButton"..i.."Class"]

		button.icon = button:CreateTexture("$parentIcon", "ARTWORK")
		button.icon:Size(15)
		button.icon:Point("LEFT", 45, 0)
		button.icon:SetTexture("Interface\\WorldStateFrame\\Icons-Classes")

		button:CreateBackdrop("Default", true)
		button.backdrop:SetAllPoints(button.icon)
		S:HandleButtonHighlight(button)

		level:ClearAllPoints()
		level:SetPoint("TOPLEFT", 11, -1)

		name:Size(100, 14)
		name:ClearAllPoints()
		name:Point("LEFT", 85, 0)

		class:Hide()
	end

	WhoListScrollFrame:StripTextures()
	S:HandleScrollBar(WhoListScrollFrameScrollBar)

	S:HandleEditBox(WhoFrameEditBox)

	S:HandleButton(WhoFrameWhoButton)
	S:HandleButton(WhoFrameAddFriendButton)
	S:HandleButton(WhoFrameGroupInviteButton)

	WhoFrameColumnHeader3:ClearAllPoints()
	WhoFrameColumnHeader3:Point("TOPLEFT", 20, -48)

	WhoFrameColumnHeader4:ClearAllPoints()
	WhoFrameColumnHeader4:Point("LEFT", WhoFrameColumnHeader3, "RIGHT", -2, 0)
	WhoFrameColumn_SetWidth(WhoFrameColumnHeader4, 48)

	WhoFrameColumnHeader1:ClearAllPoints()
	WhoFrameColumnHeader1:Point("LEFT", WhoFrameColumnHeader4, "RIGHT", -2, 0)
	WhoFrameColumn_SetWidth(WhoFrameColumnHeader1, 105)

	WhoFrameColumnHeader2:ClearAllPoints()
	WhoFrameColumnHeader2:Point("LEFT", WhoFrameColumnHeader1, "RIGHT", -6, 1)

	WhoFrameButton1:Point("TOPLEFT", 17, -75)

	WhoListScrollFrame:Size(304, 284)
	WhoListScrollFrame:Point("TOPRIGHT", FriendsFrame, "TOPRIGHT", -61, -71)

	WhoListScrollFrameScrollBar:Point("TOPLEFT", WhoListScrollFrame, "TOPRIGHT", 3, -19)
	WhoListScrollFrameScrollBar:Point("BOTTOMLEFT", WhoListScrollFrame, "BOTTOMRIGHT", 3, 19)

	WhoFrameTotals:Point("BOTTOM", -10, 137)

	WhoFrameEditBox:Size(323, 18)
	WhoFrameEditBox:Point("BOTTOM", -11, 114)

	WhoFrameGroupInviteButton:Width(117)
	WhoFrameAddFriendButton:Width(117)
	WhoFrameGroupInviteButton:Point("BOTTOMRIGHT", -40, 84)
	WhoFrameAddFriendButton:Point("RIGHT", WhoFrameGroupInviteButton, "LEFT", -3, 0)
	WhoFrameWhoButton:Point("RIGHT", WhoFrameAddFriendButton, "LEFT", -3, 0)

	hooksecurefunc("WhoList_Update", function()
		local numWhos = GetNumWhoResults()
		if numWhos == 0 then return end

		numWhos = numWhos > WHOS_TO_DISPLAY and WHOS_TO_DISPLAY or numWhos

		local _, level, classFileName
		local button, buttonText, classTextColor, levelTextColor

		for i = 1, numWhos do
			button = _G["WhoFrameButton"..i]
			_, _, level, _, _, _, classFileName = GetWhoInfo(button.whoIndex)

			if classFileName then
				classTextColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[classFileName] or RAID_CLASS_COLORS[classFileName]
				button.icon:Show()
				button.icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[classFileName]))
			else
				classTextColor = HIGHLIGHT_FONT_COLOR
				button.icon:Hide()
			end

			levelTextColor = GetQuestDifficultyColor(level)

			buttonText = _G["WhoFrameButton"..i.."Name"]
			buttonText:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b)
			buttonText = _G["WhoFrameButton"..i.."Level"]
			buttonText:SetTextColor(levelTextColor.r, levelTextColor.g, levelTextColor.b)
			buttonText = _G["WhoFrameButton"..i.."Class"]
			buttonText:SetTextColor(1.0, 1.0, 1.0)
		end
	end)

	-- Guild Frame
	S:HandleCheckBox(GuildFrameLFGButton)

	GuildFrameLFGFrame:StripTextures()
	GuildFrameLFGFrame:SetTemplate("Default")

	GuildListScrollFrame:StripTextures()
	S:HandleScrollBar(GuildListScrollFrameScrollBar)

	S:HandleNextPrevButton(GuildFrameGuildListToggleButton)

	S:HandleButton(GuildFrameGuildInformationButton)
	S:HandleButton(GuildFrameAddMemberButton)
	S:HandleButton(GuildFrameControlButton)

	for i = 1, GUILDMEMBERS_TO_DISPLAY do
		local button = _G["GuildFrameButton"..i]
		local level = _G["GuildFrameButton"..i.."Level"]
		local name = _G["GuildFrameButton"..i.."Name"]
		local class = _G["GuildFrameButton"..i.."Class"]
		local statusButton = _G["GuildFrameGuildStatusButton"..i]
		local statusName = _G["GuildFrameGuildStatusButton"..i.."Name"]

		button.icon = button:CreateTexture("$parentIcon", "ARTWORK")
		button.icon:Size(15)
		button.icon:Point("LEFT", 48, 0)
		button.icon:SetTexture("Interface\\WorldStateFrame\\Icons-Classes")

		button:CreateBackdrop("Default", true)
		button.backdrop:SetAllPoints(button.icon)

		S:HandleButtonHighlight(button)
		S:HandleButtonHighlight(statusButton)

		level:ClearAllPoints()
		level:Point("TOPLEFT", 10, -1)

		name:Size(100, 14)
		name:ClearAllPoints()
		name:Point("LEFT", 85, 0)

		class:Hide()

		statusName:ClearAllPoints()
		statusName:SetPoint("LEFT", 10, 0)
	end

	for i = 1, 4 do
		local header = _G["GuildFrameColumnHeader"..i]
		header:StripTextures()
		header:StyleButton()

		header = _G["GuildFrameGuildStatusColumnHeader"..i]
		header:StripTextures()
		header:StyleButton()
	end

	GuildFrameColumnHeader3:ClearAllPoints()
	GuildFrameColumnHeader3:Point("TOPLEFT", 20, -66)
	WhoFrameColumn_SetWidth(GuildFrameColumnHeader3, 32)

	GuildFrameColumnHeader4:ClearAllPoints()
	GuildFrameColumnHeader4:Point("LEFT", GuildFrameColumnHeader3, "RIGHT", -2, 0)
	WhoFrameColumn_SetWidth(GuildFrameColumnHeader4, 48)

	GuildFrameColumnHeader1:ClearAllPoints()
	GuildFrameColumnHeader1:Point("LEFT", GuildFrameColumnHeader4, "RIGHT", -2, 0)
	WhoFrameColumn_SetWidth(GuildFrameColumnHeader1, 105)

	GuildFrameColumnHeader2:ClearAllPoints()
	GuildFrameColumnHeader2:Point("LEFT", GuildFrameColumnHeader1, "RIGHT", -2, 0)
	WhoFrameColumn_SetWidth(GuildFrameColumnHeader2, 127)

	GuildFrameGuildStatusColumnHeader1:Point("TOPLEFT", 20, -66)

	GuildFrameButton1:Point("TOPLEFT", GuildFrame, "TOPLEFT", 17, -93)
	GuildFrameGuildStatusButton1:Point("TOPLEFT", GuildFrame, "TOPLEFT", 17, -93)

	GuildListScrollFrame:Size(304, 220)
	GuildListScrollFrame:Point("TOPRIGHT", -61, -89)

	GuildListScrollFrameScrollBar:Point("TOPLEFT", GuildListScrollFrame, "TOPRIGHT", 3, -19)
	GuildListScrollFrameScrollBar:Point("BOTTOMLEFT", GuildListScrollFrame, "BOTTOMRIGHT", 3, 19)

	GuildFrameTotals:Point("BOTTOM", GuildFrame, "LEFT", 82, -77)

	GuildFrameGuildListToggleButton:Point("LEFT", 305, -69)
	GuildFrameGuildListToggleButton.SetPoint = E.noop

	GuildFrameNotesLabel:Point("TOPLEFT", 19, -340)
	GuildFrameNotesText:Width(325)

	GuildFrameGuildInformationButton:Width(121)
	GuildFrameControlButton:Width(100)
	GuildFrameGuildInformationButton:Point("RIGHT", GuildFrameAddMemberButton, "LEFT", -3, 0)
	GuildFrameAddMemberButton:Point("RIGHT", GuildFrameControlButton, "LEFT", -3, 0)
	GuildFrameControlButton:Point("BOTTOMRIGHT", -40, 84)

	hooksecurefunc("GuildStatus_Update", function()
		local _, online, classFileName, button, classTextColor

		if FriendsFrame.playerStatusFrame then
			local level, buttonText, levelTextColor

			for i = 1, GUILDMEMBERS_TO_DISPLAY do
				button = _G["GuildFrameButton"..i]
				_, _, _, level, _, _, _, _, online, _, classFileName = GetGuildRosterInfo(button.guildIndex)
				if classFileName then
					if online then
						classTextColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[classFileName] or RAID_CLASS_COLORS[classFileName]
						levelTextColor = GetQuestDifficultyColor(level)
						buttonText = _G["GuildFrameButton"..i.."Name"]
						buttonText:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b)
						buttonText = _G["GuildFrameButton"..i.."Level"]
						buttonText:SetTextColor(levelTextColor.r, levelTextColor.g, levelTextColor.b)
					end
					button.icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[classFileName]))
				end
			end
		else
			for i = 1, GUILDMEMBERS_TO_DISPLAY do
				button = _G["GuildFrameGuildStatusButton"..i]
				_, _, _, _, _, _, _, _, online, _, classFileName = GetGuildRosterInfo(button.guildIndex)
				if classFileName then
					if online then
						classTextColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[classFileName] or RAID_CLASS_COLORS[classFileName]
						_G["GuildFrameGuildStatusButton"..i.."Name"]:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b)
						_G["GuildFrameGuildStatusButton"..i.."Online"]:SetTextColor(1.0, 1.0, 1.0)
					end
				end
			end
		end
	end)

	GuildControlPopupFrame:SetScript("OnShow", function(self) -- fix error in case frame opened before GUILD_ROSTER_UPDATE event; fix taint; adjust UIPanel spacing
		if not self.rank then
			self.rank = GuildControlGetRankName(1)
			UIDropDownMenu_SetSelectedID(GuildControlPopupFrameDropDown, 1)
			UIDropDownMenu_SetText(GuildControlPopupFrameDropDown, self.rank)
		end

		FriendsFrame.guildControlShow = 1
		GuildControlPopupAcceptButton:Disable()
		GuildControlPopupframe_Update()

		S:SetUIPanelWindowInfo(FriendsFrame, "width", nil, floor(self.backdrop:GetWidth() + 0.5) - 1)
	end)

	GuildControlPopupFrame:SetScript("OnHide", function(self)
		FriendsFrame.guildControlShow = 0
		self.goldChanged = nil

		S:SetUIPanelWindowInfo(FriendsFrame, "width")
	end)

	-- Member Detail Frame
	GuildMemberDetailFrame:StripTextures()
	GuildMemberDetailFrame:CreateBackdrop("Transparent")
	GuildMemberDetailFrame:Point("TOPLEFT", GuildFrame, "TOPRIGHT", -32, -13)

	S:HandleCloseButton(GuildMemberDetailCloseButton, GuildMemberDetailFrame)

	S:HandleNextPrevButton(GuildFramePromoteButton)
	S:HandleNextPrevButton(GuildFrameDemoteButton)

	GuildMemberNoteBackground:SetTemplate("Default")
	GuildMemberOfficerNoteBackground:SetTemplate("Default")

	S:HandleButton(GuildMemberRemoveButton)
	S:HandleButton(GuildMemberGroupInviteButton)

	GuildFramePromoteButton:Point("LEFT", GuildMemberDetailFrame, "RIGHT", -55, 46)
	GuildFrameDemoteButton:Point("LEFT", GuildFramePromoteButton, "RIGHT", 3, 0)

	GuildMemberRemoveButton:Point("BOTTOMLEFT", 7, 7)
	GuildMemberGroupInviteButton:SetPoint("LEFT", GuildMemberRemoveButton, "RIGHT", 6, 0)

	GUILD_DETAIL_NORM_HEIGHT = 203 -- orig 195

	-- Info Frame
	GuildInfoFrame:StripTextures()
	GuildInfoFrame:CreateBackdrop("Transparent")
	GuildInfoFrame.backdrop:Point("TOPLEFT", 4, -6)
	GuildInfoFrame.backdrop:Point("BOTTOMRIGHT", -2, 0)

	S:SetBackdropHitRect(GuildInfoFrame)

	S:HandleCloseButton(GuildInfoCloseButton, GuildInfoFrame.backdrop)

	GuildInfoTextBackground:SetTemplate("Default")
	S:HandleScrollBar(GuildInfoFrameScrollFrameScrollBar)

	S:HandleButton(GuildInfoSaveButton)
	S:HandleButton(GuildInfoCancelButton)
	S:HandleButton(GuildInfoGuildEventButton)

	GuildInfoEditBox:Size(246, 312)

	GuildInfoTextBackground:Size(254, 228)
	GuildInfoTextBackground:Point("TOPLEFT", 12, -33)

	GuildInfoFrameScrollFrame:Width(252)
	GuildInfoFrameScrollFrame:Point("TOPLEFT", 2, -5)

	GuildInfoFrameScrollFrameScrollBar:Point("TOPLEFT", GuildInfoFrameScrollFrame, "TOPRIGHT", 3, -14)
	GuildInfoFrameScrollFrameScrollBar:Point("BOTTOMLEFT", GuildInfoFrameScrollFrame, "BOTTOMRIGHT", 3, 14)

	GuildInfoSaveButton:Point("BOTTOMLEFT", 104, 8)
	GuildInfoCancelButton:Point("LEFT", GuildInfoSaveButton, "RIGHT", 3, 0)
	GuildInfoGuildEventButton:Point("RIGHT", GuildInfoSaveButton, "LEFT", -27, 0)

	-- GuildEventLog Frame
	GuildEventLogFrame:StripTextures()
	GuildEventLogFrame:CreateBackdrop("Transparent")
	GuildEventLogFrame.backdrop:Point("TOPLEFT", 4, -6)
	GuildEventLogFrame.backdrop:Point("BOTTOMRIGHT", -1, 5)

	S:SetBackdropHitRect(GuildEventLogFrame)

	S:HandleCloseButton(GuildEventLogCloseButton, GuildEventLogFrame.backdrop)

	GuildEventFrame:SetTemplate("Default")
	S:HandleScrollBar(GuildEventLogScrollFrameScrollBar)

	S:HandleButton(GuildEventLogCancelButton)

	GuildEventFrame:Size(353, 361)
	GuildEventFrame:Point("TOPLEFT", GuildEventLogFrame, "TOPLEFT", 12, -32)

	GuildEventLogScrollFrame:Size(347, 353)
	GuildEventLogScrollFrame:Point("TOPRIGHT", -3, -4)

	GuildEventLogScrollFrameScrollBar:Point("TOPLEFT", GuildEventLogScrollFrame, "TOPRIGHT", 6, -15)
	GuildEventLogScrollFrameScrollBar:Point("BOTTOMLEFT", GuildEventLogScrollFrame, "BOTTOMRIGHT", 6, 15)

	-- Control Frame
	GuildControlPopupFrame:StripTextures()
	GuildControlPopupFrame:CreateBackdrop("Transparent")
	GuildControlPopupFrame.backdrop:Point("TOPLEFT", 4, -6)
	GuildControlPopupFrame.backdrop:Point("BOTTOMRIGHT", -27, 27)

	S:SetBackdropHitRect(GuildControlPopupFrame)

	S:HandleDropDownBox(GuildControlPopupFrameDropDown, 185)
	GuildControlPopupFrameDropDownButton:Size(16)

	local function SkinPlusMinus(f, minus)
		f:SetNormalTexture("")
		f.SetNormalTexture = E.noop
		f:SetPushedTexture("")
		f.SetPushedTexture = E.noop
		f:SetHighlightTexture("")
		f.SetHighlightTexture = E.noop
		f:SetDisabledTexture("")
		f.SetDisabledTexture = E.noop

		f.Text = f:CreateFontString(nil, "OVERLAY")
		f.Text:FontTemplate(nil, 22)
		f.Text:Point("LEFT", 5, 0)
		if minus then
			f.Text:SetText("-")
		else
			f.Text:SetText("+")
		end
	end

	SkinPlusMinus(GuildControlPopupFrameAddRankButton)
	SkinPlusMinus(GuildControlPopupFrameRemoveRankButton, true)

	S:HandleEditBox(GuildControlPopupFrameEditBox)
	GuildControlPopupFrameEditBox.backdrop:Point("TOPLEFT", 0, -5)
	GuildControlPopupFrameEditBox.backdrop:Point("BOTTOMRIGHT", 0, 5)

	S:HandleCheckBox(GuildControlTabPermissionsViewTab)
	S:HandleCheckBox(GuildControlTabPermissionsDepositItems)
	S:HandleCheckBox(GuildControlTabPermissionsUpdateText)

	for i = 1, 17 do
		local checkbox = _G["GuildControlPopupFrameCheckbox"..i]
		if checkbox then
			S:HandleCheckBox(checkbox)
		end
	end

	S:HandleEditBox(GuildControlWithdrawGoldEditBox)
	GuildControlWithdrawGoldEditBox.backdrop:Point("TOPLEFT", 0, -5)
	GuildControlWithdrawGoldEditBox.backdrop:Point("BOTTOMRIGHT", 0, 5)

	for i = 1, MAX_GUILDBANK_TABS do
		local tab = _G["GuildBankTabPermissionsTab"..i]

		tab:StripTextures()
		tab:CreateBackdrop("Default")
		tab.backdrop:Point("TOPLEFT", 3, -10)
		tab.backdrop:Point("BOTTOMRIGHT", -2, 4)
	end

	S:HandleEditBox(GuildControlWithdrawItemsEditBox)
	GuildControlWithdrawItemsEditBox.backdrop:Point("TOPLEFT", 0, -5)
	GuildControlWithdrawItemsEditBox.backdrop:Point("BOTTOMRIGHT", 0, 5)

	S:HandleButton(GuildControlPopupAcceptButton)
	S:HandleButton(GuildControlPopupFrameCancelButton)

	GuildControlPopupFrameDropDown:Point("TOP", 0, -41)
	GuildControlPopupFrameAddRankButton:Point("LEFT", GuildControlPopupFrameDropDown, "RIGHT", -8, 3)

	GuildControlPopupFrameEditBox:Point("TOP", 35, -67)

	select(8, GuildControlPopupFrame:GetRegions()):Point("TOP", -10, -100)

	GuildControlPopupFrameCheckboxes:Point("TOPRIGHT", -22, 9)

	GuildControlPopupFrameTabPermissions:SetTemplate("Transparent")
	GuildControlPopupFrameTabPermissions:Width(273)
	GuildControlPopupFrameTabPermissions:Point("BOTTOMLEFT", 12, 64)

	GuildControlPopupFrameCancelButton:Point("BOTTOMRIGHT", -35, 35)
	GuildControlPopupAcceptButton:Point("RIGHT", GuildControlPopupFrameCancelButton, "LEFT", -3, 0)

	-- Channel Frame
	ChannelFrameVerticalBar:Kill()

	S:HandleCheckBox(ChannelFrameAutoJoinParty)
	S:HandleCheckBox(ChannelFrameAutoJoinBattleground)

	for i = 1, MAX_DISPLAY_CHANNEL_BUTTONS do
		local button = _G["ChannelButton"..i]
		local text = _G["ChannelButton"..i.."Text"]

		button:StripTextures()
		S:HandleButtonHighlight(button)

		-- fix font template
		if not text:GetFontObject() then
			text:SetFontObject("GameTooltipTextSmall")
		end

		_G["ChannelButton"..i.."Collapsed"]:SetTextColor(1, 1, 1)
	end

	for i = 1, 22 do
		S:HandleButtonHighlight(_G["ChannelMemberButton"..i])
	end

	ChannelListScrollFrame:StripTextures()
	S:HandleScrollBar(ChannelListScrollFrameScrollBar)

	ChannelRosterScrollFrame:StripTextures()
	S:HandleScrollBar(ChannelRosterScrollFrameScrollBar)

	S:HandleButton(ChannelFrameNewButton)

	ChannelListScrollFrame:Size(161, 381)
	ChannelListScrollFrame:Point("TOPLEFT", 19, -47)

	ChannelListScrollFrameScrollBar:Point("TOPLEFT", ChannelListScrollFrame, "TOPRIGHT", 3, -19)
	ChannelListScrollFrameScrollBar:Point("BOTTOMLEFT", ChannelListScrollFrame, "BOTTOMRIGHT", 3, 19)

	ChannelRoster:Point("TOPLEFT", ChannelFrame, "TOP", 126, -70)
	ChannelRoster.SetPoint = E.noop

	ChannelMemberButton1:Point("TOPLEFT", ChannelFrame, "TOPLEFT", 186, -66)
	ChannelMemberButton1.SetPoint = E.noop

	ChannelRosterScrollFrame:Size(138, 352)
	ChannelRosterScrollFrame:Point("TOPRIGHT", ChannelFrame, "TOPRIGHT", -32, -47)

	ChannelRosterScrollFrameScrollBar:Point("TOPLEFT", ChannelRosterScrollFrame, "TOPRIGHT", 3, -19)
	ChannelRosterScrollFrameScrollBar:Point("BOTTOMLEFT", ChannelRosterScrollFrame, "BOTTOMRIGHT", 3, 19)

	ChannelFrameNewButton:Point("BOTTOMRIGHT", -11, 84)

	hooksecurefunc("ChannelList_SetScroll", function()
		local buttonWidth

		if ChannelListScrollFrame.scrolling then
			buttonWidth = 135
			ChannelListScrollFrame:Width(138)
		else
			buttonWidth = 155
			ChannelListScrollFrame:Width(161)
		end

		for i = 1, MAX_CHANNEL_BUTTONS do
			_G["ChannelButton"..i]:Width(buttonWidth)
		end
	end)

	-- Channel Frame DaughterFrame
	ChannelFrameDaughterFrame:StripTextures()
	ChannelFrameDaughterFrame:SetTemplate("Transparent")

	S:HandleCloseButton(ChannelFrameDaughterFrameDetailCloseButton, ChannelFrameDaughterFrame)

	S:HandleEditBox(ChannelFrameDaughterFrameChannelName)
	S:HandleEditBox(ChannelFrameDaughterFrameChannelPassword)

	S:HandleButton(ChannelFrameDaughterFrameOkayButton)
	S:HandleButton(ChannelFrameDaughterFrameCancelButton)

	ChannelFrameDaughterFrame:Width(211)

	ChannelFrameDaughterFrameChannelName:Width(175)
	ChannelFrameDaughterFrameChannelName:Point("TOPLEFT", 18, -60)

	ChannelFrameDaughterFrameChannelPassword:Width(175)

	ChannelFrameDaughterFrameOkayButton:Point("BOTTOMLEFT", 8, 8)
	ChannelFrameDaughterFrameCancelButton:Point("LEFT", ChannelFrameDaughterFrameOkayButton, "RIGHT", 3, 0)

	-- Raid Frame
	S:HandleButton(RaidFrameConvertToRaidButton)
	S:HandleButton(RaidFrameRaidInfoButton)
	S:HandleButton(RaidFrameNotInRaidRaidBrowserButton)

	RaidFrameConvertToRaidButton:Point("TOPLEFT", 45, -33)
	RaidFrameRaidInfoButton:Point("LEFT", RaidFrameConvertToRaidButton, "RIGHT", 69, 0)

	-- Raid Info Frame
	RaidInfoFrame:StripTextures(true)
	RaidInfoFrame:SetTemplate("Transparent")
	RaidInfoFrame:Size(341, 246)

	RaidInfoInstanceLabel:StripTextures()
	RaidInfoIDLabel:StripTextures()

	S:HandleCloseButton(RaidInfoCloseButton, RaidInfoFrame)

	S:HandleScrollBar(RaidInfoScrollFrameScrollBar)

	S:HandleButton(RaidInfoExtendButton)
	S:HandleButton(RaidInfoCancelButton)

	RaidInfoInstanceLabel:Point("TOPLEFT", 13, -10)

	RaidInfoScrollFrame:CreateBackdrop("Transparent")
	RaidInfoScrollFrame.backdrop:Point("TOPLEFT", -1, 1)
	RaidInfoScrollFrame.backdrop:Point("BOTTOMRIGHT", 1, -2)

	RaidInfoScrollFrame:Height(178)
	RaidInfoScrollFrame:Point("TOPLEFT", 9, -31)

	RaidInfoScrollFrameScrollBar:Point("TOPLEFT", RaidInfoScrollFrame, "TOPRIGHT", 4, -18)
	RaidInfoScrollFrameScrollBar:Point("BOTTOMLEFT", RaidInfoScrollFrame, "BOTTOMRIGHT", 4, 17)

	for _, button in ipairs(RaidInfoScrollFrame.buttons) do
		button.reset:Width(115)
		S:HandleButtonHighlight(button)
	end

	RaidInfoExtendButton:Point("BOTTOMLEFT", 8, 8)
	RaidInfoCancelButton:Point("BOTTOMRIGHT", -8, 8)

	RaidInfoFrame:SetScript("OnShow", function(self)
		if GetNumRaidMembers() > 0 then
			self:Point("TOPLEFT", RaidFrame, "TOPRIGHT", -4, -12)
		else
			self:Point("TOPLEFT", RaidFrame, "TOPRIGHT", -33, -12)
		end

		PlaySound("UChatScrollButton")
	end)

	RaidInfoScrollFrameScrollBar:SetScript("OnShow", function(self)
		local parent = self:GetParent()
		parent:Width(302)
		RaidInfoInstanceLabel:Width(164)

		for _, frame in ipairs(parent.buttons) do
			frame:Width(297)
			frame.name:Width(171)
		end
	end)

	RaidInfoScrollFrameScrollBar:SetScript("OnHide", function(self)
		local parent = self:GetParent()
		parent:Width(323)
		RaidInfoInstanceLabel:Width(184)

		for _, frame in ipairs(parent.buttons) do
			frame:Width(318)
			frame.name:Width(192)
		end
	end)

	RaidInfoScrollFrameScrollBar:GetScript("OnHide")(RaidInfoScrollFrameScrollBar)
end)