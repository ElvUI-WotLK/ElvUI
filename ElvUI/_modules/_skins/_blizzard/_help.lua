local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins");

local _G = _G;

local function LoadSkin()
	if(E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.help ~= true) then return; end

	local helpFrameButtons = {
		"GMTalkOpenTicket", "GMTalkCancel",
		"ReportIssueOpenTicket", "ReportIssueCancel",
		"LagLoot", "LagAuctionHouse", "LagMail", "LagChat", "LagMovement", "LagSpell", "LagCancel",
		"StuckStuck", "StuckOpenTicket", "StuckCancel",
		"OpenTicketCancel", "OpenTicketSubmit",
		"ViewResponseCancel", "ViewResponseMoreHelp", "ViewResponseIssueResolved",
		"WelcomeGMTalk", "WelcomeReportIssue", "WelcomeStuck", "WelcomeCancel"
	};

	HelpFrame:StripTextures();
	HelpFrame:CreateBackdrop("Transparent");
	HelpFrame.backdrop:Point("TOPLEFT", 6, -6);
	HelpFrame.backdrop:Point("BOTTOMRIGHT", -45, 14);

	S:HandleCloseButton(HelpFrameCloseButton);

	for i = 1, #helpFrameButtons do
		local button = _G["HelpFrame" .. helpFrameButtons[i]];
		S:HandleButton(button);
	end

	HelpFrameOpenTicketDivider:StripTextures();

	S:HandleScrollBar(HelpFrameOpenTicketScrollFrameScrollBar);

	HelpFrameOpenTicketSubmit:SetPoint("RIGHT", HelpFrameOpenTicketCancel, "LEFT", -2, 0);

	S:HandleScrollBar(HelpFrameViewResponseIssueScrollFrameScrollBar);
	HelpFrameViewResponseDivider:Kill();
	S:HandleScrollBar(HelpFrameViewResponseMessageScrollFrameScrollBar);
	HelpFrameViewResponseIssueResolved:SetPoint("LEFT", HelpFrameViewResponseMoreHelp, "RIGHT", -3, 0);

	KnowledgeBaseFrame:StripTextures();

	KnowledgeBaseFrame:HookScript("OnShow", function()
		select(11, HelpFrame:GetRegions()):Hide();
	end);

	KnowledgeBaseFrame:SetScript("OnHide", function()
		select(11, HelpFrame:GetRegions()):Show();
	end);

	S:HandleButton(KnowledgeBaseFrameTopIssuesButton);
	S:HandleButton(GMChatOpenLog);

	KnowledgeBaseFrameDivider:Kill();

	S:HandleEditBox(KnowledgeBaseFrameEditBox);
	KnowledgeBaseFrameEditBox.backdrop:Point("TOPLEFT", -E.Border, -4);
	KnowledgeBaseFrameEditBox.backdrop:Point("BOTTOMRIGHT", E.Border, 7);

	S:HandleDropDownBox(KnowledgeBaseFrameCategoryDropDown);
	S:HandleDropDownBox(KnowledgeBaseFrameSubCategoryDropDown);

	S:HandleButton(KnowledgeBaseFrameSearchButton);

	KnowledgeBaseFrameDivider2:Kill();

	S:HandleNextPrevButton(KnowledgeBaseArticleListFrameNextButton);
	S:HandleNextPrevButton(KnowledgeBaseArticleListFramePreviousButton);

	S:HandleScrollBar(KnowledgeBaseArticleScrollFrameScrollBar);
	S:HandleButton(KnowledgeBaseArticleScrollChildFrameBackButton);

	S:HandleButton(KnowledgeBaseFrameReportIssue);
	KnowledgeBaseFrameGMTalk:SetPoint("BOTTOM", KnowledgeBaseFrameReportIssue, "TOP", 0, 2);
	S:HandleButton(KnowledgeBaseFrameGMTalk);
	S:HandleButton(KnowledgeBaseFrameAbandonTicket);
	KnowledgeBaseFrameEditTicket:SetPoint("BOTTOM", KnowledgeBaseFrameAbandonTicket, "TOP", 0, 2);
	S:HandleButton(KnowledgeBaseFrameEditTicket);

	KnowledgeBaseFrameStuck:SetPoint("LEFT", KnowledgeBaseFrameReportIssue, "RIGHT", 2, 0);
	S:HandleButton(KnowledgeBaseFrameStuck);
	KnowledgeBaseFrameLag:SetPoint("LEFT", KnowledgeBaseFrameGMTalk, "RIGHT", 2, 0);
	S:HandleButton(KnowledgeBaseFrameLag);
	S:HandleButton(KnowledgeBaseFrameCancel);
end

S:AddCallback("Help", LoadSkin);