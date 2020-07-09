local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local select = select
--WoW API / Variables

S:AddCallback("Skin_Help", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.help then return end

	HelpFrame:StripTextures()
	HelpFrame:CreateBackdrop("Transparent")
	HelpFrame.backdrop:Point("TOPLEFT", 6, 0)
	HelpFrame.backdrop:Point("BOTTOMRIGHT", -45, 14)

	S:SetBackdropHitRect(HelpFrame)

	S:HandleCloseButton(HelpFrameCloseButton, HelpFrame.backdrop)

	local helpFrameButtons = {
		"GMTalkOpenTicket",
		"GMTalkCancel",
		"ReportIssueOpenTicket",
		"ReportIssueCancel",
		"LagLoot",
		"LagAuctionHouse",
		"LagMail",
		"LagChat",
		"LagMovement",
		"LagSpell",
		"LagCancel",
		"StuckStuck",
		"StuckOpenTicket",
		"StuckCancel",
		"OpenTicketCancel",
		"OpenTicketSubmit",
		"ViewResponseCancel",
		"ViewResponseMoreHelp",
		"ViewResponseIssueResolved",
		"WelcomeGMTalk",
		"WelcomeReportIssue",
		"WelcomeStuck",
		"WelcomeCancel"
	}

	for i = 1, #helpFrameButtons do
		S:HandleButton(_G["HelpFrame"..helpFrameButtons[i]])
	end

	KnowledgeBaseFrameDivider:StripTextures()
	KnowledgeBaseFrameDivider2:StripTextures()
	HelpFrameOpenTicketDivider:StripTextures()
	HelpFrameViewResponseDivider:StripTextures()

	local scrollBars = {
		"HelpFrameOpenTicketScrollFrameScrollBar",
		"HelpFrameViewResponseIssueScrollFrameScrollBar",
		"HelpFrameViewResponseMessageScrollFrameScrollBar",
	}

	for _, scrollBar in ipairs(scrollBars) do
		S:HandleScrollBar(_G[scrollBar])
		_G[scrollBar.."Top"]:Hide()
		_G[scrollBar.."Middle"]:Hide()
		_G[scrollBar.."Bottom"]:Hide()
	end

	HelpFrameViewResponseIssueScrollFrame:CreateBackdrop("Transparent")
	HelpFrameViewResponseIssueScrollFrame.backdrop:Point("TOPLEFT", -2, 2)
	HelpFrameViewResponseIssueScrollFrame.backdrop:Point("BOTTOMRIGHT", 2, -2)

	HelpFrameViewResponseMessageScrollFrame:CreateBackdrop("Transparent")
	HelpFrameViewResponseMessageScrollFrame.backdrop:Point("TOPLEFT", -2, 2)
	HelpFrameViewResponseMessageScrollFrame.backdrop:Point("BOTTOMRIGHT", 2, -2)

	KnowledgeBaseFrame:StripTextures()

	KnowledgeBaseFrame:HookScript("OnShow", function()
		select(11, HelpFrame:GetRegions()):Hide()
	end)

	KnowledgeBaseFrame:SetScript("OnHide", function()
		select(11, HelpFrame:GetRegions()):Show()
	end)

	S:HandleButton(GMChatOpenLog)
	S:HandleButton(KnowledgeBaseFrameTopIssuesButton)

	S:HandleEditBox(KnowledgeBaseFrameEditBox)
	S:HandleDropDownBox(KnowledgeBaseFrameCategoryDropDown)
	S:HandleDropDownBox(KnowledgeBaseFrameSubCategoryDropDown)
	S:HandleButton(KnowledgeBaseFrameSearchButton)

	S:HandleNextPrevButton(KnowledgeBaseArticleListFrameNextButton)
	S:HandleNextPrevButton(KnowledgeBaseArticleListFramePreviousButton)

	S:HandleScrollBar(KnowledgeBaseArticleScrollFrameScrollBar)
	S:HandleButton(KnowledgeBaseArticleScrollChildFrameBackButton)

	S:HandleButton(KnowledgeBaseFrameReportIssue)
	S:HandleButton(KnowledgeBaseFrameGMTalk)
	S:HandleButton(KnowledgeBaseFrameStuck)
	S:HandleButton(KnowledgeBaseFrameLag)
	S:HandleButton(KnowledgeBaseFrameCancel)
	S:HandleButton(KnowledgeBaseFrameAbandonTicket)
	S:HandleButton(KnowledgeBaseFrameEditTicket)

	GMChatOpenLog:Point("TOPLEFT", 23, -22)
	KnowledgeBaseFrameTopIssuesButton:Point("TOPRIGHT", -62, -118)
	KnowledgeBaseFrameTopIssuesButton.Enable = E.noop
	KnowledgeBaseFrameTopIssuesButton:Disable()

	KnowledgeBaseFrameEditBox:Height(18)
	KnowledgeBaseFrameEditBox:Point("TOPLEFT", KnowledgeBaseFrameDivider, "BOTTOMLEFT", 12, 10)
	KnowledgeBaseFrameCategoryDropDown:Point("LEFT", KnowledgeBaseFrameEditBox, "RIGHT", -14, -3)
	KnowledgeBaseFrameSubCategoryDropDown:Point("LEFT", KnowledgeBaseFrameCategoryDropDown, "RIGHT", -23, 0)

	KnowledgeBaseFrameSearchButton:Height(20)
	KnowledgeBaseFrameSearchButton:Point("LEFT", KnowledgeBaseFrameSubCategoryDropDown, "RIGHT", -2, 3)

	KnowledgeBaseFrameReportIssue:Point("BOTTOMLEFT", 14, 22)
	KnowledgeBaseFrameGMTalk:Point("BOTTOM", KnowledgeBaseFrameReportIssue, "TOP", 0, 3)
	KnowledgeBaseFrameStuck:Point("LEFT", KnowledgeBaseFrameReportIssue, "RIGHT", 3, 0)
	KnowledgeBaseFrameLag:Point("LEFT", KnowledgeBaseFrameGMTalk, "RIGHT", 3, 0)

	KnowledgeBaseFrameAbandonTicket:Point("BOTTOMLEFT", 14, 22)
	KnowledgeBaseFrameEditTicket:Point("BOTTOM", KnowledgeBaseFrameAbandonTicket, "TOP", 0, 3)

	KnowledgeBaseFrameCancel:Point("BOTTOMRIGHT", -53, 22)
	HelpFrameGMTalkCancel:Point("BOTTOMRIGHT", -53, 22)
	HelpFrameLagCancel:Point("BOTTOMRIGHT", -53, 22)
	HelpFrameReportIssueCancel:Point("BOTTOMRIGHT", -53, 22)
	HelpFrameStuckCancel:Point("BOTTOMRIGHT", -53, 22)

	HelpFrameOpenTicketCancel:Height(21)
	HelpFrameOpenTicketCancel:Point("BOTTOMRIGHT", -53, 22)
	HelpFrameOpenTicketSubmit:Point("RIGHT", HelpFrameOpenTicketCancel, "LEFT", -3, 0)

	HelpFrameViewResponseMoreHelp:Point("BOTTOMLEFT", 14, 22)
	HelpFrameViewResponseIssueResolved:Point("LEFT", HelpFrameViewResponseMoreHelp, "RIGHT", 3, 0)
	HelpFrameViewResponseCancel:Height(21)
	HelpFrameViewResponseCancel:Point("BOTTOMRIGHT", -53, 22)
end)