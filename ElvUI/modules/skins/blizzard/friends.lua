local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.friends ~= true then return end
	-- Friends Frame
	FriendsFrame:StripTextures(true);
	FriendsFrame:CreateBackdrop("Transparent");
	FriendsFrame.backdrop:Point("TOPLEFT", 10, -12);
	FriendsFrame.backdrop:Point("BOTTOMRIGHT", -33, 76);
	
	S:HandleCloseButton(FriendsFrameCloseButton);
	
	S:HandleDropDownBox(FriendsFrameStatusDropDown, 100);
	
	for i = 1, 5 do
		S:HandleTab(_G['FriendsFrameTab'..i]);
	end
	
	for i = 1, 2 do -- Friends List Frame
		local Tab = _G['FriendsTabHeaderTab'..i];
		Tab:StripTextures();
		Tab:CreateBackdrop("Default", true);
		Tab.backdrop:Point("TOPLEFT", 3, -7);
		Tab.backdrop:Point("BOTTOMRIGHT", -2, -1);
		
		Tab:HookScript('OnEnter', function(self) self.backdrop:SetBackdropBorderColor(unpack(E['media'].rgbvaluecolor)); end);
		Tab:HookScript('OnLeave', function(self) self.backdrop:SetBackdropBorderColor(unpack(E['media'].bordercolor)); end);
	end
	
	S:HandleScrollBar(FriendsFrameFriendsScrollFrameScrollBar);
	
	S:HandleButton(FriendsFrameAddFriendButton, true);
	S:HandleButton(FriendsFrameSendMessageButton, true);
	
	S:HandleButton(FriendsFrameIgnorePlayerButton, true); -- Ignore List Frame
	S:HandleButton(FriendsFrameUnsquelchButton, true);
	-- Who Frame
	for i = 1, 4 do
		_G['WhoFrameColumnHeader'..i]:StripTextures();
		_G['WhoFrameColumnHeader'..i]:StyleButton();
	end
	
	S:HandleDropDownBox(WhoFrameDropDown);
	
	WhoListScrollFrame:StripTextures();
	S:HandleScrollBar(WhoListScrollFrameScrollBar);
	
	S:HandleButton(WhoFrameWhoButton);
	S:HandleButton(WhoFrameAddFriendButton);
	S:HandleButton(WhoFrameGroupInviteButton);
	-- Guild Frame
	GuildFrameLFGFrame:StripTextures();
	GuildFrameLFGFrame:SetTemplate("Default");
	S:HandleCheckBox(GuildFrameLFGButton);
	
	for i = 1, 4 do
		_G['GuildFrameColumnHeader'..i]:StripTextures();
		_G['GuildFrameColumnHeader'..i]:StyleButton();
		_G['GuildFrameGuildStatusColumnHeader'..i]:StripTextures();
		_G['GuildFrameGuildStatusColumnHeader'..i]:StyleButton();
	end
	
	GuildListScrollFrame:StripTextures();
	S:HandleScrollBar(GuildListScrollFrameScrollBar);
	
	S:HandleNextPrevButton(GuildFrameGuildListToggleButton);
	
	S:HandleButton(GuildFrameGuildInformationButton);
	S:HandleButton(GuildFrameAddMemberButton);
	S:HandleButton(GuildFrameControlButton);
	
	GuildMemberDetailFrame:StripTextures(); -- Member Detail Frame
	GuildMemberDetailFrame:CreateBackdrop("Transparent");
	
	S:HandleCloseButton(GuildMemberDetailCloseButton);
	
	GuildMemberNoteBackground:SetTemplate("Default");
	GuildMemberOfficerNoteBackground:SetTemplate("Default");
	
	S:HandleButton(GuildMemberRemoveButton);
	S:HandleButton(GuildMemberGroupInviteButton);
	
	GuildInfoFrame:StripTextures(); -- Info Frame
	GuildInfoFrame:CreateBackdrop("Transparent");
	GuildInfoFrame.backdrop:Point("TOPLEFT", 3, -5);
	GuildInfoFrame.backdrop:Point("BOTTOMRIGHT", -2, 3);
	
	S:HandleCloseButton(GuildInfoCloseButton);
	
	GuildInfoTextBackground:SetTemplate("Default");
	
	S:HandleScrollBar(GuildInfoFrameScrollFrameScrollBar);
	
	S:HandleButton(GuildInfoGuildEventButton);
	S:HandleButton(GuildInfoSaveButton);
	S:HandleButton(GuildInfoCancelButton);
	
	GuildEventLogFrame:StripTextures(); -- GuildEventLog Frame
	GuildEventLogFrame:CreateBackdrop("Transparent");
	GuildEventLogFrame.backdrop:Point("TOPLEFT", 5, -6);
	GuildEventLogFrame.backdrop:Point("BOTTOMRIGHT", -2, 6);
	
	GuildEventFrame:SetTemplate("Default");
	
	S:HandleScrollBar(GuildEventLogScrollFrameScrollBar);
	S:HandleCloseButton(GuildEventLogCloseButton);
	S:HandleButton(GuildEventLogCancelButton);
	
	GuildControlPopupFrame:StripTextures(); -- Control Frame
	GuildControlPopupFrame:CreateBackdrop("Transparent");
	GuildControlPopupFrame.backdrop:Point("TOPLEFT", 3, -5);
	GuildControlPopupFrame.backdrop:Point("BOTTOMRIGHT", -27, 27);
	
	S:HandleDropDownBox(GuildControlPopupFrameDropDown, 185);
	GuildControlPopupFrameDropDownButton:Size(16, 16);
	
	S:HandleEditBox(GuildControlPopupFrameEditBox);
	GuildControlPopupFrameEditBox.backdrop:Point("TOPLEFT", 0, -5);
	GuildControlPopupFrameEditBox.backdrop:Point("BOTTOMRIGHT", 0, 5);
	
	for i = 1, 17 do
		local Checkbox = _G["GuildControlPopupFrameCheckbox"..i];
		if(Checkbox) then
			S:HandleCheckBox(Checkbox);
		end
	end
	
	S:HandleEditBox(GuildControlWithdrawGoldEditBox);
	GuildControlWithdrawGoldEditBox.backdrop:Point("TOPLEFT", 0, -5);
	GuildControlWithdrawGoldEditBox.backdrop:Point("BOTTOMRIGHT", 0, 5);
	
	for i = 1, MAX_GUILDBANK_TABS do
		Tab = _G["GuildBankTabPermissionsTab"..i];
		Tab:StripTextures();
		Tab:CreateBackdrop("Default");
		Tab.backdrop:Point("TOPLEFT", 3, -10);
		Tab.backdrop:Point("BOTTOMRIGHT", -2, 4);
	end
	
	GuildControlPopupFrameTabPermissions:SetTemplate("Default");
	
	S:HandleCheckBox(GuildControlTabPermissionsViewTab);
	S:HandleCheckBox(GuildControlTabPermissionsDepositItems);
	S:HandleCheckBox(GuildControlTabPermissionsUpdateText);
	
	S:HandleEditBox(GuildControlWithdrawItemsEditBox);
	GuildControlWithdrawItemsEditBox.backdrop:Point("TOPLEFT", 0, -5);
	GuildControlWithdrawItemsEditBox.backdrop:Point("BOTTOMRIGHT", 0, 5);
	
	S:HandleCheckBox(GuildControlPopupAcceptButton);
	S:HandleCheckBox(GuildControlPopupFrameCancelButton);
	-- Channel Frame
	ChannelFrameVerticalBar:Kill();
	
	S:HandleCheckBox(ChannelFrameAutoJoinParty);
	S:HandleCheckBox(ChannelFrameAutoJoinBattleground);
	
	S:HandleButton(ChannelFrameNewButton);
	
	ChannelListScrollFrame:StripTextures();
	S:HandleScrollBar(ChannelListScrollFrameScrollBar);
	
	for i = 1, MAX_DISPLAY_CHANNEL_BUTTONS do
		_G["ChannelButton"..i]:StripTextures();
		_G["ChannelButton"..i]:StyleButton();
		
		_G["ChannelButton"..i.."Collapsed"]:SetTextColor(1, 1, 1);
	end
	
	ChannelRosterScrollFrame:StripTextures();
	S:HandleScrollBar(ChannelRosterScrollFrameScrollBar);
	
	ChannelFrameDaughterFrame:StripTextures();
	ChannelFrameDaughterFrame:SetTemplate("Transparent");
	
	S:HandleEditBox(ChannelFrameDaughterFrameChannelName);
	S:HandleEditBox(ChannelFrameDaughterFrameChannelPassword);
	
	S:HandleCloseButton(ChannelFrameDaughterFrameDetailCloseButton);
	
	S:HandleButton(ChannelFrameDaughterFrameCancelButton);
	S:HandleButton(ChannelFrameDaughterFrameOkayButton);
	-- Raid Frame
	S:HandleButton(RaidFrameConvertToRaidButton);
	S:HandleButton(RaidFrameRaidInfoButton);
	S:HandleButton(RaidFrameNotInRaidRaidBrowserButton);
	
	RaidInfoFrame:StripTextures(true); -- Raid Info Frame
	RaidInfoFrame:SetTemplate("Transparent");
	
	RaidInfoInstanceLabel:StripTextures();
	RaidInfoIDLabel:StripTextures();
	
	S:HandleCloseButton(RaidInfoCloseButton);
	
	S:HandleScrollBar(RaidInfoScrollFrameScrollBar);
	
	S:HandleButton(RaidInfoExtendButton);
	S:HandleButton(RaidInfoCancelButton);
end

S:RegisterSkin('ElvUI', LoadSkin)