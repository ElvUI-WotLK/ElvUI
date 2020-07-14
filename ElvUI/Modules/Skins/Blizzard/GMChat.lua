local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
--WoW API / Variables
local IsShiftKeyDown = IsShiftKeyDown

S:AddCallbackForAddon("Blizzard_GMChatUI", "Skin_Blizzard_GMChatUI", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.gmchat then return end

	GMChatFrame:StripTextures()
	GMChatFrame:CreateBackdrop("Transparent")
	GMChatFrame.backdrop:Point("TOPLEFT", -2, 7)
	GMChatFrame.backdrop:Point("BOTTOMRIGHT", 2, -6)

	GMChatFrame:SetClampRectInsets(-6, 6, 33, -10)
	GMChatFrame:Size(LeftChatPanel:GetWidth() - 4, 120)
	GMChatFrame:Point("BOTTOMLEFT", LeftChatPanel, "TOPLEFT", 2, 5)
	GMChatFrame:EnableMouseWheel(true)

	GMChatTab:StripTextures()
	GMChatTab:CreateBackdrop("Default")
	GMChatTab.backdrop:Point("TOPLEFT", -2, 0)
	GMChatTab.backdrop:Point("BOTTOMRIGHT", 2, 3)

	GMChatTabText:Point("LEFT", GMChatTab, 17, 2)
	GMChatTabText:FontTemplate(E.LSM:Fetch("font", E.db.chat.tabFont), E.db.chat.tabFontSize, E.db.chat.tabFontOutline)

	GMChatTabText:SetTextColor(unpack(E.media.rgbvaluecolor))

	S:HandleCloseButton(GMChatFrameCloseButton)
	GMChatFrameCloseButton:Point("RIGHT", GMChatTab, 6, 2)

	GMChatFrameButtonFrame:Kill()

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
	end)

	local statusFrame = select(2, GMChatStatusFrame:GetChildren())
	statusFrame:StripTextures()
	statusFrame:CreateBackdrop("Transparent")
	statusFrame.backdrop:Point("TOPLEFT", 0, 1)
	statusFrame.backdrop:Point("BOTTOMRIGHT", 0, 0)

	GMChatStatusFramePulse:SetTexture("Interface\\GMChatFrame\\UI-GMStatusFrame-Pulse")
	GMChatStatusFramePulse:Point("TOPLEFT", -25, 21)
	GMChatStatusFramePulse:Point("BOTTOMRIGHT", 25, -19)

	GMChatStatusFrame:HookScript("OnShow", function(self)
		if TicketStatusFrame and TicketStatusFrame:IsShown() then
			self:Point("TOPLEFT", TicketStatusFrame, "BOTTOMLEFT", 0, 1)
		else
			self:SetAllPoints(TicketStatusFrame)
		end
	end)

	TicketStatusFrame:HookScript("OnShow", function(self)
		GMChatStatusFrame:Point("TOPLEFT", self, "BOTTOMLEFT", 0, 1)
	end)
	TicketStatusFrame:HookScript("OnHide", function(self)
		GMChatStatusFrame:SetAllPoints(self)
	end)
end)

S:AddCallbackForAddon("Blizzard_GMSurveyUI", "Skin_Blizzard_GMSurveyUI", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.gmchat then return end

	GMSurveyFrame:StripTextures()
	GMSurveyFrame:CreateBackdrop("Transparent")
	GMSurveyFrame.backdrop:Point("TOPLEFT", 11, 4)
	GMSurveyFrame.backdrop:Point("BOTTOMRIGHT", -49, 10)

	GMSurveyFrame:EnableMouse(true)
	S:SetBackdropHitRect(GMSurveyFrame)

	GMSurveyHeader:StripTextures()
	S:HandleCloseButton(GMSurveyCloseButton, GMSurveyFrame.backdrop)

	GMSurveyScrollFrame:StripTextures()
	S:HandleScrollBar(GMSurveyScrollFrameScrollBar)

	S:HandleButton(GMSurveyCancelButton)
	S:HandleButton(GMSurveySubmitButton)

	for i = 1, 7 do
		local frame = _G["GMSurveyQuestion"..i]
		frame:StripTextures()
		frame:SetTemplate("Transparent")
	end

	GMSurveyCommentFrame:StripTextures()
	GMSurveyCommentFrame:SetTemplate("Transparent")

	GMSurveyScrollFrameScrollBar:Point("TOPLEFT", GMSurveyScrollFrame, "TOPRIGHT", 5, -19)
	GMSurveyScrollFrameScrollBar:Point("BOTTOMLEFT", GMSurveyScrollFrame, "BOTTOMRIGHT", 5, 18)

	GMSurveySubmitButton:Height(22)
	GMSurveySubmitButton:Point("BOTTOMRIGHT", -57, 18)
	GMSurveyCancelButton:Point("BOTTOMLEFT", 19, 18)
end)