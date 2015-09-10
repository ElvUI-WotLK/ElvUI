local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule('Skins');

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.help ~= true then return end
	
	HelpFrame:StripTextures(true);
	HelpFrame:CreateBackdrop("Transparent");
	HelpFrame.backdrop:Point("TOPLEFT", 6, -6);
	HelpFrame.backdrop:Point("BOTTOMRIGHT", -45, 14);
	
	KnowledgeBaseFrame:StripTextures(true);
	
	S:HandleCloseButton(HelpFrameCloseButton);
	
	S:HandleButton(GMChatOpenLog);
	S:HandleButton(KnowledgeBaseFrameTopIssuesButton);
	
	KnowledgeBaseFrameDivider:StripTextures();
	
	S:HandleEditBox(KnowledgeBaseFrameEditBox);
	
	S:HandleDropDownBox(KnowledgeBaseFrameCategoryDropDown);
	S:HandleDropDownBox(KnowledgeBaseFrameSubCategoryDropDown);
	
	S:HandleButton(KnowledgeBaseFrameSearchButton);
	
	KnowledgeBaseFrameDivider2:StripTextures();
	
	S:HandleButton(KnowledgeBaseFrameGMTalk);
	S:HandleButton(KnowledgeBaseFrameLag);
	S:HandleButton(KnowledgeBaseFrameReportIssue);
	S:HandleButton(KnowledgeBaseFrameStuck);
	S:HandleButton(KnowledgeBaseFrameEditTicket);
	S:HandleButton(KnowledgeBaseFrameAbandonTicket);
	
	S:HandleButton(KnowledgeBaseFrameCancel);
	
	S:HandleButton(HelpFrameGMTalkOpenTicket); -- Связатся с ГМ
	S:HandleButton(HelpFrameGMTalkCancel);
	
	S:HandleButton(HelpFrameLagLoot, true); -- Сообщить о задержки
	S:HandleButton(HelpFrameLagAuctionHouse, true);
	S:HandleButton(HelpFrameLagMail, true);
	S:HandleButton(HelpFrameLagChat, true);
	S:HandleButton(HelpFrameLagMovement, true);
	S:HandleButton(HelpFrameLagSpell, true);
	
	S:HandleButton(HelpFrameLagCancel);
	
	S:HandleButton(HelpFrameReportIssueOpenTicket); -- Сообщить о проблеме
	
	S:HandleButton(HelpFrameReportIssueCancel);
	
	HelpFrameOpenTicketDivider:StripTextures();
	
	S:HandleScrollBar(HelpFrameOpenTicketScrollFrameScrollBar);
	
	S:HandleButton(HelpFrameOpenTicketSubmit);
	S:HandleButton(HelpFrameOpenTicketCancel);
	
	S:HandleButton(HelpFrameStuckStuck, true); -- Персонаж застрял
	S:HandleButton(HelpFrameStuckOpenTicket, true);
	S:HandleButton(HelpFrameStuckCancel);
	
	KnowledgeBaseFrame:HookScript("OnShow", function()
		select(11, HelpFrame:GetRegions()):Hide();
	end);
	
	KnowledgeBaseFrame:SetScript("OnHide", function()
		select(11, HelpFrame:GetRegions()):Show();
	end);
end

S:RegisterSkin('ElvUI', LoadSkin);