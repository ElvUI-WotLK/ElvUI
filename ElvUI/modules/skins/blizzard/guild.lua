local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local unpack = unpack

local hooksecurefunc = hooksecurefunc
local GetWhoInfo = GetWhoInfo
local GetGuildRosterInfo = GetGuildRosterInfo
local GUILDMEMBERS_TO_DISPLAY = GUILDMEMBERS_TO_DISPLAY
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.guild ~= true then return end

	-- Guild Frame    
    GuildFrame:StripTextures()
    GuildFrame:CreateBackdrop("Transparent")

    S:HandleCloseButton(GuildFrameCloseButton)
    
    -- Guild Roster
    S:HandleDropDownBox(GuildRosterViewDropdown, 170)
    
	for i = 1, 5 do
		_G["GuildRosterColumnButton"..i]:StripTextures()
		_G["GuildRosterColumnButton"..i]:StyleButton()
	end
    
    for i = 1, 4 do
        _G["GuildFrameRightTab"..i]:SetFrameLevel(6)
		S:HandleTab(_G["GuildFrameRightTab"..i])
	end

	GuildRosterContainer:StripTextures()
	S:HandleScrollBar(GuildRosterContainerScrollBar)

	S:HandleButton(GuildViewLogButton)
	S:HandleButton(GuildAddMemberButton)
	S:HandleButton(GuildControlButton)

	-- Member Detail Frame
	GuildMemberDetailFrame:StripTextures()
	GuildMemberDetailFrame:CreateBackdrop("Transparent")
	GuildMemberDetailFrame:Point("TOPLEFT", GuildFrame, "TOPRIGHT", 5, 0)

	S:HandleCloseButton(GuildMemberDetailCloseButton)

	S:HandleButton(GuildMemberRemoveButton)
	GuildMemberRemoveButton:SetPoint("BOTTOMLEFT", 8, 7)
	S:HandleButton(GuildMemberGroupInviteButton)
	GuildMemberGroupInviteButton:SetPoint("LEFT", GuildMemberRemoveButton, "RIGHT", 3, 0)

	S:HandleNextPrevButton(GuildFramePromoteButton, true)
	S:HandleNextPrevButton(GuildFrameDemoteButton, true)
	GuildFrameDemoteButton:SetPoint("LEFT", GuildFramePromoteButton, "RIGHT", 2, 0)

	GuildMemberNoteBackground:SetTemplate("Default")
	GuildMemberOfficerNoteBackground:SetTemplate("Default")

	-- Info Frame   
	GuildTextEditFrame:StripTextures()
	GuildTextEditFrame:CreateBackdrop("Transparent")
	GuildTextEditFrame.backdrop:Point("TOPLEFT", 3, -6)
	GuildTextEditFrame.backdrop:Point("BOTTOMRIGHT", -2, 3)

	GuildTextEditFrame:SetTemplate("Default")
	S:HandleScrollBar(GuildTextEditScrollFrameScrollBar)

	S:HandleCloseButton(GuildTextEditFrameCloseButton)

	S:HandleButton(GuildTextEditFrameAcceptButton)

	S:HandleButton(GuildTextEditFrameCloseButton)
	-- GuildEventLog Frame
	GuildLogFrame:StripTextures()
	GuildLogFrame:CreateBackdrop("Transparent")
	GuildLogFrame.backdrop:Point("TOPLEFT", 3, -6)
	GuildLogFrame.backdrop:Point("BOTTOMRIGHT", -1, 5)

	GuildLogFrame:SetTemplate("Default")

    GuildLogScrollFrame:StripTextures()
	S:HandleScrollBar(GuildLogScrollFrameScrollBar)
	S:HandleCloseButton(GuildLogFrameCloseButton)

	S:HandleButton(GuildLogFrameCloseButton)

	-- Control Frame
	GuildControlPopupFrame:StripTextures()
	GuildControlPopupFrame:CreateBackdrop("Transparent")
	GuildControlPopupFrame.backdrop:Point("TOPLEFT", 3, -6)
	GuildControlPopupFrame.backdrop:Point("BOTTOMRIGHT", -27, 27)

	S:HandleDropDownBox(GuildControlPopupFrameDropDown, 185)
	GuildControlPopupFrameDropDownButton:SetSize(16, 16)

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

	GuildControlPopupFrameAddRankButton:Point("LEFT", GuildControlPopupFrameDropDown, "RIGHT", -8, 3)
	SkinPlusMinus(GuildControlPopupFrameAddRankButton)
	SkinPlusMinus(GuildControlPopupFrameRemoveRankButton, true)

	S:HandleEditBox(GuildControlPopupFrameEditBox)
	GuildControlPopupFrameEditBox.backdrop:Point("TOPLEFT", 0, -5)
	GuildControlPopupFrameEditBox.backdrop:Point("BOTTOMRIGHT", 0, 5)

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

	GuildControlPopupFrameTabPermissions:SetTemplate("Default")

	S:HandleCheckBox(GuildControlTabPermissionsViewTab)
	S:HandleCheckBox(GuildControlTabPermissionsDepositItems)
	S:HandleCheckBox(GuildControlTabPermissionsUpdateText)

	S:HandleEditBox(GuildControlWithdrawItemsEditBox)
	GuildControlWithdrawItemsEditBox.backdrop:Point("TOPLEFT", 0, -5)
	GuildControlWithdrawItemsEditBox.backdrop:Point("BOTTOMRIGHT", 0, 5)

	S:HandleButton(GuildControlPopupAcceptButton)
	S:HandleButton(GuildControlPopupFrameCancelButton)

end

S:AddCallback("Guild", LoadSkin)