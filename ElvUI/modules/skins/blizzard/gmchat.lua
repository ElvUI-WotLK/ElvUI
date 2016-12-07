local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins");

local function LoadChatSkin()
	if(not E.private.skins.blizzard.enable or not E.private.skins.blizzard.gmchat) then return; end

	GMChatFrame:StripTextures();
	GMChatFrame:CreateBackdrop("Transparent");
	GMChatFrame.backdrop:Point("TOPLEFT", -2, 3);
	GMChatFrame.backdrop:Point("BOTTOMRIGHT", 2, -6);
	GMChatFrame:SetClampRectInsets(-2, 2, 0, -10);
	GMChatFrame:Size(LeftChatPanel:GetWidth() - 4, 120);
	GMChatFrame:Point("BOTTOMLEFT", LeftChatPanel, "TOPLEFT", 2, 5);
	GMChatFrame:EnableMouseWheel(true);

	GMChatTab:StripTextures();
	GMChatTab:CreateBackdrop("Default");
	GMChatTab.backdrop:Point("TOPLEFT", -2, 0);
	GMChatTab.backdrop:Point("BOTTOMRIGHT", 2, -1);

	GMChatFrameButtonFrame:Kill();

	S:HandleCloseButton(GMChatFrameCloseButton, GMChatTab);

	local numScrollMessages = E.db.chat.numScrollMessages or 3
	GMChatFrame:SetScript("OnMouseWheel", function(self, delta)
		if delta < 0 then
			if IsShiftKeyDown() then
				self:ScrollToBottom()
			else
				for i = 1, numScrollMessages do
					self:ScrollDown()
				end
			end
		elseif delta > 0 then
			if IsShiftKeyDown() then
				self:ScrollToTop()
			else
				for i = 1, numScrollMessages do
					self:ScrollUp()
				end
			end
		end
	end);
end

local function LoadSurveySkin()
	if(not E.private.skins.blizzard.enable or not E.private.skins.blizzard.gmchat) then return; end

	GMSurveyFrame:StripTextures();
	GMSurveyFrame:CreateBackdrop("Transparent");
	GMSurveyFrame.backdrop:Point("TOPLEFT", 4, 4);
	GMSurveyFrame.backdrop:Point("BOTTOMRIGHT", -44, 10);

	GMSurveyHeader:StripTextures();
	S:HandleCloseButton(GMSurveyCloseButton, GMSurveyFrame.backdrop);

	GMSurveyScrollFrame:StripTextures();
	S:HandleScrollBar(GMSurveyScrollFrameScrollBar);

	GMSurveyCancelButton:Point("BOTTOMLEFT", 19, 18);
	S:HandleButton(GMSurveyCancelButton);

	GMSurveySubmitButton:Point("BOTTOMRIGHT", -57, 18);
	S:HandleButton(GMSurveySubmitButton);

	for i = 1, 7 do
		local frame = _G["GMSurveyQuestion"..i ];
		frame:StripTextures();
		frame:SetTemplate("Transparent");
	end

	GMSurveyCommentFrame:StripTextures();
	GMSurveyCommentFrame:SetTemplate("Transparent");
end

S:AddCallbackForAddon("Blizzard_GMChatUI", "GMChatFrame", LoadChatSkin);
S:AddCallbackForAddon("Blizzard_GMSurveyUI", "GMSurveyFrame", LoadSurveySkin);